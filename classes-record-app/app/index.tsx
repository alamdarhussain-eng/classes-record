import React from "react";
import {
  View, Text, StyleSheet, TouchableOpacity, ScrollView, Platform,
  ActivityIndicator,
} from "react-native";
import { useRouter } from "expo-router";

import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useQuery } from "@tanstack/react-query";

import { useColors } from "@/hooks/useColors";
import { Feather } from "@expo/vector-icons";
import { fetchPublicSchedules } from "@/hooks/useApi";

const TILES = [
  { route: "/(screens)/schedule",      emoji: "📅", title: "Weekly Schedule",      subtitle: "Mon–Fri timetable",           color: "#1565C0", bg: "#E3F2FD" },
  { route: "/(screens)/entry",         emoji: "✏️",  title: "New Entry",            subtitle: "Missed · Late · Makeup",      color: "#E65100", bg: "#FFF3E0" },
  { route: "/(screens)/summary",       emoji: "📊", title: "Teaching Summary",     subtitle: "TBC · Deficit · Surplus",     color: "#2E7D32", bg: "#E8F5E9" },
  { route: "/(screens)/meeting",       emoji: "👥", title: "Meeting Availability", subtitle: "Check who is free",           color: "#6A1B9A", bg: "#F3E5F5" },
  { route: "/(screens)/holidays",      emoji: "🗓️", title: "Gazzetted Holidays",   subtitle: "Excluded from TBC count",     color: "#00695C", bg: "#E0F2F1" },
  { route: "/(screens)/my-schedules",  emoji: "🔒", title: "My Schedules",         subtitle: "Private · Login required",    color: "#AD1457", bg: "#FCE4EC" },
  { route: "/(screens)/finance",       emoji: "💰", title: "Account & Finance",    subtitle: "Fees · Salary · Payments",    color: "#F57F17", bg: "#FFFDE7" },
  { route: "/(screens)/tutorial",      emoji: "📖", title: "Tutorial",             subtitle: "Guide · Examples · PDF",      color: "#283593", bg: "#E8EAF6" },
  { route: "/(screens)/faculty-portal",emoji: "👤", title: "Faculty Sign In",      subtitle: "Attendance · Exam marks",     color: "#00695C", bg: "#E0F2F1" },
  { route: "/(screens)/contact",       emoji: "📞", title: "Contact Us",           subtitle: "Alamdar Hussain · Islamabad", color: "#1565C0", bg: "#E3F2FD" },
  { route: "/(screens)/admin-panel",   emoji: "🛡️", title: "Admin Panel",          subtitle: "Users · Passwords · CSV",     color: "#4A148C", bg: "#EDE7F6" },
];

