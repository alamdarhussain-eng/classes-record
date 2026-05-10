import React, { useState, useMemo, useCallback } from "react";
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  Modal, ActivityIndicator, Platform, Alert, useWindowDimensions,
} from "react-native";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useFocusEffect, useLocalSearchParams } from "expo-router";
import * as ScreenOrientation from "expo-screen-orientation";
import { printOrShareHtml } from "@/utils/printHtml";

import { useColors } from "@/hooks/useColors";
import {
  fetchSchedule, fetchOptions, addScheduleEntry, deleteScheduleRow,
  importScheduleExcel, importOptionsExcel, ScheduleRow, ScheduleOptions,
} from "@/hooks/useApi";
import { PickerModal } from "@/components/PickerModal";
import { ExcelImportButton, ImportPanel } from "@/components/ExcelImportButton";

const DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri"];
const DAY_FULL: Record<string, string> = {
  Mon: "Monday", Tue: "Tuesday", Wed: "Wednesday", Thu: "Thursday", Fri: "Friday",
};
const HOURS = Array.from({ length: 9 }, (_, i) => i + 9);
const TIME_SLOTS = HOURS.map((h) => {
  const fmt = (n: number) =>
    n < 12 ? `${n.toString().padStart(2, "0")}:00 AM`
    : n === 12 ? "12:00 PM"
    : `${(n - 12).toString().padStart(2, "0")}:00 PM`;
  return { label: `${fmt(h)}–${fmt(h + 1)}`, shortLabel: fmt(h), hour: h };
});

function normalizeDay(d: string): string {
  const l = d?.toLowerCase() ?? "";
  if (l.startsWith("mon")) return "Mon";
  if (l.startsWith("tue")) return "Tue";
  if (l.startsWith("wed")) return "Wed";
  if (l.startsWith("thu")) return "Thu";
  if (l.startsWith("fri")) return "Fri";
  return "";
}

function formatHour(h: number): string {
  const t12 = (h % 12) || 12;
  return `${t12.toString().padStart(2, "0")}:00 ${h >= 12 ? "PM" : "AM"}`;
}

interface AddForm {
  faculty: string; subject: string; className: string; dept: string;
  day: string; location: string; timeStart: string; timeEnd: string;
  lecLab: string; elective: string;
}
const LAB_OPTIONS = ["Lec", "Lab"];
const ELECTIVE_OPTIONS = [{ label: "Regular", value: "" }, { label: "Elective", value: "Elective" }];
const HOUR_OPTIONS = Array.from({ length: 9 }, (_, i) => formatHour(i + 9));

type PickerField = "faculty" | "subject" | "className" | "dept" | "location"
  | "filterFaculty" | "filterClass" | null;

const EMPTY_FORM: AddForm = {
  faculty: "", subject: "", className: "", dept: "",
  day: "Mon", location: "", timeStart: "09:00 AM", timeEnd: "10:00 AM",
  lecLab: "Lec", elective: "",
};

function MiniCard({ row, colors }: { row: ScheduleRow; colors: ReturnType<typeof useColors> }) {
  const isMakeup = row.Type === "Makeup";
  return (
    <View style={{
      backgroundColor: isMakeup ? colors.successBg : colors.secondary,
      borderRadius: 6, padding: 4, marginBottom: 3,
      borderLeftWidth: 3, borderLeftColor: isMakeup ? "#4CAF50" : colors.primary,
    }}>
      <Text numberOfLines={2} style={{ fontSize: 11, fontFamily: "Inter_600SemiBold", color: colors.foreground }}>
        {row.Subject}
      </Text>
      <Text numberOfLines={1} style={{ fontSize: 10, fontFamily: "Inter_400Regular", color: colors.mutedForeground }}>
        {row.Class}
      </Text>
      {row.Location ? (
        <Text numberOfLines={1} style={{ fontSize: 9, fontFamily: "Inter_400Regular", color: colors.primary }}>
          {row.Location}
        </Text>
      ) : null}
      {isMakeup ? (
        <Text style={{ fontSize: 9, fontFamily: "Inter_600SemiBold", color: "#4CAF50" }}>
          {row.EntryDate ? `MAKEUP · ${row.EntryDate.split("T")[0]}` : "MAKEUP"}
        </Text>
      ) : null}
    </View>
  );
}

