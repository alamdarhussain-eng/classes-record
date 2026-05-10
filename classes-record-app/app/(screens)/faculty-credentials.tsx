import React, { useState, useCallback } from "react";
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  TextInput, ActivityIndicator, Alert, Modal, Linking, Platform,
} from "react-native";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useLocalSearchParams, useFocusEffect } from "expo-router";
import * as ScreenOrientation from "expo-screen-orientation";

import { useColors } from "@/hooks/useColors";
import {
  fetchFacultyAccounts, generateFacultyAccounts,
  updateFacultyAccount, deleteFacultyAccount,
  FacultyAccount,
} from "@/hooks/useApi";

export default function FacultyCredentialsScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const qc = useQueryClient();
  const { scheduleId: rawId, scheduleTitle } =
    useLocalSearchParams<{ scheduleId: string; scheduleTitle: string }>();
  const scheduleId = Number(rawId);

  useFocusEffect(useCallback(() => {
    if (Platform.OS !== "web")
      ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.PORTRAIT_UP).catch(() => {});
  }, []));

  const { data: accounts = [], isLoading } = useQuery({
    queryKey: ["facultyAccounts", scheduleId],
    queryFn: () => fetchFacultyAccounts(scheduleId),
    enabled: !!scheduleId,
  });

  const [generating, setGenerating] = useState(false);
  const [editEmailId, setEditEmailId] = useState<number | null>(null);
  const [emailDraft, setEmailDraft] = useState("");
  const [savingEmail, setSavingEmail] = useState(false);
  const [regenId, setRegenId] = useState<number | null>(null);
  const [showPassId, setShowPassId] = useState<Set<number>>(new Set());
  const [detailAccount, setDetailAccount] = useState<FacultyAccount | null>(null);

  async function handleGenerate() {
    setGenerating(true);
    try {
      const r = await generateFacultyAccounts(scheduleId);
      qc.invalidateQueries({ queryKey: ["facultyAccounts", scheduleId] });
      if (r.created === 0) {
        Alert.alert("Up to Date", "All faculty already have credentials.");
      } else {
        Alert.alert("Done", `Created ${r.created} new account${r.created !== 1 ? "s" : ""}.`);
      }
    } finally {
      setGenerating(false);
    }
  }

  async function handleRegenPassword(id: number) {
    Alert.alert(
      "Regenerate Password",
      "Generate a new random password for this faculty member?",
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Regenerate",
          onPress: async () => {
            setRegenId(id);
            await updateFacultyAccount(id, { regenerate: true });
            qc.invalidateQueries({ queryKey: ["facultyAccounts", scheduleId] });
            setRegenId(null);
          },
        },
      ]
    );
  }

  async function handleSaveEmail(id: number) {
    setSavingEmail(true);
    await updateFacultyAccount(id, { email: emailDraft.trim() });
    qc.invalidateQueries({ queryKey: ["facultyAccounts", scheduleId] });
    setSavingEmail(false);
    setEditEmailId(null);
  }

  async function handleDelete(acc: FacultyAccount) {
    Alert.alert(
      "Delete Account",
      `Remove credentials for ${acc.facultyName}? They will no longer be able to log in.`,
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Delete",
          style: "destructive",
          onPress: async () => {
            await deleteFacultyAccount(acc.id);
            qc.invalidateQueries({ queryKey: ["facultyAccounts", scheduleId] });
          },
        },
      ]
    );
  }

  function toggleShowPass(id: number) {
    setShowPassId(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id); else next.add(id);
      return next;
    });
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
    toolbar: {
      flexDirection: "row", gap: 10, padding: 12,
      backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    toolBtn: {
      flex: 1, flexDirection: "row", alignItems: "center", justifyContent: "center",
      gap: 7, paddingVertical: 10, borderRadius: 10, borderWidth: 1,
    },
    toolBtnTxt: { fontSize: 13, fontFamily: "Inter_600SemiBold" },
    infoBar: {
      flexDirection: "row", alignItems: "center", gap: 6,
      marginHorizontal: 12, marginVertical: 8, padding: 10,
      backgroundColor: "#E3F2FD", borderRadius: 10,
    },
    infoTxt: { fontSize: 12, fontFamily: "Inter_400Regular", color: "#1565C0", flex: 1 },
    card: {
      marginHorizontal: 12, marginVertical: 6,
      backgroundColor: colors.card, borderRadius: 14,
      borderWidth: 1, borderColor: colors.border,
      overflow: "hidden",
    },
    cardHeader: { padding: 14, backgroundColor: "#E3F2FD", borderBottomWidth: 1, borderBottomColor: colors.border },
    facName: { fontSize: 15, fontFamily: "Inter_700Bold", color: "#1565C0" },
    facClasses: { fontSize: 11, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginTop: 2 },
    credRow: {
      flexDirection: "row", alignItems: "center", gap: 8,
      paddingHorizontal: 14, paddingVertical: 9,
      borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    credLabel: { width: 70, fontSize: 12, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground },
    credValue: { flex: 1, fontSize: 13, fontFamily: "Inter_500Medium", color: colors.foreground },
    credMasked: { flex: 1, fontSize: 16, fontFamily: "Inter_500Medium", color: colors.foreground, letterSpacing: 3 },
    iconBtn: { padding: 4 },
    emailInput: {
      flex: 1, fontSize: 13, fontFamily: "Inter_400Regular", color: colors.foreground,
      backgroundColor: colors.muted, borderRadius: 7, borderWidth: 1, borderColor: colors.border,
      paddingHorizontal: 8, paddingVertical: 5,
    },
    saveEmailBtn: {
      backgroundColor: colors.primary, borderRadius: 7,
      paddingHorizontal: 10, paddingVertical: 6,
    },
    saveEmailTxt: { color: "#fff", fontSize: 12, fontFamily: "Inter_700Bold" },
    cardFooter: {
      flexDirection: "row", gap: 8, padding: 10,
      backgroundColor: colors.muted,
    },
    footerBtn: {
      flex: 1, flexDirection: "row", alignItems: "center", justifyContent: "center",
      gap: 5, paddingVertical: 8, borderRadius: 8, borderWidth: 1,
    },
    footerBtnTxt: { fontSize: 12, fontFamily: "Inter_600SemiBold" },
    detailOverlay: {
      flex: 1, backgroundColor: "rgba(0,0,0,0.5)", justifyContent: "center",
      alignItems: "center", padding: 24,
    },
    detailBox: {
      backgroundColor: colors.card, borderRadius: 16, width: "100%",
      padding: 20, gap: 14,
    },
    detailTitle: { fontSize: 17, fontFamily: "Inter_700Bold", color: colors.foreground, textAlign: "center" },
    detailRow: {
      flexDirection: "row", alignItems: "center",
      backgroundColor: colors.muted, borderRadius: 10, padding: 12, gap: 10,
    },
    detailLabel: { width: 80, fontSize: 12, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground },
    detailVal: { flex: 1, fontSize: 15, fontFamily: "Inter_700Bold", color: colors.foreground },
    detailCloseBtn: {
      backgroundColor: colors.primary, borderRadius: 10,
      paddingVertical: 12, alignItems: "center",
    },
    detailCloseTxt: { color: "#fff", fontSize: 15, fontFamily: "Inter_700Bold" },
    empty: { alignItems: "center", marginTop: 60, paddingHorizontal: 32 },
    emptyTxt: { fontSize: 15, fontFamily: "Inter_400Regular", color: colors.mutedForeground, textAlign: "center", marginTop: 12 },
  });

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
        <Text style={s.headerTitle}>Faculty Access</Text>
        <Text style={s.headerSub}>{scheduleTitle} · {accounts.length} account{accounts.length !== 1 ? "s" : ""}</Text>
      </View>

      {/* Toolbar */}
      <View style={s.toolbar}>
        <TouchableOpacity
          style={[s.toolBtn, { backgroundColor: "#E8F5E9", borderColor: "#2E7D32" }]}
          onPress={handleGenerate}
          disabled={generating}
        >
          {generating
            ? <ActivityIndicator color="#2E7D32" size="small" />
            : <Feather name="zap" size={16} color="#2E7D32" />
          }
          <Text style={[s.toolBtnTxt, { color: "#2E7D32" }]}>Generate All</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[s.toolBtn, { backgroundColor: "#E3F2FD", borderColor: "#1565C0" }]}
          onPress={() => Linking.openURL(`https://${process.env.EXPO_PUBLIC_DOMAIN}/api/faculty-access/download?scheduleId=${scheduleId}`)}
          disabled={accounts.length === 0}
        >
          <Feather name="download" size={16} color="#1565C0" />
          <Text style={[s.toolBtnTxt, { color: "#1565C0" }]}>Download Excel</Text>
        </TouchableOpacity>
      </View>

      <View style={s.infoBar}>
        <Feather name="info" size={14} color="#1565C0" />
        <Text style={s.infoTxt}>
          Tap a row to view full credentials. Share username &amp; password privately with each faculty member.
        </Text>
      </View>

      {isLoading ? (
        <ActivityIndicator color={colors.primary} style={{ marginTop: 40 }} size="large" />
      ) : accounts.length === 0 ? (
        <View style={s.empty}>
          <Feather name="user-x" size={44} color={colors.mutedForeground} />
          <Text style={s.emptyTxt}>
            No faculty accounts yet.{"\n"}Tap "Generate All" to create credentials for every faculty member in this schedule.
          </Text>
        </View>
      ) : (
        <ScrollView contentContainerStyle={{ paddingBottom: 32 }}>
          {accounts.map(acc => {
            const showPass = showPassId.has(acc.id);
            const isEditingEmail = editEmailId === acc.id;
            return (
              <View key={acc.id} style={s.card}>
                {/* Card header */}
                <TouchableOpacity style={s.cardHeader} onPress={() => setDetailAccount(acc)} activeOpacity={0.8}>
                  <Text style={s.facName}>{acc.facultyName}</Text>
                  {acc.classes.length > 0 && (
                    <Text style={s.facClasses} numberOfLines={2}>
                      {acc.classes.slice(0, 3).join(" · ")}{acc.classes.length > 3 ? ` +${acc.classes.length - 3} more` : ""}
                    </Text>
                  )}
                </TouchableOpacity>

                {/* Username */}
                <View style={s.credRow}>
                  <Text style={s.credLabel}>Username</Text>
                  <Text style={s.credValue}>{acc.username}</Text>
                </View>

                {/* Password */}
                <View style={s.credRow}>
                  <Text style={s.credLabel}>Password</Text>
                  <Text style={showPass ? s.credValue : s.credMasked}>
                    {showPass ? acc.password : "••••••••"}
                  </Text>
                  <TouchableOpacity style={s.iconBtn} onPress={() => toggleShowPass(acc.id)}>
                    <Feather name={showPass ? "eye-off" : "eye"} size={16} color={colors.mutedForeground} />
                  </TouchableOpacity>
                </View>

                {/* Email */}
                <View style={s.credRow}>
                  <Text style={s.credLabel}>Email</Text>
                  {isEditingEmail ? (
                    <>
                      <TextInput
                        style={s.emailInput}
                        value={emailDraft}
                        onChangeText={setEmailDraft}
                        placeholder="faculty@university.edu"
                        placeholderTextColor={colors.mutedForeground}
                        autoCapitalize="none"
                        keyboardType="email-address"
                        autoFocus
                      />
                      {savingEmail
                        ? <ActivityIndicator color={colors.primary} size="small" />
                        : (
                          <TouchableOpacity style={s.saveEmailBtn} onPress={() => handleSaveEmail(acc.id)}>
                            <Text style={s.saveEmailTxt}>Save</Text>
                          </TouchableOpacity>
                        )
                      }
                      <TouchableOpacity style={s.iconBtn} onPress={() => setEditEmailId(null)}>
                        <Feather name="x" size={16} color={colors.mutedForeground} />
                      </TouchableOpacity>
                    </>
                  ) : (
                    <>
                      <Text style={[s.credValue, !acc.email && { color: colors.mutedForeground, fontStyle: "italic" }]}>
                        {acc.email || "Not set"}
                      </Text>
                      <TouchableOpacity style={s.iconBtn} onPress={() => { setEditEmailId(acc.id); setEmailDraft(acc.email); }}>
                        <Feather name="edit-2" size={15} color={colors.primary} />
                      </TouchableOpacity>
                    </>
                  )}
                </View>

                {/* Card footer actions */}
                <View style={s.cardFooter}>
                  <TouchableOpacity
                    style={[s.footerBtn, { borderColor: "#E65100", backgroundColor: "#FFF3E0" }]}
                    onPress={() => handleRegenPassword(acc.id)}
                    disabled={regenId === acc.id}
                  >
                    {regenId === acc.id
                      ? <ActivityIndicator color="#E65100" size="small" />
                      : <Feather name="refresh-cw" size={14} color="#E65100" />
                    }
                    <Text style={[s.footerBtnTxt, { color: "#E65100" }]}>Regenerate</Text>
                  </TouchableOpacity>

                  <TouchableOpacity
                    style={[s.footerBtn, { borderColor: "#C62828", backgroundColor: "#FFEBEE" }]}
                    onPress={() => handleDelete(acc)}
                  >
                    <Feather name="trash-2" size={14} color="#C62828" />
                    <Text style={[s.footerBtnTxt, { color: "#C62828" }]}>Delete</Text>
                  </TouchableOpacity>
                </View>
              </View>
            );
          })}
        </ScrollView>
      )}

      {/* Detail modal — shows full credentials for sharing */}
      <Modal visible={!!detailAccount} transparent animationType="fade">
        <View style={s.detailOverlay}>
          {detailAccount && (
            <View style={s.detailBox}>
              <Text style={s.detailTitle}>{detailAccount.facultyName}</Text>
              <View style={s.detailRow}>
                <Text style={s.detailLabel}>Username</Text>
                <Text style={s.detailVal}>{detailAccount.username}</Text>
              </View>
              <View style={s.detailRow}>
                <Text style={s.detailLabel}>Password</Text>
                <Text style={s.detailVal}>{detailAccount.password}</Text>
              </View>
              {detailAccount.email ? (
                <View style={s.detailRow}>
                  <Text style={s.detailLabel}>Email</Text>
                  <Text style={[s.detailVal, { fontSize: 13 }]}>{detailAccount.email}</Text>
                </View>
              ) : null}
              {detailAccount.classes.length > 0 && (
                <View style={s.detailRow}>
                  <Text style={s.detailLabel}>Classes</Text>
                  <Text style={[s.detailVal, { fontSize: 12, fontFamily: "Inter_400Regular" }]} numberOfLines={4}>
                    {detailAccount.classes.join(", ")}
                  </Text>
                </View>
              )}
              <TouchableOpacity style={s.detailCloseBtn} onPress={() => setDetailAccount(null)}>
                <Text style={s.detailCloseTxt}>Close</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>
      </Modal>
    </View>
  );
}
