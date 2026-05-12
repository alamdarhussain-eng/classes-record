import React, { useState, useMemo } from "react";
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, TextInput, ActivityIndicator, Modal, Linking } from "react-native";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useLocalSearchParams } from "expo-router";
import * as DocumentPicker from "expo-document-picker";
import { useColors } from "@/hooks/useColors";
import { fetchSchedule, fetchStudents, addStudent, deleteStudent, importStudentsExcel, Student } from "@/hooks/useApi";
import { PickerModal } from "@/components/PickerModal";

export default function StudentsScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const qc = useQueryClient();
  const { scheduleId: rawId, scheduleTitle } = useLocalSearchParams<{ scheduleId: string; scheduleTitle: string }>();
  const scheduleId = Number(rawId);

  const [selectedKey, setSelectedKey] = useState("");
  const [showClassPicker, setShowClassPicker] = useState(false);
  const [newRoll, setNewRoll] = useState("");
  const [newName, setNewName] = useState("");
  const [newEmail, setNewEmail] = useState("");
  const [addLoading, setAddLoading] = useState(false);
  const [bulkLoading, setBulkLoading] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<Student | null>(null);
  const [error, setError] = useState("");

  const { data: scheduleRows = [] } = useQuery({
    queryKey: ["schedule", scheduleId],
    queryFn: () => (scheduleId ? require("@/hooks/useApi").fetchSchedule(scheduleId) : Promise.resolve([])),
    enabled: !!scheduleId,
  });

  const classSubjectMap = useMemo(() => {
    const map: Record<string, string> = {};
    scheduleRows.filter((r: any) => !r.Type && r.Class && r.Subject && r.Class !== "_ref_" && r.Faculty !== "_locations_").forEach((r: any) => {
      const key = `${r.Class}|||${r.Subject}`;
      map[key] = `${r.Class} · ${r.Subject}`;
    });
    return map;
  }, [scheduleRows]);

  const classSubjectList = Object.keys(classSubjectMap);
  const [selectedClass, selectedSubject] = selectedKey ? selectedKey.split("|||") : ["", ""];

  const { data: students = [], isLoading } = useQuery({
    queryKey: ["students", scheduleId, selectedClass],
    queryFn: () => fetchStudents(scheduleId, selectedClass),
    enabled: !!selectedClass,
  });

  const deleteMut = useMutation({
    mutationFn: (id: number) => deleteStudent(id),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["students", scheduleId, selectedClass] }); setDeleteTarget(null); },
  });

  async function handleAdd() {
    if (!selectedClass || !newRoll.trim() || !newName.trim()) { setError("Select class, enter Reg No and Name"); return; }
    setAddLoading(true); setError("");
    const res = await addStudent(scheduleId, selectedClass, newRoll.trim(), newName.trim(), newEmail.trim());
    setAddLoading(false);
    if (res.success) {
      qc.invalidateQueries({ queryKey: ["students", scheduleId, selectedClass] });
      setNewRoll(""); setNewName(""); setNewEmail("");
    } else { setError(res.error || "Failed to add student"); }
  }

  async function handleBulkUpload() {
    if (!selectedClass) { setError("Select a class first"); return; }
    try {
      const result = await DocumentPicker.getDocumentAsync({ type: ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet","text/csv"], copyToCacheDirectory: true });
      if (result.canceled || !result.assets?.length) return;
      const asset = result.assets[0];
      setBulkLoading(true); setError("");
      const res = await importStudentsExcel(scheduleId, selectedClass, asset.uri, asset.name, asset.mimeType ?? "application/octet-stream");
      setBulkLoading(false);
      if (res.inserted >= 0) { qc.invalidateQueries({ queryKey: ["students", scheduleId, selectedClass] }); }
      else { setError(res.error || "Upload failed"); }
    } catch { setBulkLoading(false); setError("Upload error"); }
  }

  const s = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    header: { backgroundColor: "#1565C0", paddingTop: insets.top + (require("react-native").Platform.OS === "web" ? 67 : 0), paddingBottom: 16, paddingHorizontal: 16 },
    backBtn: { flexDirection: "row", alignItems: "center", gap: 6, marginBottom: 10 },
    backTxt: { color: "#fff", fontSize: 13, fontFamily: "Inter_500Medium" },
    headerTitle: { color: "#fff", fontSize: 22, fontFamily: "Inter_700Bold" },
    headerSub: { color: "rgba(255,255,255,0.8)", fontSize: 13, fontFamily: "Inter_400Regular", marginTop: 2 },
    classPicker: { flexDirection: "row", alignItems: "center", backgroundColor: "rgba(255,255,255,0.15)", borderRadius: 10, paddingHorizontal: 14, paddingVertical: 10, marginTop: 12, gap: 8 },
    classPickerTxt: { color: "#fff", fontSize: 14, fontFamily: "Inter_500Medium", flex: 1 },
    addRow: { flexDirection: "row", gap: 8, padding: 16, backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border },
    addInput: { flex: 1, borderWidth: 1, borderColor: colors.border, borderRadius: 8, paddingHorizontal: 10, paddingVertical: 8, fontSize: 14, fontFamily: "Inter_400Regular", color: colors.foreground, backgroundColor: colors.background },
    addBtn: { backgroundColor: "#1565C0", borderRadius: 8, paddingHorizontal: 14, alignItems: "center", justifyContent: "center" },
    studentRow: { flexDirection: "row", alignItems: "center", paddingHorizontal: 16, paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: colors.border, backgroundColor: colors.card },
    rollBadge: { backgroundColor: "#E3F2FD", borderRadius: 6, paddingHorizontal: 8, paddingVertical: 3, marginRight: 10 },
    rollTxt: { fontSize: 12, fontFamily: "Inter_600SemiBold", color: "#1565C0" },
    nameTxt: { fontSize: 14, fontFamily: "Inter_600SemiBold", color: colors.foreground, flex: 1 },
    emailTxt: { fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground },
    enrollTxt: { fontSize: 11, fontFamily: "Inter_400Regular", color: colors.mutedForeground },
    errorTxt: { color: "#B71C1C", fontSize: 13, fontFamily: "Inter_400Regular", paddingHorizontal: 16, paddingTop: 8 },
  });

  return (
    <View style={s.container}>
      <View style={s.header}>
        <TouchableOpacity style={s.backBtn} onPress={() => router.back()}>
          <Feather name="arrow-left" size={14} color="#fff" />
          <Text style={s.backTxt}>Back</Text>
        </TouchableOpacity>
        <Text style={s.headerTitle}>Students</Text>
        <Text style={s.headerSub}>{scheduleTitle ? decodeURIComponent(scheduleTitle) : ""}</Text>
        <TouchableOpacity style={s.classPicker} onPress={() => setShowClassPicker(true)}>
          <Feather name="book" size={15} color="#fff" />
          <Text style={s.classPickerTxt}>{selectedKey ? classSubjectMap[selectedKey] : "Select Class & Subject…"}</Text>
          <Feather name="chevron-down" size={15} color="#fff" />
        </TouchableOpacity>
      </View>

      {selectedClass ? (
        <>
          <View style={s.addRow}>
            <TextInput style={[s.addInput, { width: 100 }]} placeholder="Reg No" placeholderTextColor={colors.mutedForeground}
              value={newRoll} onChangeText={setNewRoll} autoCapitalize="characters" />
            <TextInput style={[s.addInput, { flex: 1 }]} placeholder="Student Name" placeholderTextColor={colors.mutedForeground}
              value={newName} onChangeText={setNewName} />
            <TextInput style={[s.addInput, { flex: 1 }]} placeholder="Email (optional)" placeholderTextColor={colors.mutedForeground}
              value={newEmail} onChangeText={setNewEmail} autoCapitalize="none" keyboardType="email-address" />
            <TouchableOpacity style={s.addBtn} onPress={handleAdd} disabled={addLoading}>
              {addLoading ? <ActivityIndicator color="#fff" size="small" /> : <Feather name="user-plus" size={18} color="#fff" />}
            </TouchableOpacity>
          </View>
          <View style={{ flexDirection:"row", gap:8, paddingHorizontal:16, paddingTop:10 }}>
            <TouchableOpacity style={{ flex:1, flexDirection:"row", alignItems:"center", justifyContent:"center", gap:6, borderWidth:1, borderColor:colors.primary, borderRadius:8, paddingVertical:9, backgroundColor:colors.background }}
              onPress={handleBulkUpload} disabled={bulkLoading}>
              {bulkLoading ? <ActivityIndicator color={colors.primary} size="small" /> : <><Feather name="upload" size={14} color={colors.primary} /><Text style={{ fontSize:13, fontFamily:"Inter_600SemiBold", color:colors.primary }}>{"  Bulk Upload (Excel)"}</Text></>}
            </TouchableOpacity>
            <TouchableOpacity style={{ flexDirection:"row", alignItems:"center", justifyContent:"center", gap:6, borderWidth:1, borderColor:"#2E7D32", borderRadius:8, paddingVertical:9, paddingHorizontal:14, backgroundColor:colors.background }}
              onPress={() => Linking.openURL(`https://${process.env.EXPO_PUBLIC_DOMAIN}/api/attendance/students/sample`)}>
              <Feather name="download" size={14} color="#2E7D32" />
              <Text style={{ fontSize:13, fontFamily:"Inter_600SemiBold", color:"#2E7D32" }}>Sample</Text>
            </TouchableOpacity>
          </View>
          {error ? <Text style={s.errorTxt}>{error}</Text> : null}
          <Text style={{ paddingHorizontal: 16, paddingTop: 12, paddingBottom: 6, fontSize: 13, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground }}>
            {isLoading ? "Loading…" : `${students.length} student${students.length !== 1 ? "s" : ""} enrolled`}
          </Text>
          <ScrollView>
            {students.map((st: Student) => (
              <View key={st.id} style={s.studentRow}>
                <View style={s.rollBadge}><Text style={s.rollTxt}>{st.rollNo}</Text></View>
                <View style={{ flex: 1 }}>
                  <Text style={s.nameTxt}>{st.name}</Text>
                  {st.email ? <Text style={s.emailTxt}>{st.email}</Text> : null}
                  <Text style={s.enrollTxt}>Enrolled: {st.enrolledAt}</Text>
                </View>
                <TouchableOpacity onPress={() => setDeleteTarget(st)} style={{ padding: 8 }}>
                  <Feather name="trash-2" size={16} color="#B71C1C" />
                </TouchableOpacity>
              </View>
            ))}
          </ScrollView>
        </>
      ) : (
        <View style={{ flex: 1, alignItems: "center", justifyContent: "center", gap: 12 }}>
          <Feather name="users" size={48} color={colors.mutedForeground} />
          <Text style={{ fontSize: 15, fontFamily: "Inter_400Regular", color: colors.mutedForeground }}>Select a class to manage students</Text>
        </View>
      )}

      <PickerModal
        visible={showClassPicker}
        title="Select Class & Subject"
        items={classSubjectList.map(k => classSubjectMap[k])}
        selected={selectedKey ? classSubjectMap[selectedKey] : ""}
        onSelect={(val) => { const k = classSubjectList.find(k => classSubjectMap[k] === val); if (k) setSelectedKey(k); setShowClassPicker(false); }}
        onClose={() => setShowClassPicker(false)}
        placeholder="Search class or subject…"
      />

      <Modal visible={!!deleteTarget} transparent animationType="fade">
        <View style={{ flex: 1, justifyContent: "center", alignItems: "center", backgroundColor: "rgba(0,0,0,0.45)", padding: 32 }}>
          <View style={{ backgroundColor: colors.card, borderRadius: 16, padding: 24, width: "100%", alignItems: "center" }}>
            <Text style={{ fontSize: 17, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 8 }}>Remove Student</Text>
            <Text style={{ fontSize: 14, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginBottom: 20, textAlign: "center" }}>
              Remove {deleteTarget?.name} ({deleteTarget?.rollNo})? Their attendance records will also be deleted.
            </Text>
            <View style={{ flexDirection: "row", gap: 10, width: "100%" }}>
              <TouchableOpacity onPress={() => setDeleteTarget(null)} style={{ flex: 1, padding: 13, borderRadius: 10, borderWidth: 1, borderColor: colors.border, alignItems: "center" }}>
                <Text style={{ fontFamily: "Inter_600SemiBold", color: colors.mutedForeground }}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity onPress={() => deleteTarget && deleteMut.mutate(deleteTarget.id)} style={{ flex: 1, padding: 13, borderRadius: 10, backgroundColor: "#B71C1C", alignItems: "center" }}>
                <Text style={{ fontFamily: "Inter_700Bold", color: "#fff" }}>Remove</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
}