export default function DashboardScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();

  const { data: publicSchedules = [], isLoading: pubLoading } = useQuery({
    queryKey: ["publicSchedules"],
    queryFn: fetchPublicSchedules,
  });

  const s = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    header: {
      backgroundColor: colors.primary,
      paddingTop: insets.top + (Platform.OS === "web" ? 67 : 16),
      paddingBottom: 24,
      paddingHorizontal: 20,
    },
    appName: {
      color: "#fff",
      fontSize: 28,
      fontFamily: "Inter_700Bold",
      letterSpacing: 0.5,
    },
    appSub: {
      color: "rgba(255,255,255,0.75)",
      fontSize: 14,
      fontFamily: "Inter_400Regular",
      marginTop: 4,
    },
    scroll: { flex: 1 },
    grid: {
      padding: 16,
      flexDirection: "row",
      flexWrap: "wrap",
      gap: 14,
    },
    tile: {
      width: "47%",
      borderRadius: 18,
      padding: 16,
      borderWidth: 0.5,
      borderColor: colors.border,
      alignItems: "flex-start",
      backgroundColor: colors.card,
      shadowColor: "#000",
      shadowOffset: { width: 0, height: 1 },
      shadowOpacity: 0.05,
      shadowRadius: 3,
      elevation: 1,
    },
    tileWide: {
      width: "100%",
    },
    iconCircle: {
      width: 52,
      height: 52,
      borderRadius: 14,
      alignItems: "center",
      justifyContent: "center",
      marginBottom: 12,
    },
    tileTitle: {
      fontSize: 14,
      fontFamily: "Inter_600SemiBold",
      color: colors.foreground,
      marginBottom: 3,
    },
    tileSub: {
      fontSize: 12,
      fontFamily: "Inter_400Regular",
      color: colors.mutedForeground,
    },
    sectionHeader: {
      flexDirection: "row",
      alignItems: "center",
      gap: 8,
      marginHorizontal: 16,
      marginTop: 8,
      marginBottom: 10,
    },
    sectionTitle: {
      fontSize: 16,
      fontFamily: "Inter_700Bold",
      color: colors.foreground,
    },
    pubCard: {
      marginHorizontal: 16,
      marginBottom: 10,
      backgroundColor: colors.card,
      borderRadius: 14,
      borderWidth: 1.5,
      borderColor: "#1976D2",
      padding: 14,
      flexDirection: "row",
      alignItems: "center",
      gap: 12,
      shadowColor: "#000",
      shadowOffset: { width: 0, height: 1 },
      shadowOpacity: 0.05,
      shadowRadius: 3,
      elevation: 2,
    },
    pubCardIcon: {
      width: 42,
      height: 42,
      borderRadius: 21,
      backgroundColor: "#E3F2FD",
      alignItems: "center",
      justifyContent: "center",
    },
    pubCardName: {
      fontSize: 14,
      fontFamily: "Inter_700Bold",
      color: colors.foreground,
    },
    pubCardSub: {
      fontSize: 12,
      fontFamily: "Inter_400Regular",
      color: colors.mutedForeground,
      marginTop: 2,
    },
    pubEmpty: {
      marginHorizontal: 16,
      marginBottom: 12,
      padding: 14,
      backgroundColor: colors.muted,
      borderRadius: 12,
      alignItems: "center",
    },
    pubEmptyTxt: {
      fontSize: 13,
      fontFamily: "Inter_400Regular",
      color: colors.mutedForeground,
    },
    footer: {
      paddingHorizontal: 20,
      paddingBottom: insets.bottom + 20,
      alignItems: "center",
    },
    footerTxt: {
      fontSize: 12,
      fontFamily: "Inter_400Regular",
      color: colors.mutedForeground,
    },
  });

  return (
    <View style={s.container}>
      <View style={s.header}>
        <Text style={s.appName}>Classes Record</Text>
        <Text style={s.appSub}>Faculty Management System</Text>
      </View>

      <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 20 }}>
        <View style={s.grid}>
          {TILES.map((tile, idx) => {
            const isLast = idx === TILES.length - 1;
            return (
              <TouchableOpacity
                key={tile.route}
                style={[s.tile, { backgroundColor: tile.bg }, isLast && s.tileWide]}
                onPress={() => router.push(tile.route as never)}
                activeOpacity={0.75}
              >
                <View style={[s.iconCircle, { backgroundColor: tile.bg }]}>
                  <Text style={{ fontSize: 26 }}>{tile.emoji}</Text>
                </View>
                <Text style={s.tileTitle}>{tile.title}</Text>
                <Text style={s.tileSub}>{tile.subtitle}</Text>
              </TouchableOpacity>
            );
          })}
        </View>

        {/* ── Public Schedules section ── */}
        <View style={s.sectionHeader}>
          <Text style={{ fontSize: 18 }}>🌐</Text>
          <Text style={s.sectionTitle}>Public Schedules</Text>
        </View>

        {pubLoading ? (
          <ActivityIndicator color="#1976D2" style={{ marginBottom: 16 }} />
        ) : publicSchedules.length === 0 ? (
          <View style={s.pubEmpty}>
            <Text style={s.pubEmptyTxt}>No public schedules yet</Text>
          </View>
        ) : (
          publicSchedules.map((sch) => (
            <TouchableOpacity
              key={sch.id}
              style={s.pubCard}
              activeOpacity={0.75}
              onPress={() =>
                router.push(
                  `/(screens)/schedule-dashboard?scheduleId=${sch.id}&scheduleTitle=${encodeURIComponent(sch.name)}&creatorName=${encodeURIComponent(sch.userId)}&isPublic=1&startDate=${sch.startDate ?? ""}&endDate=${sch.endDate ?? ""}` as never
                )
              }
            >
              <View style={s.pubCardIcon}>
                <Text style={{ fontSize: 20 }}>🌐</Text>
              </View>
              <View style={{ flex: 1 }}>
                <Text style={s.pubCardName}>{sch.name}</Text>
                <Text style={s.pubCardSub}>by {sch.userId}</Text>
              </View>
              <Feather name="chevron-right" size={18} color={colors.mutedForeground} />
            </TouchableOpacity>
          ))
        )}
      </ScrollView>

      <View style={s.footer}>
        <Text style={s.footerTxt}>Tap a tile to open the screen</Text>
      </View>
    </View>
  );
}
