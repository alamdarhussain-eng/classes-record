// Build: 2026-05-09 17:25
import React, { useState, useMemo, useCallback } from "react";
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  TextInput, ActivityIndicator, Platform, Alert,
} from "react-native";
import { useQuery } from "@tanstack/react-query";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useFocusEffect } from "expo-router";
import * as ScreenOrientation from "expo-screen-orientation";
import { printOrShareHtml } from "@/utils/printHtml";

import { useColors } from "@/hooks/useColors";
import { fetchSummary, fetchOptions, SummaryRecord, ScheduleOptions } from "@/hooks/useApi";
import { PickerModal } from "@/components/PickerModal";

const SEM_START = "2026-01-19";

function todayStr() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

const MON_NUM: Record<string, string> = {
  Jan: "01", Feb: "02", Mar: "03", Apr: "04", May: "05", Jun: "06",
  Jul: "07", Aug: "08", Sep: "09", Oct: "10", Nov: "11", Dec: "12",
};

function shortDate(d: string): string {
  return (d || "").split("T")[0];
}

interface FlatRow extends SummaryRecord { dept: string; }

export default function SummaryScreen() {
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

  const [startDate, setStartDate] = useState(SEM_START);
  const [endDate, setEndDate] = useState(todayStr);
  const [deptFilter, setDeptFilter] = useState("ALL");
  const [facFilter, setFacFilter] = useState("");
  const [showFacPicker, setShowFacPicker] = useState(false);

  const { data, isLoading, refetch, isFetching } = useQuery({
    queryKey: ["summary", startDate, endDate],
    queryFn: () => fetchSummary(startDate, endDate),
  });

  const { data: options } = useQuery<ScheduleOptions>({ queryKey: ["options", 4], queryFn: () => fetchOptions(4) });

  const facultyList = useMemo(() => {
    if (data) {
      const names = new Set<string>();
      Object.values(data).forEach((dept) => Object.values(dept).forEach((r) => names.add(r.Faculty)));
      const sorted = [...names].sort();
      if (sorted.length > 0) return sorted;
    }
    return options?.faculty ?? [];
  }, [data, options]);

  const depts = useMemo(() => (data ? ["ALL", ...Object.keys(data).sort()] : ["ALL"]), [data]);

  const rows = useMemo<FlatRow[]>(() => {
    if (!data) return [];
    const out: FlatRow[] = [];
    const selectedDepts = deptFilter === "ALL" ? Object.keys(data) : [deptFilter];
    for (const dept of selectedDepts) {
      for (const rec of Object.values(data[dept] || {})) {
        if (facFilter && rec.Faculty !== facFilter) continue;
        out.push({ ...rec, dept });
      }
    }
    out.sort((a, b) => {
      const diffA = a.GrandTotal - a.ToBeConducted;
      const diffB = b.GrandTotal - b.ToBeConducted;
      if (diffA === 0 && diffB !== 0) return 1;
      if (diffA !== 0 && diffB === 0) return -1;
      if (diffA < 0 && diffB >= 0) return -1;
      if (diffA >= 0 && diffB < 0) return 1;
      return diffA - diffB;
    });
    return out;
  }, [data, deptFilter, facFilter]);

  const totals = useMemo(() => ({
    tbc: rows.reduce((s, r) => s + r.ToBeConducted, 0),
    missed: rows.reduce((s, r) => s + r.Missed, 0),
    makeup: rows.reduce((s, r) => s + r.Makeup, 0),
    late: rows.reduce((s, r) => s + r.Late, 0),
    gt: rows.reduce((s, r) => s + r.GrandTotal, 0),
    deficit: rows.filter((r) => r.GrandTotal < r.ToBeConducted).length,
    surplus: rows.filter((r) => r.GrandTotal > r.ToBeConducted).length,
    onTrack: rows.filter((r) => r.GrandTotal === r.ToBeConducted).length,
  }), [rows]);

  function statusInfo(r: FlatRow) {
    const diff = r.GrandTotal - r.ToBeConducted;
    if (diff < 0) return { color: "#D32F2F", bg: colors.errorBg, label: "Deficit" };
    if (diff > 0) return { color: "#388E3C", bg: colors.surplusBg, label: "Surplus" };
    return { color: colors.mutedForeground, bg: colors.muted, label: "On Track" };
  }

  async function handleDownload() {
    if (rows.length === 0) { Alert.alert("No Data", "Apply filters and load data before downloading."); return; }

    const filterNote = [
      facFilter && `Faculty: ${facFilter}`,
      deptFilter !== "ALL" && `Dept: ${deptFilter}`,
    ].filter(Boolean).join(" · ") || "All Faculty · All Departments";

    const statusColor = (r: FlatRow) => {
      const diff = r.GrandTotal - r.ToBeConducted;
      return diff < 0 ? "#D32F2F" : diff > 0 ? "#388E3C" : "#666";
    };
    const statusLabel = (r: FlatRow) => {
      const diff = r.GrandTotal - r.ToBeConducted;
      return diff < 0 ? "Deficit" : diff > 0 ? "Surplus" : "On Track";
    };

    const dateSub = (dates: string[]) =>
      dates.length > 0
        ? `<div style="font-size:8px;color:#999;margin-top:2px;line-height:1.4">${dates.map(shortDate).join(", ")}</div>`
        : "";

    const tableRows = rows.map((r, i) => {
      const sc = statusColor(r);
      const sl = statusLabel(r);
      const bg = i % 2 === 0 ? "#fff" : "#F9FAFB";
      return `<tr style="background:${bg}">
        <td>${i + 1}</td>
        <td>${r.Faculty}</td>
        <td>${r.Subject}</td>
        <td>${r.Class}</td>
        <td>${r.dept}</td>
        <td class="num">${r.ToBeConducted}</td>
        <td class="num" style="color:#D32F2F">${r.Missed}${dateSub(r.MissedDates)}</td>
        <td class="num" style="color:#388E3C">${r.Makeup}${dateSub(r.MakeupDates)}</td>
        <td class="num" style="color:#FF8F00">${r.Late}${dateSub(r.LateDates)}</td>
        <td class="num bold" style="color:${sc}">${r.GrandTotal}</td>
        <td><span style="color:${sc};font-weight:bold;font-size:10px">${sl}</span></td>
      </tr>`;
    }).join("");

    const html = `<!DOCTYPE html><html><head><meta charset="utf-8"/>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: Arial, sans-serif; font-size: 11px; }
  .hdr { background: #1976D2; color: #fff; padding: 12px 16px; }
  .hdr h1 { font-size: 17px; font-weight: bold; }
  .hdr p { font-size: 10px; opacity: .85; margin-top: 2px; }
  .totals { display: flex; gap: 0; border-bottom: 2px solid #1976D2; background: #E3F2FD; }
  .tot-cell { flex: 1; padding: 8px 12px; border-right: 1px solid #90CAF9; }
  .tot-cell:last-child { border-right: none; }
  .tot-num { font-size: 20px; font-weight: bold; color: #1976D2; }
  .tot-lbl { font-size: 9px; color: #555; margin-top: 1px; }
  table { width: 100%; border-collapse: collapse; margin-top: 0; }
  th { background: #1976D2; color: #fff; padding: 6px 4px; font-size: 10px; text-align: center; border: 1px solid #1565C0; }
  td { border: 1px solid #E0E0E0; padding: 5px 4px; font-size: 10px; vertical-align: middle; }
  .num { text-align: center; }
  .bold { font-weight: bold; }
  th:nth-child(1), td:nth-child(1) { width: 28px; text-align: center; }
  th:nth-child(6), td:nth-child(6),
  th:nth-child(7), td:nth-child(7),
  th:nth-child(8), td:nth-child(8),
  th:nth-child(9), td:nth-child(9),
  th:nth-child(10), td:nth-child(10) { width: 48px; }
  th:nth-child(11), td:nth-child(11) { width: 60px; text-align: center; }
</style></head><body>
<div class="hdr">
  <h1>Teaching Summary</h1>
  <p>${filterNote} &nbsp;·&nbsp; ${startDate} to ${endDate} &nbsp;·&nbsp; Generated ${new Date().toLocaleDateString("en-PK", { weekday:"long", year:"numeric", month:"long", day:"numeric" })}</p>
</div>
<div class="totals">
  <div class="tot-cell"><div class="tot-num">${totals.tbc}</div><div class="tot-lbl">To Be Conducted</div></div>
  <div class="tot-cell"><div class="tot-num" style="color:#D32F2F">${totals.missed}</div><div class="tot-lbl">Missed</div></div>
  <div class="tot-cell"><div class="tot-num" style="color:#388E3C">${totals.makeup}</div><div class="tot-lbl">Makeup</div></div>
  <div class="tot-cell"><div class="tot-num" style="color:#FF8F00">${totals.late}</div><div class="tot-lbl">Late</div></div>
  <div class="tot-cell"><div class="tot-num">${totals.gt}</div><div class="tot-lbl">Grand Total</div></div>
  <div class="tot-cell"><div class="tot-num" style="color:#D32F2F">${totals.deficit}</div><div class="tot-lbl">Deficit</div></div>
  <div class="tot-cell"><div class="tot-num" style="color:#388E3C">${totals.surplus}</div><div class="tot-lbl">Surplus</div></div>
  <div class="tot-cell"><div class="tot-num">${totals.onTrack}</div><div class="tot-lbl">On Track</div></div>
</div>
<table>
  <thead><tr>
    <th>#</th><th>Faculty</th><th>Subject</th><th>Class</th><th>Dept</th>
    <th>TBC</th><th>Missed</th><th>Makeup</th><th>Late</th><th>Total</th><th>Status</th>
  </tr></thead>
  <tbody>${tableRows}</tbody>
</table>
</body></html>`;

    try {
      await printOrShareHtml(html, "Save Teaching Summary PDF");
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
    filterSection: { backgroundColor: colors.card, padding: 12, borderBottomWidth: 1, borderBottomColor: colors.border },
    dateRow: { flexDirection: "row", gap: 8, marginBottom: 8 },
    dateInput: {
      flex: 1, backgroundColor: colors.muted, borderRadius: 8, paddingHorizontal: 10, paddingVertical: 8,
      fontFamily: "Inter_400Regular", fontSize: 13, color: colors.foreground,
      borderWidth: 1, borderColor: colors.border,
    },
    quickBtns: { flexDirection: "row", gap: 6, marginBottom: 8 },
    quickBtn: {
      paddingHorizontal: 10, paddingVertical: 6, borderRadius: 8, borderWidth: 1,
      borderColor: colors.border, backgroundColor: colors.muted,
    },
    quickBtnTxt: { fontFamily: "Inter_500Medium", fontSize: 12, color: colors.mutedForeground },
    applyBtn: { backgroundColor: colors.primary, borderRadius: 8, padding: 10, alignItems: "center" },
    applyBtnTxt: { color: "#fff", fontFamily: "Inter_600SemiBold", fontSize: 14 },
    facPickerBtn: {
      flexDirection: "row", alignItems: "center", gap: 8,
      backgroundColor: colors.muted, borderRadius: 8,
      paddingHorizontal: 10, paddingVertical: 8,
      borderWidth: 1, borderColor: colors.border, marginTop: 8,
    },
    facPickerBtnActive: { borderColor: colors.primary, backgroundColor: colors.secondary },
    facPickerTxt: { flex: 1, fontFamily: "Inter_400Regular", fontSize: 13, color: colors.mutedForeground },
    facPickerTxtActive: { color: colors.foreground, fontFamily: "Inter_500Medium" },
    deptRow: {
      flexDirection: "row", gap: 8, paddingHorizontal: 12, paddingVertical: 8,
      backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    deptBtn: { paddingHorizontal: 12, paddingVertical: 6, borderRadius: 20, borderWidth: 1, borderColor: colors.border, backgroundColor: colors.muted },
    deptBtnActive: { backgroundColor: colors.primary, borderColor: colors.primary },
    deptTxt: { fontFamily: "Inter_500Medium", fontSize: 12, color: colors.mutedForeground },
    deptTxtActive: { color: "#fff" },
    summaryBar: {
      flexDirection: "row", paddingHorizontal: 16, paddingVertical: 10,
      backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border, gap: 16,
    },
    summaryChip: { alignItems: "center" },
    summaryChipNum: { fontSize: 18, fontFamily: "Inter_700Bold" },
    summaryChipLbl: { fontSize: 10, fontFamily: "Inter_400Regular", color: colors.mutedForeground },
    scroll: { flex: 1 },
    card: {
      backgroundColor: colors.card, marginHorizontal: 12, marginTop: 10,
      borderRadius: 12, borderWidth: 1, borderColor: colors.border, overflow: "hidden",
    },
    cardHeader: { paddingHorizontal: 14, paddingTop: 12, paddingBottom: 8 },
    cardTitle: { fontSize: 15, fontFamily: "Inter_700Bold", color: colors.foreground },
    cardSub: { fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginTop: 2 },
    statsRow: { flexDirection: "row", borderTopWidth: 1, borderTopColor: colors.border },
    stat: { flex: 1, alignItems: "center", paddingVertical: 10, borderRightWidth: 1, borderRightColor: colors.border },
    statNum: { fontSize: 18, fontFamily: "Inter_700Bold", color: colors.foreground },
    statLbl: { fontSize: 9, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginTop: 1 },
    statusTag: {
      flexDirection: "row", alignItems: "center", paddingHorizontal: 12, paddingVertical: 6,
      borderTopWidth: 1, borderTopColor: colors.border, gap: 6,
    },
    statusDot: { width: 8, height: 8, borderRadius: 4 },
    statusTxt: { fontSize: 12, fontFamily: "Inter_600SemiBold" },
    totalsCard: {
      backgroundColor: "#E8F4FD", marginHorizontal: 12, marginTop: 10,
      borderRadius: 12, padding: 14, borderWidth: 1, borderColor: "#B3D9F0",
    },
    totalTitle: { fontSize: 13, fontFamily: "Inter_700Bold", color: colors.primary, marginBottom: 8 },
    totalRow: { flexDirection: "row", justifyContent: "space-between", paddingVertical: 2 },
    totalLabel: { fontSize: 13, fontFamily: "Inter_400Regular", color: colors.foreground },
    totalValue: { fontSize: 13, fontFamily: "Inter_700Bold", color: colors.foreground },
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
          <TouchableOpacity style={s.homeBtn} onPress={handleDownload}>
            <Feather name="download" size={13} color="#fff" />
            <Text style={s.homeBtnTxt}>Download</Text>
          </TouchableOpacity>
        </View>
        <Text style={s.headerTitle}>Teaching Summary</Text>
        <Text style={s.headerSub}>{rows.length} records · {deptFilter === "ALL" ? "All Departments" : deptFilter}</Text>
      </View>

      <ScrollView
        style={s.scroll}
        contentContainerStyle={{ paddingBottom: 60 }}
        keyboardShouldPersistTaps="handled"
      >
        {/* ── Filters ── */}
        <View style={s.filterSection}>
          <View style={s.dateRow}>
            <TextInput style={s.dateInput} value={startDate} onChangeText={setStartDate} placeholder="Start YYYY-MM-DD" placeholderTextColor={colors.mutedForeground} />
            <TextInput style={s.dateInput} value={endDate} onChangeText={setEndDate} placeholder="End YYYY-MM-DD" placeholderTextColor={colors.mutedForeground} />
          </View>
          <View style={s.quickBtns}>
            {[
              { label: "Today", fn: () => { const t = todayStr(); setStartDate(t); setEndDate(t); } },
              { label: "Last Week", fn: () => { const e = new Date(); const s2 = new Date(); s2.setDate(s2.getDate() - 7); setStartDate(`${s2.getFullYear()}-${String(s2.getMonth() + 1).padStart(2, "0")}-${String(s2.getDate()).padStart(2, "0")}`); setEndDate(todayStr()); } },
              { label: "Since Sem Start", fn: () => { setStartDate(SEM_START); setEndDate(todayStr()); } },
            ].map(({ label, fn }) => (
              <TouchableOpacity key={label} style={s.quickBtn} onPress={() => { fn(); setTimeout(() => refetch(), 100); }}>
                <Text style={s.quickBtnTxt}>{label}</Text>
              </TouchableOpacity>
            ))}
          </View>

          <TouchableOpacity
            style={[s.facPickerBtn, facFilter && s.facPickerBtnActive]}
            onPress={() => setShowFacPicker(true)}
          >
            <Feather name="user" size={14} color={facFilter ? colors.primary : colors.mutedForeground} />
            <Text style={[s.facPickerTxt, facFilter && s.facPickerTxtActive]} numberOfLines={1}>
              {facFilter || "All Faculty  (tap to filter)"}
            </Text>
            {facFilter ? (
              <TouchableOpacity onPress={() => setFacFilter("")}>
                <Feather name="x-circle" size={16} color={colors.primary} />
              </TouchableOpacity>
            ) : (
              <Feather name="chevron-down" size={14} color={colors.mutedForeground} />
            )}
          </TouchableOpacity>

          <TouchableOpacity style={[s.applyBtn, { marginTop: 8 }]} onPress={() => refetch()}>
            {isFetching ? <ActivityIndicator color="#fff" size="small" /> : <Text style={s.applyBtnTxt}>Apply Date Filter</Text>}
          </TouchableOpacity>
        </View>

        {/* ── Dept tabs ── */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={{ backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border }}>
          <View style={s.deptRow}>
            {depts.map((d) => (
              <TouchableOpacity key={d} style={[s.deptBtn, deptFilter === d && s.deptBtnActive]} onPress={() => setDeptFilter(d)}>
                <Text style={[s.deptTxt, deptFilter === d && s.deptTxtActive]}>{d}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </ScrollView>

        {/* ── Stats bar ── */}
        {rows.length > 0 && (
          <View style={s.summaryBar}>
            {[
              { num: totals.deficit, lbl: "Deficit", color: "#D32F2F" },
              { num: totals.surplus, lbl: "Surplus", color: "#388E3C" },
              { num: totals.onTrack, lbl: "On Track", color: colors.mutedForeground },
              { num: totals.missed, lbl: "Missed", color: colors.destructive },
              { num: totals.makeup, lbl: "Makeup", color: colors.success },
            ].map(({ num, lbl, color }) => (
              <View key={lbl} style={s.summaryChip}>
                <Text style={[s.summaryChipNum, { color }]}>{num}</Text>
                <Text style={s.summaryChipLbl}>{lbl}</Text>
              </View>
            ))}
          </View>
        )}

        {/* ── Content ── */}
        {isLoading ? (
          <ActivityIndicator size="large" color={colors.primary} style={{ marginTop: 40 }} />
        ) : rows.length === 0 ? (
          <View style={{ alignItems: "center", marginTop: 60 }}>
            <Feather name="inbox" size={48} color={colors.mutedForeground} />
            <Text style={{ color: colors.mutedForeground, fontFamily: "Inter_400Regular", marginTop: 12, fontSize: 15 }}>No records found</Text>
          </View>
        ) : (
          <>
            <View style={s.totalsCard}>
              <Text style={s.totalTitle}>TOTALS</Text>
              {[["To Be Conducted", totals.tbc], ["Missed", totals.missed], ["Makeup", totals.makeup], ["Late", totals.late], ["Grand Total", totals.gt]].map(([lbl, val]) => (
                <View key={lbl as string} style={s.totalRow}>
                  <Text style={s.totalLabel}>{lbl}</Text>
                  <Text style={s.totalValue}>{val}</Text>
                </View>
              ))}
            </View>

            {rows.map((r, i) => {
              const st = statusInfo(r);
              return (
                <View key={i} style={[s.card, { backgroundColor: st.bg }]}>
                  <View style={s.cardHeader}>
                    <Text style={s.cardTitle}>{r.Subject}</Text>
                    <Text style={s.cardSub}>{r.Faculty} · {r.Class} · {r.dept} · {r.CreditHrs} hrs</Text>
                  </View>
                  <View style={s.statsRow}>
                    {[["TBC", r.ToBeConducted], ["Missed", r.Missed], ["Makeup", r.Makeup], ["Late", r.Late], ["Total", r.GrandTotal]].map(([lbl, val], j, arr) => (
                      <View key={lbl as string} style={[s.stat, j === arr.length - 1 && { borderRightWidth: 0 }]}>
                        <Text style={[s.statNum, lbl === "Total" && { color: r.GrandTotal < r.ToBeConducted ? "#D32F2F" : r.GrandTotal > r.ToBeConducted ? "#388E3C" : colors.foreground }]}>{val}</Text>
                        <Text style={s.statLbl}>{lbl}</Text>
                      </View>
                    ))}
                  </View>
                  <View style={[s.statusTag, { backgroundColor: st.bg }]}>
                    <View style={[s.statusDot, { backgroundColor: st.color }]} />
                    <Text style={[s.statusTxt, { color: st.color }]}>{st.label}</Text>
                  </View>
                  {(r.MissedDates.length > 0 || r.MakeupDates.length > 0 || r.LateDates.length > 0) && (
                    <View style={{ paddingHorizontal: 12, paddingBottom: 8, gap: 2 }}>
                      {r.MissedDates.length > 0 && (
                        <Text style={{ fontSize: 11, color: "#D32F2F", fontFamily: "Inter_400Regular" }}>
                          Missed: {r.MissedDates.map(shortDate).join(", ")}
                        </Text>
                      )}
                      {r.MakeupDates.length > 0 && (
                        <Text style={{ fontSize: 11, color: "#388E3C", fontFamily: "Inter_400Regular" }}>
                          Makeup: {r.MakeupDates.map(shortDate).join(", ")}
                        </Text>
                      )}
                      {r.LateDates.length > 0 && (
                        <Text style={{ fontSize: 11, color: "#FF8F00", fontFamily: "Inter_400Regular" }}>
                          Late: {r.LateDates.map(shortDate).join(", ")}
                        </Text>
                      )}
                    </View>
                  )}
                </View>
              );
            })}
          </>
        )}
      </ScrollView>

      <PickerModal
        visible={showFacPicker}
        title="Filter by Faculty"
        items={facultyList}
        selected={facFilter}
        onSelect={(v) => setFacFilter(v)}
        onClose={() => setShowFacPicker(false)}
        placeholder="Search faculty..."
      />
    </View>
  );
}
