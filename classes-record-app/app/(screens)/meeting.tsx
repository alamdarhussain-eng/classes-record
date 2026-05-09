import React, { useState, useMemo, useCallback } from "react";
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  TextInput, ActivityIndicator, Platform, Alert,
} from "react-native";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useFocusEffect } from "expo-router";
import * as ScreenOrientation from "expo-screen-orientation";
import { printOrShareHtml } from "@/utils/printHtml";

import { useColors } from "@/hooks/useColors";
import { fetchMeeting, fetchSchedule, fetchOptions, MeetingResult, ScheduleOptions } from "@/hooks/useApi";
import { PickerModal } from "@/components/PickerModal";

const HOUR_LABELS = Array.from({ length: 9 }, (_, i) => {
  const h = i + 9;
  if (h < 12) return `${h.toString().padStart(2, "0")}:00 AM`;
  if (h === 12) return "12:00 PM";
  return `${(h - 12).toString().padStart(2, "0")}:00 PM`;
});

function todayStr() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

function formatHM(m: number): string {
  const h = Math.floor(m / 60);
  const min = m % 60;
  const ap = h >= 12 ? "PM" : "AM";
  const h12 = (h % 12) || 12;
  return `${h12.toString().padStart(2, "0")}:${min.toString().padStart(2, "0")} ${ap}`;
}

