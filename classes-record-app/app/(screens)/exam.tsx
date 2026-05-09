import React, { useState, useMemo } from "react";
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  TextInput, ActivityIndicator, Modal, Alert, Linking, Platform,
} from "react-native";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useLocalSearchParams } from "expo-router";
import * as DocumentPicker from "expo-document-picker";

import { useColors } from "@/hooks/useColors";
import { useAuth } from "@/context/AuthContext";
import {
  fetchSchedule, fetchStudents,
  fetchExamWeights, saveExamWeights, fetchExamMarks, saveExamMark,
  importExamMarksExcel, fetchStudentExamResult,
  ExamWeights, ExamMarkRow,
} from "@/hooks/useApi";
import { PickerModal } from "@/components/PickerModal";

type Tab = "weights" | "marks" | "students";

const COMPONENTS: Array<{ key: keyof ExamWeights; label: string; color: string }> = [
  { key: "quiz",       label: "Quiz",       color: "#1565C0" },
  { key: "assignment", label: "Assignment",  color: "#2E7D32" },
  { key: "mid",        label: "Mid Exam",    color: "#E65100" },
  { key: "final",      label: "Final Exam",  color: "#6A1B9A" },
];

function num(v: string | null | undefined): number | null {
  if (v == null || v === "") return null;
  const n = parseFloat(v);
  return isNaN(n) ? null : n;
}

function calcTotal(row: ExamMarkRow, w: ExamWeights): number | null {
  const q = num(row.quiz), a = num(row.assignment), m = num(row.mid), f = num(row.final);
  if (q == null || a == null || m == null || f == null) return null;
  return Math.round((q / 100) * w.quiz + (a / 100) * w.assignment + (m / 100) * w.mid + (f / 100) * w.final);
}

