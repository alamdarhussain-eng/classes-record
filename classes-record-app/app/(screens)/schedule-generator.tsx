import React, { useState } from "react";
import { View, Text, ScrollView, TouchableOpacity, ActivityIndicator, StyleSheet, Alert } from "react-native";
import { useLocalSearchParams, useRouter } from "expo-router";
import { Feather } from "@expo/vector-icons";
import * as DocumentPicker from "expo-document-picker";
import * as FileSystem from "expo-file-system";

const colors = { primary:"#1565C0", success:"#2E7D32", bg:"#F5F7FA", card:"#fff", text:"#1a1a2e", muted:"#6B7280", purple:"#6A1B9A" };

function parseTime(t: string): number {
  if (!t) return 0;
  const m = t.match(/(\d+):(\d+)\s*(AM|PM)/i);
  if (!m) return 0;
  let h = parseInt(m[1]); const min = parseInt(m[2]); const ap = m[3].toUpperCase();
  if (ap === "PM" && h !== 12) h += 12;
  if (ap === "AM" && h === 12) h = 0;
  return h * 60 + min;
}

function fmt12(h: number): string {
  const ap = h >= 12 ? "PM" : "AM"; const h12 = h % 12 || 12;
  return `${h12}:00 ${ap}`;
}

function generateSchedule(rows: any[], activeDays: string[], startHour: number, endHour: number, breakStart: number, breakEnd: number) {
  const entries: any[] = [];
  const dayOrder = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
  const days = activeDays.filter(d => dayOrder.includes(d)).sort((a,b)=>dayOrder.indexOf(a)-dayOrder.indexOf(b));

  // Parse credit hrs: "3+1" -> { lec:3, lab:1 }
  function parseCred(c: string) {
    const p = String(c||"2+0").split("+");
    return { lec: parseInt(p[0])||2, lab: parseInt(p[1])||0 };
  }

  // ============================================================
  // PRE-PROCESS: Expand rows based on Class + Instructor sections
  // Draft CSV: Column F = Class (e.g. BEE-6), Column D = Instructor Name with Sections (e.g. Mr. Talha (ABCD))
  // Each letter in the bracket = one section: BEE-6A, BEE-6B, BEE-6C, BEE-6D
  // Multiple instructors can share sections: Mr. X (AB) + Mr. Y (CD) for same class
  // ============================================================
  const expandedRows: any[] = [];
  for (const r of rows) {
    const baseClass = String(r["Class"]||r["Sections"]||r["class"]||"").trim();
    const instrRaw  = String(r["Instructor Name with Sections"]||r["Instructor Name"]||r["Faculty"]||r["faculty"]||"").trim();
    if (!baseClass) continue;

    // Extract section letters from brackets: "Mr. Talha (ABCD)" -> ["A","B","C","D"]
    // Instructor name is everything before the last "("
    const bracketMatch = instrRaw.match(/\(([A-Za-z]+)\)\s*$/);
    if (bracketMatch) {
      const letters = bracketMatch[1].split(""); // ["A","B","C","D"]
      const instrName = instrRaw.slice(0, instrRaw.lastIndexOf("(")).trim(); // "Mr. Talha"
      for (const letter of letters) {
        expandedRows.push({
          ...r,
          "Class": baseClass + letter,          // BEE-6A, BEE-6B, etc.
          "Faculty": instrName,                  // clean instructor name
          "Instructor Name": instrName,
          "_sectionLetter": letter,
          "_baseClass": baseClass,
        });
      }
    } else {
      // No bracket info — treat as-is (e.g. already "BEE-6A" or no section info)
      expandedRows.push({
        ...r,
        "Faculty": instrRaw,
        "Instructor Name": instrRaw,
      });
    }
  }

  // Group by expanded section (Class column)
  const sections: Record<string, any[]> = {};
  for (const r of expandedRows) {
    const sec = String(r["Class"]||r["Sections"]||r["class"]||"").trim();
    if (!sec) continue;
    if (!sections[sec]) sections[sec] = [];
    sections[sec].push(r);
  }

  // Location: CR-1 to CR-N per section index
  const sectionKeys = Object.keys(sections);
  const sectionLocation: Record<string,string> = {};
  sectionKeys.forEach((s,i) => { sectionLocation[s] = `CR-${i+1}`; });

  // Faculty busy tracker: { faculty -> { day -> [{ start,end }] } }
  const facBusy: Record<string, Record<string, {start:number,end:number}[]>> = {};

  function isFacFree(fac: string, day: string, start: number, end: number) {
    if (!facBusy[fac] || !facBusy[fac][day]) return true;
    return facBusy[fac][day].every(b => end <= b.start || start >= b.end);
  }

  function bookFac(fac: string, day: string, start: number, end: number) {
    if (!facBusy[fac]) facBusy[fac] = {};
    if (!facBusy[fac][day]) facBusy[fac][day] = [];
    facBusy[fac][day].push({ start, end });
  }

  function isBreak(start: number, end: number) {
    return start < breakEnd && end > breakStart;
  }

  function findSlot(fac: string, day: string, durationMins: number, lateStart: boolean): number {
    const s = (lateStart ? startHour + 1 : startHour) * 60;
    const e = endHour * 60;
    for (let t = s; t + durationMins <= e; t += 60) {
      if (isBreak(t, t + durationMins)) continue;
      if (t < breakEnd && t + durationMins > breakStart) { t = breakEnd - 60; continue; }
      if (isFacFree(fac, day, t, t + durationMins)) return t;
    }
    return -1;
  }

  for (const [secIdx, secKey] of sectionKeys.entries()) {
    const secRows = sections[secKey];
    const location = sectionLocation[secKey];

    for (const row of secRows) {
      const facRaw = String(row["Faculty"]||row["Instructor Name"]||row["instructor"]||"").trim();
      const fac = facRaw.replace(/\s*\([A-Za-z]+\)\s*$/, "").trim();
      const subj = String(row["Subjects"]||row["Subject"]||row["subject"]||"").trim();
      const dept = String(row["Department"]||row["Deptt"]||row["dept"]||"").trim();
      const credStr = String(row["Credit Hrs"]||row["credits"]||"2+0").trim();
      const elective = String(row["Regular/Elective"]||row["elective"]||"").trim();
      const isElective = elective.toLowerCase().includes("elective");
      const breakStr = String(row["Break Time"]||"13:00-14:00").trim();
      const cred = parseCred(credStr);
      const totalWeeklyHrs = cred.lec + (cred.lab > 0 ? 3 : 0);
      const lateStart = totalWeeklyHrs <= 2;

      // Compute max days faculty should teach this section
      let maxDays = totalWeeklyHrs <= 2 ? 2 : totalWeeklyHrs <= 3 ? 3 : 4;
      const useDays = days.slice(0, Math.min(maxDays, days.length));

      // For electives: spread sections across different days
      // Each section gets its own rotation offset based on section index
      let electiveDayOffset = 0;
      if (isElective) {
        // Rotate starting day per section so sections are on different days
        electiveDayOffset = secIdx % days.length;
      }
      const rotatedDays = isElective
        ? [...days.slice(electiveDayOffset), ...days.slice(0, electiveDayOffset)]
        : useDays;
      const finalDays = isElective ? rotatedDays.slice(0, Math.min(cred.lec, rotatedDays.length)) : useDays;

      // Schedule lectures
      let lecScheduled = 0;
      for (const day of finalDays) {
        if (lecScheduled >= cred.lec) break;
        const slot = findSlot(fac, day, 60, lateStart);
        if (slot === -1) continue;
        const timeStart = fmt12(slot / 60);
        const timeEnd = fmt12((slot + 60) / 60);
        entries.push({
          Faculty: fac, Subject: subj, Class: secKey, Deptt: dept,
          Day: day, Time: timeStart, EndTime: timeEnd,
          Location: location, LecLab: "Lec",
          Elective: isElective ? "E" : "",
          SortKey: dayOrder.indexOf(day) * 100 + slot / 60
        });
        bookFac(fac, day, slot, slot + 60);
        lecScheduled++;
      }

      // Schedule lab (3 consecutive hrs)
      if (cred.lab > 0) {
        let labDone = false;
        for (const day of days) {
          if (labDone) break;
          // Try after break first, then before break
          for (const startMinOffset of [breakEnd, breakStart - 180, startHour * 60]) {
            const t = Math.max(startHour * 60, startMinOffset);
            if (t + 180 > endHour * 60) continue;
            if (isBreak(t, t + 180)) continue;
            if (!isFacFree(fac, day, t, t + 180)) continue;
            const timeStart = fmt12(t / 60);
            const timeEnd3 = fmt12((t + 180) / 60);
            for (let h = 0; h < 3; h++) {
              entries.push({
                Faculty: fac, Subject: subj, Class: secKey, Deptt: dept,
                Day: day, Time: fmt12((t + h * 60) / 60), EndTime: fmt12((t + (h+1) * 60) / 60),
                Location: "", LecLab: "Lab",
                Elective: isElective ? "E" : "",
                SortKey: dayOrder.indexOf(day) * 100 + (t + h * 60) / 60
              });
            }
            bookFac(fac, day, t, t + 180);
            labDone = true;
            break;
          }
        }
      }
    }
  }

  return entries;
}

