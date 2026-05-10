import React, { useCallback } from "react";
import {
  View, Text, StyleSheet, TouchableOpacity, Linking, Platform, Alert,
} from "react-native";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useFocusEffect } from "expo-router";
import * as ScreenOrientation from "expo-screen-orientation";

import { useColors } from "@/hooks/useColors";

const CONTACT = {
  name: "Alamdar Hussain",
  location: "Islamabad, Pakistan",
  email: "patoprincipalseecs@gmail.com",
  whatsapp: "+92 301 3092112",
  whatsappRaw: "923013092112",
  phone: "+92 301 3092112",
};

async function openLink(url: string) {
  const ok = await Linking.canOpenURL(url);
  if (ok) {
    Linking.openURL(url);
  } else {
    Alert.alert("Cannot open", url);
  }
}

export default function ContactScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();

  useFocusEffect(
    useCallback(() => {
      if (Platform.OS !== "web") {
        ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.PORTRAIT_UP).catch(() => {});
      }
    }, [])
  );

  const s = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    header: {
      backgroundColor: colors.primary,
      paddingTop: insets.top + (Platform.OS === "web" ? 67 : 16),
      paddingBottom: 20,
      paddingHorizontal: 20,
    },
    headerRow: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 10 },
    pill: {
      flexDirection: "row", alignItems: "center", gap: 5,
      backgroundColor: "rgba(255,255,255,0.2)", borderRadius: 20,
      paddingHorizontal: 12, paddingVertical: 6,
    },
    pillTxt: { color: "#fff", fontSize: 13, fontFamily: "Inter_600SemiBold" },
    headerTitle: { color: "#fff", fontSize: 22, fontFamily: "Inter_700Bold" },
    headerSub: { color: "rgba(255,255,255,0.75)", fontSize: 13, fontFamily: "Inter_400Regular", marginTop: 2 },

    body: { flex: 1, padding: 20 },

    avatarWrap: {
      alignItems: "center",
      marginVertical: 28,
    },
    avatar: {
      width: 88, height: 88, borderRadius: 44,
      backgroundColor: "#E3F2FD",
      alignItems: "center", justifyContent: "center",
      marginBottom: 14,
      borderWidth: 3,
      borderColor: colors.primary,
    },
    name: {
      fontSize: 22, fontFamily: "Inter_700Bold",
      color: colors.foreground, textAlign: "center",
    },
    location: {
      fontSize: 14, fontFamily: "Inter_400Regular",
      color: colors.mutedForeground, textAlign: "center",
      marginTop: 4, flexDirection: "row", alignItems: "center",
    },

    card: {
      backgroundColor: colors.card,
      borderRadius: 16,
      borderWidth: 1,
      borderColor: colors.border,
      marginBottom: 12,
      overflow: "hidden",
    },
    row: {
      flexDirection: "row", alignItems: "center",
      paddingHorizontal: 16, paddingVertical: 16, gap: 14,
    },
    rowBorder: {
      borderTopWidth: 1, borderTopColor: colors.border,
    },
    iconBox: {
      width: 42, height: 42, borderRadius: 21,
      alignItems: "center", justifyContent: "center",
    },
    rowLabel: {
      fontSize: 12, fontFamily: "Inter_400Regular",
      color: colors.mutedForeground, marginBottom: 2,
    },
    rowValue: {
      fontSize: 15, fontFamily: "Inter_600SemiBold",
      color: colors.foreground,
    },
    rowChevron: { marginLeft: "auto" },

    note: {
      marginTop: 8,
      padding: 14,
      backgroundColor: colors.muted,
      borderRadius: 12,
      alignItems: "center",
    },
    noteTxt: {
      fontSize: 12, fontFamily: "Inter_400Regular",
      color: colors.mutedForeground, textAlign: "center", lineHeight: 18,
    },
  });

  return (
    <View style={s.container}>
      <View style={s.header}>
        <View style={s.headerRow}>
          <View style={{ flexDirection: "row", gap: 8 }}>
            <TouchableOpacity style={s.pill} onPress={() => router.back()}>
              <Feather name="chevron-left" size={13} color="#fff" />
              <Text style={s.pillTxt}>Back</Text>
            </TouchableOpacity>
            <TouchableOpacity style={s.pill} onPress={() => router.replace("/" as never)}>
              <Feather name="home" size={13} color="#fff" />
              <Text style={s.pillTxt}>Home</Text>
            </TouchableOpacity>
          </View>
        </View>
        <Text style={s.headerTitle}>Contact Us</Text>
        <Text style={s.headerSub}>Get help · Report issues · Feedback</Text>
      </View>

      <View style={s.body}>
        <View style={s.avatarWrap}>
          <View style={s.avatar}>
            <Feather name="user" size={42} color={colors.primary} />
          </View>
          <Text style={s.name}>{CONTACT.name}</Text>
          <View style={{ flexDirection: "row", alignItems: "center", gap: 4, marginTop: 4 }}>
            <Feather name="map-pin" size={13} color={colors.mutedForeground} />
            <Text style={{ fontSize: 14, fontFamily: "Inter_400Regular", color: colors.mutedForeground }}>
              {CONTACT.location}
            </Text>
          </View>
        </View>

        <View style={s.card}>
          <TouchableOpacity
            style={s.row}
            activeOpacity={0.7}
            onPress={() => openLink(`mailto:${CONTACT.email}`)}
          >
            <View style={[s.iconBox, { backgroundColor: "#E3F2FD" }]}>
              <Feather name="mail" size={20} color="#1565C0" />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={s.rowLabel}>Email</Text>
              <Text style={s.rowValue}>{CONTACT.email}</Text>
            </View>
            <Feather name="external-link" size={16} color={colors.mutedForeground} style={s.rowChevron} />
          </TouchableOpacity>

          <TouchableOpacity
            style={[s.row, s.rowBorder]}
            activeOpacity={0.7}
            onPress={() => openLink(`whatsapp://send?phone=${CONTACT.whatsappRaw}`)}
          >
            <View style={[s.iconBox, { backgroundColor: "#E8F5E9" }]}>
              <Feather name="message-circle" size={20} color="#2E7D32" />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={s.rowLabel}>WhatsApp</Text>
              <Text style={s.rowValue}>{CONTACT.whatsapp}</Text>
            </View>
            <Feather name="external-link" size={16} color={colors.mutedForeground} style={s.rowChevron} />
          </TouchableOpacity>

          <TouchableOpacity
            style={[s.row, s.rowBorder]}
            activeOpacity={0.7}
            onPress={() => openLink(`tel:${CONTACT.phone}`)}
          >
            <View style={[s.iconBox, { backgroundColor: "#FFF3E0" }]}>
              <Feather name="phone" size={20} color="#E65100" />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={s.rowLabel}>Phone</Text>
              <Text style={s.rowValue}>{CONTACT.phone}</Text>
            </View>
            <Feather name="external-link" size={16} color={colors.mutedForeground} style={s.rowChevron} />
          </TouchableOpacity>
        </View>

        <View style={s.note}>
          <Text style={s.noteTxt}>
            Tap any row to open the respective app.{"\n"}For fastest response, use WhatsApp.
          </Text>
        </View>
      </View>
    </View>
  );
}