export default function ExamScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const qc = useQueryClient();
  const { user } = useAuth();

  const { scheduleId: rawId, scheduleTitle, isPublic, facultyName } =
    useLocalSearchParams<{ scheduleId: string; scheduleTitle: string; isPublic?: string; facultyName?: string }>();
  const scheduleId = Number(rawId);
  const publicMode = isPublic === "1";
  const isLoggedIn = !!user;
  const teacherMode = !publicMode && isLoggedIn;
  // Even on a public schedule, a logged-in faculty can adjust weights
  const canEditWeights = isLoggedIn;
  const facultyMode = !!facultyName;
  const effectiveTeacherMode = teacherMode || facultyMode;

  const [activeTab, setActiveTab] = useState<Tab>(effectiveTeacherMode ? "weights" : "marks");
  const [selectedClass, setSelectedClass] = useState("");
  const [selectedSubject, setSelectedSubject] = useState("");
  const [showClassPicker, setShowClassPicker] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");

  // Weights edit state
  const [editWeights, setEditWeights] = useState<ExamWeights | null>(null);
  const [weightsSaving, setWeightsSaving] = useState(false);

  // Marks inline edit
  const [editingRow, setEditingRow] = useState<string | null>(null);
  const [editVals, setEditVals] = useState<{ quiz: string; assignment: string; mid: string; final: string }>({ quiz: "", assignment: "", mid: "", final: "" });
  const [savingMark, setSavingMark] = useState(false);
  const [bulkLoading, setBulkLoading] = useState(false);

  // Public lookup
  const [lookupReg, setLookupReg] = useState("");
  const [lookupResult, setLookupResult] = useState<Awaited<ReturnType<typeof fetchStudentExamResult>> | null>(null);
  const [lookupLoading, setLookupLoading] = useState(false);

  const { data: scheduleRows = [] } = useQuery({
    queryKey: ["schedule", scheduleId],
    queryFn: () => fetchSchedule(scheduleId),
    enabled: !!scheduleId,
  });

  const classSubjectList = useMemo(() => {
    const seen = new Set<string>();
    const out: string[] = [];
    for (const r of scheduleRows) {
      if (!r.Type && r.Class && r.Subject) {
        if (facultyMode && r.Faculty !== facultyName) continue;
        const key = `${r.Class}|||${r.Subject}`;
        if (!seen.has(key)) { seen.add(key); out.push(key); }
      }
    }
    return out.sort((a, b) => {
      const [ac, as_] = a.split("|||"), [bc, bs] = b.split("|||");
      return ac !== bc ? ac.localeCompare(bc) : as_.localeCompare(bs);
    });
  }, [scheduleRows, facultyMode, facultyName]);

  const classSubjectDisplay = useMemo(() => {
    const map: Record<string, string> = {};
    for (const key of classSubjectList) {
      const [cls, subj] = key.split("|||");
      map[key] = `${cls} · ${subj}`;
    }
    return map;
  }, [classSubjectList]);

  const { data: weights, isLoading: weightsLoading } = useQuery({
    queryKey: ["examWeights", scheduleId],
    queryFn: () => fetchExamWeights(scheduleId),
    enabled: !!scheduleId,
  });

  const { data: marks = [], isLoading: marksLoading } = useQuery({
    queryKey: ["examMarks", scheduleId, selectedClass],
    queryFn: () => fetchExamMarks(scheduleId, selectedClass),
    enabled: !!selectedClass,
  });

  const { data: students = [] } = useQuery({
    queryKey: ["students", scheduleId, selectedClass],
    queryFn: () => fetchStudents(scheduleId, selectedClass),
    enabled: !!selectedClass,
  });

  const w: ExamWeights = weights ?? { quiz: 10, assignment: 10, mid: 20, final: 60 };
  const wEdit = editWeights ?? w;
  const wSum = wEdit.quiz + wEdit.assignment + wEdit.mid + wEdit.final;

  async function handleSaveWeights() {
    if (wSum !== 100) { setErrorMsg("Weights must sum to exactly 100%"); return; }
    setWeightsSaving(true);
    const res = await saveExamWeights(scheduleId, wEdit);
    setWeightsSaving(false);
    if (res.success) {
      qc.invalidateQueries({ queryKey: ["examWeights", scheduleId] });
      setEditWeights(null);
      Alert.alert("Saved", "Exam weights updated.");
    } else {
      setErrorMsg(res.error ?? "Could not save weights");
    }
  }

  function startEdit(row: ExamMarkRow) {
    setEditingRow(row.rollNo);
    setEditVals({
      quiz: row.quiz ?? "",
      assignment: row.assignment ?? "",
      mid: row.mid ?? "",
      final: row.final ?? "",
    });
  }

  async function handleSaveMark(row: ExamMarkRow) {
    setSavingMark(true);
    const toNum = (s: string) => s.trim() === "" ? null : parseFloat(s);
    await saveExamMark(
      scheduleId, selectedClass, row.rollNo,
      toNum(editVals.quiz), toNum(editVals.assignment), toNum(editVals.mid), toNum(editVals.final)
    );
    setSavingMark(false);
    setEditingRow(null);
    qc.invalidateQueries({ queryKey: ["examMarks", scheduleId, selectedClass] });
  }

  async function handleBulkUpload() {
    try {
      const result = await DocumentPicker.getDocumentAsync({
        type: ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.ms-excel", "*/*"],
        copyToCacheDirectory: true,
      });
      if (result.canceled || !result.assets?.length) return;
      const asset = result.assets[0];
      setBulkLoading(true);
      const res = await importExamMarksExcel(scheduleId, selectedClass, asset.uri, asset.name, asset.mimeType ?? "application/octet-stream");
      setBulkLoading(false);
      if (res.success) {
        Alert.alert("Import Complete", `${res.updated ?? 0} students updated, ${res.skipped ?? 0} skipped.`);
        qc.invalidateQueries({ queryKey: ["examMarks", scheduleId, selectedClass] });
      } else {
        setErrorMsg(res.error ?? "Import failed");
      }
    } catch {
      setBulkLoading(false);
      setErrorMsg("Could not pick file");
    }
  }

  async function handleLookup() {
    if (!lookupReg.trim()) return;
    setLookupLoading(true);
    setLookupResult(null);
    const result = await fetchStudentExamResult(scheduleId, lookupReg.trim());
    setLookupLoading(false);
    setLookupResult(result);
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
    classPickerRow: {
      flexDirection: "row", alignItems: "center", gap: 8,
      backgroundColor: colors.card, padding: 10,
      borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    classBtn: {
      flex: 1, flexDirection: "row", alignItems: "center", gap: 8,
      backgroundColor: colors.muted, borderRadius: 10, paddingHorizontal: 12, paddingVertical: 10,
      borderWidth: 1, borderColor: colors.border,
    },
    classBtnTxt: { flex: 1, fontFamily: "Inter_500Medium", fontSize: 14, color: colors.foreground },
    tabRow: {
      flexDirection: "row", backgroundColor: colors.card,
      borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    tab: { flex: 1, paddingVertical: 11, alignItems: "center" },
    tabActive: { borderBottomWidth: 2, borderBottomColor: colors.primary },
    tabTxt: { fontFamily: "Inter_500Medium", fontSize: 13, color: colors.mutedForeground },
    tabTxtActive: { color: colors.primary, fontFamily: "Inter_700Bold" },
    noClass: { alignItems: "center", marginTop: 80, paddingHorizontal: 32 },
    noClassTxt: { fontSize: 15, fontFamily: "Inter_400Regular", color: colors.mutedForeground, textAlign: "center", marginTop: 12 },
    section: { padding: 16 },
    sectionTitle: { fontSize: 13, fontFamily: "Inter_700Bold", color: colors.mutedForeground, marginBottom: 12, textTransform: "uppercase", letterSpacing: 0.5 },
    weightCard: {
      backgroundColor: colors.card, borderRadius: 14, borderWidth: 1, borderColor: colors.border,
      padding: 16, marginBottom: 12,
    },
    weightRow: { flexDirection: "row", alignItems: "center", marginBottom: 12, gap: 10 },
    weightLabel: { width: 90, fontFamily: "Inter_600SemiBold", fontSize: 14, color: colors.foreground },
    weightInput: {
      flex: 1, backgroundColor: colors.muted, borderRadius: 8,
      borderWidth: 1, borderColor: colors.border,
      paddingHorizontal: 12, paddingVertical: 8,
      fontFamily: "Inter_400Regular", fontSize: 15, color: colors.foreground,
      textAlign: "center",
    },
    weightPct: { width: 36, fontFamily: "Inter_400Regular", fontSize: 14, color: colors.mutedForeground },
    weightSum: { fontFamily: "Inter_700Bold", fontSize: 15, color: colors.foreground, textAlign: "right", marginTop: 4 },
    saveBtn: {
      backgroundColor: colors.primary, borderRadius: 10,
      paddingVertical: 12, alignItems: "center", marginTop: 12,
    },
    saveBtnTxt: { color: "#fff", fontFamily: "Inter_700Bold", fontSize: 15 },
    // Marks table
    tableHead: {
      flexDirection: "row", backgroundColor: "#1976D2",
      paddingHorizontal: 8, paddingVertical: 8,
    },
    thNum: { width: 28, fontFamily: "Inter_700Bold", fontSize: 10, color: "#fff" },
    thRoll: { width: 100, fontFamily: "Inter_700Bold", fontSize: 10, color: "#fff" },
    thName: { flex: 1, fontFamily: "Inter_700Bold", fontSize: 10, color: "#fff" },
    thCell: { width: 42, fontFamily: "Inter_700Bold", fontSize: 10, color: "#fff", textAlign: "center" },
    thTotal: { width: 40, fontFamily: "Inter_700Bold", fontSize: 10, color: "#fff", textAlign: "center" },
    tableRow: {
      flexDirection: "row", alignItems: "center",
      paddingHorizontal: 8, paddingVertical: 7,
      borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    tdNum: { width: 28, fontFamily: "Inter_400Regular", fontSize: 11, color: colors.mutedForeground },
    tdRoll: { width: 100, fontFamily: "Inter_500Medium", fontSize: 11, color: colors.foreground },
    tdName: { flex: 1, fontFamily: "Inter_400Regular", fontSize: 11, color: colors.foreground },
    tdCell: { width: 42, textAlign: "center", fontFamily: "Inter_500Medium", fontSize: 12, color: colors.foreground },
    tdTotal: { width: 40, textAlign: "center", fontFamily: "Inter_700Bold", fontSize: 12, color: "#1565C0" },
    markInput: {
      width: 42, borderRadius: 6, borderWidth: 1, borderColor: colors.primary,
      backgroundColor: "#E3F2FD", paddingHorizontal: 3, paddingVertical: 3,
      fontFamily: "Inter_400Regular", fontSize: 12, color: colors.foreground, textAlign: "center",
    },
    editBtn: { marginLeft: 4, padding: 4 },
    saveMarkBtn: {
      marginLeft: 4, backgroundColor: colors.primary, borderRadius: 6,
      paddingHorizontal: 8, paddingVertical: 4,
    },
    saveMarkBtnTxt: { color: "#fff", fontFamily: "Inter_700Bold", fontSize: 11 },
    bulkRow: {
      flexDirection: "row", gap: 8, padding: 10,
      backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border,
      alignItems: "center",
    },
    bulkBtn: {
      flex: 1, flexDirection: "row", alignItems: "center", gap: 6,
      backgroundColor: colors.muted, borderRadius: 8, paddingHorizontal: 12, paddingVertical: 9,
      borderWidth: 1, borderColor: colors.border,
    },
    bulkBtnTxt: { fontFamily: "Inter_500Medium", fontSize: 13, color: colors.foreground },
    sampleBtn: {
      flexDirection: "row", alignItems: "center", gap: 5,
      borderRadius: 8, paddingHorizontal: 10, paddingVertical: 9,
      borderWidth: 1, borderColor: colors.primary,
    },
    sampleBtnTxt: { fontFamily: "Inter_500Medium", fontSize: 12, color: colors.primary },
    lookupRow: {
      flexDirection: "row", gap: 8, padding: 12,
      backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    lookupInput: {
      flex: 1, backgroundColor: colors.muted, borderRadius: 8,
      borderWidth: 1, borderColor: colors.border,
      paddingHorizontal: 12, paddingVertical: 9,
      fontFamily: "Inter_400Regular", fontSize: 14, color: colors.foreground,
    },
    lookupBtn: {
      backgroundColor: colors.primary, borderRadius: 8,
      paddingHorizontal: 16, justifyContent: "center", alignItems: "center",
    },
    lookupBtnTxt: { color: "#fff", fontFamily: "Inter_700Bold", fontSize: 14 },
    resultCard: {
      margin: 14, backgroundColor: colors.card,
      borderRadius: 14, borderWidth: 1, borderColor: colors.border, overflow: "hidden",
    },
    resultHeader: {
      backgroundColor: "#1565C0", padding: 14,
    },
    resultName: { color: "#fff", fontSize: 17, fontFamily: "Inter_700Bold" },
    resultReg: { color: "rgba(255,255,255,0.8)", fontSize: 13, fontFamily: "Inter_400Regular", marginTop: 2 },
    resultRow: {
      flexDirection: "row", alignItems: "center",
      paddingHorizontal: 14, paddingVertical: 10,
      borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    resultClass: { flex: 1, fontFamily: "Inter_600SemiBold", fontSize: 13, color: colors.foreground },
    resultMarkCell: { width: 44, textAlign: "center", fontFamily: "Inter_500Medium", fontSize: 12, color: colors.foreground },
    resultTotal: { width: 44, textAlign: "center", fontFamily: "Inter_700Bold", fontSize: 14, color: "#1565C0" },
    weightsBanner: {
      flexDirection: "row", gap: 8, flexWrap: "wrap",
      padding: 10, backgroundColor: colors.muted, borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    weightPill: {
      borderRadius: 10, paddingHorizontal: 8, paddingVertical: 3,
      backgroundColor: colors.card, borderWidth: 1, borderColor: colors.border,
    },
    weightPillTxt: { fontSize: 11, fontFamily: "Inter_500Medium", color: colors.foreground },
  });

  const renderWeightsTab = () => (
    <ScrollView contentContainerStyle={{ padding: 16, paddingBottom: 40 }}>
      <Text style={s.sectionTitle}>Exam Component Weights</Text>
      <View style={s.weightCard}>
        {COMPONENTS.map(comp => (
          <View key={comp.key} style={s.weightRow}>
            <View style={{ width: 12, height: 12, borderRadius: 6, backgroundColor: comp.color, marginRight: 4 }} />
            <Text style={s.weightLabel}>{comp.label}</Text>
            <TextInput
              style={[s.weightInput, { borderColor: canEditWeights ? comp.color : colors.border }]}
              value={String(wEdit[comp.key])}
              onChangeText={(t) => {
                if (!canEditWeights) return;
                const n = parseInt(t) || 0;
                setEditWeights({ ...wEdit, [comp.key]: n });
              }}
              keyboardType="number-pad"
              maxLength={3}
              editable={canEditWeights}
            />
            <Text style={s.weightPct}>%</Text>
          </View>
        ))}
        <View style={{ flexDirection: "row", justifyContent: "space-between", alignItems: "center", paddingTop: 8, borderTopWidth: 1, borderTopColor: colors.border }}>
          <Text style={{ fontFamily: "Inter_400Regular", fontSize: 13, color: colors.mutedForeground }}>Total</Text>
          <Text style={[s.weightSum, { color: wSum === 100 ? "#2E7D32" : "#C62828" }]}>{wSum}%</Text>
        </View>
        {canEditWeights && (
          <TouchableOpacity
            style={[s.saveBtn, { backgroundColor: wSum !== 100 ? colors.mutedForeground : colors.primary }]}
            onPress={handleSaveWeights}
            disabled={weightsSaving || wSum !== 100}
          >
            {weightsSaving
              ? <ActivityIndicator color="#fff" size="small" />
              : <Text style={s.saveBtnTxt}>Save Weights</Text>
            }
          </TouchableOpacity>
        )}
      </View>
      {!canEditWeights && (
        <Text style={{ fontSize: 13, fontFamily: "Inter_400Regular", color: colors.mutedForeground, textAlign: "center", marginTop: 12 }}>
          Weights are set by the faculty and are read-only.
        </Text>
      )}
    </ScrollView>
  );

  const renderMarksTab = () => {
    if (!selectedClass) {
      return (
        <View style={s.noClass}>
          <Feather name="award" size={44} color={colors.mutedForeground} />
          <Text style={s.noClassTxt}>Select a class above to view or enter marks.</Text>
        </View>
      );
    }
    if (marksLoading) return <ActivityIndicator color={colors.primary} style={{ marginTop: 40 }} size="large" />;
    if (marks.length === 0) {
      return (
        <View style={s.noClass}>
          <Feather name="users" size={44} color={colors.mutedForeground} />
          <Text style={s.noClassTxt}>No students enrolled in this class. Add them via the Attendance → Students tab first.</Text>
        </View>
      );
    }
    return (
      <View style={{ flex: 1 }}>
        {effectiveTeacherMode && (
          <View style={s.bulkRow}>
            <TouchableOpacity style={s.bulkBtn} onPress={handleBulkUpload} disabled={bulkLoading}>
              {bulkLoading
                ? <ActivityIndicator color={colors.primary} size="small" />
                : <><Feather name="upload" size={15} color={colors.primary} /><Text style={s.bulkBtnTxt}>  Bulk Upload Marks (Excel)</Text></>
              }
            </TouchableOpacity>
            <TouchableOpacity
              style={s.sampleBtn}
              onPress={() => Linking.openURL(`https://${process.env.EXPO_PUBLIC_DOMAIN}/api/exam/marks/sample`)}
            >
              <Feather name="download" size={13} color={colors.primary} />
              <Text style={s.sampleBtnTxt}>Template</Text>
            </TouchableOpacity>
          </View>
        )}
        {/* Weights banner */}
        <View style={s.weightsBanner}>
          {COMPONENTS.map(c => (
            <View key={c.key} style={[s.weightPill, { borderColor: c.color }]}>
              <Text style={[s.weightPillTxt, { color: c.color }]}>{c.label}: {w[c.key]}%</Text>
            </View>
          ))}
        </View>
        <ScrollView contentContainerStyle={{ paddingBottom: 20 }}>
          {/* Table header */}
          <View style={s.tableHead}>
            <Text style={s.thNum}>#</Text>
            <Text style={s.thRoll}>Reg No</Text>
            <Text style={s.thName}>Name</Text>
            <Text style={s.thCell}>Quiz</Text>
            <Text style={s.thCell}>Assg</Text>
            <Text style={s.thCell}>Mid</Text>
            <Text style={s.thCell}>Final</Text>
            <Text style={s.thTotal}>Total</Text>
            {effectiveTeacherMode && <Text style={{ width: 52 }} />}
          </View>
          {marks.map((row, i) => {
            const isEditing = editingRow === row.rollNo;
            const total = calcTotal(row, w);
            return (
              <View key={row.rollNo} style={[s.tableRow, { backgroundColor: i % 2 === 0 ? colors.card : colors.muted }]}>
                <Text style={s.tdNum}>{i + 1}</Text>
                <Text style={s.tdRoll} numberOfLines={1}>{row.rollNo}</Text>
                <Text style={s.tdName} numberOfLines={1}>{row.name}</Text>
                {isEditing ? (
                  <>
                    {(["quiz", "assignment", "mid", "final"] as const).map(k => (
                      <TextInput
                        key={k}
                        style={s.markInput}
                        value={editVals[k]}
                        onChangeText={t => setEditVals(v => ({ ...v, [k]: t }))}
                        keyboardType="numeric"
                        maxLength={5}
                        placeholder="–"
                        placeholderTextColor={colors.mutedForeground}
                      />
                    ))}
                    <Text style={[s.tdTotal, { color: colors.mutedForeground }]}>–</Text>
                    <TouchableOpacity style={s.saveMarkBtn} onPress={() => handleSaveMark(row)} disabled={savingMark}>
                      {savingMark
                        ? <ActivityIndicator color="#fff" size="small" />
                        : <Text style={s.saveMarkBtnTxt}>Save</Text>
                      }
                    </TouchableOpacity>
                  </>
                ) : (
                  <>
                    <Text style={s.tdCell}>{row.quiz ?? "–"}</Text>
                    <Text style={s.tdCell}>{row.assignment ?? "–"}</Text>
                    <Text style={s.tdCell}>{row.mid ?? "–"}</Text>
                    <Text style={s.tdCell}>{row.final ?? "–"}</Text>
                    <Text style={[s.tdTotal, { color: total != null ? "#1565C0" : colors.mutedForeground }]}>
                      {total ?? "–"}
                    </Text>
                    {effectiveTeacherMode && (
                      <TouchableOpacity style={s.editBtn} onPress={() => startEdit(row)}>
                        <Feather name="edit-2" size={14} color={colors.primary} />
                      </TouchableOpacity>
                    )}
                  </>
                )}
              </View>
            );
          })}
        </ScrollView>
      </View>
    );
  };

  const renderStudentLookup = () => (
    <View style={{ flex: 1 }}>
      <View style={s.lookupRow}>
        <TextInput
          style={s.lookupInput}
          placeholder="Enter your Reg No (e.g. 2K22-BEE-01)"
          placeholderTextColor={colors.mutedForeground}
          value={lookupReg}
          onChangeText={setLookupReg}
          autoCapitalize="characters"
          returnKeyType="search"
          onSubmitEditing={handleLookup}
        />
        <TouchableOpacity style={s.lookupBtn} onPress={handleLookup} disabled={lookupLoading}>
          {lookupLoading
            ? <ActivityIndicator color="#fff" size="small" />
            : <Text style={s.lookupBtnTxt}>Search</Text>
          }
        </TouchableOpacity>
      </View>
      {lookupResult && (
        lookupResult.found ? (
          <View style={s.resultCard}>
            <View style={s.resultHeader}>
              <Text style={s.resultName}>{lookupResult.studentName}</Text>
              <Text style={s.resultReg}>{lookupResult.rollNo}</Text>
            </View>
            {/* Column headers */}
            <View style={[s.resultRow, { backgroundColor: "#E3F2FD" }]}>
              <Text style={[s.resultClass, { fontFamily: "Inter_700Bold", fontSize: 12 }]}>Subject / Class</Text>
              <Text style={[s.resultMarkCell, { fontFamily: "Inter_700Bold", color: "#1565C0", fontSize: 11 }]}>Quiz{"\n"}{lookupResult.weights?.quiz}%</Text>
              <Text style={[s.resultMarkCell, { fontFamily: "Inter_700Bold", color: "#2E7D32", fontSize: 11 }]}>Assg{"\n"}{lookupResult.weights?.assignment}%</Text>
              <Text style={[s.resultMarkCell, { fontFamily: "Inter_700Bold", color: "#E65100", fontSize: 11 }]}>Mid{"\n"}{lookupResult.weights?.mid}%</Text>
              <Text style={[s.resultMarkCell, { fontFamily: "Inter_700Bold", color: "#6A1B9A", fontSize: 11 }]}>Final{"\n"}{lookupResult.weights?.final}%</Text>
              <Text style={[s.resultTotal, { fontFamily: "Inter_700Bold", fontSize: 11 }]}>Total</Text>
            </View>
            {(lookupResult.rows ?? []).map((row, i) => (
              <View key={i} style={[s.resultRow, { backgroundColor: i % 2 === 0 ? colors.card : colors.muted }]}>
                <Text style={s.resultClass} numberOfLines={2}>{row.className}</Text>
                <Text style={s.resultMarkCell}>{row.quiz ?? "–"}</Text>
                <Text style={s.resultMarkCell}>{row.assignment ?? "–"}</Text>
                <Text style={s.resultMarkCell}>{row.mid ?? "–"}</Text>
                <Text style={s.resultMarkCell}>{row.final ?? "–"}</Text>
                <Text style={[s.resultTotal, { color: row.total != null ? "#1565C0" : colors.mutedForeground }]}>
                  {row.total != null ? `${row.total}` : "–"}
                </Text>
              </View>
            ))}
          </View>
        ) : (
          <View style={s.noClass}>
            <Feather name="search" size={40} color={colors.mutedForeground} />
            <Text style={s.noClassTxt}>No results found for Reg No "{lookupReg}". Make sure you are enrolled in this schedule.</Text>
          </View>
        )
      )}
      {!lookupResult && !lookupLoading && (
        <View style={s.noClass}>
          <Feather name="award" size={44} color={colors.mutedForeground} />
          <Text style={s.noClassTxt}>Enter your Reg No above to see your exam marks for this schedule.</Text>
        </View>
      )}
    </View>
  );

  const TABS: Array<{ key: Tab; label: string; show: boolean }> = [
    { key: "weights", label: "Weights", show: true },
    { key: "marks",   label: effectiveTeacherMode ? "Enter Marks" : "Marks",    show: !publicMode },
    { key: "students", label: "My Marks", show: publicMode },
  ];
  const visibleTabs = TABS.filter(t => t.show);

  return (
    <View style={s.container}>
      <View style={s.header}>
        <View style={s.headerRow}>
          <TouchableOpacity style={s.navBtn} onPress={() => router.back()}>
            <Feather name="chevron-left" size={14} color="#fff" />
            <Text style={s.navBtnTxt}>Back</Text>
          </TouchableOpacity>
          <TouchableOpacity style={s.navBtn} onPress={() => router.replace("/")}>
            <Feather name="home" size={13} color="#fff" />
            <Text style={s.navBtnTxt}>Home</Text>
          </TouchableOpacity>
        </View>
        <Text style={s.headerTitle}>Exam Marks</Text>
        <Text style={s.headerSub}>{scheduleTitle}</Text>
      </View>

      {/* Class picker — always visible except on student lookup tab */}
      {activeTab !== "students" && (
        <View style={s.classPickerRow}>
          <TouchableOpacity style={s.classBtn} onPress={() => setShowClassPicker(true)}>
            <Feather name="layers" size={16} color={colors.primary} />
            <Text style={s.classBtnTxt} numberOfLines={1}>
              {selectedClass ? `${selectedClass} · ${selectedSubject}` : "Select Class & Subject"}
            </Text>
            <Feather name="chevron-down" size={16} color={colors.mutedForeground} />
          </TouchableOpacity>
        </View>
      )}

      {/* Tabs */}
      <View style={s.tabRow}>
        {visibleTabs.map(tab => (
          <TouchableOpacity
            key={tab.key}
            style={[s.tab, activeTab === tab.key && s.tabActive]}
            onPress={() => setActiveTab(tab.key)}
          >
            <Text style={[s.tabTxt, activeTab === tab.key && s.tabTxtActive]}>{tab.label}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Tab content */}
      {activeTab === "weights" && renderWeightsTab()}
      {activeTab === "marks" && renderMarksTab()}
      {activeTab === "students" && renderStudentLookup()}

      <PickerModal
        visible={showClassPicker}
        title="Select Class & Subject"
        items={classSubjectList.map(k => classSubjectDisplay[k])}
        selected={selectedClass && selectedSubject ? `${selectedClass} · ${selectedSubject}` : ""}
        onSelect={(displayVal) => {
          const key = classSubjectList.find(k => classSubjectDisplay[k] === displayVal);
          if (!key) return;
          const [cls, subj] = key.split("|||");
          setSelectedClass(cls);
          setSelectedSubject(subj);
          setEditingRow(null);
        }}
        onClose={() => setShowClassPicker(false)}
        placeholder="Search class or subject…"
      />

      {!!errorMsg && (
        <Modal visible transparent animationType="fade">
          <View style={{ flex: 1, justifyContent: "center", alignItems: "center", backgroundColor: "rgba(0,0,0,0.45)", padding: 32 }}>
            <View style={{ backgroundColor: colors.card, borderRadius: 16, padding: 24, width: "100%", alignItems: "center" }}>
              <Feather name="alert-circle" size={32} color={colors.destructive} style={{ marginBottom: 10 }} />
              <Text style={{ fontSize: 15, fontFamily: "Inter_400Regular", color: colors.foreground, textAlign: "center", marginBottom: 20 }}>
                {errorMsg}
              </Text>
              <TouchableOpacity
                onPress={() => setErrorMsg("")}
                style={{ backgroundColor: colors.primary, borderRadius: 10, paddingVertical: 11, paddingHorizontal: 32 }}
              >
                <Text style={{ color: "#fff", fontSize: 15, fontFamily: "Inter_700Bold" }}>OK</Text>
              </TouchableOpacity>
            </View>
          </View>
        </Modal>
      )}
    </View>
  );
}
