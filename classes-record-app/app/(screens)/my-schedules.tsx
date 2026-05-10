import React, { useState, useCallback } from "react";
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  TextInput, ActivityIndicator, Modal, Platform,
} from "react-native";
import DateTimePicker from "@react-native-community/datetimepicker";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useFocusEffect } from "expo-router";
import * as ScreenOrientation from "expo-screen-orientation";

import { useColors } from "@/hooks/useColors";
import { useAuth } from "@/context/AuthContext";
import {
  fetchUserSchedules, createUserSchedule, deleteUserSchedule,
  toggleSchedulePublic, changePassword, recoverPasswordWithPin, UserSchedule,
} from "@/hooks/useApi";

function fmtDate(iso: string | null | undefined): string {
  if (!iso) return "—";
  const clean = iso.split("T")[0];
  const [y, m, d] = clean.split("-");
  const months = ["January","February","March","April","May","June","July","August","September","October","November","December"];
  return `${parseInt(d, 10)} ${months[parseInt(m, 10) - 1]} ${y}`;
}

function toIso(d: Date): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${dd}`;
}

export default function MySchedulesScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const qc = useQueryClient();
  const { user, login, logout, isLoading: authLoading } = useAuth();

  useFocusEffect(
    useCallback(() => {
      if (Platform.OS !== "web") {
        ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.PORTRAIT_UP).catch(() => {});
      }
    }, [])
  );

  const [loginUsername, setLoginUsername] = useState("");
  const [loginPassword, setLoginPassword] = useState("");
  const [loginPin, setLoginPin] = useState("");
  const [loginLoading, setLoginLoading] = useState(false);
  const [registerMode, setRegisterMode] = useState(false);

  const [showChangePassword, setShowChangePassword] = useState(false);
  const [changeCurrentPassword, setChangeCurrentPassword] = useState("");
  const [changeNewPassword, setChangeNewPassword] = useState("");
  const [changeConfirmPassword, setChangeConfirmPassword] = useState("");
  const [changeLoading, setChangeLoading] = useState(false);

  const [showRecover, setShowRecover] = useState(false);
  const [recoverUsername, setRecoverUsername] = useState("");
  const [recoverPin, setRecoverPin] = useState("");
  const [recoverNewPassword, setRecoverNewPassword] = useState("");
  const [recoverConfirmPassword, setRecoverConfirmPassword] = useState("");
  const [recoverLoading, setRecoverLoading] = useState(false);

  const [showCreate, setShowCreate] = useState(false);
  const [newName, setNewName] = useState("");
  const [startDate, setStartDate] = useState<Date>(new Date());
  const [endDate, setEndDate] = useState<Date>(new Date());
  const [pickerTarget, setPickerTarget] = useState<"start" | "end" | null>(null);

  const [deleteTarget, setDeleteTarget] = useState<UserSchedule | null>(null);
  const [errorMsg, setErrorMsg] = useState("");

  const { data: schedules = [], isLoading: schedulesLoading } = useQuery({
    queryKey: ["userSchedules", user],
    queryFn: () => fetchUserSchedules(user!),
    enabled: !!user,
  });

  const createMutation = useMutation({
    mutationFn: ({ name, sd, ed }: { name: string; sd?: string; ed?: string }) =>
      createUserSchedule(user!, name, sd, ed),
    onSuccess: (data) => {
      if (data.error) { setErrorMsg(data.error); return; }
      qc.invalidateQueries({ queryKey: ["userSchedules", user] });
      qc.invalidateQueries({ queryKey: ["publicSchedules"] });
      setShowCreate(false);
      setNewName("");
      setStartDate(null);
      setEndDate(null);
    },
    onError: () => setErrorMsg("Could not create schedule"),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteUserSchedule(id),
    onSuccess: () => {
      setDeleteTarget(null);
      qc.invalidateQueries({ queryKey: ["userSchedules", user] });
      qc.invalidateQueries({ queryKey: ["publicSchedules"] });
    },
    onError: () => { setDeleteTarget(null); setErrorMsg("Could not delete schedule"); },
  });

  const publicMutation = useMutation({
    mutationFn: ({ id, isPublic }: { id: number; isPublic: boolean }) =>
      toggleSchedulePublic(id, isPublic),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["userSchedules", user] });
      qc.invalidateQueries({ queryKey: ["publicSchedules"] });
    },
    onError: () => setErrorMsg("Could not update schedule visibility"),
  });

  async function handleLogin() {
    if (!loginUsername.trim() || !loginPassword.trim()) {
      setErrorMsg("Enter username and password"); return;
    }
    setLoginLoading(true);
    const res = await login(loginUsername.trim(), loginPassword.trim());
    setLoginLoading(false);
    if (!res.success) setErrorMsg(res.message ?? "Invalid credentials");
  }

  async function handleRegister() {
    if (!loginUsername.trim() || !loginPassword.trim()) {
      setErrorMsg("Enter username and password"); return;
    }
    if (loginPassword.trim().length < 4) {
      setErrorMsg("Password must be at least 4 characters"); return;
    }
    if (!/^\d{4}$/.test(loginPin.trim())) {
      setErrorMsg("PIN must be exactly 4 digits (0–9)"); return;
    }
    setLoginLoading(true);
    const API_BASE = `https://${process.env.EXPO_PUBLIC_DOMAIN}/api`;
    try {
      const res = await fetch(`${API_BASE}/auth/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username: loginUsername.trim(), password: loginPassword.trim(), pin: loginPin.trim() }),
      });
      const data = await res.json();
      setLoginLoading(false);
      if (data.success) {
        await login(loginUsername.trim(), loginPassword.trim());
      } else {
        setErrorMsg(data.message ?? "Could not create account");
      }
    } catch {
      setLoginLoading(false);
      setErrorMsg("Connection error");
    }
  }

  async function handleChangePassword() {
    if (!changeCurrentPassword.trim() || !changeNewPassword.trim() || !changeConfirmPassword.trim()) {
      setErrorMsg("All fields are required"); return;
    }
    if (changeNewPassword.trim().length < 4) {
      setErrorMsg("New password must be at least 4 characters"); return;
    }
    if (changeNewPassword.trim() !== changeConfirmPassword.trim()) {
      setErrorMsg("Passwords do not match"); return;
    }
    setChangeLoading(true);
    const res = await changePassword(user!, changeCurrentPassword.trim(), changeNewPassword.trim());
    setChangeLoading(false);
    if (res.success) {
      setShowChangePassword(false);
      setChangeCurrentPassword(""); setChangeNewPassword(""); setChangeConfirmPassword("");
      setErrorMsg("Password changed successfully.");
    } else {
      setErrorMsg(res.message ?? "Could not change password");
    }
  }

  async function handleRecoverPassword() {
    if (!recoverUsername.trim() || !recoverPin.trim() || !recoverNewPassword.trim() || !recoverConfirmPassword.trim()) {
      setErrorMsg("All fields are required"); return;
    }
    if (!/^\d{4}$/.test(recoverPin.trim())) {
      setErrorMsg("PIN must be exactly 4 digits"); return;
    }
    if (recoverNewPassword.trim().length < 4) {
      setErrorMsg("New password must be at least 4 characters"); return;
    }
    if (recoverNewPassword.trim() !== recoverConfirmPassword.trim()) {
      setErrorMsg("Passwords do not match"); return;
    }
    setRecoverLoading(true);
    const res = await recoverPasswordWithPin(recoverUsername.trim(), recoverPin.trim(), recoverNewPassword.trim());
    setRecoverLoading(false);
    if (res.success) {
      setShowRecover(false);
      setRecoverUsername(""); setRecoverPin(""); setRecoverNewPassword(""); setRecoverConfirmPassword("");
      setErrorMsg("Password recovered. You can now sign in with your new password.");
    } else {
      setErrorMsg(res.message ?? "Recovery failed");
    }
  }

  const s = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    header: {
      backgroundColor: colors.primary,
      paddingTop: insets.top + (Platform.OS === "web" ? 67 : 16),
      paddingBottom: 20,
      paddingHorizontal: 20,
    },
    headerRow: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 10 },
    homeBtn: {
      flexDirection: "row", alignItems: "center", gap: 5,
      backgroundColor: "rgba(255,255,255,0.2)", borderRadius: 20,
      paddingHorizontal: 12, paddingVertical: 6,
    },
    homeBtnTxt: { color: "#fff", fontSize: 13, fontFamily: "Inter_600SemiBold" },
    headerTitle: { color: "#fff", fontSize: 22, fontFamily: "Inter_700Bold" },
    headerSub: { color: "rgba(255,255,255,0.75)", fontSize: 13, fontFamily: "Inter_400Regular", marginTop: 2 },

    loginBox: { margin: 20, padding: 24, backgroundColor: colors.card, borderRadius: 16, borderWidth: 1, borderColor: colors.border },
    loginTitle: { fontSize: 18, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 4 },
    loginSub: { fontSize: 13, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginBottom: 20 },
    input: {
      backgroundColor: colors.background, borderWidth: 1, borderColor: colors.border,
      borderRadius: 10, padding: 12, fontSize: 14, fontFamily: "Inter_400Regular",
      color: colors.foreground, marginBottom: 12,
    },
    loginBtn: {
      backgroundColor: colors.primary, borderRadius: 10, paddingVertical: 13,
      alignItems: "center", marginTop: 4,
    },
    loginBtnTxt: { color: "#fff", fontSize: 15, fontFamily: "Inter_700Bold" },
    switchRow: { flexDirection: "row", justifyContent: "center", marginTop: 16, gap: 4 },
    switchTxt: { fontSize: 13, fontFamily: "Inter_400Regular", color: colors.mutedForeground },
    switchLink: { fontSize: 13, fontFamily: "Inter_600SemiBold", color: colors.primary },

    fab: {
      position: "absolute", bottom: insets.bottom + 24, right: 24,
      backgroundColor: colors.primary, width: 56, height: 56, borderRadius: 28,
      alignItems: "center", justifyContent: "center",
      shadowColor: "#000", shadowOffset: { width: 0, height: 3 }, shadowOpacity: 0.2, shadowRadius: 6, elevation: 6,
    },

    card: {
      marginHorizontal: 16, marginTop: 12, backgroundColor: colors.card,
      borderRadius: 14, borderWidth: 1, borderColor: colors.border, padding: 16,
      flexDirection: "row", alignItems: "center",
      shadowColor: "#000", shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.05, shadowRadius: 3, elevation: 2,
    },
    cardIcon: {
      width: 44, height: 44, borderRadius: 22,
      backgroundColor: colors.primary + "18", alignItems: "center", justifyContent: "center", marginRight: 14,
    },
    cardTitle: { fontSize: 15, fontFamily: "Inter_700Bold", color: colors.foreground },
    cardSub: { fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginTop: 2 },
    publicBadge: {
      flexDirection: "row", alignItems: "center", gap: 4,
      backgroundColor: "#E3F2FD", borderRadius: 10, paddingHorizontal: 7, paddingVertical: 3,
      marginTop: 5, alignSelf: "flex-start",
    },
    publicBadgeTxt: { fontSize: 11, fontFamily: "Inter_600SemiBold", color: "#1565C0" },
    actionBtns: { flexDirection: "row", alignItems: "center", gap: 4, marginLeft: "auto" as never },
    globeBtn: { padding: 8 },
    delBtn: { padding: 8 },

    empty: { alignItems: "center", marginTop: 60, paddingHorizontal: 40 },
    emptyIcon: { marginBottom: 16 },
    emptyTxt: { fontSize: 16, fontFamily: "Inter_700Bold", color: colors.foreground, textAlign: "center", marginBottom: 8 },
    emptySub: { fontSize: 13, fontFamily: "Inter_400Regular", color: colors.mutedForeground, textAlign: "center" },

    overlay: { flex: 1, backgroundColor: "rgba(0,0,0,0.5)", justifyContent: "flex-end" },
    sheet: {
      backgroundColor: colors.card, borderTopLeftRadius: 20, borderTopRightRadius: 20,
      padding: 24, paddingBottom: insets.bottom + 24,
    },
    sheetTitle: { fontSize: 17, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 16 },
    sheetInput: {
      backgroundColor: colors.background, borderWidth: 1, borderColor: colors.border,
      borderRadius: 10, padding: 12, fontSize: 14, fontFamily: "Inter_400Regular",
      color: colors.foreground, marginBottom: 12,
    },
    sheetLabel: { fontSize: 12, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground, marginBottom: 6, textTransform: "uppercase", letterSpacing: 0.5 },
    dateRow: { flexDirection: "row", gap: 10, marginBottom: 16 },
    datePill: {
      flex: 1, flexDirection: "row", alignItems: "center", gap: 6,
      backgroundColor: colors.background, borderWidth: 1, borderColor: colors.border,
      borderRadius: 10, paddingHorizontal: 12, paddingVertical: 11,
    },
    datePillTxt: { fontSize: 13, fontFamily: "Inter_400Regular", flex: 1 },
    sheetBtn: { backgroundColor: colors.primary, borderRadius: 10, paddingVertical: 13, alignItems: "center" },
    sheetBtnTxt: { color: "#fff", fontSize: 15, fontFamily: "Inter_700Bold" },
    sheetCancel: { alignItems: "center", marginTop: 12, paddingVertical: 8 },
    sheetCancelTxt: { color: colors.mutedForeground, fontSize: 14, fontFamily: "Inter_400Regular" },

    logoutRow: { flexDirection: "row", justifyContent: "flex-end", marginHorizontal: 16, marginTop: 16, marginBottom: 4 },
    logoutBtn: {
      flexDirection: "row", alignItems: "center", gap: 5,
      backgroundColor: colors.secondary, borderRadius: 20, paddingHorizontal: 12, paddingVertical: 6,
    },
    logoutTxt: { fontSize: 13, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground },
  });

  if (authLoading) {
    return (
      <View style={[s.container, { justifyContent: "center", alignItems: "center" }]}>
        <ActivityIndicator size="large" color={colors.primary} />
      </View>
    );
  }

  return (
    <View style={s.container}>
      <View style={s.header}>
        <View style={s.headerRow}>
          <TouchableOpacity style={s.homeBtn} onPress={() => router.replace("/")}>
            <Feather name="home" size={13} color="#fff" />
            <Text style={s.homeBtnTxt}>Home</Text>
          </TouchableOpacity>
        </View>
        <Text style={s.headerTitle}>My Schedules</Text>
        <Text style={s.headerSub}>
          {user ? `Logged in as ${user}` : "Login to manage your private schedules"}
        </Text>
      </View>

      {!user ? (
        <ScrollView keyboardShouldPersistTaps="handled">
          <View style={s.loginBox}>
            <Text style={s.loginTitle}>{registerMode ? "Create Account" : "Sign In"}</Text>
            <Text style={s.loginSub}>
              {registerMode
                ? "Register to create and manage private timetables"
                : "Access your private schedule data"}
            </Text>
            <TextInput
              style={s.input}
              placeholder="Username"
              placeholderTextColor={colors.mutedForeground}
              value={loginUsername}
              onChangeText={setLoginUsername}
              autoCapitalize="none"
            />
            <TextInput
              style={s.input}
              placeholder="Password"
              placeholderTextColor={colors.mutedForeground}
              value={loginPassword}
              onChangeText={setLoginPassword}
              secureTextEntry
            />
            {registerMode && (
              <>
                <TextInput
                  style={s.input}
                  placeholder="Secret PIN (4 digits) — used to change password"
                  placeholderTextColor={colors.mutedForeground}
                  value={loginPin}
                  onChangeText={(t) => setLoginPin(t.replace(/\D/g, "").slice(0, 4))}
                  keyboardType="number-pad"
                  maxLength={4}
                  secureTextEntry
                />
                <Text style={{ fontSize: 11, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginBottom: 12, marginTop: -8 }}>
                  Remember this PIN — you will need it to change your password later.
                </Text>
              </>
            )}
            <TouchableOpacity
              style={s.loginBtn}
              onPress={registerMode ? handleRegister : handleLogin}
              disabled={loginLoading}
            >
              {loginLoading
                ? <ActivityIndicator color="#fff" size="small" />
                : <Text style={s.loginBtnTxt}>{registerMode ? "Create Account" : "Sign In"}</Text>
              }
            </TouchableOpacity>
            <View style={s.switchRow}>
              <Text style={s.switchTxt}>
                {registerMode ? "Already have an account?" : "No account?"}
              </Text>
              <TouchableOpacity onPress={() => setRegisterMode(!registerMode)}>
                <Text style={s.switchLink}>{registerMode ? " Sign In" : " Register"}</Text>
              </TouchableOpacity>
            </View>
            {!registerMode && (
              <TouchableOpacity
                style={{ alignItems: "center", marginTop: 4, paddingVertical: 6 }}
                onPress={() => { setRecoverUsername(""); setRecoverPin(""); setRecoverNewPassword(""); setRecoverConfirmPassword(""); setShowRecover(true); }}
              >
                <Text style={{ fontSize: 13, fontFamily: "Inter_400Regular", color: colors.primary }}>
                  Forgot password? Recover via PIN
                </Text>
              </TouchableOpacity>
            )}
          </View>
        </ScrollView>
      ) : (
        <View style={{ flex: 1 }}>
          <View style={s.logoutRow}>
            <TouchableOpacity
              style={[s.logoutBtn, { marginRight: 8 }]}
              onPress={() => { setChangeCurrentPassword(""); setChangeNewPassword(""); setChangeConfirmPassword(""); setShowChangePassword(true); }}
            >
              <Feather name="lock" size={13} color={colors.mutedForeground} />
              <Text style={s.logoutTxt}>Change Password</Text>
            </TouchableOpacity>
            <TouchableOpacity style={s.logoutBtn} onPress={logout}>
              <Feather name="log-out" size={13} color={colors.mutedForeground} />
              <Text style={s.logoutTxt}>Logout</Text>
            </TouchableOpacity>
          </View>

          {schedulesLoading ? (
            <ActivityIndicator size="large" color={colors.primary} style={{ marginTop: 40 }} />
          ) : schedules.length === 0 ? (
            <View style={s.empty}>
              <View style={s.emptyIcon}>
                <Feather name="folder-plus" size={52} color={colors.mutedForeground} />
              </View>
              <Text style={s.emptyTxt}>No schedules yet</Text>
              <Text style={s.emptySub}>
                Tap the + button to create your first private schedule with custom time slots
              </Text>
            </View>
          ) : (
            <ScrollView contentContainerStyle={{ paddingBottom: 100 }}>
              <Text style={{ marginHorizontal: 16, marginTop: 16, marginBottom: 4, fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground }}>
                Tap the globe icon to make a schedule public or private
              </Text>
              {schedules.map((sch) => (
                <View key={sch.id} style={[s.card, sch.isPublic && { borderColor: "#1976D2", borderWidth: 1.5 }]}>
                  <TouchableOpacity
                    style={{ flex: 1, flexDirection: "row", alignItems: "center" }}
                    onPress={() => router.push(`/(screens)/schedule-dashboard?scheduleId=${sch.id}&scheduleTitle=${encodeURIComponent(sch.name)}&startDate=${sch.startDate ?? ""}&endDate=${sch.endDate ?? ""}` as never)}
                    activeOpacity={0.75}
                  >
                    <View style={s.cardIcon}>
                      <Feather name="calendar" size={22} color={colors.primary} />
                    </View>
                    <View style={{ flex: 1 }}>
                      <Text style={s.cardTitle}>{sch.name}</Text>
                      {(sch.startDate || sch.endDate) ? (
                        <Text style={s.cardSub}>
                          {fmtDate(sch.startDate)} – {fmtDate(sch.endDate)}
                        </Text>
                      ) : (
                        <Text style={s.cardSub}>
                          Created {new Date(sch.createdAt).toLocaleDateString("en-PK", { day: "numeric", month: "long", year: "numeric" })}
                        </Text>
                      )}
                      {sch.isPublic && (
                        <View style={s.publicBadge}>
                          <Feather name="globe" size={11} color="#1565C0" />
                          <Text style={s.publicBadgeTxt}>Public</Text>
                        </View>
                      )}
                    </View>
                  </TouchableOpacity>
                  <View style={s.actionBtns}>
                    <TouchableOpacity
                      style={s.globeBtn}
                      onPress={() => publicMutation.mutate({ id: sch.id, isPublic: !sch.isPublic })}
                      hitSlop={{ top: 12, bottom: 12, left: 8, right: 8 }}
                    >
                      <Feather
                        name="globe"
                        size={18}
                        color={sch.isPublic ? "#1976D2" : colors.mutedForeground}
                      />
                    </TouchableOpacity>
                    <TouchableOpacity
                      style={s.delBtn}
                      onPress={() => setDeleteTarget(sch)}
                      hitSlop={{ top: 12, bottom: 12, left: 8, right: 8 }}
                    >
                      <Feather name="trash-2" size={18} color={colors.destructive} />
                    </TouchableOpacity>
                  </View>
                </View>
              ))}
            </ScrollView>
          )}

          <TouchableOpacity style={s.fab} onPress={() => setShowCreate(true)}>
            <Feather name="plus" size={26} color="#fff" />
          </TouchableOpacity>
        </View>
      )}

      {/* Error modal */}
      {!!errorMsg && (
        <Modal visible transparent animationType="fade">
          <View style={{ flex: 1, justifyContent: "center", alignItems: "center", backgroundColor: "rgba(0,0,0,0.45)", padding: 32 }}>
            <View style={{ backgroundColor: colors.card, borderRadius: 16, padding: 24, width: "100%", alignItems: "center" }}>
              <Feather name="alert-circle" size={32} color={colors.destructive} style={{ marginBottom: 10 }} />
              <Text style={{ fontSize: 15, fontFamily: "Inter_400Regular", color: colors.foreground, textAlign: "center", marginBottom: 20 }}>{errorMsg}</Text>
              <TouchableOpacity
                onPress={() => setErrorMsg("")}
                style={{ backgroundColor: colors.primary, borderRadius: 10, paddingVertical: 11, paddingHorizontal: 32 }}
              >
                <Text style={{ color: "#fff", fontSize: 15, fontFamily: "Inter_700Bold" }}>OK</Text>
              </TouchableOpacity>
            </View>
          </View>
        </Modal>
      )}

      {/* Delete confirmation modal */}
      <Modal visible={!!deleteTarget} transparent animationType="fade">
        <View style={{ flex: 1, justifyContent: "center", alignItems: "center", backgroundColor: "rgba(0,0,0,0.45)", padding: 32 }}>
          <View style={{ backgroundColor: colors.card, borderRadius: 16, padding: 24, width: "100%" }}>
            <Text style={{ fontSize: 17, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 8 }}>Delete Schedule</Text>
            <Text style={{ fontSize: 14, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginBottom: 24 }}>
              Delete &quot;{deleteTarget?.name}&quot; and all its entries? This cannot be undone.
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
                  : <Text style={{ fontSize: 15, fontFamily: "Inter_700Bold", color: "#fff" }}>Delete</Text>
                }
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      {/* New Schedule sheet */}
      <Modal visible={showCreate} transparent animationType="slide">
        <View style={s.overlay}>
          <View style={s.sheet}>
            <Text style={s.sheetTitle}>New Schedule</Text>
            <TextInput
              style={s.sheetInput}
              placeholder="Schedule name  e.g. Semester 1 – Fall 2026"
              placeholderTextColor={colors.mutedForeground}
              value={newName}
              onChangeText={setNewName}
              autoFocus
            />

            <Text style={s.sheetLabel}>Start Date</Text>
            {Platform.OS === "web" ? (
              <View style={[s.datePill, { marginBottom: 16 }]}>
                <Feather name="calendar" size={15} color={colors.primary} />
                <TextInput
                  style={[s.datePillTxt, { color: colors.foreground, outlineStyle: "none" } as never]}
                  value={toIso(startDate)}
                  onChangeText={(t) => { const d = new Date(t); if (!isNaN(d.getTime())) setStartDate(d); }}
                  placeholder="YYYY-MM-DD"
                  placeholderTextColor={colors.mutedForeground}
                />
                <Text style={{ fontSize: 11, color: colors.mutedForeground }}>{fmtDate(toIso(startDate))}</Text>
              </View>
            ) : (
              <TouchableOpacity style={[s.datePill, { marginBottom: 16 }]} onPress={() => setPickerTarget("start")}>
                <Feather name="calendar" size={15} color={colors.primary} />
                <Text style={[s.datePillTxt, { color: colors.foreground }]}>{fmtDate(toIso(startDate))}</Text>
              </TouchableOpacity>
            )}

            <Text style={s.sheetLabel}>End Date</Text>
            {Platform.OS === "web" ? (
              <View style={[s.datePill, { marginBottom: 20 }]}>
                <Feather name="calendar" size={15} color={colors.primary} />
                <TextInput
                  style={[s.datePillTxt, { color: colors.foreground, outlineStyle: "none" } as never]}
                  value={toIso(endDate)}
                  onChangeText={(t) => { const d = new Date(t); if (!isNaN(d.getTime())) setEndDate(d); }}
                  placeholder="YYYY-MM-DD"
                  placeholderTextColor={colors.mutedForeground}
                />
                <Text style={{ fontSize: 11, color: colors.mutedForeground }}>{fmtDate(toIso(endDate))}</Text>
              </View>
            ) : (
              <TouchableOpacity style={[s.datePill, { marginBottom: 20 }]} onPress={() => setPickerTarget("end")}>
                <Feather name="calendar" size={15} color={colors.primary} />
                <Text style={[s.datePillTxt, { color: colors.foreground }]}>{fmtDate(toIso(endDate))}</Text>
              </TouchableOpacity>
            )}

            <TouchableOpacity
              style={s.sheetBtn}
              onPress={() => {
                if (newName.trim()) {
                  createMutation.mutate({ name: newName, sd: toIso(startDate), ed: toIso(endDate) });
                }
              }}
              disabled={createMutation.isPending || !newName.trim()}
            >
              {createMutation.isPending
                ? <ActivityIndicator color="#fff" size="small" />
                : <Text style={s.sheetBtnTxt}>Create Schedule</Text>
              }
            </TouchableOpacity>
            <TouchableOpacity
              style={s.sheetCancel}
              onPress={() => { setShowCreate(false); setNewName(""); setStartDate(new Date()); setEndDate(new Date()); }}
            >
              <Text style={s.sheetCancelTxt}>Cancel</Text>
            </TouchableOpacity>

            {pickerTarget === "start" && (
              <DateTimePicker
                mode="date"
                value={startDate}
                onChange={(_, d) => { setPickerTarget(null); if (d) setStartDate(d); }}
              />
            )}
            {pickerTarget === "end" && (
              <DateTimePicker
                mode="date"
                value={endDate}
                onChange={(_, d) => { setPickerTarget(null); if (d) setEndDate(d); }}
              />
            )}
          </View>
        </View>
      </Modal>

      {/* Recover Password via PIN sheet (accessible without login) */}
      <Modal visible={showRecover} transparent animationType="slide">
        <View style={s.overlay}>
          <View style={s.sheet}>
            <Text style={s.sheetTitle}>Recover Password</Text>
            <Text style={{ fontSize: 13, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginBottom: 16, marginTop: -8 }}>
              Use your secret PIN to reset your password — no current password needed.
            </Text>

            <Text style={s.sheetLabel}>Username</Text>
            <TextInput
              style={s.sheetInput}
              placeholder="Your username"
              placeholderTextColor={colors.mutedForeground}
              value={recoverUsername}
              onChangeText={setRecoverUsername}
              autoCapitalize="none"
            />

            <Text style={s.sheetLabel}>Secret PIN</Text>
            <TextInput
              style={s.sheetInput}
              placeholder="4-digit PIN set at registration"
              placeholderTextColor={colors.mutedForeground}
              value={recoverPin}
              onChangeText={(t) => setRecoverPin(t.replace(/\D/g, "").slice(0, 4))}
              keyboardType="number-pad"
              maxLength={4}
              secureTextEntry
            />

            <Text style={s.sheetLabel}>New Password</Text>
            <TextInput
              style={s.sheetInput}
              placeholder="New password (min 4 characters)"
              placeholderTextColor={colors.mutedForeground}
              value={recoverNewPassword}
              onChangeText={setRecoverNewPassword}
              secureTextEntry
            />

            <Text style={s.sheetLabel}>Confirm New Password</Text>
            <TextInput
              style={s.sheetInput}
              placeholder="Re-enter new password"
              placeholderTextColor={colors.mutedForeground}
              value={recoverConfirmPassword}
              onChangeText={setRecoverConfirmPassword}
              secureTextEntry
            />

            <TouchableOpacity
              style={s.sheetBtn}
              onPress={handleRecoverPassword}
              disabled={recoverLoading}
            >
              {recoverLoading
                ? <ActivityIndicator color="#fff" size="small" />
                : <Text style={s.sheetBtnTxt}>Reset Password</Text>
              }
            </TouchableOpacity>
            <TouchableOpacity
              style={s.sheetCancel}
              onPress={() => { setShowRecover(false); setRecoverUsername(""); setRecoverPin(""); setRecoverNewPassword(""); setRecoverConfirmPassword(""); }}
            >
              <Text style={s.sheetCancelTxt}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>

      {/* Change Password sheet */}
      <Modal visible={showChangePassword} transparent animationType="slide">
        <View style={s.overlay}>
          <View style={s.sheet}>
            <Text style={s.sheetTitle}>Change Password</Text>
            <Text style={{ fontSize: 13, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginBottom: 16, marginTop: -8 }}>
              Logged in as <Text style={{ fontFamily: "Inter_700Bold", color: colors.foreground }}>{user}</Text>
            </Text>

            <Text style={s.sheetLabel}>Current Password</Text>
            <TextInput
              style={s.sheetInput}
              placeholder="Enter your current password"
              placeholderTextColor={colors.mutedForeground}
              value={changeCurrentPassword}
              onChangeText={setChangeCurrentPassword}
              secureTextEntry
            />

            <Text style={s.sheetLabel}>New Password</Text>
            <TextInput
              style={s.sheetInput}
              placeholder="New password (min 4 characters)"
              placeholderTextColor={colors.mutedForeground}
              value={changeNewPassword}
              onChangeText={setChangeNewPassword}
              secureTextEntry
            />

            <Text style={s.sheetLabel}>Confirm New Password</Text>
            <TextInput
              style={s.sheetInput}
              placeholder="Re-enter new password"
              placeholderTextColor={colors.mutedForeground}
              value={changeConfirmPassword}
              onChangeText={setChangeConfirmPassword}
              secureTextEntry
            />

            <TouchableOpacity
              style={s.sheetBtn}
              onPress={handleChangePassword}
              disabled={changeLoading}
            >
              {changeLoading
                ? <ActivityIndicator color="#fff" size="small" />
                : <Text style={s.sheetBtnTxt}>Update Password</Text>
              }
            </TouchableOpacity>
            <TouchableOpacity
              style={s.sheetCancel}
              onPress={() => { setShowChangePassword(false); setChangeCurrentPassword(""); setChangeNewPassword(""); setChangeConfirmPassword(""); }}
            >
              <Text style={s.sheetCancelTxt}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </View>
  );
}
