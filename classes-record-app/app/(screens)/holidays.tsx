import React, { useState, useCallback } from "react";
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  TextInput, ActivityIndicator, Alert, Platform,
} from "react-native";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useFocusEffect } from "expo-router";
import * as ScreenOrientation from "expo-screen-orientation";

import { useColors } from "@/hooks/useColors";
import { fetchHolidays, addHoliday, deleteHoliday } from "@/hooks/useApi";

export default function HolidaysScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const qc = useQueryClient();
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

  const [newDate, setNewDate] = useState("");
  const [newName, setNewName] = useState("");

  const { data: holidays = [], isLoading } = useQuery({ queryKey: ["holidays"], queryFn: fetchHolidays });

  const addMutation = useMutation({
    mutationFn: () => addHoliday(newDate, newName),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["holidays"] }); setNewDate(""); setNewName(""); },
    onError: () => Alert.alert("Error", "Failed to add holiday"),
  });

  const deleteMutation = useMutation({
    mutationFn: deleteHoliday,
    onSuccess: () => qc.invalidateQueries({ queryKey: ["holidays"] }),
  });

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
    addCard: {
      backgroundColor: colors.card, margin: 12, borderRadius: 12, padding: 16,
      borderWidth: 1, borderColor: colors.border,
    },
    addTitle: { fontSize: 15, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 12 },
    input: {
      backgroundColor: colors.muted, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12,
      fontFamily: "Inter_400Regular", fontSize: 14, color: colors.foreground,
      borderWidth: 1, borderColor: colors.border, marginBottom: 10,
    },
    addBtn: {
      backgroundColor: colors.primary, borderRadius: 10, padding: 12,
      alignItems: "center",
    },
    addBtnTxt: { color: "#fff", fontFamily: "Inter_700Bold", fontSize: 15 },
    list: { paddingHorizontal: 12, paddingBottom: 40 },
    listTitle: { fontSize: 14, fontFamily: "Inter_700Bold", color: colors.mutedForeground, marginBottom: 8, marginTop: 4 },
    card: {
      backgroundColor: colors.card, borderRadius: 10, padding: 14, marginBottom: 8,
      borderWidth: 1, borderColor: colors.border, flexDirection: "row", alignItems: "center",
    },
    cardIcon: { marginRight: 12 },
    cardContent: { flex: 1 },
    cardDate: { fontSize: 12, fontFamily: "Inter_600SemiBold", color: colors.primary },
    cardName: { fontSize: 15, fontFamily: "Inter_500Medium", color: colors.foreground, marginTop: 2 },
    emptyTxt: { color: colors.mutedForeground, fontFamily: "Inter_400Regular", fontSize: 14, textAlign: "center", marginTop: 20 },
  });

  return (
    <View style={s.container}>
      <View style={s.header}>
        <View style={{ flexDirection: "row", gap: 8, marginBottom: 10 }}>
          <TouchableOpacity style={[s.homeBtn, { marginBottom: 0 }]} onPress={() => router.back()}>
            <Feather name="chevron-left" size={14} color="#fff" />
            <Text style={s.homeBtnTxt}>Back</Text>
          </TouchableOpacity>
          <TouchableOpacity style={[s.homeBtn, { marginBottom: 0 }]} onPress={() => router.replace("/")}>
            <Feather name="home" size={14} color="#fff" />
            <Text style={s.homeBtnTxt}>Home</Text>
          </TouchableOpacity>
        </View>
        <Text style={s.headerTitle}>Gazzetted Holidays</Text>
        <Text style={s.headerSub}>These days are excluded from ToBeConducted count</Text>
      </View>

      <ScrollView contentContainerStyle={{ paddingBottom: 20 }} keyboardShouldPersistTaps="handled">
        <View style={s.addCard}>
          <Text style={s.addTitle}>Add Holiday</Text>
          <TextInput
            style={s.input} value={newDate} onChangeText={setNewDate}
            placeholder="Date (YYYY-MM-DD)" placeholderTextColor={colors.mutedForeground}
          />
          <TextInput
            style={s.input} value={newName} onChangeText={setNewName}
            placeholder="Holiday name" placeholderTextColor={colors.mutedForeground}
          />
          <TouchableOpacity
            style={[s.addBtn, (addMutation.isPending || !newDate || !newName) && { opacity: 0.5 }]}
            disabled={addMutation.isPending || !newDate || !newName}
            onPress={() => addMutation.mutate()}
          >
            {addMutation.isPending ? <ActivityIndicator color="#fff" /> : <Text style={s.addBtnTxt}>Add Holiday</Text>}
          </TouchableOpacity>
        </View>

        <View style={s.list}>
          <Text style={s.listTitle}>{holidays.length} Holiday{holidays.length !== 1 ? "s" : ""} Recorded</Text>

          {isLoading ? (
            <ActivityIndicator size="large" color={colors.primary} style={{ marginTop: 20 }} />
          ) : holidays.length === 0 ? (
            <Text style={s.emptyTxt}>No holidays added yet</Text>
          ) : (
            holidays.map((h) => (
              <View key={h.id} style={s.card}>
                <Feather name="sun" size={22} color="#F59E0B" style={s.cardIcon} />
                <View style={s.cardContent}>
                  <Text style={s.cardDate}>{h.date}</Text>
                  <Text style={s.cardName}>{h.name}</Text>
                </View>
                <TouchableOpacity onPress={() => {
                  Alert.alert("Remove Holiday", `Remove "${h.name}"?`, [
                    { text: "Cancel", style: "cancel" },
                    { text: "Remove", style: "destructive", onPress: () => deleteMutation.mutate(h.id) },
                  ]);
                }}>
                  <Feather name="trash-2" size={18} color={colors.mutedForeground} />
                </TouchableOpacity>
              </View>
            ))
          )}
        </View>
      </ScrollView>
    </View>
  );
}
