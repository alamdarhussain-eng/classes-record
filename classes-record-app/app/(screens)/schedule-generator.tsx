import React, { useState } from "react";
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, ActivityIndicator, Alert, Platform } from "react-native";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useLocalSearchParams } from "expo-router";
import * as DocumentPicker from "expo-document-picker";
import { useColors } from "@/hooks/useColors";

function parseCSVLine(line) {
  const result = []; let current = ""; let inQuote = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (ch === '"') { inQuote = !inQuote; }
    else if (ch === "," && !inQuote) { result.push(current.trim()); current = ""; }
    else { current += ch; }
  }
  result.push(current.trim()); return result;
}

function parseCSV(text) {
  const normalized = text.replace(/\r\n/g,"\n").replace(/\r/g,"\n");
  const joined = []; let buffer = ""; let inQuote = false;
  for (const char of normalized) {
    if (char === '"') inQuote = !inQuote;
    if (char === "\n" && inQuote) { buffer += " "; continue; }
    if (char === "\n" && !inQuote) { joined.push(buffer); buffer = ""; continue; }
    buffer += char;
  }
  if (buffer) joined.push(buffer);
  const rows = [];
  for (let i = 1; i < joined.length; i++) {
    const line = joined[i].trim(); if (!line) continue;
    const cols = parseCSVLine(line); if (cols.length < 7) continue;
    rows.push({ subjectCode:cols[0]?.replace(/"/g,"").trim()||"", subject:cols[1]?.replace(/"/g,"").trim()||"", department:cols[2]?.replace(/"/g,"").trim()||"", instructorRaw:cols[3]?.replace(/"/g,"").trim()||"", type:(cols[4]?.replace(/"/g,"").trim()||"Regular"), classGroup:cols[5]?.replace(/"/g,"").trim()||"", creditHrsRaw:cols[6]?.replace(/"/g,"").trim()||"2+0", breakTime:cols[7]?.replace(/"/g,"").trim()||"1300-1400" });
  }
  return rows;
}

function parseCreditHrs(raw) {
  const clean = raw.split("/")[0].trim();
  const parts = clean.split("+");
  const lecHrs = parseInt(parts[0])||0; const labHrs = parseInt(parts[1])||0;
  return { lecHrs, labHrs, totalWeeklyHrs: lecHrs + labHrs*3 };
}

function calcDaysNeeded(total) {
  if (total <= 2) return 2; if (total === 3) return 3; return 4;
}

function expandSections(raw, globalStart) {
  const entries = [];
  const bm = raw.breakTime.match(/(\d{2})(\d{2})-(\d{2})(\d{2})/);
  const breakStart = bm ? parseInt(bm[1])+(parseInt(bm[2])>=30?1:0) : 13;
  const breakEnd = bm ? parseInt(bm[3])+(parseInt(bm[4])>=30?1:0) : 14;
  const creditParts = raw.creditHrsRaw.split("/").map(p=>p.trim()).filter(Boolean);
  const instrLines = raw.instructorRaw.split(/\n|(?<![0-9])\/(?![0-9])/g).map(l=>l.trim()).filter(Boolean);
  const makeEntry = (faculty, section, creditStr, isElective, electiveGroup) => {
    const { lecHrs, labHrs, totalWeeklyHrs } = parseCreditHrs(creditStr);
    const isLowCredit = totalWeeklyHrs <= 2;
    return { subjectCode:raw.subjectCode, subject:raw.subject, department:raw.department, faculty:faculty.replace(/\s+/g," ").trim(), section, classGroup:raw.classGroup, type:raw.type, lecHrs, labHrs, totalWeeklyHrs, breakStart, breakEnd, isElective, electiveGroup, daysNeeded:calcDaysNeeded(totalWeeklyHrs), isLowCredit, lateStart:isLowCredit?globalStart+1:globalStart };
  };
  if (raw.type === "Elective") {
    instrLines.forEach((instrLine, idx) => {
      const creditStr = creditParts[idx]||creditParts[0]||"3+0";
      const faculty = instrLine.replace(/\([^)]*\)/g,"").trim();
      entries.push(makeEntry(faculty, String.fromCharCode(65+idx), creditStr, true, raw.subjectCode+"::"+raw.classGroup));
    });
  } else {
    instrLines.forEach(instrLine => {
      const sm = instrLine.match(/\(([A-Z]+)\)/); const sletters = sm?sm[1]:"A";
      const faculty = instrLine.replace(/\([^)]*\)/g,"").trim();
      const creditStr = creditParts[0]||"3+0";
      for (const sec of sletters.split("")) entries.push(makeEntry(faculty, sec, creditStr, false));
    });
  }
  return entries;
}