export default function MeetingScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();

  useFocusEffect(
    useCallback(() => {
      if (Platform.OS !== "web") {
        ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.LANDSCAPE).catch(() => {});
      }
      return () => {
        if (Platform.OS !== "web") {
          ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.PORTRAIT_UP).catch(() => {});
        }
      };
    }, [])
  );

  const [date, setDate] = useState(todayStr);
  const [start, setStart] = useState("09:00 AM");
  const [end, setEnd] = useState("10:00 AM");
  const [selectedFaculty, setSelectedFaculty] = useState<string[]>([]);
  const [showFacPicker, setShowFacPicker] = useState(false);
  const [result, setResult] = useState<MeetingResult | null>(null);
  const [activeTab, setActiveTab] = useState<"free" | "busy">("free");

  const { data: schedule = [] } = useQuery({ queryKey: ["schedule"], queryFn: fetchSchedule });
  const { data: options } = useQuery<ScheduleOptions>({ queryKey: ["options"], queryFn: fetchOptions });

  const facultyList = useMemo(() => {
    const fromDB = [...new Set(schedule.filter((r) => !r.Type).map((r) => r.Faculty))].sort();
    const fromOpts = options?.faculty ?? [];
    return [...new Set([...fromDB, ...fromOpts])].sort();
  }, [schedule, options]);

  const availableFaculty = useMemo(
    () => facultyList.filter((f) => !selectedFaculty.includes(f)),
    [facultyList, selectedFaculty]
  );

  const mutation = useMutation({
    mutationFn: () => fetchMeeting(date, start, end, selectedFaculty.length > 0 ? selectedFaculty : undefined),
    onSuccess: (data) => setResult(data),
    onError: () => Alert.alert("Error", "Could not generate report"),
  });

  async function handleDownload() {
    if (!result) { Alert.alert("No Report", "Generate a report first before downloading."); return; }

    const facNote = selectedFaculty.length > 0 ? selectedFaculty.join(", ") : "All Faculty";

    const deptBreakdown = Object.entries(result.summary).sort()
      .map(([dept, counts]) => `<tr>
        <td>${dept}</td>
        <td style="text-align:center;color:#388E3C;font-weight:bold">${counts.free}</td>
        <td style="text-align:center;color:#D32F2F;font-weight:bold">${counts.busy}</td>
      </tr>`).join("");

    const freeRows = result.free.map((f) =>
      `<tr><td><span style="color:#388E3C">●</span> ${f.name}</td><td style="color:#555">${f.dept}</td></tr>`
    ).join("");

    const busyRows = result.busy.map((b) => {
      const records = b.records.map((r) =>
        `<div style="background:#FFF3F3;border-left:3px solid #F44336;border-radius:3px;padding:3px 6px;margin-top:4px;font-size:9px">
          <b>${r.subject}</b> · ${r.cls}<br/>
          <span style="color:#888">${formatHM(r.start)} – ${formatHM(r.end)} · ${r.loc} · ${r.type}</span>
        </div>`
      ).join("");
      return `<tr>
        <td style="white-space:nowrap"><span style="color:#D32F2F">●</span> <b>${b.name}</b></td>
        <td><span style="color:#888;font-size:9px">${b.dept}</span>${records}</td>
      </tr>`;
    }).join("");

    const html = `<!DOCTYPE html><html><head><meta charset="utf-8"/>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: Arial, sans-serif; font-size: 11px; }
  .hdr { background: #1976D2; color: #fff; padding: 12px 16px; }
  .hdr h1 { font-size: 17px; font-weight: bold; }
  .hdr p { font-size: 10px; opacity: .85; margin-top: 2px; }
  .summary-boxes { display: flex; gap: 0; border-bottom: 1px solid #E0E0E0; }
  .box { flex: 1; padding: 12px; text-align: center; border-right: 1px solid #E0E0E0; }
  .box:last-child { border-right: none; }
  .box-num { font-size: 32px; font-weight: bold; }
  .box-lbl { font-size: 10px; color: #555; margin-top: 2px; }
  .section-title { background: #F5F5F5; padding: 6px 12px; font-weight: bold; font-size: 12px; color: #333; border-top: 2px solid #1976D2; border-bottom: 1px solid #E0E0E0; margin-top: 8px; }
  table { width: 100%; border-collapse: collapse; }
  td { border: 1px solid #E0E0E0; padding: 6px 8px; font-size: 10px; vertical-align: top; }
  th { background: #1976D2; color: #fff; padding: 6px 8px; font-size: 10px; text-align: left; }
  tr { page-break-inside: avoid; }
</style></head><body>
<div class="hdr">
  <h1>Meeting Availability Report</h1>
  <p>${result.dayName}, ${result.date} &nbsp;·&nbsp; ${result.start} – ${result.end} &nbsp;·&nbsp; ${facNote}</p>
  <p style="margin-top:4px">Generated ${new Date().toLocaleDateString("en-PK", { weekday:"long", year:"numeric", month:"long", day:"numeric" })}</p>
</div>
<div class="summary-boxes">
  <div class="box"><div class="box-num" style="color:#388E3C">${result.free.length}</div><div class="box-lbl">Free Faculty</div></div>
  <div class="box"><div class="box-num" style="color:#D32F2F">${result.busy.length}</div><div class="box-lbl">Busy Faculty</div></div>
  <div class="box"><div class="box-num" style="color:#1976D2">${result.free.length + result.busy.length}</div><div class="box-lbl">Total Checked</div></div>
</div>
${Object.keys(result.summary).length > 0 ? `
<div class="section-title">Department Breakdown</div>
<table><thead><tr><th>Department</th><th style="text-align:center">Free</th><th style="text-align:center">Busy</th></tr></thead>
<tbody>${deptBreakdown}</tbody></table>` : ""}
<div class="section-title" style="color:#388E3C;border-top-color:#388E3C">Free Faculty (${result.free.length})</div>
<table><thead><tr><th>Name</th><th>Department</th></tr></thead>
<tbody>${freeRows || "<tr><td colspan='2' style='color:#999'>None</td></tr>"}</tbody></table>
<div class="section-title" style="color:#D32F2F;border-top-color:#D32F2F">Busy Faculty (${result.busy.length})</div>
<table><thead><tr><th>Name</th><th>Department &amp; Schedule</th></tr></thead>
<tbody>${busyRows || "<tr><td colspan='2' style='color:#999'>None</td></tr>"}</tbody></table>
</body></html>`;

    try {
      await printOrShareHtml(html, "Save Meeting Report PDF");
    } catch {
      Alert.alert("Error", "Could not generate PDF. Please try again.");
    }
  }

  const s = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    header: {
      backgroundColor: colors.primary,
      paddingTop: insets.top + (Platform.OS === "web" ? 67 : 0),
      paddingBottom: 14, paddingHorizontal: 16,
    },
    homeBtn: {
      flexDirection: "row", alignItems: "center", gap: 6,
      backgroundColor: "rgba(255,255,255,0.2)", borderRadius: 20,
      paddingHorizontal: 12, paddingVertical: 6, alignSelf: "flex-start", marginBottom: 10,
    },
    homeBtnTxt: { color: "#fff", fontFamily: "Inter_600SemiBold", fontSize: 13 },
    headerTitle: { color: "#fff", fontSize: 22, fontFamily: "Inter_700Bold" },
    headerSub: { color: "rgba(255,255,255,0.8)", fontSize: 13, fontFamily: "Inter_400Regular", marginTop: 2 },
    scroll: { padding: 16 },
    label: { fontSize: 12, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground, marginBottom: 6, marginTop: 14, textTransform: "uppercase", letterSpacing: 0.5 },
    input: {
      backgroundColor: colors.card, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12,
      fontFamily: "Inter_400Regular", fontSize: 14, color: colors.foreground,
      borderWidth: 1, borderColor: colors.border,
    },
    optRow: { flexDirection: "row", gap: 8, flexWrap: "wrap" },
    optBtn: { paddingHorizontal: 12, paddingVertical: 8, borderRadius: 8, borderWidth: 1, borderColor: colors.border, backgroundColor: colors.card },
    optBtnActive: { backgroundColor: colors.primary, borderColor: colors.primary },
    optTxt: { fontFamily: "Inter_500Medium", fontSize: 13, color: colors.foreground },
    optTxtActive: { color: "#fff" },
    facAddBtn: {
      flexDirection: "row", alignItems: "center", gap: 8,
      backgroundColor: colors.card, borderRadius: 10,
      paddingHorizontal: 14, paddingVertical: 12,
      borderWidth: 1, borderColor: colors.border, borderStyle: "dashed",
    },
    facAddTxt: { flex: 1, fontFamily: "Inter_400Regular", fontSize: 14, color: colors.mutedForeground },
    chipsRow: { flexDirection: "row", flexWrap: "wrap", gap: 6, marginTop: 8 },
    chip: {
      flexDirection: "row", alignItems: "center", gap: 6, backgroundColor: colors.secondary,
      borderRadius: 20, paddingHorizontal: 12, paddingVertical: 6,
      borderWidth: 1, borderColor: colors.primary,
    },
    chipTxt: { fontFamily: "Inter_500Medium", fontSize: 13, color: colors.primary },
    allFacChip: {
      flexDirection: "row", alignItems: "center", gap: 6, backgroundColor: colors.muted,
      borderRadius: 20, paddingHorizontal: 12, paddingVertical: 6,
      borderWidth: 1, borderColor: colors.border,
    },
    allFacTxt: { fontFamily: "Inter_400Regular", fontSize: 13, color: colors.mutedForeground, fontStyle: "italic" },
    generateBtn: {
      backgroundColor: colors.primary, borderRadius: 12, padding: 14,
      alignItems: "center", marginTop: 20,
    },
    generateBtnTxt: { color: "#fff", fontFamily: "Inter_700Bold", fontSize: 16 },
    divider: { height: 1, backgroundColor: colors.border, marginVertical: 16 },
    resultHeader: { fontSize: 16, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 8 },
    tabRow: { flexDirection: "row", marginBottom: 12 },
    tabBtn: { flex: 1, paddingVertical: 10, borderBottomWidth: 2, borderBottomColor: colors.border, alignItems: "center" },
    tabBtnActive: { borderBottomColor: colors.primary },
    tabTxt: { fontFamily: "Inter_600SemiBold", fontSize: 14, color: colors.mutedForeground },
    tabTxtActive: { color: colors.primary },
    summaryCard: { flexDirection: "row", gap: 12, marginBottom: 16 },
    summaryBox: {
      flex: 1, padding: 14, borderRadius: 12, borderWidth: 1,
      borderColor: colors.border, alignItems: "center",
    },
    summaryNum: { fontSize: 28, fontFamily: "Inter_700Bold" },
    summaryLbl: { fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginTop: 2 },
    personCard: {
      backgroundColor: colors.card, borderRadius: 10, padding: 12, marginBottom: 8,
      borderWidth: 1, borderColor: colors.border,
    },
    personName: { fontSize: 15, fontFamily: "Inter_600SemiBold", color: colors.foreground },
    personDept: { fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginTop: 2 },
    busyRecord: { marginTop: 8, backgroundColor: colors.muted, borderRadius: 8, padding: 10 },
    busyTxt: { fontSize: 12, fontFamily: "Inter_400Regular", color: colors.foreground },
    emptyTxt: { color: colors.mutedForeground, fontFamily: "Inter_400Regular", fontSize: 14, textAlign: "center", marginTop: 20 },
    deptSummaryCard: {
      backgroundColor: colors.card, borderRadius: 10, padding: 12, marginBottom: 16,
      borderWidth: 1, borderColor: colors.border,
    },
    deptTitle: { fontSize: 14, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 8 },
    deptRow2: { flexDirection: "row", justifyContent: "space-between", paddingVertical: 3, borderBottomWidth: 1, borderBottomColor: colors.border },
    deptRowLast: { borderBottomWidth: 0 },
  });

  return (
    <View style={s.container}>
      <View style={s.header}>
        <View style={{ flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 10 }}>
          <View style={{ flexDirection: "row", gap: 8 }}>
            <TouchableOpacity style={s.homeBtn} onPress={() => router.back()}>
              <Feather name="chevron-left" size={13} color="#fff" />
              <Text style={s.homeBtnTxt}>Back</Text>
            </TouchableOpacity>
            <TouchableOpacity style={s.homeBtn} onPress={() => router.replace("/")}>
              <Feather name="home" size={13} color="#fff" />
              <Text style={s.homeBtnTxt}>Home</Text>
            </TouchableOpacity>
          </View>
          <TouchableOpacity
            style={[s.homeBtn, !result && { opacity: 0.5 }]}
            onPress={handleDownload}
          >
            <Feather name="download" size={13} color="#fff" />
            <Text style={s.homeBtnTxt}>Download</Text>
          </TouchableOpacity>
        </View>
        <Text style={s.headerTitle}>Meeting Availability</Text>
        <Text style={s.headerSub}>Check who is free for a meeting</Text>
      </View>

      <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 40 }} keyboardShouldPersistTaps="handled">
        <Text style={s.label}>Date</Text>
        <TextInput style={s.input} value={date} onChangeText={setDate} placeholder="YYYY-MM-DD" placeholderTextColor={colors.mutedForeground} />

        <Text style={s.label}>Start Time</Text>
        <View style={s.optRow}>
          {HOUR_LABELS.slice(0, 8).map((t) => (
            <TouchableOpacity key={t} style={[s.optBtn, start === t && s.optBtnActive]} onPress={() => setStart(t)}>
              <Text style={[s.optTxt, start === t && s.optTxtActive]}>{t}</Text>
            </TouchableOpacity>
          ))}
        </View>

        <Text style={s.label}>End Time</Text>
        <View style={s.optRow}>
          {HOUR_LABELS.slice(1).map((t) => (
            <TouchableOpacity key={t} style={[s.optBtn, end === t && s.optBtnActive]} onPress={() => setEnd(t)}>
              <Text style={[s.optTxt, end === t && s.optTxtActive]}>{t}</Text>
            </TouchableOpacity>
          ))}
        </View>

        <Text style={s.label}>
          Faculty Filter{selectedFaculty.length > 0 ? ` · ${selectedFaculty.length} selected` : " (optional — leave empty for ALL)"}
        </Text>

        {selectedFaculty.length === 0 ? (
          <View style={s.allFacChip}>
            <Feather name="users" size={14} color={colors.mutedForeground} />
            <Text style={s.allFacTxt}>All faculty — no filter applied</Text>
          </View>
        ) : (
          <View style={s.chipsRow}>
            {selectedFaculty.map((f) => (
              <TouchableOpacity key={f} style={s.chip} onPress={() => setSelectedFaculty((prev) => prev.filter((x) => x !== f))}>
                <Text style={s.chipTxt} numberOfLines={1}>{f}</Text>
                <Feather name="x" size={13} color={colors.primary} />
              </TouchableOpacity>
            ))}
          </View>
        )}

        <TouchableOpacity style={[s.facAddBtn, { marginTop: 8 }]} onPress={() => setShowFacPicker(true)}>
          <Feather name="user-plus" size={16} color={colors.primary} />
          <Text style={s.facAddTxt}>
            {availableFaculty.length > 0 ? "Add faculty to filter…" : "All faculty selected"}
          </Text>
          <Feather name="chevron-down" size={16} color={colors.mutedForeground} />
        </TouchableOpacity>

        {selectedFaculty.length > 0 && (
          <TouchableOpacity
            onPress={() => setSelectedFaculty([])}
            style={{ marginTop: 6, alignSelf: "flex-start", flexDirection: "row", alignItems: "center", gap: 4 }}
          >
            <Feather name="x-circle" size={13} color={colors.mutedForeground} />
            <Text style={{ fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground }}>Clear all</Text>
          </TouchableOpacity>
        )}

        <TouchableOpacity
          style={[s.generateBtn, mutation.isPending && { opacity: 0.6 }]}
          onPress={() => mutation.mutate()}
          disabled={mutation.isPending}
        >
          {mutation.isPending ? <ActivityIndicator color="#fff" /> : <Text style={s.generateBtnTxt}>Generate Report</Text>}
        </TouchableOpacity>

        {result && (
          <View>
            <View style={s.divider} />
            <Text style={s.resultHeader}>
              {result.dayName}, {result.date} · {result.start} – {result.end}
            </Text>

            <View style={s.summaryCard}>
              <View style={[s.summaryBox, { borderColor: "#4CAF50", backgroundColor: colors.successBg }]}>
                <Text style={[s.summaryNum, { color: "#388E3C" }]}>{result.free.length}</Text>
                <Text style={s.summaryLbl}>Free</Text>
              </View>
              <View style={[s.summaryBox, { borderColor: "#F44336", backgroundColor: colors.errorBg }]}>
                <Text style={[s.summaryNum, { color: "#D32F2F" }]}>{result.busy.length}</Text>
                <Text style={s.summaryLbl}>Busy</Text>
              </View>
            </View>

            {Object.keys(result.summary).length > 0 && (
              <View style={s.deptSummaryCard}>
                <Text style={s.deptTitle}>Department Breakdown</Text>
                {Object.entries(result.summary).sort().map(([dept, counts], i, arr) => (
                  <View key={dept} style={[s.deptRow2, i === arr.length - 1 && s.deptRowLast]}>
                    <Text style={{ fontFamily: "Inter_500Medium", fontSize: 13, color: colors.foreground }}>{dept}</Text>
                    <Text style={{ fontFamily: "Inter_400Regular", fontSize: 13, color: colors.mutedForeground }}>
                      Free: <Text style={{ color: "#388E3C", fontFamily: "Inter_700Bold" }}>{counts.free}</Text>{"  "}
                      Busy: <Text style={{ color: "#D32F2F", fontFamily: "Inter_700Bold" }}>{counts.busy}</Text>
                    </Text>
                  </View>
                ))}
              </View>
            )}

            <View style={s.tabRow}>
              <TouchableOpacity style={[s.tabBtn, activeTab === "free" && s.tabBtnActive]} onPress={() => setActiveTab("free")}>
                <Text style={[s.tabTxt, activeTab === "free" && s.tabTxtActive]}>Free ({result.free.length})</Text>
              </TouchableOpacity>
              <TouchableOpacity style={[s.tabBtn, activeTab === "busy" && s.tabBtnActive]} onPress={() => setActiveTab("busy")}>
                <Text style={[s.tabTxt, activeTab === "busy" && s.tabTxtActive]}>Busy ({result.busy.length})</Text>
              </TouchableOpacity>
            </View>

            {activeTab === "free" ? (
              result.free.length === 0
                ? <Text style={s.emptyTxt}>No free faculty</Text>
                : result.free.map((f) => (
                  <View key={f.name} style={[s.personCard, { borderLeftWidth: 3, borderLeftColor: "#4CAF50" }]}>
                    <Text style={s.personName}>{f.name}</Text>
                    <Text style={s.personDept}>{f.dept}</Text>
                  </View>
                ))
            ) : (
              result.busy.length === 0
                ? <Text style={s.emptyTxt}>No busy faculty</Text>
                : result.busy.map((b) => (
                  <View key={b.name} style={[s.personCard, { borderLeftWidth: 3, borderLeftColor: "#F44336" }]}>
                    <Text style={s.personName}>{b.name}</Text>
                    <Text style={s.personDept}>{b.dept}</Text>
                    {b.records.map((r, i) => (
                      <View key={i} style={s.busyRecord}>
                        <Text style={s.busyTxt}>{r.subject} · {r.cls}</Text>
                        <Text style={[s.busyTxt, { color: colors.mutedForeground }]}>
                          {formatHM(r.start)} – {formatHM(r.end)} · {r.loc} · {r.type}
                        </Text>
                      </View>
                    ))}
                  </View>
                ))
            )}
          </View>
        )}
      </ScrollView>

      <PickerModal
        visible={showFacPicker}
        title="Add Faculty"
        items={availableFaculty}
        selected=""
        onSelect={(v) => {
          setSelectedFaculty((prev) => [...prev, v]);
          setShowFacPicker(true);
        }}
        onClose={() => setShowFacPicker(false)}
        placeholder="Search faculty..."
      />
    </View>
  );
}
