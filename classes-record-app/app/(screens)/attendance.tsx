import React, { useState, useMemo, useCallback, useRef } from "react";
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  TextInput, ActivityIndicator, Modal, Platform, Alert, Linking,
} from "react-native";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useLocalSearchParams, useFocusEffect } from "expo-router";
import * as ScreenOrientation from "expo-screen-orientation";
import * as DocumentPicker from "expo-document-picker";

import { useColors } from "@/hooks/useColors";
import { useAuth } from "@/context/AuthContext";
import {
  fetchSchedule, fetchStudents, addStudent, deleteStudent,
  markAttendance, fetchRoster, importStudentsExcel,
  fetchStudentAttendanceSummary,
  Student, ScheduleRow, StudentAttendanceSummary,
} from "@/hooks/useApi";
import { PickerModal } from "@/components/PickerModal";
import { printOrShareHtml } from "@/utils/printHtml";

const STATUS_COLORS = { P: "#2E7D32", A: "#C62828", L: "#E65100" };
const STATUS_BG    = { P: "#E8F5E9", A: "#FFEBEE", L: "#FFF3E0" };
const STATUS_LABELS = { P: "Present", A: "Absent", L: "Leave" };

const DAY_NUM: Record<string, number> = { Sun: 0, Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6 };
const DAY_NAMES = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const MONTH_SHORT = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

type SemDate = { date: string; type: "regular" | "makeup"; dayName: string; time?: string };
type Tab = "mark" | "roster" | "students";

