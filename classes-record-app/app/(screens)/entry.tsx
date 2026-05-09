import React, { useState, useMemo, useEffect, useCallback } from "react";
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  ActivityIndicator, Alert, Platform, TextInput, Modal, Linking,
} from "react-native";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import * as Haptics from "expo-haptics";
import { KeyboardAwareScrollView } from "react-native-keyboard-controller";
import { useRouter, useFocusEffect } from "expo-router";
import * as ScreenOrientation from "expo-screen-orientation";

import { useColors } from "@/hooks/useColors";
import { useAuth } from "@/context/AuthContext";
import {
  fetchSchedule, fetchOptions, saveEntry, importEntriesExcel,
  fetchStudentEmailsForNotify,
  ScheduleRow, ScheduleOptions,
} from "@/hooks/useApi";
import { PickerModal } from "@/components/PickerModal";
import { ExcelImportButton, ImportPanel } from "@/components/ExcelImportButton";

const TYPE_OPTIONS = ["Missed", "Late", "Makeup"] as const;
type EntryType = typeof TYPE_OPTIONS[number];
const DAY_NAMES = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

function getDateDay(dateStr: string): string {
  if (!dateStr) return "";
  const parts = dateStr.split("-");
  if (parts.length !== 3) return "";
  const d = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
  return DAY_NAMES[d.getDay()] ?? "";
}

function formatHour(h: number): string {
  const t12 = (h % 12) || 12;
  return `${t12.toString().padStart(2, "0")}:00 ${h >= 12 ? "PM" : "AM"}`;
}

function hourFromTime(t: string): number {
  const m = t.match(/(\d{1,2}):(\d{2})\s*(AM|PM)/i);
  if (!m) return 0;
  let h = Number(m[1]);
  const ap = m[3].toUpperCase();
  if (ap === "PM" && h !== 12) h += 12;
  if (ap === "AM" && h === 12) h = 0;
  return h;
}

type PickerField = "faculty" | "subject" | "cls" | null;

