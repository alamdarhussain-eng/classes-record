import React, { useState, useCallback, useEffect } from "react";
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  TextInput, ActivityIndicator, Modal, Platform, Linking,
} from "react-native";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useFocusEffect } from "expo-router";
import * as ScreenOrientation from "expo-screen-orientation";
import * as FileSystem from "expo-file-system";
import * as Sharing from "expo-sharing";
import { useColors } from "@/hooks/useColors";

const API_BASE = `https://${process.env.EXPO_PUBLIC_DOMAIN}/api`;
const ADMIN_PASSWORD = "Administr@r@123";
const ADMIN_USERNAME = "patoprincipalseecs@gmail.com";

interface ManagedUser {
  id: number;
  username: string;
  password: string;
  pin: string;
  isLocked: boolean;
  registeredAt: string;
  expiryDate: string | null;
  scheduleCount: number;
}

async function adminGet(path: string) {
  const res = await fetch(`${API_BASE}${path}`, { headers: { "x-admin-password": ADMIN_PASSWORD } });
  return res.json();
}
async function adminPatch(path: string, body: object) {
  const res = await fetch(`${API_BASE}${path}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json", "x-admin-password": ADMIN_PASSWORD },
    body: JSON.stringify(body),
  });
  return res.json();
}
async function adminDelete(path: string) {
  const res = await fetch(`${API_BASE}${path}`, {
    method: "DELETE", headers: { "x-admin-password": ADMIN_PASSWORD },
  });
  return res.json();
}

function fmtDate(d: string | null | undefined) {
  if (!d) return "—";
  return new Date(d).toLocaleDateString("en-PK", { day: "numeric", month: "short", year: "numeric" });
}

function expiryStatus(u: ManagedUser): { label: string; color: string; bg: string } {
  if (u.isLocked) return { label: "Locked", color: "#B71C1C", bg: "#FFEBEE" };
  if (!u.expiryDate) return { label: "No Expiry", color: "#1565C0", bg: "#E3F2FD" };
  const days = Math.ceil((new Date(u.expiryDate).getTime() - Date.now()) / 86400000);
  if (days < 0) return { label: "Expired", color: "#B71C1C", bg: "#FFEBEE" };
  if (days <= 5) return { label: `${days}d left`, color: "#E65100", bg: "#FFF3E0" };
  return { label: `${days}d left`, color: "#2E7D32", bg: "#E8F5E9" };
}

export default function AdminPanelScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();

  useFocusEffect(useCallback(() => {
    if (Platform.OS !== "web") {
      ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.PORTRAIT_UP).catch(() => {});
    }
  }, []));

  const [authed, setAuthed] = useState(false);
  const [authUser, setAuthUser] = useState("");
  const [authPass, setAuthPass] = useState("");
  const [authError, setAuthError] = useState("");
  const [users, setUsers] = useState<ManagedUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);
  const [search, setSearch] = useState("");
  const [errorMsg, setErrorMsg] = useState("");
  const [successMsg, setSuccessMsg] = useState("");
  const [deleteTarget, setDeleteTarget] = useState<ManagedUser | null>(null);
  const [passwordTarget, setPasswordTarget] = useState<ManagedUser | null>(null);
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [expiryTarget, setExpiryTarget] = useState<ManagedUser | null>(null);
  const [expiryDays, setExpiryDays] = useState("30");
  const [expiryCustomDate, setExpiryCustomDate] = useState("");
  const [expiryMode, setExpiryMode] = useState<"days" | "date">("days");

  async function loadUsers() {
    setLoading(true);
    try {
      const data = await adminGet("/admin/users");
      if (data.success) setUsers(data.users);
      else setErrorMsg(data.message ?? "Failed to load users");
    } catch { setErrorMsg("Connection error — is the server running?"); }
    setLoading(false);
  }

  useEffect(() => { loadUsers(); }, []);

  async function handleDelete() {
    if (!deleteTarget) return;
    setActionLoading(true);
    const res = await adminDelete(`/admin/users/${deleteTarget.id}`);
    setActionLoading(false);
    setDeleteTarget(null);
    if (res.success) { setSuccessMsg(`"${deleteTarget.username}" deleted.`); loadUsers(); }
    else setErrorMsg(res.message ?? "Delete failed");
  }

  async function handleChangePassword() {
    if (!passwordTarget) return;
    if (newPassword.length < 4) { setErrorMsg("Min 4 characters"); return; }
    if (newPassword !== confirmPassword) { setErrorMsg("Passwords do not match"); return; }
    setActionLoading(true);
    const res = await adminPatch(`/admin/users/${passwordTarget.id}/password`, { newPassword });
    setActionLoading(false);
    if (res.success) {
      setPasswordTarget(null); setNewPassword(""); setConfirmPassword("");
      setSuccessMsg(`Password updated for "${passwordTarget.username}".`); loadUsers();
    } else setErrorMsg(res.message ?? "Failed");
  }

  async function handleToggleLock(u: ManagedUser) {
    setActionLoading(true);
    const res = await adminPatch(`/admin/users/${u.id}/lock`, { isLocked: !u.isLocked });
    setActionLoading(false);
    if (res.success) { setSuccessMsg(`"${u.username}" ${!u.isLocked ? "locked" : "unlocked"}.`); loadUsers(); }
    else setErrorMsg(res.message ?? "Failed");
  }

  async function handleSetExpiry() {
    if (!expiryTarget) return;
    let expiry: string;
    if (expiryMode === "days") {
      const d = parseInt(expiryDays);
      if (isNaN(d) || d < 1) { setErrorMsg("Enter valid number of days"); return; }
      const date = new Date(); date.setDate(date.getDate() + d);
      expiry = date.toISOString().split("T")[0];
    } else {
      if (!expiryCustomDate.match(/^\d{4}-\d{2}-\d{2}$/)) { setErrorMsg("Use YYYY-MM-DD format"); return; }
      expiry = expiryCustomDate;
    }
    setActionLoading(true);
    const res = await adminPatch(`/admin/users/${expiryTarget.id}/expiry`, { expiryDate: expiry });
    setActionLoading(false);
    if (res.success) {
      setExpiryTarget(null);
      setSuccessMsg(`"${expiryTarget.username}" activated until ${fmtDate(expiry)}.`);
      loadUsers();
    } else setErrorMsg(res.message ?? "Failed");
  }

  async function handleDownloadCSV() {
    const header = "ID,Username,Password,PIN,Status,Registered,Expiry,Schedules";
    const rows = users.map(u =>
      `${u.id},"${u.username}","${u.password}","${u.pin}","${expiryStatus(u).label}","${fmtDate(u.registeredAt)}","${fmtDate(u.expiryDate)}",${u.scheduleCount}`
    );
    const csv = [header, ...rows].join("\n");
    if (Platform.OS === "web") {
      const blob = new Blob([csv], { type: "text/csv" });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a"); a.href = url; a.download = "users.csv"; a.click();
      URL.revokeObjectURL(url);
    } else {
      const filePath = (FileSystem.documentDirectory ?? "") + "users.csv";
      await FileSystem.writeAsStringAsync(filePath, csv);
      await Sharing.shareAsync(filePath, { mimeType: "text/csv" });
    }
  }

  const filtered = users.filter(u => u.username.toLowerCase().includes(search.toLowerCase()));

  const s = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    header: { backgroundColor: "#1565C0", paddingTop: insets.top + (Platform.OS === "web" ? 67 : 16), paddingBottom: 20, paddingHorizontal: 20 },
    headerRow: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 10 },
    homeBtn: { flexDirection: "row", alignItems: "center", gap: 5, backgroundColor: "rgba(255,255,255,0.2)", borderRadius: 20, paddingHorizontal: 12, paddingVertical: 6 },
    homeBtnTxt: { color: "#fff", fontSize: 13, fontFamily: "Inter_600SemiBold" },
    headerTitle: { color: "#fff", fontSize: 22, fontFamily: "Inter_700Bold" },
    headerSub: { color: "rgba(255,255,255,0.75)", fontSize: 13, fontFamily: "Inter_400Regular", marginTop: 2 },
    toolbar: { flexDirection: "row", gap: 8, margin: 14, alignItems: "center" },
    searchBox: { flex: 1, flexDirection: "row", alignItems: "center", gap: 8, backgroundColor: colors.card, borderWidth: 1, borderColor: colors.border, borderRadius: 10, paddingHorizontal: 12, paddingVertical: 9 },
    searchInput: { flex: 1, fontSize: 14, fontFamily: "Inter_400Regular", color: colors.foreground },
    iconBtn: { flexDirection: "row", alignItems: "center", gap: 5, backgroundColor: "#1565C0", borderRadius: 10, paddingHorizontal: 12, paddingVertical: 10 },
    iconBtnTxt: { color: "#fff", fontSize: 13, fontFamily: "Inter_600SemiBold" },
    card: { marginHorizontal: 14, marginBottom: 10, backgroundColor: colors.card, borderRadius: 14, borderWidth: 1, borderColor: colors.border, padding: 14 },
    cardTop: { flexDirection: "row", alignItems: "center", marginBottom: 8 },
    avatar: { width: 42, height: 42, borderRadius: 21, backgroundColor: "#EDE7F6", alignItems: "center", justifyContent: "center", marginRight: 12 },
    username: { fontSize: 14, fontFamily: "Inter_700Bold", color: colors.foreground },
    infoTxt: { fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginTop: 1 },
    metaRow: { flexDirection: "row", flexWrap: "wrap", gap: 6, marginBottom: 8 },
    badge: { flexDirection: "row", alignItems: "center", gap: 4, borderRadius: 10, paddingHorizontal: 8, paddingVertical: 3 },
    badgeTxt: { fontSize: 11, fontFamily: "Inter_600SemiBold" },
    actionRow: { flexDirection: "row", gap: 6, marginTop: 6, flexWrap: "wrap" },
    actionBtn: { flexDirection: "row", alignItems: "center", gap: 4, borderRadius: 8, paddingVertical: 7, paddingHorizontal: 10, borderWidth: 1 },
    actionBtnTxt: { fontSize: 12, fontFamily: "Inter_600SemiBold" },
    overlay: { flex: 1, backgroundColor: "rgba(0,0,0,0.55)", justifyContent: "center", alignItems: "center", padding: 20 },
    modalBox: { backgroundColor: colors.card, borderRadius: 18, padding: 22, width: "100%" },
    modalTitle: { fontSize: 17, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 6 },
    modalSub: { fontSize: 13, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginBottom: 18 },
    modalInput: { backgroundColor: colors.background, borderWidth: 1, borderColor: colors.border, borderRadius: 10, padding: 12, fontSize: 14, fontFamily: "Inter_400Regular", color: colors.foreground, marginBottom: 12 },
    modalLabel: { fontSize: 11, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground, marginBottom: 5, textTransform: "uppercase" },
    modeRow: { flexDirection: "row", gap: 8, marginBottom: 14 },
    modeBtn: { flex: 1, borderRadius: 8, paddingVertical: 8, alignItems: "center", borderWidth: 1 },
    quickRow: { flexDirection: "row", gap: 8, marginBottom: 14 },
    modalRow: { flexDirection: "row", gap: 10, marginTop: 4 },
    cancelBtn: { flex: 1, backgroundColor: colors.secondary, borderRadius: 10, paddingVertical: 12, alignItems: "center" },
    cancelTxt: { fontSize: 14, fontFamily: "Inter_600SemiBold", color: colors.foreground },
    confirmBtn: { flex: 1, borderRadius: 10, paddingVertical: 12, alignItems: "center" },
    confirmTxt: { fontSize: 14, fontFamily: "Inter_700Bold", color: "#fff" },
  });

  const MsgModal = ({ msg, color, icon, onClose }: { msg: string; color: string; icon: string; onClose: () => void }) => (
    <Modal visible={!!msg} transparent animationType="fade">
      <View style={s.overlay}>
        <View style={s.modalBox}>
          <Feather name={icon as any} size={28} color={color} style={{ marginBottom: 10, alignSelf: "center" }} />
          <Text style={{ fontSize: 14, fontFamily: "Inter_400Regular", color: colors.foreground, textAlign: "center", marginBottom: 20 }}>{msg}</Text>
          <TouchableOpacity onPress={onClose} style={{ backgroundColor: color, borderRadius: 10, paddingVertical: 11, alignItems: "center" }}>
            <Text style={{ color: "#fff", fontSize: 15, fontFamily: "Inter_700Bold" }}>OK</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );

  if (!authed) {
    return (
      <View style={[s.container, { justifyContent: "center", padding: 28 }]}>
        <View style={{ alignItems: "center", marginBottom: 32 }}>
          <View style={{ width: 72, height: 72, borderRadius: 36, backgroundColor: "#EDE7F6", alignItems: "center", justifyContent: "center", marginBottom: 16 }}>
            <Feather name="shield" size={36} color="#1565C0" />
          </View>
          <Text style={{ fontSize: 24, fontFamily: "Inter_700Bold", color: "#1565C0", marginBottom: 6 }}>Admin Panel</Text>
          <Text style={{ fontSize: 14, fontFamily: "Inter_400Regular", color: "#666", textAlign: "center" }}>Enter admin credentials to continue</Text>
        </View>
        <Text style={{ fontSize: 11, fontFamily: "Inter_600SemiBold", color: "#666", marginBottom: 6, textTransform: "uppercase" }}>Admin Username</Text>
        <TextInput
          style={{ backgroundColor: "#F5F5F5", borderWidth: 1, borderColor: authError ? "#B71C1C" : "#DDD", borderRadius: 12, padding: 14, fontSize: 15, fontFamily: "Inter_400Regular", marginBottom: 14, color: "#222" }}
          placeholder="Admin username"
          placeholderTextColor="#999"
          value={authUser}
          onChangeText={setAuthUser}
          autoCapitalize="none"
        />
        <Text style={{ fontSize: 11, fontFamily: "Inter_600SemiBold", color: "#666", marginBottom: 6, textTransform: "uppercase" }}>Admin Password</Text>
        <TextInput
          style={{ backgroundColor: "#F5F5F5", borderWidth: 1, borderColor: authError ? "#B71C1C" : "#DDD", borderRadius: 12, padding: 14, fontSize: 15, fontFamily: "Inter_400Regular", marginBottom: 8, color: "#222" }}
          placeholder="Admin password"
          placeholderTextColor="#999"
          value={authPass}
          onChangeText={setAuthPass}
          secureTextEntry
        />
        {authError ? <Text style={{ color: "#B71C1C", fontSize: 13, fontFamily: "Inter_400Regular", marginBottom: 12 }}>{authError}</Text> : <View style={{ height: 20 }} />}
        <TouchableOpacity
          style={{ backgroundColor: "#1565C0", borderRadius: 12, paddingVertical: 14, alignItems: "center", marginTop: 4 }}
          onPress={() => {
            if (authUser.trim() === ADMIN_USERNAME && authPass === ADMIN_PASSWORD) {
              setAuthed(true);
              setAuthError("");
            } else {
              setAuthError("Invalid admin username or password");
            }
          }}
        >
          <Text style={{ color: "#fff", fontSize: 16, fontFamily: "Inter_700Bold" }}>Sign In</Text>
        </TouchableOpacity>
        <TouchableOpacity style={{ marginTop: 16, alignItems: "center" }} onPress={() => router.back()}>
          <Text style={{ color: "#1565C0", fontSize: 14, fontFamily: "Inter_600SemiBold" }}>← Go Back</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={s.container}>
      <View style={s.header}>
        <View style={s.headerRow}>
          <TouchableOpacity style={s.homeBtn} onPress={() => router.replace("/" as never)}>
            <Feather name="home" size={13} color="#fff" /><Text style={s.homeBtnTxt}>Home</Text>
          </TouchableOpacity>
          <TouchableOpacity style={s.homeBtn} onPress={() => router.back()}>
            <Feather name="arrow-left" size={13} color="#fff" /><Text style={s.homeBtnTxt}>Back</Text>
          </TouchableOpacity>
        </View>
        <Text style={s.headerTitle}>Admin Panel</Text>
        <Text style={s.headerSub}>{users.length} registered user{users.length !== 1 ? "s" : ""}</Text>
      </View>

      <View style={s.toolbar}>
        <View style={s.searchBox}>
          <Feather name="search" size={15} color={colors.mutedForeground} />
          <TextInput style={s.searchInput} placeholder="Search username..." placeholderTextColor={colors.mutedForeground} value={search} onChangeText={setSearch} autoCapitalize="none" />
        </View>
        <TouchableOpacity style={s.iconBtn} onPress={handleDownloadCSV}>
          <Feather name="download" size={14} color="#fff" /><Text style={s.iconBtnTxt}>CSV</Text>
        </TouchableOpacity>
        <TouchableOpacity style={[s.iconBtn, { backgroundColor: colors.mutedForeground }]} onPress={loadUsers}>
          <Feather name="refresh-cw" size={14} color="#fff" />
        </TouchableOpacity>
      </View>

      {loading ? (
        <ActivityIndicator size="large" color="#1565C0" style={{ marginTop: 40 }} />
      ) : filtered.length === 0 ? (
        <View style={{ alignItems: "center", marginTop: 60 }}>
          <Feather name="users" size={48} color={colors.mutedForeground} />
          <Text style={{ fontSize: 15, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground, marginTop: 12 }}>
            {search ? "No users match search" : "No users registered yet"}
          </Text>
        </View>
      ) : (
        <ScrollView contentContainerStyle={{ paddingBottom: 40 }}>
          {filtered.map((u) => {
            const status = expiryStatus(u);
            return (
              <View key={u.id} style={[s.card, u.isLocked && { borderColor: "#B71C1C" }]}>
                <View style={s.cardTop}>
                  <View style={s.avatar}>
                    <Text style={{ fontSize: 16, fontFamily: "Inter_700Bold", color: "#1565C0" }}>{u.username.charAt(0).toUpperCase()}</Text>
                  </View>
                  <View style={{ flex: 1 }}>
                    <Text style={s.username}>{u.username}</Text>
                    <Text style={s.infoTxt}>Pass: <Text style={{ fontFamily: "Inter_600SemiBold", color: colors.foreground }}>{u.password}</Text>  PIN: <Text style={{ fontFamily: "Inter_600SemiBold", color: colors.foreground }}>{u.pin || "—"}</Text></Text>
                  </View>
                </View>
                <View style={s.metaRow}>
                  <View style={[s.badge, { backgroundColor: status.bg }]}>
                    <Feather name="clock" size={10} color={status.color} />
                    <Text style={[s.badgeTxt, { color: status.color }]}>{status.label}</Text>
                  </View>
                  <View style={[s.badge, { backgroundColor: colors.secondary }]}>
                    <Feather name="calendar" size={10} color={colors.mutedForeground} />
                    <Text style={[s.badgeTxt, { color: colors.mutedForeground }]}>{u.scheduleCount} schedules</Text>
                  </View>
                </View>
                <Text style={s.infoTxt}>Registered: {fmtDate(u.registeredAt)}</Text>
                <Text style={s.infoTxt}>Expiry: <Text style={{ fontFamily: "Inter_600SemiBold", color: u.expiryDate ? (new Date(u.expiryDate) < new Date() ? "#B71C1C" : "#2E7D32") : "#1565C0" }}>{u.expiryDate ? fmtDate(u.expiryDate) : "No Expiry Set"}</Text></Text>
                <View style={s.actionRow}>
                  <TouchableOpacity style={[s.actionBtn, { borderColor: "#1565C0", backgroundColor: "#EDE7F6" }]} onPress={() => { setExpiryTarget(u); setExpiryDays("30"); setExpiryCustomDate(""); setExpiryMode("days"); }} disabled={actionLoading}>
                    <Feather name="check-circle" size={12} color="#1565C0" /><Text style={[s.actionBtnTxt, { color: "#1565C0" }]}>Activate</Text>
                  </TouchableOpacity>
                  <TouchableOpacity style={[s.actionBtn, { borderColor: u.isLocked ? "#2E7D32" : "#E65100", backgroundColor: u.isLocked ? "#E8F5E9" : "#FFF3E0" }]} onPress={() => handleToggleLock(u)} disabled={actionLoading}>
                    <Feather name={u.isLocked ? "unlock" : "lock"} size={12} color={u.isLocked ? "#2E7D32" : "#E65100"} /><Text style={[s.actionBtnTxt, { color: u.isLocked ? "#2E7D32" : "#E65100" }]}>{u.isLocked ? "Unlock" : "Lock"}</Text>
                  </TouchableOpacity>
                  <TouchableOpacity style={[s.actionBtn, { borderColor: colors.primary, backgroundColor: colors.primary + "15" }]} onPress={() => { setPasswordTarget(u); setNewPassword(""); setConfirmPassword(""); }} disabled={actionLoading}>
                    <Feather name="key" size={12} color={colors.primary} /><Text style={[s.actionBtnTxt, { color: colors.primary }]}>Password</Text>
                  </TouchableOpacity>
                  <TouchableOpacity style={[s.actionBtn, { borderColor: colors.destructive, backgroundColor: colors.destructive + "12" }]} onPress={() => setDeleteTarget(u)} disabled={actionLoading}>
                    <Feather name="trash-2" size={12} color={colors.destructive} /><Text style={[s.actionBtnTxt, { color: colors.destructive }]}>Delete</Text>
                  </TouchableOpacity>
                </View>
              </View>
            );
          })}
        </ScrollView>
      )}

      {/* Activate modal */}
      <Modal visible={!!expiryTarget} transparent animationType="slide">
        <View style={[s.overlay, { justifyContent: "flex-end", padding: 0 }]}>
          <View style={[s.modalBox, { borderRadius: 0, borderTopLeftRadius: 20, borderTopRightRadius: 20, paddingBottom: insets.bottom + 24 }]}>
            <Text style={s.modalTitle}>Activate Account</Text>
            <Text style={s.modalSub}>Set duration for <Text style={{ fontFamily: "Inter_700Bold", color: colors.foreground }}>{expiryTarget?.username}</Text></Text>
            <View style={s.modeRow}>
              {(["days", "date"] as const).map(m => (
                <TouchableOpacity key={m} style={[s.modeBtn, { borderColor: expiryMode === m ? "#1565C0" : colors.border, backgroundColor: expiryMode === m ? "#EDE7F6" : colors.background }]} onPress={() => setExpiryMode(m)}>
                  <Text style={{ fontSize: 13, fontFamily: "Inter_600SemiBold", color: expiryMode === m ? "#1565C0" : colors.mutedForeground }}>{m === "days" ? "By Days" : "By Date"}</Text>
                </TouchableOpacity>
              ))}
            </View>
            {expiryMode === "days" ? (
              <>
                <Text style={s.modalLabel}>Days from Today</Text>
                <TextInput style={s.modalInput} placeholder="e.g. 30" placeholderTextColor={colors.mutedForeground} value={expiryDays} onChangeText={setExpiryDays} keyboardType="number-pad" autoFocus />
                <View style={s.quickRow}>
                  {[30, 90, 180, 365].map(d => (
                    <TouchableOpacity key={d} onPress={() => setExpiryDays(String(d))} style={{ flex: 1, backgroundColor: expiryDays === String(d) ? "#1565C0" : colors.secondary, borderRadius: 8, paddingVertical: 7, alignItems: "center" }}>
                      <Text style={{ fontSize: 12, fontFamily: "Inter_600SemiBold", color: expiryDays === String(d) ? "#fff" : colors.mutedForeground }}>{d}d</Text>
                    </TouchableOpacity>
                  ))}
                </View>
              </>
            ) : (
              <>
                <Text style={s.modalLabel}>Expiry Date (YYYY-MM-DD)</Text>
                <TextInput style={s.modalInput} placeholder="2026-12-31" placeholderTextColor={colors.mutedForeground} value={expiryCustomDate} onChangeText={setExpiryCustomDate} autoFocus />
              </>
            )}
            <View style={s.modalRow}>
              <TouchableOpacity style={s.cancelBtn} onPress={() => setExpiryTarget(null)} disabled={actionLoading}><Text style={s.cancelTxt}>Cancel</Text></TouchableOpacity>
              <TouchableOpacity style={[s.confirmBtn, { backgroundColor: "#1565C0" }]} onPress={handleSetExpiry} disabled={actionLoading}>
                {actionLoading ? <ActivityIndicator color="#fff" size="small" /> : <Text style={s.confirmTxt}>Activate</Text>}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      {/* Change Password modal */}
      <Modal visible={!!passwordTarget} transparent animationType="slide">
        <View style={[s.overlay, { justifyContent: "flex-end", padding: 0 }]}>
          <View style={[s.modalBox, { borderRadius: 0, borderTopLeftRadius: 20, borderTopRightRadius: 20, paddingBottom: insets.bottom + 24 }]}>
            <Text style={s.modalTitle}>Change Password</Text>
            <Text style={s.modalSub}>New password for <Text style={{ fontFamily: "Inter_700Bold", color: colors.foreground }}>{passwordTarget?.username}</Text></Text>
            <Text style={s.modalLabel}>New Password</Text>
            <TextInput style={s.modalInput} placeholder="Min 4 characters" placeholderTextColor={colors.mutedForeground} value={newPassword} onChangeText={setNewPassword} secureTextEntry autoFocus />
            <Text style={s.modalLabel}>Confirm Password</Text>
            <TextInput style={s.modalInput} placeholder="Re-enter" placeholderTextColor={colors.mutedForeground} value={confirmPassword} onChangeText={setConfirmPassword} secureTextEntry />
            <View style={s.modalRow}>
              <TouchableOpacity style={s.cancelBtn} onPress={() => setPasswordTarget(null)} disabled={actionLoading}><Text style={s.cancelTxt}>Cancel</Text></TouchableOpacity>
              <TouchableOpacity style={[s.confirmBtn, { backgroundColor: "#1565C0" }]} onPress={handleChangePassword} disabled={actionLoading}>
                {actionLoading ? <ActivityIndicator color="#fff" size="small" /> : <Text style={s.confirmTxt}>Update</Text>}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      {/* Delete modal */}
      <Modal visible={!!deleteTarget} transparent animationType="fade">
        <View style={s.overlay}>
          <View style={s.modalBox}>
            <Text style={s.modalTitle}>Delete User</Text>
            <Text style={s.modalSub}>Permanently delete "{deleteTarget?.username}" and all their data? This cannot be undone.</Text>
            <View style={s.modalRow}>
              <TouchableOpacity style={s.cancelBtn} onPress={() => setDeleteTarget(null)} disabled={actionLoading}><Text style={s.cancelTxt}>Cancel</Text></TouchableOpacity>
              <TouchableOpacity style={[s.confirmBtn, { backgroundColor: colors.destructive }]} onPress={handleDelete} disabled={actionLoading}>
                {actionLoading ? <ActivityIndicator color="#fff" size="small" /> : <Text style={s.confirmTxt}>Delete</Text>}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      <MsgModal msg={errorMsg} color={colors.destructive} icon="alert-circle" onClose={() => setErrorMsg("")} />
      <MsgModal msg={successMsg} color="#2E7D32" icon="check-circle" onClose={() => setSuccessMsg("")} />
    </View>
  );
}