export default function ScheduleGenerator() {
  const params = useLocalSearchParams();
  const router = useRouter();
  const [csvData, setCsvData] = useState<any[]>([]);
  const [fileName, setFileName] = useState("");
  const [generated, setGenerated] = useState<any[]>([]);
  const [generating, setGenerating] = useState(false);
  const [importing, setImporting] = useState(false);
  const [error, setError] = useState("");

  const activeDays = String(params.activeDays||"").split(",").filter(Boolean);
  const startHour = parseInt(String(params.startHour||"9"));
  const endHour = parseInt(String(params.endHour||"17"));
  const breakStart = 13 * 60; // 1 PM
  const breakEnd = 14 * 60;   // 2 PM

  const handleUpload = async () => {
    try {
      const res = await DocumentPicker.getDocumentAsync({ type: "text/csv" });
      if (res.canceled) return;
      const uri = res.assets[0].uri;
      setFileName(res.assets[0].name);
      const text = await FileSystem.readAsStringAsync(uri);
      const lines = text.split(/\r?\n/).filter(l => l.trim());
      const headers = lines[0].split(",").map(h => h.trim().replace(/\r/,""));
      const data = lines.slice(1).map(line => {
        const vals = line.split(",");
        const obj: Record<string,string> = {};
        headers.forEach((h,i) => { obj[h] = (vals[i]||"").trim().replace(/\r/,""); });
        return obj;
      }).filter(r => Object.values(r).some(v => v));
      setCsvData(data);
      setGenerated([]);
      setError("");
    } catch(e: any) { setError("Upload failed: " + e.message); }
  };

  const handleGenerate = () => {
    if (!csvData.length) { setError("Upload CSV first"); return; }
    setGenerating(true);
    setTimeout(() => {
      try {
        const entries = generateSchedule(csvData, activeDays, startHour, endHour, breakStart, breakEnd);
        setGenerated(entries);
        setError("");
      } catch(e: any) { setError("Generation failed: " + e.message); }
      setGenerating(false);
    }, 100);
  };

  const handleImport = async () => {
    if (!generated.length || !params.scheduleId) return;
    setImporting(true);
    try {
      const domain = process.env.EXPO_PUBLIC_DOMAIN;
      const res = await fetch(`https://${domain}/api/import/schedule`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          scheduleId: parseInt(String(params.scheduleId)),
          rows: generated
        })
      });
      const data = await res.json();
      if (data.success || data.imported || data.inserted) {
        Alert.alert("Done", `${data.imported || data.inserted || generated.length} entries imported.`);
        router.back();
      } else {
        setError("Import failed: " + JSON.stringify(data));
      }
    } catch(e: any) { setError("Import error: " + e.message); }
    setImporting(false);
  };

  const s = StyleSheet.create({
    container: { flex:1, backgroundColor: colors.bg },
    header: { backgroundColor: colors.primary, padding: 20, paddingTop: 50 },
    hTitle: { fontSize:20, fontWeight:"700", color:"#fff" },
    hSub: { fontSize:13, color:"rgba(255,255,255,0.8)", marginTop:4 },
    body: { padding:16 },
    card: { backgroundColor:colors.card, borderRadius:12, padding:14, marginBottom:12, shadowColor:"#000", shadowOpacity:0.05, shadowRadius:6, elevation:2 },
    btn: { borderRadius:10, paddingVertical:13, paddingHorizontal:16, alignItems:"center", justifyContent:"center", flexDirection:"row", gap:8 },
    btnTxt: { fontSize:14, fontWeight:"600" },
    row: { flexDirection:"row", borderBottomWidth:1, borderColor:"#eee", paddingVertical:6 },
    cell: { flex:1, fontSize:11, color:colors.text },
    errBox: { backgroundColor:"#FFEBEE", borderRadius:8, padding:10, marginBottom:10 },
    errTxt: { color:"#c62828", fontSize:12 },
  });

  return (
    <View style={s.container}>
      <View style={s.header}>
        <TouchableOpacity onPress={() => router.back()} style={{ flexDirection:"row", alignItems:"center", gap:6, marginBottom:10 }}>
          <Feather name="arrow-left" size={18} color="#fff"/><Text style={{ color:"#fff", fontWeight:"600" }}>Back</Text>
        </TouchableOpacity>
        <Text style={s.hTitle}>AI Schedule Generator</Text>
        <Text style={s.hSub}>{params.scheduleTitle} \u00b7 {activeDays.join(", ")} \u00b7 {startHour}:00\u2013{endHour}:00</Text>
      </View>
      <ScrollView style={s.body}>
        {!!error && <View style={s.errBox}><Text style={s.errTxt}>{error}</Text></View>}

        <View style={s.card}>
          <TouchableOpacity style={[s.btn,{backgroundColor:colors.primary}]} onPress={handleUpload}>
            <Feather name="upload" size={16} color="#fff"/>
            <Text style={[s.btnTxt,{color:"#fff"}]}>{fileName||"Upload Draft CSV"}</Text>
          </TouchableOpacity>
          {!!fileName && <Text style={{fontSize:11,color:colors.success,marginTop:6,textAlign:"center"}}>\u2713 {csvData.length} rows loaded</Text>}
        </View>

        {csvData.length > 0 && (
          <View style={s.card}>
            <TouchableOpacity style={[s.btn,{backgroundColor:"#E65100"}]} onPress={handleGenerate} disabled={generating}>
              {generating ? <ActivityIndicator color="#fff" size="small"/> : <Feather name="cpu" size={16} color="#fff"/>}
              <Text style={[s.btnTxt,{color:"#fff"}]}>{generating?"Generating...":"Generate Schedule with AI"}</Text>
            </TouchableOpacity>
          </View>
        )}

        {generated.length > 0 && (
          <View style={s.card}>
            <View style={{flexDirection:"row",paddingBottom:6,borderBottomWidth:1,borderColor:"#eee"}}>
              {["Faculty","Subject","Class","Day","Time","End","L/L"].map(h=><Text key={h} style={[s.cell,{fontWeight:"700"}]}>{h}</Text>)}
            </View>
            {generated.slice(0,25).map((r,i)=>(
              <View key={i} style={s.row}>
                <Text style={s.cell}>{r.Faculty}</Text>
                <Text style={s.cell}>{r.Subject}</Text>
                <Text style={s.cell}>{r.Class}</Text>
                <Text style={s.cell}>{r.Day}</Text>
                <Text style={s.cell}>{r.Time}</Text>
                <Text style={s.cell}>{r.EndTime}</Text>
                <Text style={[s.cell,{color:r.LecLab==="Lab"?colors.purple:r.Elective?"#E65100":colors.text}]}>{r.LecLab}{r.Elective?" E":""}</Text>
              </View>
            ))}
            {generated.length>25&&<Text style={{padding:10,textAlign:"center",fontSize:11,color:colors.muted}}>...+{generated.length-25} more \u00b7 Labs=purple \u00b7 Electives=E</Text>}
            <TouchableOpacity style={[s.btn,{backgroundColor:colors.success,marginTop:10}]} onPress={handleImport} disabled={importing}>
              {importing?<ActivityIndicator color="#fff" size="small"/>:<Feather name="check" size={16} color="#fff"/>}
              <Text style={[s.btnTxt,{color:"#fff"}]}>{importing?"Importing...":"Import "+generated.length+" Entries to Schedule"}</Text>
            </TouchableOpacity>
          </View>
        )}
      </ScrollView>
    </View>
  );
}
