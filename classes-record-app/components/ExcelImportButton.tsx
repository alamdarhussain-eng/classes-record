import React, { useState } from "react";
import {
  TouchableOpacity, Text, StyleSheet, ActivityIndicator,
  Alert, View, Modal, Linking,
} from "react-native";
import * as DocumentPicker from "expo-document-picker";
import { Feather } from "@expo/vector-icons";
import { useColors } from "@/hooks/useColors";

interface Props {
  label: string;
  description: string;
  onImport: (uri: string, name: string, mimeType: string, file?: File) => Promise<{ success: boolean; inserted?: number; faculty?: number; subjects?: number; classes?: number; locations?: number; error?: string }>;
  onSuccess?: () => void;
  variant?: "primary" | "outline" | "ghost";
  icon?: keyof typeof Feather.glyphMap;
  sampleUrl?: string;
  sampleFileName?: string;
}

export function ExcelImportButton({ label, description, onImport, onSuccess, variant = "outline", icon = "upload", sampleUrl, sampleFileName = "Sample.xlsx" }: Props) {
  const colors = useColors();
  const [loading, setLoading] = useState(false);

  async function handlePick() {
    try {
      const result = await DocumentPicker.getDocumentAsync({
        type: [
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
          "application/vnd.ms-excel",
          "*/*",
        ],
        copyToCacheDirectory: true,
      });

      if (result.canceled || !result.assets?.length) return;

      const asset = result.assets[0];
      setLoading(true);

      const file = (asset as any).file as File | undefined;
      const importResult = await onImport(
        asset.uri,
        asset.name,
        asset.mimeType ?? "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        file
      );

      setLoading(false);

      if (importResult.success) {
        const details = [
          importResult.inserted != null && `${importResult.inserted} rows imported`,
          importResult.faculty != null && `${importResult.faculty} faculty`,
          importResult.subjects != null && `${importResult.subjects} subjects`,
          importResult.classes != null && `${importResult.classes} classes`,
          importResult.locations != null && `${importResult.locations} locations`,
        ].filter(Boolean).join(" · ");

        Alert.alert("Import Successful ✓", details || "Data imported successfully");
        onSuccess?.();
      } else {
        Alert.alert("Import Failed", importResult.error ?? "Unknown error");
      }
    } catch (err) {
      setLoading(false);
      Alert.alert("Error", "Could not pick or upload file");
    }
  }

  async function handleDownloadSample() {
    if (!sampleUrl) return;
    try {
      await Linking.openURL(sampleUrl);
    } catch {
      Alert.alert("Error", "Could not open download link.");
    }
  }

  const s = StyleSheet.create({
    btn: {
      flexDirection: "row", alignItems: "center", gap: 8,
      paddingHorizontal: 14, paddingVertical: 10, borderRadius: 10,
      borderWidth: variant === "outline" ? 1 : 0,
      borderColor: colors.primary,
      backgroundColor: variant === "primary" ? colors.primary : variant === "ghost" ? "transparent" : colors.secondary,
    },
    label: {
      fontFamily: "Inter_600SemiBold", fontSize: 14,
      color: variant === "primary" ? "#fff" : colors.primary,
      flex: 1,
    },
    sampleRow: {
      flexDirection: "row", alignItems: "center", gap: 5,
      marginTop: 6, paddingLeft: 2,
    },
    sampleTxt: {
      fontFamily: "Inter_400Regular", fontSize: 12,
      color: colors.mutedForeground, textDecorationLine: "underline",
    },
  });

  return (
    <View>
      <TouchableOpacity style={s.btn} onPress={handlePick} disabled={loading}>
        {loading
          ? <ActivityIndicator size="small" color={variant === "primary" ? "#fff" : colors.primary} />
          : <Feather name={icon} size={16} color={variant === "primary" ? "#fff" : colors.primary} />
        }
        <Text style={s.label}>{loading ? "Importing…" : label}</Text>
      </TouchableOpacity>

      {sampleUrl && (
        <TouchableOpacity style={s.sampleRow} onPress={handleDownloadSample}>
          <Feather name="download" size={12} color={colors.mutedForeground} />
          <Text style={s.sampleTxt}>Download sample file ({sampleFileName})</Text>
        </TouchableOpacity>
      )}
    </View>
  );
}

// A panel that groups multiple import actions
interface PanelProps {
  visible: boolean;
  onClose: () => void;
  children: React.ReactNode;
  title: string;
}

export function ImportPanel({ visible, onClose, children, title }: PanelProps) {
  const colors = useColors();
  const s = StyleSheet.create({
    overlay: { flex: 1, backgroundColor: "rgba(0,0,0,0.5)", justifyContent: "flex-end" },
    sheet: {
      backgroundColor: colors.card, borderTopLeftRadius: 20, borderTopRightRadius: 20,
      padding: 20, paddingBottom: 36,
    },
    headerRow: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 6 },
    title: { fontSize: 18, fontFamily: "Inter_700Bold", color: colors.foreground },
    sub: { fontSize: 13, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginBottom: 20 },
    divider: { height: 1, backgroundColor: colors.border, marginVertical: 12 },
  });

  return (
    <Modal visible={visible} animationType="slide" transparent onRequestClose={onClose}>
      <View style={s.overlay}>
        <View style={s.sheet}>
          <View style={s.headerRow}>
            <Text style={s.title}>{title}</Text>
            <TouchableOpacity onPress={onClose}>
              <Feather name="x" size={22} color={colors.mutedForeground} />
            </TouchableOpacity>
          </View>
          <Text style={s.sub}>Select an Excel (.xlsx) file from your device</Text>
          {children}
        </View>
      </View>
    </Modal>
  );
}
