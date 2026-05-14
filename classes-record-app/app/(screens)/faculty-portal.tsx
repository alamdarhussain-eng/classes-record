import React, { useState, useEffect, useCallback } from "react";
import {
  View, Text, StyleSheet, TouchableOpacity, TextInput,
  ActivityIndicator, Alert, Modal, ScrollView, Platform,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useFocusEffect } from "expo-router";
import * as ScreenOrientation from "expo-screen-orientation";

import { useColors } from "@/hooks/useColors";
import { facultyLogin, changeFacultyPassword, FacultySession } from "@/hooks/useApi";

const SESSION_KEY = "facultySession";

export default function FacultyPortalScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();

  useFocusEffect(useCallback(() => {
    if (Platform.OS !== "web")
      ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.PORTRAIT_UP).catch(() => {});
  }, []));

  const [session, setSession] = useState<FacultySession | null>(null);
  const [loading, setLoading] = useState(true);

  // Login form
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [showPass, setShowPass] = useState(false);
  const [loginLoading, setLoginLoading] = useState(false);
  const [loginError, setLoginError] = useState("");

  // Schedule picker (when username matches multiple schedules)
  const [scheduleOptions, setScheduleOptions] = useState<FacultySession[]>([]);
  const [showSchedulePicker, setShowSchedulePicker] = useState(false);

  // Change password
  const [showChangePass, setShowChangePass] = useState(false);
  const [curPass, setCurPass] = useState("");
  const [newPass, setNewPass] = useState("");
  const [confirmPass, setConfirmPass] = useState("");
  const [changingPass, setChangingPass] = useState(false);

  useEffect(() => {
    AsyncStorage.getItem(SESSION_KEY).then(raw => {
      if (raw) {
        try { setSession(JSON.parse(raw)); } catch { /* ignore */ }
      }
      setLoading(false);
    });
  }, []);

  async function handleLogin() {
    if (!username.trim() || !password.trim()) {
      setLoginError("Enter username and password");
        return;
    }
    setLoginLoading(true);
    setLoginError("");
    try {
      const res = await facultyLogin(username.trim().toLowerCase(), password.trim());
      if (!res.success) {
        setLoginError(res.message ?? "Login failed");
        return;
      }
      const results = res.sessions ?? [];
      if (results.length === 1) {
        await saveSession(results[0]);
      } else {
        setScheduleOptions(results);
        setShowSchedulePicker(true);
      }
    } catch (e: unknown) {
      setLoginError((e as Error).message ?? "Login failed");
    } finally {
      setLoginLoading(false);
    }
  }

  async function saveSession(s: FacultySession) {
    await AsyncStorage.setItem(SESSION_KEY, JSON.stringify(s));
    setSession(s);
    setShowSchedulePicker(false);
    setUsername("");
    setPassword("");
  }

  async function handleSignOut() {
    Alert.alert("Sign Out", "Sign out of faculty portal?", [
      { text: "Cancel", style: "cancel" },
      {
        text: "Sign Out", style: "destructive", onPress: async () => {
          await AsyncStorage.removeItem(SESSION_KEY);
          setSession(null);
        },
      },
    ]);
  }

  async function handleChangePassword() {
    if (!newPass.trim() || !curPass.trim()) { Alert.alert("Error", "Fill in all fields"); return; }
    if (newPass.length < 6) { Alert.alert("Error", "New password must be at least 6 characters"); return; }
    if (newPass !== confirmPass) { Alert.alert("Error", "New passwords do not match"); return; }
    if (!session) return;
    setChangingPass(true);
    const r = await changeFacultyPassword(session.accountId, curPass, newPass);
    setChangingPass(false);
    if (r.success) {
      Alert.alert("Success", "Password changed. Use your new password next time you log in.");
      setShowChangePass(false);
      setCurPass(""); setNewPass(""); setConfirmPass("");
    } else {
      Alert.alert("Error", r.error ?? "Could not change password");
    }
  }

  const s = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    header: {
      backgroundColor: colors.primary,
      paddingTop: insets.top + (Platform.OS === "web" ? 67 : 16),
      paddingBottom: 24, paddingHorizontal: 20,
    },
    headerRow: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 10 },
    homeBtn: {
      flexDirection: "row", alignItems: "center", gap: 5,
      backgroundColor: "rgba(255,255,255,0.2)", borderRadius: 20,
      paddingHorizontal: 12, paddingVertical: 6,
    },
    homeBtnTxt: { color: "#fff", fontSize: 13, fontFamily: "Inter_600SemiBold" },
    signOutBtn: {
      flexDirection: "row", alignItems: "center", gap: 5,
      backgroundColor: "rgba(255,255,255,0.2)", borderRadius: 20,
      paddingHorizontal: 12, paddingVertical: 6,
    },
    signOutTxt: { color: "#fff", fontSize: 13, fontFamily: "Inter_600SemiBold" },
    headerTitle: { color: "#fff", fontSize: 22, fontFamily: "Inter_700Bold" },
    headerSub: { color: "rgba(255,255,255,0.8)", fontSize: 13, fontFamily: "Inter_400Regular", marginTop: 3 },
    headerBadge: {
      flexDirection: "row", alignItems: "center", gap: 6,
      backgroundColor: "rgba(255,255,255,0.15)", borderRadius: 8,
      paddingHorizontal: 10, paddingVertical: 5, marginTop: 8, alignSelf: "flex-start",
    },
    headerBadgeTxt: { color: "#fff", fontSize: 12, fontFamily: "Inter_400Regular" },

    // Login form
    loginCard: {
      margin: 20, backgroundColor: colors.card, borderRadius: 16,
      borderWidth: 1, borderColor: colors.border, padding: 24, gap: 16,
    },
    loginTitle: { fontSize: 18, fontFamily: "Inter_700Bold", color: colors.foreground, textAlign: "center" },
    loginSub: { fontSize: 13, fontFamily: "Inter_400Regular", color: colors.mutedForeground, textAlign: "center", marginTop: -8 },
    inputRow: {
      flexDirection: "row", alignItems: "center",
      backgroundColor: colors.muted, borderRadius: 10,
      borderWidth: 1, borderColor: colors.border,
      paddingHorizontal: 12, paddingVertical: 10, gap: 10,
    },
    input: { flex: 1, fontSize: 15, fontFamily: "Inter_400Regular", color: colors.foreground },
    loginBtn: {
      backgroundColor: colors.primary, borderRadius: 10,
      paddingVertical: 14, alignItems: "center",
    },
    loginBtnTxt: { color: "#fff", fontSize: 15, fontFamily: "Inter_700Bold" },
    errorTxt: { fontSize: 13, fontFamily: "Inter_400Regular", color: colors.destructive, textAlign: "center" },

    // Tiles (faculty dashboard)
    grid: { padding: 16, flexDirection: "row", flexWrap: "wrap", gap: 14 },
    tile: {
      width: "47%", borderRadius: 16, padding: 20,
      borderWidth: 1, borderColor: colors.border, alignItems: "flex-start",
      shadowColor: "#000", shadowOffset: { width: 0, height: 1 },
      shadowOpacity: 0.06, shadowRadius: 4, elevation: 2,
    },
    iconCircle: { width: 52, height: 52, borderRadius: 26, alignItems: "center", justifyContent: "center", marginBottom: 14 },
    tileTitle: { fontSize: 15, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 4 },
    tileSub: { fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground },

    // Change password
    changePassBtn: {
      marginHorizontal: 16, marginBottom: 10,
      flexDirection: "row", alignItems: "center", justifyContent: "center", gap: 7,
      backgroundColor: colors.muted, borderRadius: 10, borderWidth: 1, borderColor: colors.border,
      paddingVertical: 11,
    },
    changePassBtnTxt: { fontSize: 14, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground },

    // Modal
    overlay: { flex: 1, backgroundColor: "rgba(0,0,0,0.5)", justifyContent: "center", alignItems: "center", padding: 24 },
    modalBox: { backgroundColor: colors.card, borderRadius: 16, width: "100%", padding: 20, gap: 14 },
    modalTitle: { fontSize: 17, fontFamily: "Inter_700Bold", color: colors.foreground, textAlign: "center" },
    modalBtn: { backgroundColor: colors.primary, borderRadius: 10, paddingVertical: 13, alignItems: "center" },
    modalBtnTxt: { color: "#fff", fontSize: 15, fontFamily: "Inter_700Bold" },
    modalCancelTxt: { fontSize: 14, fontFamily: "Inter_400Regular", color: colors.mutedForeground, textAlign: "center" },
    schOption: {
      flexDirection: "row", alignItems: "center", padding: 14,
      backgroundColor: colors.muted, borderRadius: 10, gap: 10,
    },
    schOptionTxt: { flex: 1, fontSize: 14, fontFamily: "Inter_600SemiBold", color: colors.foreground },
    schOptionSub: { fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground },
  });

  if (loading) {
    return (
      <View style={[s.container, { justifyContent: "center", alignItems: "center" }]}>
        <ActivityIndicator color={colors.primary} size="large" />
      </View>
    );
  }

  // ── Logged in: faculty dashboard ──
  if (session) {
    const q = `scheduleId=${session.scheduleId}&scheduleTitle=${encodeURIComponent(session.scheduleTitle)}${session.startDate ? `&startDate=${session.startDate}&endDate=${session.endDate ?? ""}` : ""}&facultyName=${encodeURIComponent(session.facultyName)}`;

    return (
      <View style={s.container}>
        <View style={s.header}>
          <View style={s.headerRow}>
            <TouchableOpacity style={s.homeBtn} onPress={() => router.replace("/" as never)}>
              <Feather name="home" size={13} color="#fff" />
              <Text style={s.homeBtnTxt}>Home</Text>
            </TouchableOpacity>
            <TouchableOpacity style={s.signOutBtn} onPress={handleSignOut}>
              <Feather name="log-out" size={13} color="#fff" />
              <Text style={s.signOutTxt}>Sign Out</Text>
            </TouchableOpacity>
          </View>
          <Text style={s.headerTitle}>{session.facultyName}</Text>
          <Text style={s.headerSub}>{session.scheduleTitle}</Text>
          <View style={s.headerBadge}>
            <Feather name="user" size={12} color="#fff" />
            <Text style={s.headerBadgeTxt}>Logged in as {session.username}</Text>
          </View>
        </View>

        <ScrollView contentContainerStyle={{ paddingBottom: 32 }}>
          <View style={s.grid}>
            <TouchableOpacity
              style={[s.tile, { backgroundColor: "#E3F2FD", width: "47%" }]}
              onPress={() => router.push(`/(screens)/attendance?${q}` as never)}
              activeOpacity={0.75}
            >
              <View style={[s.iconCircle, { backgroundColor: "#1565C022" }]}>
                <Feather name="check-square" size={26} color="#1565C0" />
              </View>
              <Text style={s.tileTitle}>Attendance</Text>
              <Text style={s.tileSub}>Mark · Roster</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[s.tile, { backgroundColor: "#F3E5F5", width: "47%" }]}
              onPress={() => router.push(`/(screens)/exam?${q}` as never)}
              activeOpacity={0.75}
            >
              <View style={[s.iconCircle, { backgroundColor: "#6A1B9A22" }]}>
                <Feather name="award" size={26} color="#6A1B9A" />
              </View>
              <Text style={s.tileTitle}>Exam Marks</Text>
              <Text style={s.tileSub}>Enter · View</Text>
            </TouchableOpacity>
          </View>

          <TouchableOpacity
            style={s.changePassBtn}
            onPress={() => { setShowChangePass(true); setCurPass(""); setNewPass(""); setConfirmPass(""); }}
          >
            <Feather name="lock" size={15} color={colors.mutedForeground} />
            <Text style={s.changePassBtnTxt}>Change My Password</Text>
          </TouchableOpacity>
        </ScrollView>

        {/* Change password modal */}
        <Modal visible={showChangePass} transparent animationType="slide">
          <View style={s.overlay}>
            <View style={s.modalBox}>
              <Text style={s.modalTitle}>Change Password</Text>
              <View style={s.inputRow}>
                <Feather name="lock" size={16} color={colors.mutedForeground} />
                <TextInput
                  style={s.input} placeholder="Current password"
                  placeholderTextColor={colors.mutedForeground}
                  value={curPass} onChangeText={setCurPass}
                  secureTextEntry autoCapitalize="none"
                />
              </View>
              <View style={s.inputRow}>
                <Feather name="lock" size={16} color={colors.mutedForeground} />
                <TextInput
                  style={s.input} placeholder="New password (min 6 chars)"
                  placeholderTextColor={colors.mutedForeground}
                  value={newPass} onChangeText={setNewPass}
                  secureTextEntry autoCapitalize="none"
                />
              </View>
              <View style={s.inputRow}>
                <Feather name="lock" size={16} color={colors.mutedForeground} />
                <TextInput
                  style={s.input} placeholder="Confirm new password"
                  placeholderTextColor={colors.mutedForeground}
                  value={confirmPass} onChangeText={setConfirmPass}
                  secureTextEntry autoCapitalize="none"
                />
              </View>
              <TouchableOpacity style={s.modalBtn} onPress={handleChangePassword} disabled={changingPass}>
                {changingPass
                  ? <ActivityIndicator color="#fff" size="small" />
                  : <Text style={s.modalBtnTxt}>Change Password</Text>
                }
              </TouchableOpacity>
              <TouchableOpacity onPress={() => setShowChangePass(false)}>
                <Text style={s.modalCancelTxt}>Cancel</Text>
              </TouchableOpacity>
            </View>
          </View>
        </Modal>
      </View>
    );
  }

  // ── Not logged in: login form ──
  return (
    <View style={s.container}>
      <View style={s.header}>
        <View style={s.headerRow}>
          <TouchableOpacity style={s.homeBtn} onPress={() => router.replace("/" as never)}>
            <Feather name="home" size={13} color="#fff" />
            <Text style={s.homeBtnTxt}>Home</Text>
          </TouchableOpacity>
        </View>
        <Text style={s.headerTitle}>Faculty Portal</Text>
        <Text style={s.headerSub}>Sign in with your faculty credentials</Text>
      </View>

      <ScrollView contentContainerStyle={{ padding: 0 }}>
        <View style={s.loginCard}>
          <Text style={s.loginTitle}>Faculty Sign In</Text>
          <Text style={s.loginSub}>Use the username &amp; password provided by your schedule administrator</Text>

          <View style={s.inputRow}>
            <Feather name="user" size={16} color={colors.mutedForeground} />
            <TextInput
              style={s.input}
              placeholder="Username (e.g. ahmed.khan)"
              placeholderTextColor={colors.mutedForeground}
              value={username}
              onChangeText={t => { setUsername(t); setLoginError(""); }}
              autoCapitalize="none"
              autoCorrect={false}
            />
          </View>

          <View style={s.inputRow}>
            <Feather name="lock" size={16} color={colors.mutedForeground} />
            <TextInput
              style={s.input}
              placeholder="Password"
              placeholderTextColor={colors.mutedForeground}
              value={password}
              onChangeText={t => { setPassword(t); setLoginError(""); }}
              secureTextEntry={!showPass}
              autoCapitalize="none"
            />
            <TouchableOpacity onPress={() => setShowPass(p => !p)}>
              <Feather name={showPass ? "eye-off" : "eye"} size={17} color={colors.mutedForeground} />
            </TouchableOpacity>
          </View>

          {!!loginError && <Text style={s.errorTxt}>{loginError}</Text>}

          <TouchableOpacity style={s.loginBtn} onPress={handleLogin} disabled={loginLoading}>
            {loginLoading
              ? <ActivityIndicator color="#fff" size="small" />
              : <Text style={s.loginBtnTxt}>Sign In</Text>
            }
          </TouchableOpacity>
        </View>
      </ScrollView>

      {/* Schedule picker when same username exists in multiple schedules */}
      <Modal visible={showSchedulePicker} transparent animationType="slide">
        <View style={s.overlay}>
          <View style={s.modalBox}>
            <Text style={s.modalTitle}>Select Schedule</Text>
            <Text style={[s.modalCancelTxt, { marginBottom: 4 }]}>
              Your credentials match multiple schedules. Select one to continue.
            </Text>
            {scheduleOptions.map(opt => (
              <TouchableOpacity key={opt.scheduleId} style={s.schOption} onPress={() => saveSession(opt)}>
                <Feather name="calendar" size={18} color={colors.primary} />
                <View style={{ flex: 1 }}>
                  <Text style={s.schOptionTxt}>{opt.scheduleTitle}</Text>
                  {opt.startDate && (
                    <Text style={s.schOptionSub}>{opt.startDate} – {opt.endDate ?? "ongoing"}</Text>
                  )}
                </View>
                <Feather name="chevron-right" size={16} color={colors.mutedForeground} />
              </TouchableOpacity>
            ))}
            <TouchableOpacity onPress={() => setShowSchedulePicker(false)}>
              <Text style={s.modalCancelTxt}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </View>
  );
}
