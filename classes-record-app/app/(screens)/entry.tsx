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
import { useRouter, useFocusEffect, useLocalSearchParams } from "expo-router";
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
      backgroundColor: "#1565C0", paddingTop: insets.top + (Platform.OS === "web" ? 67 : 0),
      paddingBottom: 16, paddingHorizontal: 16, borderBottomWidth: 1, borderBottomColor: "rgba(255,255,255,0.15)",
    },
    homeBtn: {
      flexDirection: "row", alignItems: "center", gap: 6,
      backgroundColor: "rgba(0,0,0,0.08)", borderRadius: 20,
      paddingHorizontal: 12, paddingVertical: 6, alignSelf: "flex-start", marginBottom: 10,
    },
    homeBtnTxt: { color: typeTextColors[type], fontFamily: "Inter_600SemiBold", fontSize: 13 },
    headerTitle: { fontSize: 22, fontFamily: "Inter_700Bold", color: "#fff" },
    headerSub: { fontSize: 13, fontFamily: "Inter_400Regular", color: "rgba(255,255,255,0.8)", marginTop: 2 },
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

  if (!user) {
    return (
      <View style={s.loginCard}>
        <TouchableOpacity style={{ flexDirection: "row", alignItems: "center", gap: 6, marginBottom: 24 }} onPress={() => router.replace("/" as never)}>
          <Feather name="home" size={16} color={colors.primary} />
          <Text style={{ color: colors.primary, fontFamily: "Inter_600SemiBold", fontSize: 13 }}>Home</Text>
        </TouchableOpacity>
        <Feather name="lock" size={48} color={colors.primary} style={s.loginIcon} />
        <Text style={s.loginTitle}>Login Required</Text>
        <Text style={s.loginSub}>Enter your credentials to record entries</Text>
        <TextInput style={s.loginInput} placeholder="Username" placeholderTextColor={colors.mutedForeground} value={loginUsername} onChangeText={setLoginUsername} autoCapitalize="none" />
        <TextInput style={s.loginInput} placeholder="Password" placeholderTextColor={colors.mutedForeground} value={loginPassword} onChangeText={setLoginPassword} secureTextEntry />
        {loginError ? <Text style={s.loginError}>{loginError}</Text> : null}
        <TouchableOpacity style={s.loginBtn} onPress={handleLogin} disabled={loginLoading}>
          {loginLoading ? <ActivityIndicator color="#fff" /> : <Text style={s.loginBtnTxt}>Login</Text>}
        </TouchableOpacity>
      </View>
    );
  }

  const canSave = !!(faculty && subject && cls && date && startTime && endTime) && !saveMutation.isPending;

  return (
    <View style={s.container}>
      <View style={s.header}>
        <View style={{ flexDirection: "row", gap: 8, marginBottom: 10 }}>
          <TouchableOpacity style={[s.homeBtn, { marginBottom: 0 }]} onPress={() => router.back()}>
            <Feather name="chevron-left" size={14} color={typeTextColors[type]} />
            <Text style={s.homeBtnTxt}>Back</Text>
          </TouchableOpacity>
          <TouchableOpacity style={[s.homeBtn, { marginBottom: 0 }]} onPress={() => router.replace("/" as never)}>
            <Feather name="home" size={14} color={typeTextColors[type]} />
            <Text style={s.homeBtnTxt}>Home</Text>
          </TouchableOpacity>
        </View>
        <View style={{ flexDirection: "row", justifyContent: "space-between", alignItems: "center" }}>
          <View>
            <Text style={s.headerTitle}>New Entry</Text>
            <Text style={s.headerSub}>Logged in as {user}</Text>
          </View>
          <TouchableOpacity
            onPress={() => setShowImport(true)}
            style={{ backgroundColor: `${typeColors[type]}55`, borderRadius: 8, padding: 8, borderWidth: 1, borderColor: `${typeTextColors[type]}44` }}
          >
            <Feather name="upload" size={18} color={typeTextColors[type]} />
          </TouchableOpacity>
        </View>
      </View>

      <KeyboardAwareScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 40 }} keyboardShouldPersistTaps="handled">
        <Text style={s.label}>Entry Type</Text>
        <View style={s.optRow}>
          {TYPE_OPTIONS.map((t) => (
            <TouchableOpacity
              key={t}
              style={[s.optBtn, type === t && { borderColor: typeTextColors[t], backgroundColor: typeColors[t] }]}
              onPress={() => setType(t)}
            >
              <Text style={[s.optTxt, type === t && { color: typeTextColors[t], fontFamily: "Inter_700Bold" }]}>{t}</Text>
            </TouchableOpacity>
          ))}
        </View>

        <View style={s.divider} />

        <Text style={s.label}>Faculty *</Text>
        <TouchableOpacity style={[s.pickerBtn, faculty && s.pickerBtnActive]} onPress={() => setActivePicker("faculty")}>
          <Text style={[s.pickerTxt, faculty && s.pickerTxtActive]} numberOfLines={1}>{faculty || "Tap to select faculty…"}</Text>
          <Feather name="chevron-down" size={16} color={faculty ? colors.primary : colors.mutedForeground} />
        </TouchableOpacity>

        <Text style={s.label}>Subject *</Text>
        <TouchableOpacity
          style={[s.pickerBtn, subject && s.pickerBtnActive, !faculty && { opacity: 0.5 }]}
          onPress={() => faculty && setActivePicker("subject")}
        >
          <Text style={[s.pickerTxt, subject && s.pickerTxtActive]} numberOfLines={1}>
            {subject || (faculty ? "Tap to select subject…" : "Select faculty first")}
          </Text>
          <Feather name="chevron-down" size={16} color={subject ? colors.primary : colors.mutedForeground} />
        </TouchableOpacity>

        <Text style={s.label}>Class *</Text>
        <TouchableOpacity
          style={[s.pickerBtn, cls && s.pickerBtnActive, !subject && { opacity: 0.5 }]}
          onPress={() => subject && setActivePicker("cls")}
        >
          <Text style={[s.pickerTxt, cls && s.pickerTxtActive]} numberOfLines={1}>
            {cls || (subject ? "Tap to select class…" : "Select subject first")}
          </Text>
          <Feather name="chevron-down" size={16} color={cls ? colors.primary : colors.mutedForeground} />
        </TouchableOpacity>

        <View style={s.divider} />

        <Text style={s.label}>Date *</Text>
        <View style={s.dateRow}>
          <TextInput
            style={s.dateInput} value={date} onChangeText={setDate}
            placeholder="YYYY-MM-DD" placeholderTextColor={colors.mutedForeground}
          />
          {selectedDay ? <View style={s.dayBadge}><Text style={s.dayBadgeTxt}>{selectedDay}</Text></View> : null}
        </View>

        {cls && date && (
          <>
            <View style={s.divider} />

            <Text style={s.label}>
              Start Time *{type !== "Makeup" ? " (scheduled slots)" : " (free slots)"}
            </Text>
            {startSlots.length === 0 ? (
              <Text style={s.noSlots}>
                {type === "Makeup" ? "No free slots available for this class/date" : "No scheduled class found for this faculty/subject/class on this day"}
              </Text>
            ) : (
              <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                <View style={{ flexDirection: "row", gap: 8, paddingBottom: 4 }}>
                  {startSlots.map((t) => (
                    <TouchableOpacity key={t} style={[s.optBtn, startTime === t && s.optBtnActive]} onPress={() => setStartTime(t)}>
                      <Text style={[s.optTxt, startTime === t && s.optTxtActive]}>{t}</Text>
                    </TouchableOpacity>
                  ))}
                </View>
              </ScrollView>
            )}

            {startTime ? (
              <>
                <Text style={s.label}>End Time *</Text>
                <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                  <View style={{ flexDirection: "row", gap: 8, paddingBottom: 4 }}>
                    {Array.from({ length: 17 - hourFromTime(startTime) }, (_, i) => formatHour(hourFromTime(startTime) + 1 + i)).map((t) => (
                      <TouchableOpacity key={t} style={[s.optBtn, endTime === t && s.optBtnActive]} onPress={() => setEndTime(t)}>
                        <Text style={[s.optTxt, endTime === t && s.optTxtActive]}>{t}</Text>
                      </TouchableOpacity>
                    ))}
                  </View>
                </ScrollView>

                <Text style={s.label}>Location</Text>
                {locationSlots.length > 0 ? (
                  <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                    <View style={{ flexDirection: "row", gap: 8, paddingBottom: 4 }}>
                      {locationSlots.map((l) => (
                        <TouchableOpacity key={l} style={[s.optBtn, location === l && s.optBtnActive]} onPress={() => setLocation(l)}>
                          <Text style={[s.optTxt, location === l && s.optTxtActive]}>{l}</Text>
                        </TouchableOpacity>
                      ))}
                    </View>
                  </ScrollView>
                ) : (
                  <TextInput
                    style={{ backgroundColor: colors.card, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12, fontFamily: "Inter_400Regular", fontSize: 14, color: colors.foreground, borderWidth: 1, borderColor: colors.border }}
                    value={location} onChangeText={setLocation} placeholder="Enter location" placeholderTextColor={colors.mutedForeground}
                  />
                )}
              </>
            ) : null}
          </>
        )}

        <TouchableOpacity
          style={[s.saveBtn, !canSave && s.saveBtnDisabled]}
          disabled={!canSave}
          onPress={() => saveMutation.mutate({ Faculty: faculty, Subject: subject, Class: cls, Date: date, Location: location, Time: startTime, EndTime: endTime, Type: type, User: user! })}
        >
          {saveMutation.isPending
            ? <ActivityIndicator color="#fff" />
            : <Text style={s.saveBtnTxt}>Save {type} Entry</Text>
          }
        </TouchableOpacity>
      </KeyboardAwareScrollView>

      <ImportPanel visible={showImport} onClose={() => setShowImport(false)} title="Import Data Entries">
        <ExcelImportButton
          label="Import Data Entries"
          description="DataEntries.xlsx — Missed / Late / Makeup entries with Faculty, Subject, Class, Date, Type"
          icon="file-text"
          variant="primary"
          onImport={importEntriesExcel}
          onSuccess={() => { setShowImport(false); qc.invalidateQueries({ queryKey: ["schedule"] }); }}
        />
      </ImportPanel>

      <PickerModal visible={activePicker === "faculty"} title="Select Faculty" items={facultyList} selected={faculty}
        onSelect={(v) => { setFaculty(v); setSubject(""); setCls(""); }} onClose={() => setActivePicker(null)} />

      {/* Makeup Email Notification Modal */}
      <Modal visible={showNotify} transparent animationType="slide">
        <View style={{ flex: 1, justifyContent: "flex-end", backgroundColor: "rgba(0,0,0,0.5)" }}>
          <View style={{ backgroundColor: "#fff", borderTopLeftRadius: 20, borderTopRightRadius: 20, padding: 24, maxHeight: "80%" }}>
            <View style={{ flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
              <Text style={{ fontSize: 17, fontFamily: "Inter_700Bold", color: "#1A1A1A" }}>Notify Students</Text>
              <TouchableOpacity onPress={() => { setShowNotify(false); Alert.alert("Saved ✓", "Makeup entry saved successfully."); }}>
                <Feather name="x" size={22} color="#666" />
              </TouchableOpacity>
            </View>
            {lastMakeup && (
              <View style={{ backgroundColor: "#F0FFF4", borderRadius: 10, padding: 12, marginBottom: 12, borderWidth: 1, borderColor: "#C6F6D5" }}>
                <Text style={{ fontFamily: "Inter_700Bold", fontSize: 13, color: "#2E7D32" }}>Makeup Class Saved ✓</Text>
                <Text style={{ fontFamily: "Inter_400Regular", fontSize: 12, color: "#555", marginTop: 4 }}>
                  {lastMakeup.subject} · {lastMakeup.cls}{"\n"}{lastMakeup.date} at {lastMakeup.time}{lastMakeup.location ? ` · ${lastMakeup.location}` : ""}
                </Text>
              </View>
            )}
            {notifyStudents.length === 0 ? (
              <View style={{ alignItems: "center", paddingVertical: 24 }}>
                <Feather name="mail" size={36} color="#bbb" />
                <Text style={{ fontFamily: "Inter_400Regular", fontSize: 13, color: "#888", marginTop: 10, textAlign: "center" }}>
                  No student emails found for this class.{"\n"}Add emails in the Attendance → Students tab.
                </Text>
              </View>
            ) : (
              <>
                <Text style={{ fontFamily: "Inter_600SemiBold", fontSize: 12, color: "#888", marginBottom: 8, textTransform: "uppercase", letterSpacing: 0.5 }}>
                  {notifyStudents.filter(s => s.email).length} of {notifyStudents.length} students have emails
                </Text>
                <ScrollView style={{ maxHeight: 200, marginBottom: 16 }}>
                  {notifyStudents.map(stu => (
                    <View key={stu.rollNo} style={{ flexDirection: "row", alignItems: "center", paddingVertical: 6, borderBottomWidth: 1, borderBottomColor: "#F0F0F0" }}>
                      <Feather name={stu.email ? "mail" : "user"} size={14} color={stu.email ? "#1976D2" : "#bbb"} style={{ marginRight: 10 }} />
                      <View style={{ flex: 1 }}>
                        <Text style={{ fontFamily: "Inter_500Medium", fontSize: 12, color: "#1A1A1A" }}>{stu.name}</Text>
                        <Text style={{ fontFamily: "Inter_400Regular", fontSize: 11, color: "#888" }}>{stu.email || "No email"}</Text>
                      </View>
                    </View>
                  ))}
                </ScrollView>
                <TouchableOpacity
                  style={{ backgroundColor: "#1976D2", borderRadius: 12, padding: 14, alignItems: "center", flexDirection: "row", justifyContent: "center", gap: 8 }}
                  onPress={() => {
                    const emails = notifyStudents.filter(s => s.email).map(s => s.email).join(",");
                    const subj = encodeURIComponent(`Makeup Class: ${lastMakeup?.subject ?? ""}`);
                    const body = encodeURIComponent(
                      `Dear Students,\n\nA makeup class has been scheduled:\n\nSubject: ${lastMakeup?.subject ?? ""}\nClass: ${lastMakeup?.cls ?? ""}\nDate: ${lastMakeup?.date ?? ""}\nTime: ${lastMakeup?.time ?? ""}${lastMakeup?.location ? `\nLocation: ${lastMakeup.location}` : ""}\n\nPlease ensure your attendance.\n\nRegards`
                    );
                    Linking.openURL(`mailto:${emails}?subject=${subj}&body=${body}`);
                  }}
                >
                  <Feather name="send" size={16} color="#fff" />
                  <Text style={{ color: "#fff", fontFamily: "Inter_700Bold", fontSize: 15 }}>Open Email Client</Text>
                </TouchableOpacity>
              </>
            )}
            <TouchableOpacity
              style={{ marginTop: 12, padding: 12, alignItems: "center" }}
              onPress={() => { setShowNotify(false); Alert.alert("Saved ✓", "Makeup entry saved successfully."); }}
            >
              <Text style={{ fontFamily: "Inter_500Medium", fontSize: 14, color: "#888" }}>Skip Notification</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
      <PickerModal visible={activePicker === "subject"} title="Select Subject" items={subjectList} selected={subject}
        onSelect={(v) => { setSubject(v); setCls(""); }} onClose={() => setActivePicker(null)} />
      <PickerModal visible={activePicker === "cls"} title="Select Class" items={classList} selected={cls}
        onSelect={(v) => { setCls(v); }} onClose={() => setActivePicker(null)} />
    </View>
  );
}