function generateSchedule(sections, activeDays, startHour, endHour) {
  const rows = []; const warnings = [];
  const sectionKeys = [...new Set(sections.map(s=>s.classGroup+"-"+s.section))];
  const locationMap = {}; sectionKeys.forEach((key,idx) => { locationMap[key] = "CR-"+(idx+1); });
  const facOcc = {}; const secOcc = {};
  const getFac = (f,d) => { if(!facOcc[f]) facOcc[f]={}; if(!facOcc[f][d]) facOcc[f][d]=new Set(); return facOcc[f][d]; };
  const getSec = (sk,d) => { if(!secOcc[sk]) secOcc[sk]={}; if(!secOcc[sk][d]) secOcc[sk][d]=new Set(); return secOcc[sk][d]; };
  const isFacFree = (f,d,h,dur) => { const occ=getFac(f,d); for(let i=h;i<h+dur;i++) if(occ.has(i)) return false; return true; };
  const isSecFree = (sk,d,h,dur,bS,bE,lS) => { if(h<lS) return false; const occ=getSec(sk,d); for(let i=h;i<h+dur;i++) { if(occ.has(i)) return false; if(i>=bS&&i<bE) return false; if(i>=endHour) return false; } return true; };
  const book = (f,sk,d,h,dur) => { const fo=getFac(f,d); const so=getSec(sk,d); for(let i=h;i<h+dur;i++) { fo.add(i); so.add(i); } };
  const toTime = h => String(h).padStart(2,"0")+"00";
  const addRow = (s,day,h,dur,isLab) => { const sKey=s.classGroup+"-"+s.section; rows.push({ Faculty:s.faculty, Subject:s.subject, Class:sKey, Deptt:s.department, Day:day, Location:isLab?"":(locationMap[sKey]||"CR-?"), Time:toTime(h), EndTime:toTime(h+dur), LecLab:isLab?"Lab":"Lec", Type:"", Elective:s.isElective?"Elective":"", SortKey:h }); };
  const electiveSlots = {};
  const nextConHour = (f,day) => { const occ=getFac(f,day); if(occ.size===0) return undefined; return Math.max(...occ)+1; };
  const findBlock = (faculty,sKey,day,dur,bS,bE,lS,preferStart) => {
    const allH = Array.from({length:endHour-lS},(_,i)=>lS+i);
    const cands = preferStart!==undefined?[preferStart,...allH.filter(h=>h!==preferStart)]:allH;
    for (const h of cands) { if(h+dur>endHour) continue; let spans=false; for(let i=h;i<h+dur;i++) { if(i>=bS&&i<bE){spans=true;break;} } if(spans) continue; if(isFacFree(faculty,day,h,dur)&&isSecFree(sKey,day,h,dur,bS,bE,lS)) return h; }
    return null;
  };
  const sorted = [...sections].sort((a,b) => { if(a.isElective!==b.isElective) return a.isElective?-1:1; return b.totalWeeklyHrs-a.totalWeeklyHrs; });
  for (const s of sorted) {
    const sKey = s.classGroup+"-"+s.section;
    const preferredDays = activeDays.slice(0,s.daysNeeded);
    let scheduledLec = 0;
    if (s.isElective && s.electiveGroup) {
      if (!(s.electiveGroup in electiveSlots)) electiveSlots[s.electiveGroup]=null;
      const shared = electiveSlots[s.electiveGroup];
      if (shared) {
        const {day,hour} = shared;
        for (let offset=0;offset<s.lecHrs;offset++) { const h=hour+offset; if(h>=endHour||(h>=s.breakStart&&h<s.breakEnd)) break; if(isFacFree(s.faculty,day,h,1)&&isSecFree(sKey,day,h,1,s.breakStart,s.breakEnd,s.lateStart)){book(s.faculty,sKey,day,h,1);addRow(s,day,h,1,false);scheduledLec++;} else warnings.push("Elective clash: "+s.faculty+" "+s.subject+" "+sKey+" "+day+" "+toTime(h)); }
      } else {
        for (const day of preferredDays) { if(scheduledLec>=s.lecHrs) break; const toBook=Math.min(2,s.lecHrs-scheduledLec); const pref=nextConHour(s.faculty,day); const slot=findBlock(s.faculty,sKey,day,toBook,s.breakStart,s.breakEnd,s.lateStart,pref); if(slot!==null){if(!electiveSlots[s.electiveGroup])electiveSlots[s.electiveGroup]={day,hour:slot};book(s.faculty,sKey,day,slot,toBook);for(let d=0;d<toBook;d++)addRow(s,day,slot+d,1,false);scheduledLec+=toBook;} }
      }
    } else {
      const maxPerDay = s.isLowCredit?1:2;
      for (const day of preferredDays) { if(scheduledLec>=s.lecHrs) break; const toBook=Math.min(maxPerDay,s.lecHrs-scheduledLec); const pref=nextConHour(s.faculty,day); const slot=findBlock(s.faculty,sKey,day,toBook,s.breakStart,s.breakEnd,s.lateStart,pref); if(slot!==null){book(s.faculty,sKey,day,slot,toBook);for(let d=0;d<toBook;d++)addRow(s,day,slot+d,1,false);scheduledLec+=toBook;} else { for(let h=s.lateStart;h<endHour&&scheduledLec<s.lecHrs;h++){if(h>=s.breakStart&&h<s.breakEnd)continue;if(isFacFree(s.faculty,day,h,1)&&isSecFree(sKey,day,h,1,s.breakStart,s.breakEnd,s.lateStart)){book(s.faculty,sKey,day,h,1);addRow(s,day,h,1,false);scheduledLec++;}} } }
      if (scheduledLec<s.lecHrs) { for(const day of activeDays){if(scheduledLec>=s.lecHrs)break;if(preferredDays.includes(day))continue;const toBook=Math.min(2,s.lecHrs-scheduledLec);const pref=nextConHour(s.faculty,day);const slot=findBlock(s.faculty,sKey,day,toBook,s.breakStart,s.breakEnd,s.lateStart,pref);if(slot!==null){book(s.faculty,sKey,day,slot,toBook);for(let d=0;d<toBook;d++)addRow(s,day,slot+d,1,false);scheduledLec+=toBook;}} }
    }
    if(scheduledLec<s.lecHrs) warnings.push("Incomplete lec: "+s.faculty+" "+s.subject+" "+sKey+" ("+scheduledLec+"/"+s.lecHrs+")");
    if (s.labHrs>0) {
      let labDone=false; const dayOrder=[...preferredDays,...activeDays.filter(d=>!preferredDays.includes(d))];
      for(const day of dayOrder){if(labDone)break;const positions=[s.breakEnd,s.breakStart-3,s.lateStart].filter(h=>h>=s.lateStart&&h>=0&&h+3<=endHour);for(const h of positions){let spans=false;for(let i=h;i<h+3;i++){if(i>=s.breakStart&&i<s.breakEnd){spans=true;break;}}if(spans)continue;if(isFacFree(s.faculty,day,h,3)&&isSecFree(sKey,day,h,3,s.breakStart,s.breakEnd,s.lateStart)){book(s.faculty,sKey,day,h,3);addRow(s,day,h,3,true);labDone=true;break;}}
      if(!labDone){for(let h=s.lateStart;h+3<=endHour;h++){let spans=false;for(let i=h;i<h+3;i++){if(i>=s.breakStart&&i<s.breakEnd){spans=true;break;}}if(spans)continue;if(isFacFree(s.faculty,day,h,3)&&isSecFree(sKey,day,h,3,s.breakStart,s.breakEnd,s.lateStart)){book(s.faculty,sKey,day,h,3);addRow(s,day,h,3,true);labDone=true;break;}}}}
      if(!labDone) warnings.push("Lab not scheduled: "+s.faculty+" "+s.subject+" "+sKey);
    }
  }
  const dayIdx = {Mon:0,Tue:1,Wed:2,Thu:3,Fri:4,Sat:5,Sun:6};
  rows.sort((a,b)=>{const di=(dayIdx[a.Day]??9)-(dayIdx[b.Day]??9);return di!==0?di:parseInt(a.Time)-parseInt(b.Time);});
  return {rows,warnings};
}