function todayStr() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,"0")}-${String(d.getDate()).padStart(2,"0")}`;
}

function fmtDateLabel(iso: string) {
  const [, m, d] = iso.split("-");
  return `${d} ${MONTH_SHORT[parseInt(m,10)-1]}`;
}

function fmtDateShort(iso: string) {
  const [, m, d] = iso.split("-");
  return `${d}-${m}`;
}

function generateSemesterDates(
  rows: ScheduleRow[],
  className: string,
  subject: string,
  startIso: string,
  endIso: string,
): SemDate[] {
  const start = new Date(startIso + "T00:00:00");
  const end   = new Date(endIso   + "T00:00:00");
  const results: SemDate[] = [];

  const regular = rows
    .filter(r => !r.Type && r.Class === className && r.Subject === subject)
    .sort((a, b) => a.SortKey - b.SortKey);

  // Lab sessions span multiple consecutive hours (rows) per day — collapse to ONE session per day.
  // Lec rows are already 1 row per session, keep them all separate.
  const sessionRows: ScheduleRow[] = [];
  const labDaysSeen = new Set<string>();
  for (const row of regular) {
    if (row.LecLab === "Lab") {
      if (labDaysSeen.has(row.Day)) continue; // skip subsequent Lab hours on same day
      labDaysSeen.add(row.Day);
    }
    sessionRows.push(row);
  }

  for (const row of sessionRows) {
    if (!(row.Day in DAY_NUM)) continue;
    const target = DAY_NUM[row.Day];
    const d = new Date(start);
    const diff = (target - d.getDay() + 7) % 7;
    d.setDate(d.getDate() + diff);
    while (d <= end) {
      results.push({
        date: d.toISOString().slice(0, 10),
        type: "regular",
        dayName: row.Day,
        time: row.Time,
      });
      d.setDate(d.getDate() + 7);
    }
  }

  const makeups = rows.filter(
    r => r.Type === "Makeup" && r.Class === className && r.Subject === subject && r.EntryDate
  );
  for (const r of makeups) {
    const dateStr = r.EntryDate as string;
    if (dateStr >= startIso && dateStr <= endIso) {
      const wd = new Date(dateStr + "T00:00:00").getDay();
      results.push({ date: dateStr, type: "makeup", dayName: DAY_NAMES[wd], time: r.Time });
    }
  }

  // Sort by date then time — no deduplication (multiple sessions per day are intentional)
  return results.sort((a, b) => {
    if (a.date !== b.date) return a.date.localeCompare(b.date);
    return (a.time ?? "").localeCompare(b.time ?? "");
  });
}

export default function AttendanceScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const qc = useQueryClient();
  const { user } = useAuth();
  const scrollRef = useRef<ScrollView>(null);

  const { scheduleId: rawId, scheduleTitle, isPublic, startDate, endDate, facultyName } =
    useLocalSearchParams<{
      scheduleId: string; scheduleTitle: string;
      isPublic?: string; startDate?: string; endDate?: string; facultyName?: string;
    }>();

  const scheduleId = Number(rawId);
  const publicMode = isPublic === "1";
  const facultyMode = !!facultyName;
  const teacherMode = !publicMode && !!user;
  const hasDates = !!(startDate && endDate);

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

  const [activeTab, setActiveTab] = useState<Tab>(publicMode ? "roster" : "mark");
  const [selectedClass, setSelectedClass] = useState("");
  const [selectedSubject, setSelectedSubject] = useState("");
  const [showClassPicker, setShowClassPicker] = useState(false);
  const [expandedDate, setExpandedDate] = useState<string | null>(null);
  const [manualDate, setManualDate] = useState(todayStr);
  const [attendance, setAttendance] = useState<Record<string, string>>({});
  const [errorMsg, setErrorMsg] = useState("");
  const [deleteTarget, setDeleteTarget] = useState<Student | null>(null);
  const [newRoll, setNewRoll] = useState("");
  const [newName, setNewName] = useState("");
  const [newEmail, setNewEmail] = useState("");
  const [addLoading, setAddLoading] = useState(false);
  const [bulkLoading, setBulkLoading] = useState(false);
  const [rosterSearchReg, setRosterSearchReg] = useState("");
  const [studentSummary, setStudentSummary] = useState<StudentAttendanceSummary | null>(null);
  const [summaryLoading, setSummaryLoading] = useState(false);

  const { data: scheduleRows = [] } = useQuery({
    queryKey: ["schedule", scheduleId],
    queryFn: () => fetchSchedule(scheduleId),
    enabled: !!scheduleId,
  });

  const classSubjectList = useMemo(() => {
    const seen = new Set<string>();
    const out: string[] = [];
    for (const r of scheduleRows) {
      if (!r.Type && r.Class && r.Subject) {
        if (facultyMode && r.Faculty !== facultyName) continue;
        const key = `${r.Class}|||${r.Subject}`;
        if (!seen.has(key)) {
          seen.add(key);
          out.push(key);
        }
      }
    }
    return out.sort((a, b) => {
      const [ac, as_] = a.split("|||");
      const [bc, bs] = b.split("|||");
      return ac !== bc ? ac.localeCompare(bc) : as_.localeCompare(bs);
    });
  }, [scheduleRows, facultyMode, facultyName]);

  const classSubjectDisplay = useMemo(() => {
    const map: Record<string, string> = {};
    for (const key of classSubjectList) {
      const [cls, subj] = key.split("|||");
      map[key] = `${cls} · ${subj}`;
    }
    return map;
  }, [classSubjectList]);

  const semesterDates = useMemo(() => {
    if (!selectedClass || !selectedSubject || !hasDates) return [];
    return generateSemesterDates(scheduleRows, selectedClass, selectedSubject, startDate!, endDate!);
  }, [scheduleRows, selectedClass, selectedSubject, startDate, endDate, hasDates]);

  const { data: students = [], isLoading: studentsLoading } = useQuery({
    queryKey: ["students", scheduleId, selectedClass],
    queryFn: () => fetchStudents(scheduleId, selectedClass),
    enabled: !!selectedClass,
  });

  const { data: roster, isLoading: rosterLoading } = useQuery({
    queryKey: ["roster", scheduleId, selectedClass],
    queryFn: () => fetchRoster(scheduleId, selectedClass),
    enabled: !!selectedClass,
  });

  const markedDates = useMemo(() => new Set(roster?.dates ?? []), [roster]);

  // slotKey = "YYYY-MM-DD|HH:MM AM" for session, or plain date for manual mode
  function parseSlot(slotKey: string): { date: string; sessionTime: string } {
    const idx = slotKey.indexOf("|");
    if (idx === -1) return { date: slotKey, sessionTime: "" };
    return { date: slotKey.slice(0, idx), sessionTime: slotKey.slice(idx + 1) };
  }

  function handleDateSelect(slotKey: string) {
    if (expandedDate === slotKey) { setExpandedDate(null); return; }
    const map: Record<string, string> = {};
    for (const s of students) map[s.rollNo] = "P";
    if (roster) {
      for (const row of roster.rows) {
        if (row.records[slotKey]) map[row.rollNo] = row.records[slotKey];
      }
    }
    setAttendance(map);
    setExpandedDate(slotKey);
  }

  function handleManualDateLoad() {
    const map: Record<string, string> = {};
    for (const s of students) map[s.rollNo] = "P";
    if (roster) {
      for (const row of roster.rows) {
        if (row.records[manualDate]) map[row.rollNo] = row.records[manualDate];
      }
    }
    setAttendance(map);
    setExpandedDate(manualDate);
  }

  const saveMutation = useMutation({
    mutationFn: () => {
      const slotKey = expandedDate ?? manualDate;
      const { date, sessionTime } = parseSlot(slotKey);
      const records = students.map(s => ({
        rollNo: s.rollNo,
        status: attendance[s.rollNo] ?? "P",
      }));
      return markAttendance(scheduleId, selectedClass, date, sessionTime, records);
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["roster", scheduleId, selectedClass] });
      const slotKey = expandedDate ?? manualDate;
      Alert.alert("Saved", `Attendance saved for ${fmtDateLabel(parseSlot(slotKey).date)}.`);
    },
    onError: () => setErrorMsg("Could not save attendance"),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteStudent(id),
    onSuccess: () => {
      setDeleteTarget(null);
      qc.invalidateQueries({ queryKey: ["students", scheduleId, selectedClass] });
      qc.invalidateQueries({ queryKey: ["roster", scheduleId, selectedClass] });
    },
    onError: () => { setDeleteTarget(null); setErrorMsg("Could not delete student"); },
  });

  async function handleAddStudent() {
    if (!newRoll.trim() || !newName.trim()) { setErrorMsg("Enter reg number and name"); return; }
    setAddLoading(true);
    const res = await addStudent(scheduleId, selectedClass, newRoll.trim(), newName.trim(), newEmail.trim());
    setAddLoading(false);
    if (res.error) { setErrorMsg(res.error); return; }
    setNewRoll(""); setNewName(""); setNewEmail("");
    qc.invalidateQueries({ queryKey: ["students", scheduleId, selectedClass] });
    qc.invalidateQueries({ queryKey: ["roster", scheduleId, selectedClass] });
  }

  async function handleRosterSearch() {
    if (!rosterSearchReg.trim() || !scheduleId) return;
    setSummaryLoading(true);
    setStudentSummary(null);
    const result = await fetchStudentAttendanceSummary(scheduleId, rosterSearchReg.trim());
    setSummaryLoading(false);
    setStudentSummary(result);
  }

  async function handleBulkUpload() {
    try {
      const result = await DocumentPicker.getDocumentAsync({
        type: ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.ms-excel", "*/*"],
        copyToCacheDirectory: true,
      });
      if (result.canceled || !result.assets?.length) return;
      const asset = result.assets[0];
      setBulkLoading(true);
      const res = await importStudentsExcel(scheduleId, selectedClass, asset.uri, asset.name, asset.mimeType ?? "application/octet-stream");
      setBulkLoading(false);
      if (res.success) {
        Alert.alert("Import Complete", `${res.inserted ?? 0} students added, ${res.skipped ?? 0} skipped.`);
        qc.invalidateQueries({ queryKey: ["students", scheduleId, selectedClass] });
        qc.invalidateQueries({ queryKey: ["roster", scheduleId, selectedClass] });
      } else {
        setErrorMsg(res.error ?? "Import failed");
      }
    } catch {
      setBulkLoading(false);
      setErrorMsg("Could not pick file");
    }
  }

  async function handleDownloadPdf() {
    if (!roster || !selectedClass) return;
    const { dates, rows } = roster;
    function fmtSlotHtml(slot: string) {
      const [iso, time] = slot.split("|");
      const [, m, d] = iso.split("-");
      const base = `${d}-${m}`;
      if (!time) return base;
      const t = time.replace(":00 AM", "A").replace(":00 PM", "P").replace(" AM", "A").replace(" PM", "P");
      return `${base}<br/><span style="font-size:8px">${t}</span>`;
    }
    const dateCols = dates.map(d => `<th>${fmtSlotHtml(d)}</th>`).join("");
    const dataRows = rows.map((r, i) => {
      const bg = i % 2 === 0 ? "#fff" : "#F9FAFB";
      const pct = r.percentage;
      const pctColor = pct >= 75 ? "#2E7D32" : pct >= 60 ? "#E65100" : "#C62828";
      const cells = dates.map(d => {
        const st = r.records[d] ?? "";
        const bg2 = st === "P" ? "#E8F5E9" : st === "A" ? "#FFEBEE" : st === "L" ? "#FFF3E0" : "#fff";
        const col = st === "P" ? "#2E7D32" : st === "A" ? "#C62828" : st === "L" ? "#E65100" : "#ccc";
        return `<td style="background:${bg2};color:${col};font-weight:bold">${st || "–"}</td>`;
      }).join("");
      return `<tr style="background:${bg}">
        <td>${i+1}</td><td>${r.rollNo}</td><td>${r.name}</td>
        ${cells}
        <td style="color:#2E7D32">${r.presentCount}</td>
        <td style="color:#C62828">${r.absentCount}</td>
        <td style="color:#E65100">${r.leaveCount}</td>
        <td style="color:${pctColor};font-weight:bold">${pct}%</td>
      </tr>`;
    }).join("");

    const html = `<!DOCTYPE html><html><head><meta charset="utf-8"/>