export default function ScheduleScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const qc = useQueryClient();
  const router = useRouter();
  const { width: screenWidth } = useWindowDimensions();
  const { scheduleId: scheduleIdParam, scheduleTitle } = useLocalSearchParams<{ scheduleId?: string; scheduleTitle?: string }>();
  const scheduleId = scheduleIdParam ? Number(scheduleIdParam) : undefined;

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

  const [classFilter, setClassFilter] = useState("");
  const [facFilter, setFacFilter] = useState("");
  const [showAdd, setShowAdd] = useState(false);
  const [showImport, setShowImport] = useState(false);
  const [activePicker, setActivePicker] = useState<PickerField>(null);
  const [form, setForm] = useState<AddForm>(EMPTY_FORM);

  const { data: rows = [], isLoading } = useQuery({ queryKey: ["schedule", scheduleId], queryFn: () => fetchSchedule(scheduleId) });
  const { data: options } = useQuery<ScheduleOptions>({ queryKey: ["options", scheduleId], queryFn: () => fetchOptions(scheduleId) });

  const addMutation = useMutation({
    mutationFn: (data: Parameters<typeof addScheduleEntry>[0]) => addScheduleEntry({ ...data, scheduleId }),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["schedule", scheduleId] }); setShowAdd(false); setForm(EMPTY_FORM); },
    onError: () => Alert.alert("Error", "Failed to save schedule entry"),
  });
  const deleteMutation = useMutation({
    mutationFn: deleteScheduleRow,
    onSuccess: () => qc.invalidateQueries({ queryKey: ["schedule", scheduleId] }),
  });

  const allClasses = useMemo(() => {
    const fromDB = [...new Set(rows.filter((r) => !r.Type).map((r) => r.Class))].sort();
    const fromOpts = options?.classes ?? [];
    return [...new Set([...fromDB, ...fromOpts])].sort();
  }, [rows, options]);

  const allFaculty = useMemo(() => {
    const fromDB = [...new Set(rows.filter((r) => !r.Type).map((r) => r.Faculty))].sort();
    const fromOpts = options?.faculty ?? [];
    return [...new Set([...fromDB, ...fromOpts])].sort();
  }, [rows, options]);

  const formSubjects = useMemo(() => {
    if (!options || !form.faculty) return options?.subjects ?? [];
    return options.facSubjects[form.faculty] ?? options.subjects;
  }, [options, form.faculty]);

  const formClasses = useMemo(() => {
    if (!options || !form.faculty || !form.subject) return options?.classes ?? [];
    const key = form.faculty + "|||" + form.subject;
    return options.facSubClasses[key] ?? options.classes;
  }, [options, form.faculty, form.subject]);

  const formLocations = useMemo(() => {
    if (form.className && options?.classInfo?.[form.className]?.locations?.length)
      return options.classInfo[form.className].locations;
    return options?.locations ?? [];
  }, [options, form.className]);

  function setField<K extends keyof AddForm>(key: K, value: AddForm[K]) {
    setForm((prev) => {
      const next = { ...prev, [key]: value };
      if (key === "faculty") { next.subject = ""; next.className = ""; next.dept = ""; next.location = ""; }
      if (key === "subject") { next.className = ""; next.dept = ""; next.location = ""; }
      if (key === "className" && options?.classInfo?.[value as string]) {
        const info = options.classInfo[value as string];
        next.dept = info.dept;
        next.location = info.locations[0] ?? "";
      }
      return next;
    });
  }

  const allDaysGrid = useMemo(() => {
    const today = new Date(); today.setHours(0, 0, 0, 0);
    const filtered = rows.filter((r) => {
      if (classFilter && r.Class !== classFilter) return false;
      if (facFilter && r.Faculty !== facFilter) return false;
      return true;
    });
    const map: Record<number, Record<string, ScheduleRow[]>> = {};
    HOURS.forEach((h) => {
      map[h] = { Mon: [], Tue: [], Wed: [], Thu: [], Fri: [] };
    });
    filtered.forEach((r) => {
      let day = normalizeDay(r.Day);
      if (!day && r.Type === "Makeup" && r.EntryDate) {
        const d = new Date(r.EntryDate);
        day = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][d.getDay()];
      }
      if (!DAYS.includes(day)) return;
      if (r.Type === "Missed" || r.Type === "Late") return;
      if (r.Type === "Makeup" && r.EntryDate) {
        const d = new Date(r.EntryDate); d.setHours(0, 0, 0, 0);
        if (d < today) return;
      }
      const h = Math.floor((r.SortKey || 0) / 60);
      if (map[h]?.[day]) map[h][day].push(r);
    });
    return map;
  }, [rows, classFilter, facFilter]);

  async function handleDownload() {
    const today = new Date(); today.setHours(0, 0, 0, 0);

    const filtered = rows.filter((r) => {
      if (classFilter && r.Class !== classFilter) return false;
      if (facFilter && r.Faculty !== facFilter) return false;
      if (r.Type === "Missed" || r.Type === "Late") return false;
      if (r.Type === "Makeup" && r.EntryDate) {
        const d = new Date(r.EntryDate); d.setHours(0, 0, 0, 0);
        if (d < today) return false;
      }
      return true;
    });

    const gridMap: Record<number, Record<string, ScheduleRow[]>> = {};
    HOURS.forEach((h) => { gridMap[h] = { Mon: [], Tue: [], Wed: [], Thu: [], Fri: [] }; });
    filtered.forEach((r) => {
      let day = normalizeDay(r.Day);
      if (!day && r.Type === "Makeup" && r.EntryDate) {
        const d = new Date(r.EntryDate);
        day = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][d.getDay()];
      }
      if (!DAYS.includes(day)) return;
      const h = Math.floor((r.SortKey || 0) / 60);
      if (gridMap[h]?.[day]) gridMap[h][day].push(r);
    });

    const filterNote = [classFilter && `Class: ${classFilter}`, facFilter && `Faculty: ${facFilter}`]
      .filter(Boolean).join(" · ") || "All Classes · All Faculty";

    const cellHtml = (entries: ScheduleRow[]) => {
      if (entries.length === 0) return `<span class="free">—</span>`;
      return entries.map((e) => `
        <div class="card${e.Type === "Makeup" ? " makeup" : ""}">
          <div class="subj">${e.Subject}</div>
          <div class="cls">${e.Class}</div>
          <div class="fac">${e.Faculty}</div>
          ${e.Location ? `<div class="loc">📍 ${e.Location}</div>` : ""}
          ${e.Type === "Makeup" ? `<div class="badge">MAKEUP</div>` : ""}
        </div>`).join("");
    };

    const rowsHtml = TIME_SLOTS.map((slot) => {
      const isBreak = slot.hour === 13;
      const dayMap = gridMap[slot.hour] ?? {};
      return `
        <tr class="${isBreak ? "break-row" : ""}">
          <td class="time-cell">${slot.shortLabel}${isBreak ? "<br/><small>BREAK</small>" : ""}</td>
          ${DAYS.map((d) => `<td class="day-cell">${cellHtml(dayMap[d] ?? [])}</td>`).join("")}
        </tr>`;
    }).join("");

    const html = `<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: Arial, sans-serif; font-size: 11px; background: #fff; }
  .header { background: #1976D2; color: #fff; padding: 12px 16px; }
  .header h1 { font-size: 18px; font-weight: bold; }
  .header p  { font-size: 11px; opacity: 0.85; margin-top: 2px; }
  table { width: 100%; border-collapse: collapse; }
  thead th { background: #1976D2; color: #fff; padding: 7px 4px; font-size: 12px; font-weight: bold; text-align: center; border: 1px solid #1565C0; }
  thead th.time-h { width: 72px; }
  td { border: 1px solid #ddd; vertical-align: top; padding: 4px 3px; }
  .time-cell { background: #F5F5F5; font-size: 9px; font-weight: bold; color: #555; text-align: center; width: 72px; vertical-align: middle; }
  .day-cell { width: calc((100% - 72px) / 5); }
  .break-row td { background: #FFF8E1; }
  .break-row .time-cell { color: #856404; }
  .card { background: #E3F2FD; border-left: 3px solid #1976D2; border-radius: 4px; padding: 3px 4px; margin-bottom: 3px; }
  .card.makeup { background: #E8F5E9; border-left-color: #4CAF50; }
  .subj { font-weight: bold; font-size: 10px; color: #1a1a1a; }
  .cls  { font-size: 9px; color: #444; margin-top: 1px; }
  .fac  { font-size: 9px; color: #666; }
  .loc  { font-size: 9px; color: #1976D2; margin-top: 1px; }
  .badge { display: inline-block; background: #4CAF50; color: #fff; border-radius: 3px; font-size: 8px; font-weight: bold; padding: 1px 4px; margin-top: 2px; }
  .free { color: #ccc; font-size: 13px; display: block; text-align: center; padding: 6px 0; }
</style>
</head>
<body>
  <div class="header">
    <h1>Weekly Schedule</h1>
    <p>${filterNote} &nbsp;·&nbsp; Generated ${new Date().toLocaleDateString("en-PK", { weekday:"long", year:"numeric", month:"long", day:"numeric" })}</p>
  </div>
  <table>
    <thead>
      <tr>
        <th class="time-h">Time</th>
        ${DAYS.map((d) => `<th>${d}<br/><small style="font-weight:normal;opacity:.8">${DAY_FULL[d]}</small></th>`).join("")}
      </tr>
    </thead>
    <tbody>${rowsHtml}</tbody>
  </table>
</body>
</html>`;

    try {
      await printOrShareHtml(html, "Save Weekly Schedule PDF");
    } catch (e) {
      Alert.alert("Error", "Could not generate PDF. Please try again.");
    }
  }

  const TIME_COL_W = 58;
  const AVAIL_W = screenWidth - TIME_COL_W - (insets.left + insets.right) - 2;
  const DAY_COL_W = Math.floor(AVAIL_W / 5);

  const s = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    header: {
      backgroundColor: colors.primary,
      paddingTop: insets.top + (Platform.OS === "web" ? 67 : 0),
      paddingBottom: 10, paddingHorizontal: 14,
    },
    topRow: { flexDirection: "row", alignItems: "center", justifyContent: "space-between", marginBottom: 8 },
    homeBtn: {
      flexDirection: "row", alignItems: "center", gap: 5,
      backgroundColor: "rgba(255,255,255,0.2)", borderRadius: 20,
      paddingHorizontal: 12, paddingVertical: 6,
    },
    homeBtnTxt: { color: "#fff", fontFamily: "Inter_600SemiBold", fontSize: 13 },
    actionBtns: { flexDirection: "row", gap: 8 },
    actionBtn: {
      flexDirection: "row", alignItems: "center", gap: 6,
      backgroundColor: "rgba(255,255,255,0.2)", borderRadius: 8,
      paddingHorizontal: 12, paddingVertical: 7,
    },
    actionBtnTxt: { color: "#fff", fontFamily: "Inter_600SemiBold", fontSize: 13 },
    titleRow: { marginBottom: 8 },
    headerTitle: { color: "#fff", fontSize: 20, fontFamily: "Inter_700Bold" },
    headerSub: { color: "rgba(255,255,255,0.8)", fontSize: 12, fontFamily: "Inter_400Regular", marginTop: 1 },
    filtersRow: { flexDirection: "row", gap: 8 },
    filterBtn: {
      flex: 1, backgroundColor: "rgba(255,255,255,0.2)", borderRadius: 8,
      paddingHorizontal: 10, paddingVertical: 7,
      flexDirection: "row", alignItems: "center", gap: 6,
    },
    filterBtnActive: { backgroundColor: "rgba(255,255,255,0.35)" },
    filterBtnText: { color: "rgba(255,255,255,0.75)", fontFamily: "Inter_400Regular", fontSize: 13, flex: 1 },
    filterBtnTextActive: { color: "#fff", fontFamily: "Inter_500Medium" },
    filterClear: { padding: 2 },
    gridContainer: { flex: 1 },
    gridHeader: {
      flexDirection: "row", backgroundColor: colors.card,
      borderBottomWidth: 2, borderBottomColor: colors.primary,
    },
    gridHeaderTimeCell: {
      width: TIME_COL_W, paddingVertical: 8, alignItems: "center", justifyContent: "center",
      borderRightWidth: 1, borderRightColor: colors.border,
    },
    gridHeaderDayCell: {
      width: DAY_COL_W, paddingVertical: 8, alignItems: "center", justifyContent: "center",
      borderRightWidth: 1, borderRightColor: colors.border,
    },
    gridHeaderTxt: { fontSize: 13, fontFamily: "Inter_700Bold", color: colors.foreground },
    gridRow: { flexDirection: "row", borderBottomWidth: 1, borderBottomColor: colors.border },
    gridBreakRow: { backgroundColor: "#FFF8E1" },
    gridTimeCell: {
      width: TIME_COL_W, paddingVertical: 6, paddingHorizontal: 3,
      alignItems: "center", justifyContent: "center",
      borderRightWidth: 1, borderRightColor: colors.border,
      backgroundColor: colors.muted,
    },
    gridTimeTxt: { fontSize: 9, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground, textAlign: "center" },
    gridBreakTimeTxt: { color: "#856404" },
    gridDayCell: {
      width: DAY_COL_W, paddingVertical: 4, paddingHorizontal: 3,
      borderRightWidth: 1, borderRightColor: colors.border,
      justifyContent: "center",
    },
    freeDash: { textAlign: "center", fontSize: 12, color: colors.border, fontFamily: "Inter_400Regular" },
    fab: {
      position: "absolute", right: 20, bottom: 20,
      width: 54, height: 54, borderRadius: 27, backgroundColor: colors.primary,
      alignItems: "center", justifyContent: "center",
      shadowColor: "#000", shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.3, shadowRadius: 4, elevation: 5,
    },
    modalOverlay: { flex: 1, backgroundColor: "rgba(0,0,0,0.5)", justifyContent: "flex-end" },
    sheet: {
      backgroundColor: colors.card, borderTopLeftRadius: 20, borderTopRightRadius: 20,
      paddingHorizontal: 20, paddingTop: 20, paddingBottom: insets.bottom + 20, maxHeight: "92%",
    },
    sheetTitle: { fontSize: 18, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 4 },
    sheetSub: { fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginBottom: 16 },
    label: { fontSize: 12, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground, marginBottom: 4, marginTop: 14, textTransform: "uppercase", letterSpacing: 0.5 },
    pickerBtn: {
      backgroundColor: colors.muted, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12,
      borderWidth: 1, borderColor: colors.border, flexDirection: "row", alignItems: "center", justifyContent: "space-between",
    },
    pickerBtnActive: { borderColor: colors.primary, backgroundColor: colors.secondary },
    pickerBtnText: { fontFamily: "Inter_400Regular", fontSize: 14, color: colors.mutedForeground, flex: 1 },
    pickerBtnTextActive: { color: colors.foreground, fontFamily: "Inter_500Medium" },
    optRow: { flexDirection: "row", gap: 8, flexWrap: "wrap", marginTop: 4 },
    optBtn: { paddingHorizontal: 14, paddingVertical: 9, borderRadius: 8, borderWidth: 1, borderColor: colors.border, backgroundColor: colors.card },
    optBtnActive: { backgroundColor: colors.primary, borderColor: colors.primary },
    optTxt: { fontFamily: "Inter_500Medium", fontSize: 13, color: colors.foreground },
    optTxtActive: { color: "#fff" },
    saveBtn: { backgroundColor: colors.primary, borderRadius: 12, padding: 14, alignItems: "center", marginTop: 20 },
    saveBtnDisabled: { opacity: 0.5 },
    saveBtnTxt: { color: "#fff", fontFamily: "Inter_700Bold", fontSize: 16 },
    divider: { height: 1, backgroundColor: colors.border, marginVertical: 16 },
  });

  const pickerConfigs = {
    faculty: { title: "Select Faculty", items: options?.faculty ?? [], field: "faculty" as keyof AddForm },
    subject: { title: "Select Subject", items: formSubjects, field: "subject" as keyof AddForm },
    className: { title: "Select Class", items: formClasses, field: "className" as keyof AddForm },
    dept: { title: "Select Department", items: options?.depts ?? [], field: "dept" as keyof AddForm },
    location: { title: "Select Location", items: formLocations, field: "location" as keyof AddForm },
  };

  return (
    <View style={s.container}>
      <View style={s.header}>
        <View style={s.topRow}>
          <TouchableOpacity style={s.homeBtn} onPress={() => scheduleId ? router.back() : router.replace("/")}>
            <Feather name={scheduleId ? "arrow-left" : "home"} size={13} color="#fff" />
            <Text style={s.homeBtnTxt}>{scheduleId ? "Back" : "Home"}</Text>
          </TouchableOpacity>
          <View style={s.actionBtns}>
            <TouchableOpacity style={s.actionBtn} onPress={() => setShowImport(true)}>
              <Feather name="upload" size={15} color="#fff" />
              <Text style={s.actionBtnTxt}>Upload</Text>
            </TouchableOpacity>
            <TouchableOpacity style={s.actionBtn} onPress={handleDownload}>
              <Feather name="download" size={15} color="#fff" />
              <Text style={s.actionBtnTxt}>Download</Text>
            </TouchableOpacity>
          </View>
        </View>
        <View style={s.titleRow}>
          <Text style={s.headerTitle}>{scheduleTitle ? decodeURIComponent(scheduleTitle) : "Weekly Schedule"}</Text>
          <Text style={s.headerSub}>{scheduleId ? "Private schedule — Mon to Fri timetable" : "All 5 days — Mon to Fri timetable"}</Text>
        </View>
        <View style={s.filtersRow}>
          <TouchableOpacity style={[s.filterBtn, classFilter && s.filterBtnActive]} onPress={() => setActivePicker("filterClass")}>
            <Feather name="users" size={13} color="rgba(255,255,255,0.75)" />
            <Text style={[s.filterBtnText, classFilter && s.filterBtnTextActive]} numberOfLines={1}>
              {classFilter || "All Classes"}
            </Text>
            {classFilter
              ? <TouchableOpacity style={s.filterClear} onPress={() => setClassFilter("")}><Feather name="x" size={13} color="#fff" /></TouchableOpacity>
              : <Feather name="chevron-down" size={13} color="rgba(255,255,255,0.75)" />}
          </TouchableOpacity>
          <TouchableOpacity style={[s.filterBtn, facFilter && s.filterBtnActive]} onPress={() => setActivePicker("filterFaculty")}>
            <Feather name="user" size={13} color="rgba(255,255,255,0.75)" />
            <Text style={[s.filterBtnText, facFilter && s.filterBtnTextActive]} numberOfLines={1}>
              {facFilter || "All Faculty"}
            </Text>
            {facFilter
              ? <TouchableOpacity style={s.filterClear} onPress={() => setFacFilter("")}><Feather name="x" size={13} color="#fff" /></TouchableOpacity>
              : <Feather name="chevron-down" size={13} color="rgba(255,255,255,0.75)" />}
          </TouchableOpacity>
        </View>
      </View>

      {isLoading ? (
        <ActivityIndicator size="large" color={colors.primary} style={{ marginTop: 40 }} />
      ) : (
        <View style={s.gridContainer}>
          <View style={s.gridHeader}>
            <View style={s.gridHeaderTimeCell}>
              <Text style={[s.gridHeaderTxt, { fontSize: 10 }]}>Time</Text>
            </View>
            {DAYS.map((d) => (
              <View key={d} style={s.gridHeaderDayCell}>
                <Text style={s.gridHeaderTxt}>{d}</Text>
              </View>
            ))}
          </View>
          <ScrollView style={{ flex: 1 }} contentContainerStyle={{ paddingBottom: insets.bottom + 80 }}>
            {TIME_SLOTS.map((slot) => {
              const isBreak = slot.hour === 13;
              const dayMap = allDaysGrid[slot.hour] ?? {};
              return (
                <View key={slot.hour} style={[s.gridRow, isBreak && s.gridBreakRow]}>
                  <View style={s.gridTimeCell}>
                    <Text style={[s.gridTimeTxt, isBreak && s.gridBreakTimeTxt]}>
                      {slot.shortLabel}
                    </Text>
                    {isBreak && <Text style={[s.gridTimeTxt, { color: "#856404" }]}>BREAK</Text>}
                  </View>
                  {DAYS.map((d) => {
                    const entries = dayMap[d] ?? [];
                    return (
                      <View key={d} style={s.gridDayCell}>
                        {entries.length === 0
                          ? <Text style={s.freeDash}>—</Text>
                          : entries.map((r) => (
                              <MiniCard key={r.id} row={r} colors={colors} />
                            ))
                        }
                      </View>
                    );
                  })}
                </View>
              );
            })}
          </ScrollView>
        </View>
      )}

      <TouchableOpacity style={s.fab} onPress={() => { setForm(EMPTY_FORM); setShowAdd(true); }}>
        <Feather name="plus" size={26} color="#fff" />
      </TouchableOpacity>

      <Modal visible={showAdd} animationType="slide" transparent onRequestClose={() => setShowAdd(false)}>
        <View style={s.modalOverlay}>
          <View style={s.sheet}>
            <View style={{ flexDirection: "row", justifyContent: "space-between", alignItems: "flex-start" }}>
              <View>
                <Text style={s.sheetTitle}>Add Schedule Entry</Text>
                <Text style={s.sheetSub}>Weekly recurring class slot</Text>
              </View>
              <TouchableOpacity onPress={() => setShowAdd(false)}>
                <Feather name="x" size={22} color={colors.mutedForeground} />
              </TouchableOpacity>
            </View>
            <ScrollView showsVerticalScrollIndicator={false} keyboardShouldPersistTaps="handled">
              <Text style={s.label}>Faculty *</Text>
              <TouchableOpacity style={[s.pickerBtn, form.faculty && s.pickerBtnActive]} onPress={() => setActivePicker("faculty")}>
                <Text style={[s.pickerBtnText, form.faculty && s.pickerBtnTextActive]} numberOfLines={1}>{form.faculty || "Tap to select faculty…"}</Text>
                <Feather name="chevron-down" size={16} color={form.faculty ? colors.primary : colors.mutedForeground} />
              </TouchableOpacity>

              <Text style={s.label}>Subject *</Text>
              <TouchableOpacity style={[s.pickerBtn, form.subject && s.pickerBtnActive, !form.faculty && { opacity: 0.5 }]} onPress={() => form.faculty && setActivePicker("subject")}>
                <Text style={[s.pickerBtnText, form.subject && s.pickerBtnTextActive]} numberOfLines={1}>{form.subject || (form.faculty ? "Tap to select subject…" : "Select faculty first")}</Text>
                <Feather name="chevron-down" size={16} color={form.subject ? colors.primary : colors.mutedForeground} />
              </TouchableOpacity>

              <Text style={s.label}>Class *</Text>
              <TouchableOpacity style={[s.pickerBtn, form.className && s.pickerBtnActive, !form.subject && { opacity: 0.5 }]} onPress={() => form.subject && setActivePicker("className")}>
                <Text style={[s.pickerBtnText, form.className && s.pickerBtnTextActive]} numberOfLines={1}>{form.className || (form.subject ? "Tap to select class…" : "Select subject first")}</Text>
                <Feather name="chevron-down" size={16} color={form.className ? colors.primary : colors.mutedForeground} />
              </TouchableOpacity>

              <Text style={s.label}>Department *{form.dept && form.className ? "  ✓ auto-filled" : ""}</Text>
              <View style={s.optRow}>
                {(options?.depts ?? ["ECE", "H&S", "FoC"]).map((d) => (
                  <TouchableOpacity key={d} style={[s.optBtn, form.dept === d && s.optBtnActive]} onPress={() => setField("dept", d)}>
                    <Text style={[s.optTxt, form.dept === d && s.optTxtActive]}>{d}</Text>
                  </TouchableOpacity>
                ))}
              </View>

              <Text style={s.label}>Location{form.className ? " · filtered by class" : ""}</Text>
              <TouchableOpacity style={[s.pickerBtn, form.location && s.pickerBtnActive]} onPress={() => setActivePicker("location")}>
                <Text style={[s.pickerBtnText, form.location && s.pickerBtnTextActive]} numberOfLines={1}>{form.location || "Tap to select location…"}</Text>
                <Feather name="chevron-down" size={16} color={form.location ? colors.primary : colors.mutedForeground} />
              </TouchableOpacity>

              <View style={s.divider} />

              <Text style={s.label}>Day *</Text>
              <View style={s.optRow}>
                {DAYS.map((d) => (
                  <TouchableOpacity key={d} style={[s.optBtn, form.day === d && s.optBtnActive]} onPress={() => setField("day", d)}>
                    <Text style={[s.optTxt, form.day === d && s.optTxtActive]}>{d}</Text>
                  </TouchableOpacity>
                ))}
              </View>

              <Text style={s.label}>Start Time *</Text>
              <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                <View style={{ flexDirection: "row", gap: 8, paddingBottom: 4 }}>
                  {HOUR_OPTIONS.slice(0, 8).map((t) => (
                    <TouchableOpacity key={t} style={[s.optBtn, form.timeStart === t && s.optBtnActive]} onPress={() => setField("timeStart", t)}>
                      <Text style={[s.optTxt, form.timeStart === t && s.optTxtActive]}>{t}</Text>
                    </TouchableOpacity>
                  ))}
                </View>
              </ScrollView>

              <Text style={s.label}>End Time *</Text>
              <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                <View style={{ flexDirection: "row", gap: 8, paddingBottom: 4 }}>
                  {HOUR_OPTIONS.slice(1).map((t) => (
                    <TouchableOpacity key={t} style={[s.optBtn, form.timeEnd === t && s.optBtnActive]} onPress={() => setField("timeEnd", t)}>
                      <Text style={[s.optTxt, form.timeEnd === t && s.optTxtActive]}>{t}</Text>
                    </TouchableOpacity>
                  ))}
                </View>
              </ScrollView>

              <Text style={s.label}>Type *</Text>
              <View style={s.optRow}>
                {LAB_OPTIONS.map((l) => (
                  <TouchableOpacity key={l} style={[s.optBtn, form.lecLab === l && s.optBtnActive]} onPress={() => setField("lecLab", l)}>
                    <Text style={[s.optTxt, form.lecLab === l && s.optTxtActive]}>{l}</Text>
                  </TouchableOpacity>
                ))}
              </View>

              <Text style={s.label}>Elective</Text>
              <View style={s.optRow}>
                {ELECTIVE_OPTIONS.map((e) => (
                  <TouchableOpacity key={e.value} style={[s.optBtn, form.elective === e.value && s.optBtnActive]} onPress={() => setField("elective", e.value)}>
                    <Text style={[s.optTxt, form.elective === e.value && s.optTxtActive]}>{e.label}</Text>
                  </TouchableOpacity>
                ))}
              </View>

              <TouchableOpacity
                style={[s.saveBtn, (!form.faculty || !form.subject || !form.className || !form.dept) && s.saveBtnDisabled]}
                disabled={!form.faculty || !form.subject || !form.className || !form.dept || addMutation.isPending}
                onPress={() => addMutation.mutate(form)}
              >
                {addMutation.isPending
                  ? <ActivityIndicator color="#fff" />
                  : <Text style={s.saveBtnTxt}>Add to Schedule</Text>}
              </TouchableOpacity>
            </ScrollView>
          </View>
        </View>
      </Modal>

      <ImportPanel visible={showImport} onClose={() => setShowImport(false)} title="Import Schedule Data">
        <ExcelImportButton
          label="Import Weekly Schedule"
          description="WeeklySchedule.xlsx — Faculty, Subject, Class, Day, Time, Location"
          icon="calendar"
          variant="primary"
          onImport={(uri, name, mimeType, file) => importScheduleExcel(uri, name, mimeType, scheduleId, file)}
          onSuccess={() => { setShowImport(false); qc.invalidateQueries({ queryKey: ["schedule", scheduleId] }); }}
          sampleUrl={`https://${process.env.EXPO_PUBLIC_DOMAIN}/api/import/sample/schedule`}
          sampleFileName="SampleWeeklySchedule.xlsx"
        />
        <ExcelImportButton
          label="Import Options (Picklists)"
          description="Updates Faculty / Subject / Class / Location dropdowns"
          icon="sliders"
          variant="secondary"
          onImport={importOptionsExcel}
          onSuccess={() => { setShowImport(false); qc.invalidateQueries({ queryKey: ["options"] }); }}
        />
      </ImportPanel>

      {Object.keys(pickerConfigs).map((key) => {
        const k = key as keyof typeof pickerConfigs;
        const cfg = pickerConfigs[k];
        return (
          <PickerModal
            key={k}
            visible={activePicker === k}
            title={cfg.title}
            items={cfg.items}
            selected={form[cfg.field]}
            onSelect={(v) => { setField(cfg.field, v); setActivePicker(null); }}
            onClose={() => setActivePicker(null)}
          />
        );
      })}
      <PickerModal
        visible={activePicker === "filterClass"}
        title="Filter by Class"
        items={allClasses}
        selected={classFilter}
        onSelect={(v) => { setClassFilter(v); setActivePicker(null); }}
        onClose={() => setActivePicker(null)}
      />
      <PickerModal
        visible={activePicker === "filterFaculty"}
        title="Filter by Faculty"
        items={allFaculty}
        selected={facFilter}
        onSelect={(v) => { setFacFilter(v); setActivePicker(null); }}
        onClose={() => setActivePicker(null)}
      />
    </View>
  );
}