export default function ScheduleGeneratorScreen() {
  const colors = useColors(); const insets = useSafeAreaInsets(); const router = useRouter();
  const params = useLocalSearchParams();
  const [csvText, setCsvText] = useState(null); const [fileName, setFileName] = useState("");
  const [generating, setGenerating] = useState(false); const [generated, setGenerated] = useState(null);
  const [warnings, setWarnings] = useState([]); const [uploading, setUploading] = useState(false);
  const [error, setError] = useState(""); const [importing, setImporting] = useState(false);
  const days = params.activeDays ? params.activeDays.split(",") : ["Mon","Tue","Wed","Thu","Fri"];
  const sHour = parseInt(params.startHour||"9"); const eHour = parseInt(params.endHour||"17");

  const handleDownloadDraft = () => {
    const lines = ["Subject Code,Subjects,Department,Instructor Name with Sections,Regular/Elective,Class,Credit Hrs,Break Time","OTM455,Engineering Project Management,HU,Mr. Talha Aleem Khawja (ABCD),Regular,BEE-6,2+0,1300-1400","HU212,Technical & Business Writing,HU,Ms. Komal Malik (ABCD),Regular,BEE-6,2+0,1300-1400",'EE342,Microwave Engineering,EE,"Mr. Ahsan Azhar (A), Dr. Muhammad Umar Khan (B), Ms. Maira Islam (CD)",Regular,BEE-6,3+1,1300-1400','MATH351,Numerical Methods,BS,"Mr. Abid Kamran (AB), Ms. Aisha Javed (CD)",Regular,BEE-7,3+0,1300-1400','EE260,Electrical Machines,EE,"Dr. Farid Gul (A), Dr. Faisal Khan (B), Ms. Neelma Naz (CD)",Regular,BEE-7,3+1,1300-1400'].join("\n");
    if (Platform.OS==="web"&&typeof document!=="undefined"){const blob=new Blob([lines],{type:"text/csv;charset=utf-8;"});const url=URL.createObjectURL(blob);const a=document.createElement("a");a.href=url;a.download="Draft_Schedule.csv";document.body.appendChild(a);a.click();document.body.removeChild(a);URL.revokeObjectURL(url);}
  };
  const handleUpload = async () => { try{setUploading(true);setError("");const res=await DocumentPicker.getDocumentAsync({type:["text/csv","*/*"],copyToCacheDirectory:true});if(res.canceled){setUploading(false);return;}const file=res.assets[0];setFileName(file.name);const r=await fetch(file.uri);const text=await r.text();setCsvText(text);setGenerated(null);setWarnings([]);}catch{setError("Failed to read file.");}setUploading(false);};
  const handleGenerate = async () => { if(!csvText) return; setGenerating(true);setError("");setWarnings([]); try{const rawRows=parseCSV(csvText);if(!rawRows.length){setError("No valid rows.");setGenerating(false);return;}const sections=[];for(const row of rawRows){try{sections.push(...expandSections(row,sHour));}catch(e){console.warn("Row error:",row.subject,e);}}if(!sections.length){setError("Could not parse sections.");setGenerating(false);return;}const{rows,warnings:w}=generateSchedule(sections,days,sHour,eHour);setGenerated(rows);setWarnings(w);}catch(e){setError("Failed: "+(e?.message||e));}setGenerating(false);};
  const handleImport = async () => { if(!generated||!params.scheduleId) return; setImporting(true); try{const domain=process.env.EXPO_PUBLIC_DOMAIN;const res=await fetch("https://"+domain+"/api/import/schedule",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({scheduleId:parseInt(params.scheduleId),rows:generated.map(r=>({faculty:r.Faculty,subject:r.Subject,className:r.Class,dept:r.Deptt,day:r.Day,location:r.Location,timeStart:r.Time,timeEnd:r.EndTime,lecLab:r.LecLab,type:r.Type,elective:r.Elective,sortKey:r.SortKey}))})});const data=await res.json();if(data.success||data.inserted){Alert.alert("Done",generated.length+" entries imported.");router.back();}else setError("Import failed: "+JSON.stringify(data));}catch(e){setError("Import error: "+e?.message);}setImporting(false);};

  const s = StyleSheet.create({container:{flex:1,backgroundColor:colors.background},header:{backgroundColor:"#4A148C",paddingTop:insets.top+(Platform.OS==="web"?67:16),paddingBottom:16,paddingHorizontal:16},btn:{flexDirection:"row",alignItems:"center",justifyContent:"center",gap:8,margin:14,borderRadius:10,paddingVertical:13},btnTxt:{fontSize:15,fontFamily:"Inter_700Bold"},card:{margin:16,backgroundColor:colors.card,borderRadius:12,borderWidth:1,borderColor:colors.border,overflow:"hidden"},cardHdr:{padding:14,borderBottomWidth:1,borderBottomColor:colors.border,flexDirection:"row",alignItems:"center",gap:10},tableHdr:{flexDirection:"row",backgroundColor:colors.muted,paddingVertical:8,paddingHorizontal:10},tableRow:{flexDirection:"row",paddingVertical:5,paddingHorizontal:10,borderBottomWidth:1,borderBottomColor:colors.border},cell:{fontSize:11,fontFamily:"Inter_400Regular",color:colors.foreground,flex:1}});
  const lecN = generated?.filter(r=>r.LecLab==="Lec").length??0; const labN = generated?.filter(r=>r.LecLab==="Lab").length??0; const facN = generated?new Set(generated.map(r=>r.Faculty)).size:0;
  const preview = generated?.slice(0,25)??[];
  const rules = [["#1565C0","CR-1 to CR-N classrooms auto-assigned per section"],["#1565C0","Credit 3+1 = 3 Lec/week + 1 Lab (3 consecutive hrs)"],["#2E7D32","Low credit section (≤2 total hrs): starts 1 hr late every day"],["#2E7D32","Faculty days: ≤2 hrs→2 days · 3 hrs→3 days · ≥4 hrs→4 days max"],["#E65100","Lab = 3 consecutive hrs before OR after break, never spanning"],["#E65100","No faculty clash — one class per faculty per hour"],["#6A1B9A","Electives: all sections share same time slot"],["#6A1B9A","Consecutive lectures preferred — gaps minimised"],["#00695C","Lab classroom left blank for manual assignment"],["#00695C","Break window fully enforced — no class during break"]];
  return (
    <View style={s.container}>
      <View style={s.header}>
        <TouchableOpacity style={{flexDirection:"row",alignItems:"center",gap:6,marginBottom:10}} onPress={()=>router.back()}>
          <Feather name="arrow-left" size={14} color="#fff"/><Text style={{color:"#fff",fontSize:13,fontFamily:"Inter_500Medium"}}>Back</Text>
        </TouchableOpacity>
        <Text style={{color:"#fff",fontSize:22,fontFamily:"Inter_700Bold"}}>AI Schedule Generator</Text>
        <Text style={{color:"rgba(255,255,255,0.8)",fontSize:13,fontFamily:"Inter_400Regular",marginTop:2}}>{params.scheduleTitle?decodeURIComponent(params.scheduleTitle):"Schedule"} · {days.join(", ")} · {sHour}:00–{eHour}:00</Text>
      </View>
      <ScrollView contentContainerStyle={{paddingBottom:40}}>
        <View style={s.card}>
          <View style={[s.cardHdr,{backgroundColor:"#E3F2FD"}]}><Feather name="download" size={18} color="#1565C0"/><Text style={{fontSize:16,fontFamily:"Inter_700Bold",color:"#1565C0"}}>Step 1 — Download Draft Schedule</Text></View>
          <View style={{margin:14,borderRadius:8,padding:12,flexDirection:"row",gap:8,backgroundColor:"#E3F2FD"}}><Feather name="info" size={14} color="#1565C0"/><Text style={{fontSize:12,fontFamily:"Inter_400Regular",color:"#1565C0",flex:1,lineHeight:18}}>Download CSV → fill Subject, Faculty (Sections), Credit Hrs (e.g. 3+1), Break Time (e.g. 1300-1400) → upload below.</Text></View>
          <TouchableOpacity style={[s.btn,{backgroundColor:"#1565C0"}]} onPress={handleDownloadDraft}><Feather name="download" size={16} color="#fff"/><Text style={[s.btnTxt,{color:"#fff"}]}>Download Draft Schedule CSV</Text></TouchableOpacity>
        </View>
        <View style={s.card}>
          <View style={[s.cardHdr,{backgroundColor:"#E8F5E9"}]}><Feather name="upload" size={18} color="#2E7D32"/><Text style={{fontSize:16,fontFamily:"Inter_700Bold",color:"#2E7D32"}}>Step 2 — Upload Filled Schedule CSV</Text></View>
          <TouchableOpacity style={[s.btn,{backgroundColor:"#2E7D32"}]} onPress={handleUpload} disabled={uploading}>{uploading?<ActivityIndicator color="#fff" size="small"/>:<Feather name={csvText?"refresh-cw":"upload"} size={16} color="#fff"/>}<Text style={[s.btnTxt,{color:"#fff"}]}>{csvText?"Re-upload · "+fileName:"Upload Your Schedule CSV"}</Text></TouchableOpacity>
          {csvText&&<View style={{margin:14,marginTop:0,borderRadius:8,padding:10,backgroundColor:"#E8F5E9",flexDirection:"row",gap:8}}><Feather name="check-circle" size={14} color="#2E7D32"/><Text style={{fontSize:12,fontFamily:"Inter_400Regular",color:"#2E7D32"}}>✓ {fileName} loaded — ready to generate</Text></View>}
        </View>
        <View style={s.card}>
          <View style={[s.cardHdr,{backgroundColor:"#FFF3E0"}]}><Feather name="cpu" size={18} color="#E65100"/><Text style={{fontSize:16,fontFamily:"Inter_700Bold",color:"#E65100"}}>Step 3 — AI Generate Timetable</Text></View>
          <View style={{padding:14,paddingBottom:4}}>{rules.map(([color,text],i)=><View key={i} style={{flexDirection:"row",alignItems:"flex-start",gap:8,marginBottom:6}}><View style={{width:6,height:6,borderRadius:3,marginTop:5,backgroundColor:color}}/><Text style={{fontSize:12,fontFamily:"Inter_400Regular",color:colors.mutedForeground,flex:1,lineHeight:17}}>{text}</Text></View>)}</View>
          {error?<View style={{margin:14,borderRadius:8,padding:12,flexDirection:"row",gap:8,backgroundColor:"#FFEBEE"}}><Feather name="alert-circle" size={14} color="#B71C1C"/><Text style={{fontSize:12,fontFamily:"Inter_400Regular",color:"#B71C1C",flex:1}}>{error}</Text></View>:null}
          <TouchableOpacity style={[s.btn,{backgroundColor:csvText?"#E65100":colors.muted}]} onPress={handleGenerate} disabled={!csvText||generating}>{generating?<ActivityIndicator color="#fff" size="small"/>:<Feather name="zap" size={16} color={csvText?"#fff":colors.mutedForeground}/>}<Text style={[s.btnTxt,{color:csvText?"#fff":colors.mutedForeground}]}>{generating?"Generating Timetable…":"Generate Schedule with AI"}</Text></TouchableOpacity>
        </View>
        {warnings.length>0&&<View style={{marginHorizontal:16,marginBottom:8,backgroundColor:"#FFF8E1",borderRadius:8,padding:10}}><Text style={{fontSize:11,fontFamily:"Inter_600SemiBold",color:"#E65100",marginBottom:4}}>⚠ {warnings.length} warning{warnings.length>1?"s":""}:</Text>{warnings.slice(0,8).map((w,i)=><Text key={i} style={{fontSize:11,fontFamily:"Inter_400Regular",color:"#E65100"}}>• {w}</Text>)}{warnings.length>8&&<Text style={{fontSize:11,fontFamily:"Inter_400Regular",color:"#E65100"}}>…+{warnings.length-8} more</Text>}</View>}
        {generated&&generated.length>0&&<View style={s.card}>
          <View style={[s.cardHdr,{backgroundColor:"#E8F5E9"}]}><Feather name="check-circle" size={18} color="#2E7D32"/><Text style={{fontSize:16,fontFamily:"Inter_700Bold",color:"#2E7D32"}}>Step 4 — Preview & Import</Text></View>
          <View style={{flexDirection:"row",margin:10}}>{[[generated.length,"Total"],[lecN,"Lectures"],[labN,"Labs"],[facN,"Faculty"]].map(([n,l])=><View key={l} style={{flex:1,backgroundColor:colors.muted,borderRadius:8,padding:10,alignItems:"center",margin:4}}><Text style={{fontSize:20,fontFamily:"Inter_700Bold",color:colors.foreground}}>{n}</Text><Text style={{fontSize:10,fontFamily:"Inter_400Regular",color:colors.mutedForeground,textAlign:"center"}}>{l}</Text></View>)}</View>
          <View style={s.tableHdr}>{["Faculty","Subject","Class","Day","Time","End","Type"].map(h=><Text key={h} style={[s.cell,{fontFamily:"Inter_600SemiBold"}]}>{h}</Text>)}</View>
          {preview.map((r,i)=><View key={i} style={[s.tableRow,{backgroundColor:r.LecLab==="Lab"?"#F3E5F5":"transparent"}]}><Text style={s.cell} numberOfLines={1}>{r.Faculty.split(" ").pop()}</Text><Text style={s.cell} numberOfLines={1}>{r.Subject.split(" ").slice(0,2).join(" ")}</Text><Text style={s.cell} numberOfLines={1}>{r.Class}</Text><Text style={s.cell}>{r.Day}</Text><Text style={s.cell}>{r.Time}</Text><Text style={s.cell}>{r.EndTime}</Text><Text style={[s.cell,{color:r.LecLab==="Lab"?"#6A1B9A":r.Elective?"#E65100":colors.foreground}]}>{r.LecLab}{r.Elective?" E":""}</Text></View>)}
          {generated.length>25&&<Text style={{padding:10,textAlign:"center",fontSize:11,color:colors.mutedForeground,fontFamily:"Inter_400Regular"}}>…+{generated.length-25} more · Labs=purple · Electives=E</Text>}
          <TouchableOpacity style={[s.btn,{backgroundColor:"#2E7D32"}]} onPress={handleImport} disabled={importing}>{importing?<ActivityIndicator color="#fff" size="small"/>:<Feather name="check" size={16} color="#fff"/>}<Text style={[s.btnTxt,{color:"#fff"}]}>{importing?"Importing…":"Import "+generated.length+" Entries to Schedule"}</Text></TouchableOpacity>
        </View>}
      </ScrollView>
    </View>
  );
}