<style>
  *{box-sizing:border-box;margin:0;padding:0}
  body{font-family:Arial,sans-serif;font-size:10px}
  h2{font-size:14px;margin-bottom:4px}
  p{font-size:11px;color:#555;margin-bottom:12px}
  table{border-collapse:collapse;width:100%}
  th{background:#1565C0;color:#fff;padding:4px 6px;font-size:9px}
  td{padding:4px 6px;border:1px solid #e0e0e0;text-align:center;font-size:9px}
  td:nth-child(2),td:nth-child(3){text-align:left}
</style></head><body>
<h2>Attendance – ${selectedClass}</h2>
<p>${scheduleTitle ?? ""} · Generated ${new Date().toLocaleDateString()}</p>
<table><thead><tr>
  <th>#</th><th>Roll No</th><th>Name</th>${dateCols}
  <th>P</th><th>A</th><th>L</th><th>%</th>
</tr></thead><tbody>${dataRows}</tbody></table>
</body></html>`;
    try {
      await printOrShareHtml(html, `Attendance – ${selectedClass}`);
    } catch {
      Alert.alert("Error", "Could not generate PDF.");
    }
  }

  const s = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    header: {
      backgroundColor: colors.primary,
      paddingTop: insets.top + (Platform.OS === "web" ? 67 : 0),
      paddingBottom: 12, paddingHorizontal: 16,
    },
    headerRow: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 8 },
    navBtn: {
      flexDirection: "row", alignItems: "center", gap: 5,
      backgroundColor: "rgba(255,255,255,0.2)", borderRadius: 20,
      paddingHorizontal: 12, paddingVertical: 6,
    },
    navBtnTxt: { color: "#fff", fontSize: 13, fontFamily: "Inter_600SemiBold" },
    headerTitle: { color: "#fff", fontSize: 20, fontFamily: "Inter_700Bold" },
    headerSub: { color: "rgba(255,255,255,0.8)", fontSize: 12, fontFamily: "Inter_400Regular", marginTop: 2 },
    classPickerRow: {
      flexDirection: "row", alignItems: "center", gap: 8,
      backgroundColor: colors.card, padding: 10,
      borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    classBtn: {
      flex: 1, flexDirection: "row", alignItems: "center", gap: 8,
      backgroundColor: colors.muted, borderRadius: 10, paddingHorizontal: 12, paddingVertical: 10,
      borderWidth: 1, borderColor: colors.border,
    },
    classBtnTxt: { flex: 1, fontFamily: "Inter_500Medium", fontSize: 14, color: colors.foreground },
    downloadBtn: {
      flexDirection: "row", alignItems: "center", gap: 6,
      backgroundColor: colors.primary, borderRadius: 10,
      paddingHorizontal: 12, paddingVertical: 10,
    },
    downloadBtnTxt: { color: "#fff", fontFamily: "Inter_600SemiBold", fontSize: 13 },
    tabRow: {
      flexDirection: "row", backgroundColor: colors.card,
      borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    tab: { flex: 1, paddingVertical: 11, alignItems: "center" },
    tabActive: { borderBottomWidth: 2, borderBottomColor: colors.primary },
    tabTxt: { fontFamily: "Inter_500Medium", fontSize: 13, color: colors.mutedForeground },
    tabTxtActive: { color: colors.primary, fontFamily: "Inter_700Bold" },
    noClass: { alignItems: "center", marginTop: 80, paddingHorizontal: 32 },
    noClassTxt: { fontSize: 15, fontFamily: "Inter_400Regular", color: colors.mutedForeground, textAlign: "center", marginTop: 12 },

    // Mark tab – date list
    dateCard: {
      backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    dateCardHeader: {
      flexDirection: "row", alignItems: "center", paddingHorizontal: 14, paddingVertical: 12, gap: 10,
    },
    dateDot: { width: 10, height: 10, borderRadius: 5 },
    dateCardDay: { fontFamily: "Inter_700Bold", fontSize: 13, color: colors.foreground, width: 36 },
    dateCardDate: { fontFamily: "Inter_500Medium", fontSize: 13, color: colors.foreground, flex: 1 },
    dateTypeBadge: {
      borderRadius: 10, paddingHorizontal: 8, paddingVertical: 2, marginRight: 4,
    },
    dateTypeTxt: { fontSize: 10, fontFamily: "Inter_600SemiBold" },
    dateAttSummary: { fontFamily: "Inter_400Regular", fontSize: 11, color: colors.mutedForeground },
    dateChevron: {},

    // Expanded student list inside date card
    expandedPanel: {
      borderTopWidth: 1, borderTopColor: colors.border,
      backgroundColor: colors.background,
    },
    expandedHeader: {
      flexDirection: "row", alignItems: "center", justifyContent: "space-between",
      paddingHorizontal: 12, paddingVertical: 8,
      backgroundColor: "#1976D2",
    },
    expandedHeaderTxt: { color: "#fff", fontFamily: "Inter_700Bold", fontSize: 13 },
    saveBtn: {
      flexDirection: "row", alignItems: "center", gap: 6,
      backgroundColor: "#fff", borderRadius: 8, paddingHorizontal: 12, paddingVertical: 6,
    },
    saveBtnTxt: { color: "#1976D2", fontFamily: "Inter_700Bold", fontSize: 12 },
    studentRow: {
      flexDirection: "row", alignItems: "center",
      paddingHorizontal: 12, paddingVertical: 9,
      borderBottomWidth: 1, borderBottomColor: colors.border,
      backgroundColor: colors.card,
    },
    studentNum: { width: 28, fontFamily: "Inter_400Regular", fontSize: 11, color: colors.mutedForeground },
    studentRoll: { width: 110, fontFamily: "Inter_500Medium", fontSize: 12, color: colors.foreground },
    studentName: { flex: 1, fontFamily: "Inter_400Regular", fontSize: 12, color: colors.foreground },
    statusBtns: { flexDirection: "row", gap: 5 },
    statusBtn: { paddingHorizontal: 9, paddingVertical: 5, borderRadius: 7, borderWidth: 1, borderColor: colors.border },
    statusBtnTxt: { fontFamily: "Inter_700Bold", fontSize: 11 },
    summaryBar: { flexDirection: "row", backgroundColor: "#F5F5F5", padding: 8, gap: 16, justifyContent: "center" },

    // Manual date fallback
    manualRow: {
      flexDirection: "row", alignItems: "center", gap: 8, padding: 10,
      backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    manualInput: {
      flex: 1, backgroundColor: colors.muted, borderRadius: 8, paddingHorizontal: 10, paddingVertical: 8,
      fontFamily: "Inter_400Regular", fontSize: 13, color: colors.foreground,
      borderWidth: 1, borderColor: colors.border,
    },
    manualLoadBtn: {
      flexDirection: "row", alignItems: "center", gap: 5,
      backgroundColor: colors.primary, borderRadius: 8, paddingHorizontal: 12, paddingVertical: 9,
    },
    manualLoadBtnTxt: { color: "#fff", fontFamily: "Inter_700Bold", fontSize: 13 },

    // Roster tab
    rosterContainer: { flex: 1, flexDirection: "row" },
    rosterLeft: { backgroundColor: colors.card, borderRightWidth: 1, borderRightColor: colors.border },
    rosterLeftHead: { height: 40, paddingHorizontal: 8, justifyContent: "center", borderBottomWidth: 1, borderBottomColor: colors.border, backgroundColor: "#1976D2" },
    rosterLeftHeadTxt: { fontFamily: "Inter_700Bold", fontSize: 11, color: "#fff" },
    rosterLeftRow: { height: 44, paddingHorizontal: 8, justifyContent: "center", borderBottomWidth: 1, borderBottomColor: colors.border },
    rosterRoll: { fontFamily: "Inter_500Medium", fontSize: 11, color: colors.foreground },
    rosterName: { fontFamily: "Inter_400Regular", fontSize: 10, color: colors.mutedForeground },
    rosterRight: { flex: 1 },
    rosterCell: { width: 38, height: 44, alignItems: "center", justifyContent: "center", borderBottomWidth: 1, borderRightWidth: 1, borderColor: colors.border },
    rosterHeadCell: { width: 38, height: 40, alignItems: "center", justifyContent: "center", backgroundColor: "#1976D2", borderRightWidth: 1, borderColor: "#1565C0" },
    rosterHeadTxt: { fontFamily: "Inter_700Bold", fontSize: 9, color: "#fff" },
    rosterStatCell: { width: 36, height: 44, alignItems: "center", justifyContent: "center", backgroundColor: "#F5F5F5", borderBottomWidth: 1, borderRightWidth: 1, borderColor: colors.border },
    rosterStatHead: { width: 36, height: 40, alignItems: "center", justifyContent: "center", backgroundColor: "#1976D2", borderRightWidth: 1, borderColor: "#1565C0" },

    // Students tab
    addRow: {
      flexDirection: "row", gap: 8, padding: 10,
      backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    addInput: {
      backgroundColor: colors.muted, borderWidth: 1, borderColor: colors.border,
      borderRadius: 8, paddingHorizontal: 10, paddingVertical: 8,
      fontFamily: "Inter_400Regular", fontSize: 13, color: colors.foreground,
    },
    addBtn: {
      backgroundColor: colors.primary, borderRadius: 8, paddingHorizontal: 14,
      alignItems: "center", justifyContent: "center",
    },
    bulkRow: {
      flexDirection: "row", gap: 8, padding: 10,
      backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border,
      alignItems: "center",
    },
    bulkBtn: {
      flex: 1, flexDirection: "row", alignItems: "center", gap: 6,
      backgroundColor: colors.muted, borderRadius: 8, paddingHorizontal: 12, paddingVertical: 9,
      borderWidth: 1, borderColor: colors.border,
    },
    bulkBtnTxt: { fontFamily: "Inter_500Medium", fontSize: 13, color: colors.foreground },
    sampleBtn: {
      flexDirection: "row", alignItems: "center", gap: 5,
      borderRadius: 8, paddingHorizontal: 10, paddingVertical: 9,
      borderWidth: 1, borderColor: colors.primary,
    },
    sampleBtnTxt: { fontFamily: "Inter_500Medium", fontSize: 12, color: colors.primary },
    stuCard: {
      flexDirection: "row", alignItems: "center",
      paddingHorizontal: 14, paddingVertical: 12,
      borderBottomWidth: 1, borderBottomColor: colors.border,
      backgroundColor: colors.card,
    },
    stuNum: { width: 28, fontFamily: "Inter_400Regular", fontSize: 12, color: colors.mutedForeground },
    stuRoll: { fontFamily: "Inter_600SemiBold", fontSize: 13, color: colors.foreground },
    stuName: { fontFamily: "Inter_400Regular", fontSize: 12, color: colors.mutedForeground, marginTop: 1 },
    delBtn: { marginLeft: "auto" as never, padding: 8 },
  });

  const TABS: { id: Tab; label: string }[] = [
    { id: "mark", label: "Mark" },
    { id: "roster", label: "Roster" },
    { id: "students", label: "Students" },
  ];
  const visibleTabs = publicMode
    ? TABS.filter(t => t.id === "roster")
    : facultyMode
    ? TABS.filter(t => t.id !== "students")
    : TABS;

  const today = todayStr();

  function renderDateList() {
    if (studentsLoading || rosterLoading) {
      return <ActivityIndicator color={colors.primary} style={{ marginTop: 40 }} size="large" />;
    }

    if (!hasDates) {
      return (
        <ScrollView>
          <View style={s.manualRow}>
            <Feather name="calendar" size={16} color={colors.primary} />
            <TextInput
              style={s.manualInput}
              value={manualDate}
              onChangeText={setManualDate}
              placeholder="YYYY-MM-DD"
              placeholderTextColor={colors.mutedForeground}
            />
            <TouchableOpacity style={s.manualLoadBtn} onPress={handleManualDateLoad}>
              <Text style={s.manualLoadBtnTxt}>Load</Text>
            </TouchableOpacity>
          </View>
          {expandedDate === manualDate && renderStudentList(manualDate, "")}
        </ScrollView>
      );
    }

    if (semesterDates.length === 0) {
      return (
        <View style={s.noClass}>
          <Feather name="calendar" size={40} color={colors.mutedForeground} />
          <Text style={s.noClassTxt}>No class dates found for this class in the semester range.</Text>
        </View>
      );
    }

    return (
      <ScrollView ref={scrollRef}>
        {semesterDates.map((sd, idx) => {
          const slotKey = `${sd.date}|${sd.time ?? ""}`;
          const isToday = sd.date === today;
          const isExpanded = expandedDate === slotKey;
          const isMarked = markedDates.has(slotKey);
          const isMakeup = sd.type === "makeup";
          const isFuture = sd.date > today;

          let p = 0, a = 0, l = 0;
          if (isMarked && roster) {
            for (const row of roster.rows) {
              const st = row.records[slotKey];
              if (st === "P") p++;
              else if (st === "A") a++;
              else if (st === "L") l++;
            }
          }

          return (
            <View key={`${slotKey}-${idx}`} style={[s.dateCard, isToday && { borderLeftWidth: 3, borderLeftColor: colors.primary }]}>
              <TouchableOpacity
                style={s.dateCardHeader}
                onPress={() => handleDateSelect(slotKey)}
                activeOpacity={0.7}
              >
                <View style={[s.dateDot, {
                  backgroundColor: isMarked ? STATUS_COLORS.P : isToday ? colors.primary : isFuture ? colors.border : colors.mutedForeground,
                }]} />
                <Text style={[s.dateCardDay, isToday && { color: colors.primary }]}>{sd.dayName}</Text>
                <Text style={[s.dateCardDate, isToday && { color: colors.primary, fontFamily: "Inter_700Bold" }]}>
                  {fmtDateLabel(sd.date)}{isToday ? " (Today)" : ""}
                </Text>
                {sd.time ? (
                  <View style={[s.dateTypeBadge, { backgroundColor: colors.muted }]}>
                    <Text style={[s.dateTypeTxt, { color: colors.mutedForeground }]}>{sd.time}</Text>
                  </View>
                ) : null}
                {isMakeup && (
                  <View style={[s.dateTypeBadge, { backgroundColor: "#FFF3E0" }]}>
                    <Text style={[s.dateTypeTxt, { color: STATUS_COLORS.L }]}>Makeup</Text>
                  </View>
                )}
                {isMarked ? (
                  <View style={{ flexDirection: "row", alignItems: "center", gap: 4 }}>
                    <Feather name="check-circle" size={13} color={STATUS_COLORS.P} />
                    <Text style={s.dateAttSummary}>P:{p} A:{a} L:{l}</Text>
                  </View>
                ) : (
                  <Text style={[s.dateAttSummary, isFuture && { color: colors.border }]}>
                    {isFuture ? "Upcoming" : "Not marked"}
                  </Text>
                )}
                <Feather
                  name={isExpanded ? "chevron-up" : "chevron-down"}
                  size={16}
                  color={colors.mutedForeground}
                  style={s.dateChevron}
                />
              </TouchableOpacity>
              {isExpanded && renderStudentList(sd.date, sd.time ?? "")}
            </View>
          );
        })}
      </ScrollView>
    );
  }

  function renderStudentList(date: string, sessionTime: string) {
    const timeLabel = sessionTime ? ` · ${sessionTime}` : "";
    if (students.length === 0) {
      return (
        <View style={s.expandedPanel}>
          <View style={[s.noClass, { marginTop: 24, marginBottom: 24 }]}>
            <Feather name="user-plus" size={36} color={colors.mutedForeground} />
            <Text style={s.noClassTxt}>No students enrolled yet.{"\n"}Go to the Students tab to add them.</Text>
          </View>
        </View>
      );
    }
    return (
      <View style={s.expandedPanel}>
        <View style={s.expandedHeader}>
          <Text numberOfLines={1} style={{ flex: 1, color: "#fff", fontFamily: "Inter_700Bold", fontSize: 13 }}>
            {fmtDateLabel(date)}{timeLabel} · {students.length} students
          </Text>
          <View style={{ flexDirection: "row", gap: 8 }}>
            <TouchableOpacity
              style={[s.saveBtn, { backgroundColor: "#E8F5E9" }]}
              onPress={() => {
                const map: Record<string, string> = {};
                for (const s2 of students) map[s2.rollNo] = "P";
                setAttendance(map);
              }}
            >
              <Feather name="check" size={13} color={STATUS_COLORS.P} />
              <Text style={[s.saveBtnTxt, { color: STATUS_COLORS.P }]}>All Present</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={s.saveBtn}
              onPress={() => saveMutation.mutate()}
              disabled={saveMutation.isPending}
            >
              {saveMutation.isPending
                ? <ActivityIndicator color="#1976D2" size="small" />
                : <><Feather name="save" size={13} color="#1976D2" /><Text style={s.saveBtnTxt}>Save</Text></>
              }
            </TouchableOpacity>
          </View>
        </View>
        {students.map((stu, i) => {
          const cur = attendance[stu.rollNo] ?? "P";
          return (
            <View key={stu.id} style={[s.studentRow, { backgroundColor: i % 2 === 0 ? colors.card : colors.muted }]}>
              <Text style={s.studentNum}>{i + 1}</Text>
              <View style={{ flex: 1 }}>
                <Text style={s.studentRoll} numberOfLines={1}>{stu.rollNo}</Text>
                <Text style={s.studentName} numberOfLines={1}>{stu.name}</Text>
              </View>
              <View style={s.statusBtns}>
                {(["P", "A", "L"] as const).map(st => (
                  <TouchableOpacity
                    key={st}
                    style={[s.statusBtn, cur === st && { backgroundColor: STATUS_BG[st], borderColor: STATUS_COLORS[st] }]}
                    onPress={() => setAttendance(prev => ({ ...prev, [stu.rollNo]: st }))}
                  >
                    <Text style={[s.statusBtnTxt, { color: cur === st ? STATUS_COLORS[st] : colors.mutedForeground }]}>{st}</Text>
                  </TouchableOpacity>
                ))}
              </View>
            </View>
          );
        })}
        <View style={s.summaryBar}>
          {(["P", "A", "L"] as const).map(st => {
            const count = Object.values(attendance).filter(v => v === st).length;
            return (
              <View key={st} style={{ alignItems: "center" }}>
                <Text style={{ fontSize: 18, fontFamily: "Inter_700Bold", color: STATUS_COLORS[st] }}>{count}</Text>
                <Text style={{ fontSize: 11, fontFamily: "Inter_400Regular", color: colors.mutedForeground }}>{STATUS_LABELS[st]}</Text>
              </View>
            );
          })}
        </View>
      </View>
    );
  }

  return (
    <View style={s.container}>
      <View style={s.header}>
        <View style={s.headerRow}>
          <TouchableOpacity style={s.navBtn} onPress={() => router.back()}>
            <Feather name="chevron-left" size={14} color="#fff" />
            <Text style={s.navBtnTxt}>Back</Text>
          </TouchableOpacity>
          <TouchableOpacity style={s.navBtn} onPress={() => router.replace("/" as never)}>
            <Feather name="home" size={13} color="#fff" />
            <Text style={s.navBtnTxt}>Home</Text>
          </TouchableOpacity>
        </View>
        <Text style={s.headerTitle}>Attendance</Text>
        <Text style={s.headerSub}>
          {scheduleTitle ?? "Schedule"}{publicMode ? " · Public view" : ""}
          {hasDates ? `  ·  ${startDate} – ${endDate}` : ""}
        </Text>
      </View>

      {!publicMode && (
        <View style={s.classPickerRow}>
          <TouchableOpacity style={s.classBtn} onPress={() => setShowClassPicker(true)}>
            <Feather name="book" size={16} color={selectedClass ? colors.primary : colors.mutedForeground} />
            <Text style={[s.classBtnTxt, !selectedClass && { color: colors.mutedForeground }]} numberOfLines={1}>
              {selectedClass && selectedSubject
                ? `${selectedClass} · ${selectedSubject}`
                : "Select class & subject…"}
            </Text>
            <Feather name="chevron-down" size={14} color={colors.mutedForeground} />
          </TouchableOpacity>
          {selectedClass && activeTab === "roster" && (
            <TouchableOpacity style={s.downloadBtn} onPress={handleDownloadPdf}>
              <Feather name="download" size={14} color="#fff" />
              <Text style={s.downloadBtnTxt}>PDF</Text>
            </TouchableOpacity>
          )}
        </View>
      )}

      {!publicMode && (
        <View style={s.tabRow}>
          {visibleTabs.map(t => (
            <TouchableOpacity
              key={t.id}
              style={[s.tab, activeTab === t.id && s.tabActive]}
              onPress={() => setActiveTab(t.id)}
            >
              <Text style={[s.tabTxt, activeTab === t.id && s.tabTxtActive]}>{t.label}</Text>
            </TouchableOpacity>
          ))}
        </View>
      )}

      {publicMode ? (
        /* Public mode: skip class picker, go straight to Reg No search */
        <View style={{ flex: 1 }}>
          <View style={{ backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border, padding: 12, gap: 10 }}>
            <View style={{ flexDirection: "row", alignItems: "center", gap: 8 }}>
              <Feather name="search" size={16} color={colors.mutedForeground} />
              <TextInput
                style={[s.manualInput, { flex: 1 }]}
                placeholder="Enter your Reg No to view all class attendance…"
                placeholderTextColor={colors.mutedForeground}
                value={rosterSearchReg}
                onChangeText={setRosterSearchReg}
                autoCapitalize="characters"
                onSubmitEditing={handleRosterSearch}
                returnKeyType="search"
              />
              <TouchableOpacity
                style={[s.manualLoadBtn, summaryLoading && { opacity: 0.6 }]}
                onPress={handleRosterSearch}
                disabled={summaryLoading}
              >
                {summaryLoading
                  ? <ActivityIndicator color="#fff" size="small" />
                  : <Text style={s.manualLoadBtnTxt}>Search</Text>
                }
              </TouchableOpacity>
            </View>
            {studentSummary !== null && (
              studentSummary.found ? (
                <View style={{ backgroundColor: colors.background, borderRadius: 10, padding: 12, borderWidth: 1, borderColor: colors.border }}>
                  <Text style={{ fontFamily: "Inter_700Bold", fontSize: 14, color: colors.foreground, marginBottom: 8 }}>
                    {studentSummary.studentName} · {studentSummary.regNo}
                  </Text>
                  {studentSummary.rows.map(row => {
                    const pctColor = row.percentage >= 75 ? STATUS_COLORS.P : row.percentage >= 60 ? STATUS_COLORS.L : STATUS_COLORS.A;
                    return (
                      <View key={row.className} style={{ flexDirection: "row", alignItems: "center", paddingVertical: 6, borderTopWidth: 1, borderTopColor: colors.border }}>
                        <Text style={{ flex: 1, fontFamily: "Inter_500Medium", fontSize: 12, color: colors.foreground }}>{row.className}</Text>
                        <Text style={{ fontFamily: "Inter_400Regular", fontSize: 11, color: colors.mutedForeground, marginRight: 8 }}>
                          P:{row.present} A:{row.absent} L:{row.leave}
                        </Text>
                        <Text style={{ fontFamily: "Inter_700Bold", fontSize: 14, color: pctColor, minWidth: 44, textAlign: "right" }}>
                          {row.percentage}%
                        </Text>
                      </View>
                    );
                  })}
                </View>
              ) : (
                <View style={{ alignItems: "center", paddingVertical: 12 }}>
                  <Feather name="user-x" size={28} color={colors.mutedForeground} />
                  <Text style={{ fontFamily: "Inter_400Regular", fontSize: 13, color: colors.mutedForeground, marginTop: 6, textAlign: "center" }}>
                    No student found with Reg No "{rosterSearchReg}"
                  </Text>
                </View>
              )
            )}
          </View>
          {!studentSummary && (
            <View style={[s.noClass, { marginTop: 32 }]}>
              <Feather name="search" size={44} color={colors.mutedForeground} />
              <Text style={s.noClassTxt}>Enter your Reg No above{"\n"}to view your attendance across all classes.</Text>
            </View>
          )}
        </View>
      ) : !selectedClass || !selectedSubject ? (
        <View style={s.noClass}>
          <Feather name="book" size={48} color={colors.mutedForeground} />
          <Text style={s.noClassTxt}>Select a class above to view or mark attendance</Text>
        </View>
      ) : activeTab === "mark" ? (
        renderDateList()
      ) : activeTab === "roster" ? (
        <View style={{ flex: 1 }}>
          {/* Public search bar — always visible in public mode */}
          {publicMode && (
            <View style={{ backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border, padding: 10, gap: 8 }}>
              <View style={{ flexDirection: "row", alignItems: "center", gap: 8 }}>
                <Feather name="search" size={16} color={colors.mutedForeground} />
                <TextInput
                  style={[s.manualInput, { flex: 1 }]}
                  placeholder="Enter your Reg No to view your attendance…"
                  placeholderTextColor={colors.mutedForeground}
                  value={rosterSearchReg}
                  onChangeText={setRosterSearchReg}
                  autoCapitalize="characters"
                  onSubmitEditing={handleRosterSearch}
                  returnKeyType="search"
                />
                <TouchableOpacity
                  style={[s.manualLoadBtn, summaryLoading && { opacity: 0.6 }]}
                  onPress={handleRosterSearch}
                  disabled={summaryLoading}
                >
                  {summaryLoading
                    ? <ActivityIndicator color="#fff" size="small" />
                    : <Text style={s.manualLoadBtnTxt}>Search</Text>
                  }
                </TouchableOpacity>
              </View>
              {studentSummary !== null && (
                studentSummary.found ? (
                  <View style={{ backgroundColor: colors.background, borderRadius: 10, padding: 12, borderWidth: 1, borderColor: colors.border }}>
                    <Text style={{ fontFamily: "Inter_700Bold", fontSize: 14, color: colors.foreground, marginBottom: 8 }}>
                      {studentSummary.studentName} · {studentSummary.regNo}
                    </Text>
                    {studentSummary.rows.map(row => {
                      const pctColor = row.percentage >= 75 ? STATUS_COLORS.P : row.percentage >= 60 ? STATUS_COLORS.L : STATUS_COLORS.A;
                      return (
                        <View key={row.className} style={{ flexDirection: "row", alignItems: "center", paddingVertical: 5, borderTopWidth: 1, borderTopColor: colors.border }}>
                          <Text style={{ flex: 1, fontFamily: "Inter_500Medium", fontSize: 12, color: colors.foreground }}>{row.className}</Text>
                          <Text style={{ fontFamily: "Inter_400Regular", fontSize: 11, color: colors.mutedForeground, marginRight: 8 }}>
                            P:{row.present} A:{row.absent} L:{row.leave}
                          </Text>
                          <Text style={{ fontFamily: "Inter_700Bold", fontSize: 13, color: pctColor, minWidth: 42, textAlign: "right" }}>
                            {row.percentage}%
                          </Text>
                        </View>
                      );
                    })}
                  </View>
                ) : (
                  <Text style={{ fontFamily: "Inter_400Regular", fontSize: 13, color: colors.mutedForeground, textAlign: "center", paddingVertical: 8 }}>
                    No student found with Reg No "{rosterSearchReg}"
                  </Text>
                )
              )}
            </View>
          )}
          {/* Roster content */}
          {rosterLoading ? (
            <ActivityIndicator color={colors.primary} style={{ marginTop: 40 }} size="large" />
          ) : !roster || roster.rows.length === 0 ? (
            <View style={s.noClass}>
              <Feather name="grid" size={40} color={colors.mutedForeground} />
              <Text style={s.noClassTxt}>No attendance recorded yet for this class.</Text>
            </View>
          ) : (
          <View style={s.rosterContainer}>
            <View style={s.rosterLeft}>
              <View style={s.rosterLeftHead}>
                <Text style={s.rosterLeftHeadTxt}>Reg No / Name</Text>
              </View>
              {roster.rows.map(r => (
                <View key={r.rollNo} style={s.rosterLeftRow}>
                  <Text style={s.rosterRoll} numberOfLines={1}>{r.rollNo}</Text>
                  <Text style={s.rosterName} numberOfLines={1}>{r.name}</Text>
                </View>
              ))}
            </View>
            <ScrollView horizontal style={s.rosterRight} showsHorizontalScrollIndicator>
              <View>
                <View style={{ flexDirection: "row" }}>
                  {roster.dates.map(d => {
                    const [iso, time] = d.split("|");
                    const [, m, dy] = iso.split("-");
                    const label = `${dy}-${m}`;
                    const timeShort = time ? time.replace(":00 AM","A").replace(":00 PM","P").replace(" AM","A").replace(" PM","P") : "";
                    return (
                      <View key={d} style={[s.rosterHeadCell, { width: 42 }]}>
                        <Text style={s.rosterHeadTxt}>{label}</Text>
                        {!!timeShort && <Text style={[s.rosterHeadTxt, { fontSize: 8 }]}>{timeShort}</Text>}
                      </View>
                    );
                  })}
                  {(["P","A","L","%"] as const).map(lbl => (
                    <View key={lbl} style={s.rosterStatHead}>
                      <Text style={s.rosterHeadTxt}>{lbl}</Text>
                    </View>
                  ))}
                </View>
                {roster.rows.map((r, ri) => {
                  const pct = r.percentage;
                  const pctColor = pct >= 75 ? STATUS_COLORS.P : pct >= 60 ? STATUS_COLORS.L : STATUS_COLORS.A;
                  return (
                    <View key={r.rollNo} style={{ flexDirection: "row", backgroundColor: ri % 2 === 0 ? colors.card : colors.muted }}>
                      {roster.dates.map(d => {
                        const st = r.records[d] ?? "";
                        return (
                          <View key={d} style={[s.rosterCell, { width: 42, backgroundColor: st ? STATUS_BG[st as keyof typeof STATUS_BG] : undefined }]}>
                            <Text style={{ fontFamily: "Inter_700Bold", fontSize: 11, color: st ? STATUS_COLORS[st as keyof typeof STATUS_COLORS] : colors.border }}>
                              {st || "–"}
                            </Text>
                          </View>
                        );
                      })}
                      <View style={s.rosterStatCell}><Text style={{ fontSize: 11, fontFamily: "Inter_700Bold", color: STATUS_COLORS.P }}>{r.presentCount}</Text></View>
                      <View style={s.rosterStatCell}><Text style={{ fontSize: 11, fontFamily: "Inter_700Bold", color: STATUS_COLORS.A }}>{r.absentCount}</Text></View>
                      <View style={s.rosterStatCell}><Text style={{ fontSize: 11, fontFamily: "Inter_700Bold", color: STATUS_COLORS.L }}>{r.leaveCount}</Text></View>
                      <View style={s.rosterStatCell}><Text style={{ fontSize: 11, fontFamily: "Inter_700Bold", color: pctColor }}>{pct}%</Text></View>
                    </View>
                  );
                })}
              </View>
            </ScrollView>
          </View>
          )}
        </View>
      ) : (
        /* Students tab */
        <View style={{ flex: 1 }}>
          <View style={s.addRow}>
            <TextInput
              style={[s.addInput, { width: 110 }]}
              placeholder="Reg No"
              placeholderTextColor={colors.mutedForeground}
              value={newRoll}
              onChangeText={setNewRoll}
              autoCapitalize="characters"
            />
            <TextInput
              style={[s.addInput, { flex: 1 }]}
              placeholder="Student Name"
              placeholderTextColor={colors.mutedForeground}
              value={newName}
              onChangeText={setNewName}
            />
            <TextInput
              style={[s.addInput, { flex: 1 }]}
              placeholder="Email (optional)"
              placeholderTextColor={colors.mutedForeground}
              value={newEmail}
              onChangeText={setNewEmail}
              autoCapitalize="none"
              keyboardType="email-address"
            />
            <TouchableOpacity style={s.addBtn} onPress={handleAddStudent} disabled={addLoading}>
              {addLoading
                ? <ActivityIndicator color="#fff" size="small" />
                : <Feather name="user-plus" size={18} color="#fff" />
              }
            </TouchableOpacity>
          </View>
          <View style={s.bulkRow}>
            <TouchableOpacity style={s.bulkBtn} onPress={handleBulkUpload} disabled={bulkLoading}>
              {bulkLoading
                ? <ActivityIndicator color={colors.primary} size="small" />
                : <><Feather name="upload" size={15} color={colors.primary} /><Text style={s.bulkBtnTxt}>  Bulk Upload Students (Excel)</Text></>
              }
            </TouchableOpacity>
            <TouchableOpacity
              style={s.sampleBtn}
              onPress={() => Linking.openURL(`https://${process.env.EXPO_PUBLIC_DOMAIN}/api/attendance/students/sample`)}
            >
              <Feather name="download" size={13} color={colors.primary} />
              <Text style={s.sampleBtnTxt}>Template</Text>
            </TouchableOpacity>
          </View>
          {studentsLoading ? (
            <ActivityIndicator color={colors.primary} style={{ marginTop: 40 }} size="large" />
          ) : (
            <ScrollView contentContainerStyle={{ paddingBottom: 20 }}>
              {students.length === 0 ? (
                <View style={s.noClass}>
                  <Feather name="users" size={40} color={colors.mutedForeground} />
                  <Text style={s.noClassTxt}>No students yet. Add them above or upload an Excel file.</Text>
                </View>
              ) : (
                <>
                  <View style={[s.stuCard, { backgroundColor: "#1976D2" }]}>
                    <Text style={[s.stuNum, { color: "#fff" }]}>#</Text>
                    <View style={{ flex: 1 }}>
                      <Text style={[s.stuRoll, { color: "#fff" }]}>Reg No</Text>
                      <Text style={[s.stuName, { color: "rgba(255,255,255,0.8)" }]}>Name · Email</Text>
                    </View>
                  </View>
                  {students.map((stu, i) => (
                    <View key={stu.id} style={[s.stuCard, { backgroundColor: i % 2 === 0 ? colors.card : colors.muted }]}>
                      <Text style={s.stuNum}>{i + 1}</Text>
                      <View style={{ flex: 1 }}>
                        <Text style={s.stuRoll}>{stu.rollNo}</Text>
                        <Text style={s.stuName}>{stu.name}</Text>
                        {!!stu.email && (
                          <Text style={[s.stuName, { color: colors.primary, fontSize: 10 }]} numberOfLines={1}>{stu.email}</Text>
                        )}
                      </View>
                      <TouchableOpacity style={s.delBtn} onPress={() => setDeleteTarget(stu)} hitSlop={{ top: 12, bottom: 12, left: 8, right: 8 }}>
                        <Feather name="trash-2" size={17} color={colors.destructive} />
                      </TouchableOpacity>
                    </View>
                  ))}
                  <Text style={{ textAlign: "center", fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginTop: 12 }}>
                    {students.length} student{students.length !== 1 ? "s" : ""} enrolled
                  </Text>
                </>
              )}
            </ScrollView>
          )}
        </View>
      )}

      <PickerModal
        visible={showClassPicker}
        title="Select Class & Subject"
        items={classSubjectList.map(k => classSubjectDisplay[k])}
        selected={selectedClass && selectedSubject ? `${selectedClass} · ${selectedSubject}` : ""}
        onSelect={(displayVal) => {
          const key = classSubjectList.find(k => classSubjectDisplay[k] === displayVal);
          if (!key) return;
          const [cls, subj] = key.split("|||");
          const changed = cls !== selectedClass || subj !== selectedSubject;
          setSelectedClass(cls);
          setSelectedSubject(subj);
          if (changed) { setExpandedDate(null); setAttendance({}); }
        }}
        onClose={() => setShowClassPicker(false)}
        placeholder="Search class or subject…"
      />

      {!!errorMsg && (
        <Modal visible transparent animationType="fade">
          <View style={{ flex: 1, justifyContent: "center", alignItems: "center", backgroundColor: "rgba(0,0,0,0.45)", padding: 32 }}>
            <View style={{ backgroundColor: colors.card, borderRadius: 16, padding: 24, width: "100%", alignItems: "center" }}>
              <Feather name="alert-circle" size={32} color={colors.destructive} style={{ marginBottom: 10 }} />
              <Text style={{ fontSize: 15, fontFamily: "Inter_400Regular", color: colors.foreground, textAlign: "center", marginBottom: 20 }}>{errorMsg}</Text>
              <TouchableOpacity onPress={() => setErrorMsg("")} style={{ backgroundColor: colors.primary, borderRadius: 10, paddingVertical: 11, paddingHorizontal: 32 }}>
                <Text style={{ color: "#fff", fontSize: 15, fontFamily: "Inter_700Bold" }}>OK</Text>
              </TouchableOpacity>
            </View>
          </View>
        </Modal>
      )}

      <Modal visible={!!deleteTarget} transparent animationType="fade">
        <View style={{ flex: 1, justifyContent: "center", alignItems: "center", backgroundColor: "rgba(0,0,0,0.45)", padding: 32 }}>
          <View style={{ backgroundColor: colors.card, borderRadius: 16, padding: 24, width: "100%" }}>
            <Text style={{ fontSize: 17, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 8 }}>Remove Student</Text>
            <Text style={{ fontSize: 14, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginBottom: 24 }}>
              Remove {deleteTarget?.name} (Reg No: {deleteTarget?.rollNo}) and all their attendance records?
            </Text>
            <View style={{ flexDirection: "row", gap: 12 }}>
              <TouchableOpacity
                onPress={() => setDeleteTarget(null)}
                style={{ flex: 1, backgroundColor: colors.secondary, borderRadius: 10, paddingVertical: 12, alignItems: "center" }}
                disabled={deleteMutation.isPending}
              >
                <Text style={{ fontSize: 15, fontFamily: "Inter_600SemiBold", color: colors.foreground }}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity
                onPress={() => deleteTarget && deleteMutation.mutate(deleteTarget.id)}
                style={{ flex: 1, backgroundColor: colors.destructive, borderRadius: 10, paddingVertical: 12, alignItems: "center" }}
                disabled={deleteMutation.isPending}
              >
                {deleteMutation.isPending
                  ? <ActivityIndicator color="#fff" size="small" />
                  : <Text style={{ fontSize: 15, fontFamily: "Inter_700Bold", color: "#fff" }}>Remove</Text>
                }
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
}
