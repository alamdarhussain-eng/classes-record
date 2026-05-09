import React, { useCallback } from "react";
import {
  View, Text, StyleSheet, TouchableOpacity, ScrollView, Platform,
} from "react-native";
import { useRouter, useLocalSearchParams, useFocusEffect } from "expo-router";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import * as ScreenOrientation from "expo-screen-orientation";

import { useColors } from "@/hooks/useColors";

export default function ScheduleDashboardScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { scheduleId, scheduleTitle, creatorName, isPublic, startDate, endDate } =
    useLocalSearchParams<{ scheduleId: string; scheduleTitle: string; creatorName?: string; isPublic?: string; startDate?: string; endDate?: string }>();

  const publicMode = isPublic === "1";

  useFocusEffect(
    useCallback(() => {
      if (Platform.OS !== "web") {
        ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.PORTRAIT_UP).catch(() => {});
      }
    }, [])
  );

  const dateParams = startDate ? `&startDate=${startDate}&endDate=${endDate ?? ""}` : "";
  const q = `scheduleId=${scheduleId}&scheduleTitle=${encodeURIComponent(scheduleTitle ?? "")}${publicMode ? "&isPublic=1" : ""}${dateParams}`;

  const ALL_TILES = [
    {
      route: `/(screens)/schedule?${q}`,
      icon: "calendar" as const,
      title: "Weekly Schedule",
      subtitle: "Mon–Fri timetable",
      color: "#1565C0",
      bg: "#E3F2FD",
      publicAllowed: true,
    },
    {
      route: `/(screens)/entry?${q}`,
      icon: "edit-3" as const,
      title: "New Entry",
      subtitle: "Missed · Late · Makeup",
      color: "#E65100",
      bg: "#FFF3E0",
      publicAllowed: false,
    },
    {
      route: `/(screens)/summary?${q}`,
      icon: "bar-chart-2" as const,
      title: "Teaching Summary",
      subtitle: "TBC · Deficit · Surplus",
      color: "#2E7D32",
      bg: "#E8F5E9",
      publicAllowed: true,
    },
    {
      route: `/(screens)/meeting?${q}`,
      icon: "users" as const,
      title: "Meeting Availability",
      subtitle: "Check who is free",
      color: "#6A1B9A",
      bg: "#F3E5F5",
      publicAllowed: true,
    },
    {
      route: `/(screens)/holidays?${q}`,
      icon: "sun" as const,
      title: "Gazzetted Holidays",
      subtitle: "Excluded from TBC count",
      color: "#00695C",
      bg: "#E0F2F1",
      publicAllowed: true,
    },
    {
      route: `/(screens)/attendance?${q}`,
      icon: "check-square" as const,
      title: "Attendance",
      subtitle: "Mark · Roster · Students",
      color: "#1565C0",
      bg: "#E3F2FD",
      publicAllowed: true,
    },
    {
      route: `/(screens)/exam?${q}`,
      icon: "award" as const,
      title: "Exam Marks",
      subtitle: "Quiz · Mid · Final",
      color: "#6A1B9A",
      bg: "#F3E5F5",
      publicAllowed: true,
    },
    {
      route: `/(screens)/faculty-credentials?scheduleId=${scheduleId}&scheduleTitle=${encodeURIComponent(scheduleTitle ?? "")}`,
      icon: "user-check" as const,
      title: "Faculty Access",
      subtitle: "Credentials · Share · Download",
      color: "#00695C",
      bg: "#E0F2F1",
      publicAllowed: false,
    },
  ];

  const TILES = publicMode ? ALL_TILES.filter((t) => t.publicAllowed) : ALL_TILES;

  const s = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    header: {
      backgroundColor: colors.primary,
      paddingTop: insets.top + (Platform.OS === "web" ? 67 : 16),
      paddingBottom: 20,
      paddingHorizontal: 20,
    },
    headerRow: {
      flexDirection: "row",
      justifyContent: "space-between",
      alignItems: "center",
      marginBottom: 10,
    },
    homeBtn: {
      flexDirection: "row", alignItems: "center", gap: 5,
      backgroundColor: "rgba(255,255,255,0.2)", borderRadius: 20,
      paddingHorizontal: 12, paddingVertical: 6,
    },
    homeBtnTxt: { color: "#fff", fontSize: 13, fontFamily: "Inter_600SemiBold" },
    backBtn: {
      flexDirection: "row", alignItems: "center", gap: 5,
      backgroundColor: "rgba(255,255,255,0.2)", borderRadius: 20,
      paddingHorizontal: 12, paddingVertical: 6,
    },
    backBtnTxt: { color: "#fff", fontSize: 13, fontFamily: "Inter_600SemiBold" },
    headerTitle: { color: "#fff", fontSize: 22, fontFamily: "Inter_700Bold" },
    headerSub: { color: "rgba(255,255,255,0.75)", fontSize: 13, fontFamily: "Inter_400Regular", marginTop: 2 },
    publicBanner: {
      flexDirection: "row", alignItems: "center", gap: 6,
      backgroundColor: "rgba(255,255,255,0.15)", borderRadius: 8,
      paddingHorizontal: 10, paddingVertical: 5, marginTop: 8, alignSelf: "flex-start",
    },
    publicBannerTxt: { color: "#fff", fontSize: 12, fontFamily: "Inter_400Regular" },
    scroll: { flex: 1 },
    grid: { padding: 16, flexDirection: "row", flexWrap: "wrap", gap: 14 },
    tile: {
      width: "47%",
      borderRadius: 16,
      padding: 20,
      borderWidth: 1,
      borderColor: colors.border,
      alignItems: "flex-start",
      shadowColor: "#000",
      shadowOffset: { width: 0, height: 1 },
      shadowOpacity: 0.06,
      shadowRadius: 4,
      elevation: 2,
    },
    tileWide: { width: "100%" },
    iconCircle: {
      width: 52, height: 52, borderRadius: 26,
      alignItems: "center", justifyContent: "center", marginBottom: 14,
    },
    tileTitle: { fontSize: 15, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 4 },
    tileSub: { fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground },
    footer: { paddingHorizontal: 20, paddingBottom: insets.bottom + 20, alignItems: "center" },
    footerTxt: { fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground },
  });

  return (
    <View style={s.container}>
      <View style={s.header}>
        <View style={s.headerRow}>
          <TouchableOpacity style={s.backBtn} onPress={() => router.back()}>
            <Feather name="chevron-left" size={14} color="#fff" />
            <Text style={s.backBtnTxt}>{publicMode ? "Home" : "My Schedules"}</Text>
          </TouchableOpacity>
          <TouchableOpacity style={s.homeBtn} onPress={() => router.replace("/")}>
            <Feather name="home" size={13} color="#fff" />
            <Text style={s.homeBtnTxt}>Home</Text>
          </TouchableOpacity>
        </View>
        <Text style={s.headerTitle}>{scheduleTitle ?? "Schedule"}</Text>
        {publicMode ? (
          <View style={s.publicBanner}>
            <Feather name="globe" size={13} color="#fff" />
            <Text style={s.publicBannerTxt}>Public schedule by {creatorName}</Text>
          </View>
        ) : (
          <Text style={s.headerSub}>Private schedule dashboard</Text>
        )}
      </View>

      <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 20 }}>
        <View style={s.grid}>
          {TILES.map((tile, idx) => {
            const isLast = idx === TILES.length - 1;
            return (
              <TouchableOpacity
                key={tile.route}
                style={[s.tile, { backgroundColor: tile.bg }, isLast && TILES.length % 2 !== 0 && s.tileWide]}
                onPress={() => router.push(tile.route as never)}
                activeOpacity={0.75}
              >
                <View style={[s.iconCircle, { backgroundColor: tile.color + "22" }]}>
                  <Feather name={tile.icon} size={26} color={tile.color} />
                </View>
                <Text style={s.tileTitle}>{tile.title}</Text>
                <Text style={s.tileSub}>{tile.subtitle}</Text>
              </TouchableOpacity>
            );
          })}
        </View>
      </ScrollView>

      <View style={s.footer}>
        <Text style={s.footerTxt}>
          {publicMode ? `Public schedule by ${creatorName}` : `Viewing private schedule: ${scheduleTitle}`}
        </Text>
      </View>
    </View>
  );
}
