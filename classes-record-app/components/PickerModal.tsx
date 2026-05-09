import React, { useState, useMemo } from "react";
import {
  Modal, View, Text, TextInput, FlatList,
  TouchableOpacity, StyleSheet, Platform,
} from "react-native";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useColors } from "@/hooks/useColors";

interface Props {
  visible: boolean;
  title: string;
  items: string[];
  selected: string;
  onSelect: (val: string) => void;
  onClose: () => void;
  placeholder?: string;
}

export function PickerModal({ visible, title, items, selected, onSelect, onClose, placeholder }: Props) {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const [query, setQuery] = useState("");

  const filtered = useMemo(() => {
    if (!query.trim()) return items;
    const q = query.toLowerCase();
    return items.filter((i) => i.toLowerCase().includes(q));
  }, [items, query]);

  const s = StyleSheet.create({
    overlay: { flex: 1, backgroundColor: "rgba(0,0,0,0.5)", justifyContent: "flex-end" },
    sheet: {
      backgroundColor: colors.card,
      borderTopLeftRadius: 20,
      borderTopRightRadius: 20,
      maxHeight: "85%",
      paddingBottom: insets.bottom,
    },
    header: {
      flexDirection: "row", alignItems: "center", justifyContent: "space-between",
      paddingHorizontal: 20, paddingTop: 20, paddingBottom: 12,
      borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    title: { fontSize: 16, fontFamily: "Inter_700Bold", color: colors.foreground },
    searchBox: {
      flexDirection: "row", alignItems: "center", gap: 10,
      margin: 12, backgroundColor: colors.muted,
      borderRadius: 10, paddingHorizontal: 12, paddingVertical: 10,
      borderWidth: 1, borderColor: colors.border,
    },
    searchInput: {
      flex: 1, fontFamily: "Inter_400Regular", fontSize: 14,
      color: colors.foreground, padding: 0,
    },
    item: {
      paddingHorizontal: 20, paddingVertical: 14,
      borderBottomWidth: 1, borderBottomColor: colors.border,
      flexDirection: "row", alignItems: "center", justifyContent: "space-between",
    },
    itemActive: { backgroundColor: colors.secondary },
    itemText: { fontFamily: "Inter_400Regular", fontSize: 14, color: colors.foreground, flex: 1 },
    itemTextActive: { fontFamily: "Inter_600SemiBold", color: colors.primary },
    count: {
      paddingHorizontal: 20, paddingVertical: 8,
      backgroundColor: colors.muted,
      borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    countText: { fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground },
    empty: { padding: 40, alignItems: "center" },
    emptyText: { fontFamily: "Inter_400Regular", fontSize: 14, color: colors.mutedForeground },
  });

  return (
    <Modal visible={visible} animationType="slide" transparent onRequestClose={onClose}>
      <View style={s.overlay}>
        <View style={s.sheet}>
          <View style={s.header}>
            <Text style={s.title}>{title}</Text>
            <TouchableOpacity onPress={onClose}>
              <Feather name="x" size={22} color={colors.mutedForeground} />
            </TouchableOpacity>
          </View>

          <View style={s.searchBox}>
            <Feather name="search" size={16} color={colors.mutedForeground} />
            <TextInput
              style={s.searchInput}
              placeholder={placeholder || `Search ${title.toLowerCase()}...`}
              placeholderTextColor={colors.mutedForeground}
              value={query}
              onChangeText={setQuery}
              autoFocus
            />
            {query.length > 0 && (
              <TouchableOpacity onPress={() => setQuery("")}>
                <Feather name="x-circle" size={16} color={colors.mutedForeground} />
              </TouchableOpacity>
            )}
          </View>

          <View style={s.count}>
            <Text style={s.countText}>{filtered.length} option{filtered.length !== 1 ? "s" : ""}{query ? ` matching "${query}"` : ""}</Text>
          </View>

          <FlatList
            data={filtered}
            keyExtractor={(item) => item}
            keyboardShouldPersistTaps="handled"
            ListEmptyComponent={<View style={s.empty}><Text style={s.emptyText}>No results</Text></View>}
            renderItem={({ item }) => {
              const isActive = item === selected;
              return (
                <TouchableOpacity
                  style={[s.item, isActive && s.itemActive]}
                  onPress={() => { onSelect(item); setQuery(""); onClose(); }}
                >
                  <Text style={[s.itemText, isActive && s.itemTextActive]}>{item}</Text>
                  {isActive && <Feather name="check" size={16} color={colors.primary} />}
                </TouchableOpacity>
              );
            }}
          />
        </View>
      </View>
    </Modal>
  );
}