export default function EntryScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const qc = useQueryClient();
  const { user, login } = useAuth();
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

  const [loginUsername, setLoginUsername] = useState("");
  const [loginPassword, setLoginPassword] = useState("");
  const [loginLoading, setLoginLoading] = useState(false);
  const [loginError, setLoginError] = useState("");
  const [showNotify, setShowNotify] = useState(false);
  const [notifyStudents, setNotifyStudents] = useState<{ rollNo: string; name: string; email: string }[]>([]);
  const [lastMakeup, setLastMakeup] = useState<{ subject: string; cls: string; date: string; time: string; location: string } | null>(null);

  const [faculty, setFaculty] = useState("");
  const [subject, setSubject] = useState("");
  const [cls, setCls] = useState("");
  const [date, setDate] = useState(() => {
    const d = new Date();
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
  });
  const [type, setType] = useState<EntryType>("Makeup");
  const [startTime, setStartTime] = useState("");
  const [endTime, setEndTime] = useState("");
  const [location, setLocation] = useState("");
  const [activePicker, setActivePicker] = useState<PickerField>(null);
  const [showImport, setShowImport] = useState(false);

  const { data: schedule = [] } = useQuery({ queryKey: ["schedule"], queryFn: fetchSchedule });
  const { data: options } = useQuery<ScheduleOptions>({ queryKey: ["options"], queryFn: fetchOptions });

  const facultyList = useMemo(() => {
    const fromDB = [...new Set(schedule.filter((r) => !r.Type).map((r) => r.Faculty))].sort();
    if (fromDB.length > 0) return fromDB;
    return options?.faculty ?? [];
  }, [schedule, options]);

  const subjectList = useMemo(() => {
    if (!faculty) return [];
    const fromDB = [...new Set(schedule.filter((r) => !r.Type && r.Faculty === faculty).map((r) => r.Subject))].sort();
    if (fromDB.length > 0) return fromDB;
    return options?.facSubjects[faculty] ?? options?.subjects ?? [];
  }, [schedule, options, faculty]);

  const classList = useMemo(() => {
    if (!faculty || !subject) return [];
    const fromDB = [...new Set(schedule.filter((r) => !r.Type && r.Faculty === faculty && r.Subject === subject).map((r) => r.Class))].sort();
    if (fromDB.length > 0) return fromDB;
    const key = faculty + "|||" + subject;
    return options?.facSubClasses[key] ?? options?.classes ?? [];
  }, [schedule, options, faculty, subject]);

  const selectedDay = getDateDay(date);

  const { startSlots, endSlots, locationSlots } = useMemo(() => {
    if (!faculty || !subject || !cls || !date) return { startSlots: [], endSlots: [], locationSlots: [] };

    const dayRows = schedule.filter(
      (r) => !r.Type && r.Day === selectedDay && r.Faculty === faculty && r.Subject === subject && r.Class === cls
    );

    if (type === "Missed" || type === "Late") {
      const busyHours = dayRows.map((r) => Math.floor((r.SortKey || 0) / 60));
      const start = [...new Set(busyHours)].sort((a, b) => a - b).map(formatHour);
      const locs = [...new Set(dayRows.map((r) => r.Location).filter(Boolean))];
      return { startSlots: start, endSlots: [], locationSlots: locs };
    } else {
      const allBusyHours = schedule.filter((r) => {
        if (!r.Type && r.Day === selectedDay && r.Class === cls) return true;
        if (r.Type === "Makeup" && r.Class === cls && r.EntryDate) {
          const d = new Date(r.EntryDate);
          const s = `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,"0")}-${String(d.getDate()).padStart(2,"0")}`;
          return s === date;
        }
        return false;
      }).map((r) => Math.floor((r.SortKey || 0) / 60));

      const freeStart = Array.from({ length: 9 }, (_, i) => i + 9).filter((h) => !allBusyHours.includes(h)).map(formatHour);

      const busyLocs = new Set(schedule.filter((r) => {
        const h = Math.floor((r.SortKey || 0) / 60);
        return !r.Type && r.Day === selectedDay && allBusyHours.includes(h);
      }).map((r) => r.Location).filter(Boolean));

      const allLocs = options?.locations ?? [...new Set(schedule.map((r) => r.Location).filter(Boolean))].sort();
      const freeLocs = allLocs.filter((l) => !busyLocs.has(l));
      return { startSlots: freeStart, endSlots: [], locationSlots: freeLocs };
    }
  }, [schedule, options, faculty, subject, cls, date, selectedDay, type]);

  useEffect(() => { setStartTime(startSlots[0] || ""); }, [startSlots]);
  useEffect(() => { setLocation(locationSlots[0] || ""); }, [locationSlots]);
  useEffect(() => {
    if (startTime) setEndTime(formatHour(hourFromTime(startTime) + 1));
  }, [startTime]);

  const saveMutation = useMutation({
    mutationFn: saveEntry,
    onSuccess: async (_, vars) => {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      setStartTime(""); setEndTime(""); setLocation("");
      qc.invalidateQueries({ queryKey: ["schedule"] });
      if (vars.Type === "Makeup" && user) {
        setLastMakeup({ subject: vars.Subject, cls: vars.Class, date: vars.Date, time: vars.Time, location: vars.Location ?? "" });
        try {
          const studs = await fetchStudentEmailsForNotify(user, vars.Class);
          setNotifyStudents(studs);
        } catch { setNotifyStudents([]); }
        setShowNotify(true);
      } else {
        Alert.alert("Saved ✓", "Entry saved successfully");
      }
    },
    onError: () => Alert.alert("Error", "Failed to save entry"),
  });

  const handleLogin = async () => {
    if (!loginUsername || !loginPassword) { setLoginError("Enter username and password"); return; }
    setLoginLoading(true); setLoginError("");
    const result = await login(loginUsername, loginPassword);
    setLoginLoading(false);
    if (!result.success) setLoginError(result.message || "Invalid credentials");
  };

  const typeColors: Record<EntryType, string> = {
    Missed: colors.errorBg, Late: "#FFE1F4", Makeup: colors.successBg,
  };
  const typeTextColors: Record<EntryType, string> = {
    Missed: colors.destructive, Late: "#C2185B", Makeup: colors.success,
  };

  const s = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    header: {
      backgroundColor: typeColors[type], paddingTop: insets.top + (Platform.OS === "web" ? 67 : 0),
      paddingBottom: 16, paddingHorizontal: 16, borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    homeBtn: {
      flexDirection: "row", alignItems: "center", gap: 6,
      backgroundColor: "rgba(0,0,0,0.08)", borderRadius: 20,
      paddingHorizontal: 12, paddingVertical: 6, alignSelf: "flex-start", marginBottom: 10,
    },
    homeBtnTxt: { color: typeTextColors[type], fontFamily: "Inter_600SemiBold", fontSize: 13 },
    headerTitle: { fontSize: 22, fontFamily: "Inter_700Bold", color: typeTextColors[type] },
    headerSub: { fontSize: 13, fontFamily: "Inter_400Regular", color: typeTextColors[type], opacity: 0.8, marginTop: 2 },
    scroll: { padding: 16 },
    label: { fontSize: 12, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground, marginBottom: 6, marginTop: 16, textTransform: "uppercase", letterSpacing: 0.5 },
    pickerBtn: {
      backgroundColor: colors.card, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12,
      borderWidth: 1, borderColor: colors.border, flexDirection: "row", alignItems: "center", justifyContent: "space-between",
    },
    pickerBtnActive: { borderColor: colors.primary, backgroundColor: colors.secondary },
    pickerTxt: { fontFamily: "Inter_400Regular", fontSize: 14, color: colors.mutedForeground, flex: 1 },
    pickerTxtActive: { color: colors.foreground, fontFamily: "Inter_500Medium" },
    optRow: { flexDirection: "row", gap: 8, flexWrap: "wrap" },
    optBtn: { paddingHorizontal: 14, paddingVertical: 9, borderRadius: 8, borderWidth: 1, borderColor: colors.border, backgroundColor: colors.card },
    optBtnActive: { backgroundColor: colors.primary, borderColor: colors.primary },
    optTxt: { fontFamily: "Inter_500Medium", fontSize: 13, color: colors.foreground },
    optTxtActive: { color: "#fff" },
    dateRow: { flexDirection: "row", alignItems: "center", gap: 8 },
    dayBadge: { backgroundColor: colors.secondary, paddingHorizontal: 12, paddingVertical: 10, borderRadius: 10, borderWidth: 1, borderColor: colors.primary },
    dayBadgeTxt: { fontSize: 14, fontFamily: "Inter_700Bold", color: colors.primary },
    dateInput: {
      flex: 1, backgroundColor: colors.card, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12,
      fontFamily: "Inter_400Regular", fontSize: 14, color: colors.foreground,
      borderWidth: 1, borderColor: colors.border,
    },
    noSlots: { color: colors.mutedForeground, fontFamily: "Inter_400Regular", fontSize: 13, marginTop: 4, fontStyle: "italic" },
    saveBtn: { backgroundColor: colors.primary, borderRadius: 12, padding: 16, alignItems: "center", marginTop: 24, marginBottom: 20 },
    saveBtnDisabled: { opacity: 0.5 },
    saveBtnTxt: { color: "#fff", fontFamily: "Inter_700Bold", fontSize: 16 },
    loginCard: { flex: 1, justifyContent: "center", padding: 32, backgroundColor: colors.background, paddingTop: insets.top + (Platform.OS === "web" ? 67 : 0) },
    loginIcon: { alignSelf: "center", marginBottom: 24 },
    loginTitle: { fontSize: 26, fontFamily: "Inter_700Bold", color: colors.foreground, textAlign: "center", marginBottom: 8 },
    loginSub: { fontSize: 14, fontFamily: "Inter_400Regular", color: colors.mutedForeground, textAlign: "center", marginBottom: 32 },
    loginInput: {
      backgroundColor: colors.card, borderRadius: 12, paddingHorizontal: 16, paddingVertical: 14,
      fontFamily: "Inter_400Regular", fontSize: 15, color: colors.foreground,
      borderWidth: 1, borderColor: colors.border, marginBottom: 12,
    },
    loginError: { color: colors.destructive, fontSize: 13, fontFamily: "Inter_400Regular", marginBottom: 12, textAlign: "center" },
    loginBtn: { backgroundColor: colors.primary, borderRadius: 12, padding: 16, alignItems: "center", marginTop: 8 },
    loginBtnTxt: { color: "#fff", fontFamily: "Inter_700Bold", fontSize: 16 },
    divider: { height: 1, backgroundColor: colors.border, marginVertical: 12 },
  });


