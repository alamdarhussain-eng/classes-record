import React, { useState, useMemo } from "react";
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, TextInput, ActivityIndicator, Modal, Platform } from "react-native";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useLocalSearchParams } from "expo-router";
import { useColors } from "@/hooks/useColors";
import { fetchSchedule, addFinancePerson, deactivateFinancePerson } from "@/hooks/useApi";
import { PickerModal } from "@/components/PickerModal";

type PersonType = "student" | "faculty" | "staff" | "roster" | "access";
type ActionType = "join" | "leave";

export default function PersonnelScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const qc = useQueryClient();
  const { scheduleId: rawId, scheduleTitle } = useLocalSearchParams<{ scheduleId: string; scheduleTitle: string }>();
  const scheduleId = Number(rawId);

  const [activeTab, setActiveTab] = useState<PersonType>("faculty");
  const [showAction, setShowAction] = useState(false);
  const [actionType, setActionType] = useState<ActionType>("join");
  const [personName, setPersonName] = useState("");
  const [personEmail, setPersonEmail] = useState("");
  const [effectiveDate, setEffectiveDate] = useState(() => {
    const d = new Date();
    return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,"0")}-${String(d.getDate()).padStart(2,"0")}`;
  });
  const [reason, setReason] = useState("");
  const [studentClass, setStudentClass] = useState("");
  const [studentSubject, setStudentSubject] = useState("");
  const [showClassPicker, setShowClassPicker] = useState(false);
  const [loading, setLoading] = useState(false);
  const [msg, setMsg] = useState("");
  const [showPersonPicker, setShowPersonPicker] = useState(false);
  const [selectedPersonId, setSelectedPersonId] = useState("");
  const [selectedPersonName, setSelectedPersonName] = useState("");

  const { data: scheduleRows = [] } = useQuery({
    queryKey: ["schedule", scheduleId],
    queryFn: () => fetchSchedule(scheduleId),
    enabled: !!scheduleId,
  });

  // Get faculty list from weekly schedule
  const facultyList = useMemo(() => {
    const set = new Set<string>();
    (scheduleRows as any[]).filter((r: any) => !r.Type && r.Faculty && r.Faculty !== "_locations_")
      .forEach((r: any) => set.add(r.Faculty));
    return [...set].sort();
  }, [scheduleRows]);

  // Class+Subject map for student enrollment
  const classSubjectMap = useMemo(() => {
    const map: Record<string, string> = {};
    (scheduleRows as any[]).filter((r: any) => !r.Type && r.Class && r.Subject && r.Class !== "_ref_" && r.Faculty !== "_locations_")
      .forEach((r: any) => {
        const key = `${r.Class}|||${r.Subject}`;
        map[key] = `${r.Class} · ${r.Subject}`;
      });
    return map;
  }, [scheduleRows]);
  const classSubjectList = Object.keys(classSubjectMap);

  // Get active persons for leave action (from finance_faculty/students/staff)
  const isHRTab = activeTab === "faculty" || activeTab === "student" || activeTab === "staff";
  const { data: activePersons = [] } = useQuery({
    queryKey: ["finance-persons", scheduleId, activeTab],
    queryFn: async () => {
      const period = new Date().toISOString().slice(0, 7);
      const res = await fetch(`https://${process.env.EXPO_PUBLIC_DOMAIN}/api/finance/persons?scheduleId=${scheduleId}&personType=${activeTab}&period=${period}`);
      const data = await res.json();
      return Array.isArray(data) ? data : [];
    },
    enabled: !!scheduleId && isHRTab,
  });

  async function handleJoin() {
    if (!personName.trim() || !effectiveDate) { setMsg("Enter name and effective date"); return; }
    if (activeTab === "student" && !studentClass) { setMsg("Select class and subject for student"); return; }
    setLoading(true); setMsg("");
    const period = effectiveDate.slice(0, 7);
    let res: any;
    if (activeTab === "student") {
      // Add student to students table with class
      const [cls, subj] = studentClass.split("|||");
      res = await fetch(`https://${process.env.EXPO_PUBLIC_DOMAIN}/api/attendance/students`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ scheduleId, className: cls, rollNo: personName.trim(), name: personName.trim(), email: personEmail.trim(), activeFrom: period }),
      }).then(r => r.json());
      // Also set active_from
      await fetch(`https://${process.env.EXPO_PUBLIC_DOMAIN}/api/finance/persons`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ scheduleId, personType: "student", name: personName.trim(), email: personEmail.trim(), activeFrom: period }),
      });
    } else {
      res = await addFinancePerson(scheduleId, activeTab, personName.trim(), personEmail.trim(), period);
    }
    setLoading(false);
    if (res.success || res.student) {
      setMsg(`✓ ${personName} joined as ${activeTab}${activeTab==="student" ? ` in ${classSubjectMap[studentClass]||studentClass}` : ""} WEF ${effectiveDate}`);
      setPersonName(""); setPersonEmail(""); setReason(""); setStudentClass(""); setStudentSubject("");
      qc.invalidateQueries({ queryKey: ["finance-persons", scheduleId, activeTab] });
      qc.invalidateQueries({ queryKey: ["students-all", scheduleId] });
    } else { setMsg(res.error || "Failed to add"); }
  }

  async function handleLeave() {
    if (!selectedPersonId || !effectiveDate) { setMsg("Select person and effective date"); return; }
    setLoading(true); setMsg("");
    const period = effectiveDate.slice(0, 7);
    const res = await deactivateFinancePerson(selectedPersonId, activeTab, scheduleId, period);
    setLoading(false);
    if (res.success) {
      setMsg(`✓ ${selectedPersonName} left WEF ${effectiveDate}${reason ? ` — ${reason}` : ""}`);
      setSelectedPersonId(""); setSelectedPersonName(""); setReason("");
      qc.invalidateQueries({ queryKey: ["finance-persons", scheduleId, activeTab] });
      qc.invalidateQueries({ queryKey: ["students-all", scheduleId] });
    } else { setMsg(res.error || "Failed"); }
  }

  const tabColor = activeTab === "faculty" ? "#4A148C" : activeTab === "student" ? "#1565C0" : "#2E7D32";

  const s = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    header: { backgroundColor: "#4A148C", paddingTop: insets.top + (Platform.OS === "web" ? 67 : 0), paddingBottom: 16, paddingHorizontal: 16 },
    backBtn: { flexDirection: "row", alignItems: "center", gap: 6, marginBottom: 10 },
    backTxt: { color: "#fff", fontSize: 13, fontFamily: "Inter_500Medium" },
    headerTitle: { color: "#fff", fontSize: 22, fontFamily: "Inter_700Bold" },
    headerSub: { color: "rgba(255,255,255,0.8)", fontSize: 13, fontFamily: "Inter_400Regular", marginTop: 2 },
    tabRow: { flexDirection: "row", gap: 8, paddingHorizontal: 16, paddingVertical: 12, backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border },
    tab: { flex: 1, paddingVertical: 8, borderRadius: 8, alignItems: "center", borderWidth: 1, borderColor: colors.border },
    tabActive: { borderColor: tabColor, backgroundColor: tabColor },
    tabTxt: { fontSize: 13, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground },
    tabTxtActive: { color: "#fff" },
    card: { margin: 16, backgroundColor: colors.card, borderRadius: 12, borderWidth: 1, borderColor: colors.border, overflow: "hidden" },
    cardHeader: { padding: 14, borderBottomWidth: 1, borderBottomColor: colors.border, flexDirection: "row", alignItems: "center", gap: 10 },
    cardTitle: { fontSize: 16, fontFamily: "Inter_700Bold", color: colors.foreground },
    input: { borderWidth: 1, borderColor: colors.border, borderRadius: 8, paddingHorizontal: 12, paddingVertical: 10, fontSize: 14, fontFamily: "Inter_400Regular", color: colors.foreground, backgroundColor: colors.background, marginHorizontal: 14, marginBottom: 10 },
    label: { fontSize: 12, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground, marginHorizontal: 14, marginBottom: 4, textTransform: "uppercase" },
    btn: { margin: 14, borderRadius: 10, paddingVertical: 13, alignItems: "center" },
    personPicker: { flexDirection: "row", alignItems: "center", borderWidth: 1, borderColor: colors.border, borderRadius: 8, paddingHorizontal: 12, paddingVertical: 10, marginHorizontal: 14, marginBottom: 10, backgroundColor: colors.background, gap: 8 },
    msgTxt: { fontSize: 13, fontFamily: "Inter_600SemiBold", textAlign: "center", padding: 12 },
    personRow: { flexDirection: "row", alignItems: "center", paddingHorizontal: 14, paddingVertical: 10, borderBottomWidth: 1, borderBottomColor: colors.border },
  });

  const tabLabels: Record<PersonType, string> = { faculty: "Faculty", student: "Student", staff: "Staff", roster: "Students", access: "Faculty Access" };

  return (
    <View style={s.container}>
      <View style={s.header}>
        <TouchableOpacity style={s.backBtn} onPress={() => router.back()}>
          <Feather name="arrow-left" size={14} color="#fff" />
          <Text style={s.backTxt}>Back</Text>
        </TouchableOpacity>
        <Text style={s.headerTitle}>HR · Personnel</Text>
        <Text style={s.headerSub}>{scheduleTitle ? decodeURIComponent(scheduleTitle) : ""}</Text>
      </View>

      {/* Type Tabs - Row 1: HR actions */}
      <View style={s.tabRow}>
        {(["faculty","student","staff"] as PersonType[]).map(t => (
          <TouchableOpacity key={t} style={[s.tab, activeTab===t && s.tabActive]} onPress={() => { setActiveTab(t); setMsg(""); setSelectedPersonId(""); setSelectedPersonName(""); }}>
            <Text style={[s.tabTxt, activeTab===t && s.tabTxtActive]}>{tabLabels[t]}</Text>
          </TouchableOpacity>
        ))}
      </View>
      {/* Row 2: Management screens */}
      <View style={[s.tabRow, { borderTopWidth: 0 }]}>
        <TouchableOpacity style={[s.tab, activeTab==="roster" && { borderColor:"#1565C0", backgroundColor:"#1565C0" }]}
          onPress={() => { setActiveTab("roster"); setMsg(""); }}>
          <Text style={[s.tabTxt, activeTab==="roster" && s.tabTxtActive]}>📋 Students Roster</Text>
        </TouchableOpacity>
        <TouchableOpacity style={[s.tab, activeTab==="access" && { borderColor:"#00695C", backgroundColor:"#00695C" }]}
          onPress={() => { setActiveTab("access"); setMsg(""); }}>
          <Text style={[s.tabTxt, activeTab==="access" && s.tabTxtActive]}>🔑 Faculty Access</Text>
        </TouchableOpacity>
      </View>

      <ScrollView contentContainerStyle={{ paddingBottom: 40 }}>

        {activeTab === "roster" && (
          <View style={s.card}>
            <View style={[s.cardHeader, { backgroundColor: "#E3F2FD" }]}>
              <Feather name="users" size={18} color="#1565C0" />
              <Text style={[s.cardTitle, { color: "#1565C0" }]}>Students Enrollment & Roster</Text>
            </View>
            <TouchableOpacity
              style={[s.btn, { backgroundColor: "#1565C0", margin: 14 }]}
              onPress={() => router.push(`/(screens)/students?scheduleId=${scheduleId}&scheduleTitle=${encodeURIComponent(decodeURIComponent(scheduleTitle ?? ""))}` as never)}>
              <Text style={{ color: "#fff", fontFamily: "Inter_700Bold", fontSize: 15 }}>Open Students Screen →</Text>
            </TouchableOpacity>
            <Text style={{ paddingHorizontal:14, paddingBottom:14, fontSize:13, fontFamily:"Inter_400Regular", color:colors.mutedForeground }}>
              Enroll students, view class-wise roster, bulk upload, download reports.
            </Text>
          </View>
        )}

        {activeTab === "access" && (
          <View style={s.card}>
            <View style={[s.cardHeader, { backgroundColor: "#E0F2F1" }]}>
              <Feather name="user-check" size={18} color="#00695C" />
              <Text style={[s.cardTitle, { color: "#00695C" }]}>Faculty Access & Credentials</Text>
            </View>
            <TouchableOpacity
              style={[s.btn, { backgroundColor: "#00695C", margin: 14 }]}
              onPress={() => router.push(`/(screens)/faculty-credentials?scheduleId=${scheduleId}&scheduleTitle=${encodeURIComponent(decodeURIComponent(scheduleTitle ?? ""))}` as never)}>
              <Text style={{ color: "#fff", fontFamily: "Inter_700Bold", fontSize: 15 }}>Open Faculty Access →</Text>
            </TouchableOpacity>
            <Text style={{ paddingHorizontal:14, paddingBottom:14, fontSize:13, fontFamily:"Inter_400Regular", color:colors.mutedForeground }}>
              Manage faculty login credentials, share schedule access, download faculty reports.
            </Text>
          </View>
        )}

        {(activeTab === "faculty" || activeTab === "student" || activeTab === "staff") && (
          <>
            {/* JOIN Card */}
            <View style={s.card}>
              <View style={[s.cardHeader, { backgroundColor: "#E8F5E9" }]}>
                <Feather name="user-plus" size={18} color="#2E7D32" />
                <Text style={[s.cardTitle, { color: "#2E7D32" }]}>New {tabLabels[activeTab]} — Join</Text>
              </View>
              <View style={{ height: 14 }} />
              {activeTab === "student" && (
                <>
                  <Text style={s.label}>Class & Subject</Text>
                  <TouchableOpacity style={s.personPicker} onPress={() => setShowClassPicker(true)}>
                    <Feather name="book" size={15} color={colors.mutedForeground} />
                    <Text style={{ flex:1, fontSize:14, fontFamily:"Inter_400Regular", color: studentClass ? colors.foreground : colors.mutedForeground }}>
                      {studentClass ? classSubjectMap[studentClass] : "Select Class & Subject..."}
                    </Text>
                    <Feather name="chevron-down" size={15} color={colors.mutedForeground} />
                  </TouchableOpacity>
                </>
              )}
              <Text style={s.label}>{activeTab === "student" ? "Roll No" : "Full Name"}</Text>
              <TextInput style={s.input} placeholder={activeTab === "student" ? "e.g. 2K24-BEE-001" : "e.g. Dr. Ahmad Shah"}
                placeholderTextColor={colors.mutedForeground} value={personName} onChangeText={setPersonName} />
              <Text style={s.label}>Email (optional)</Text>
              <TextInput style={s.input} placeholder="email@example.com" placeholderTextColor={colors.mutedForeground}
                value={personEmail} onChangeText={setPersonEmail} autoCapitalize="none" keyboardType="email-address" />
              <Text style={s.label}>Joining Date (exact)</Text>
              <TextInput style={s.input} placeholder="YYYY-MM-DD" placeholderTextColor={colors.mutedForeground}
                value={effectiveDate} onChangeText={setEffectiveDate} />
              <Text style={{ fontSize: 11, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginHorizontal: 14, marginBottom: 10 }}>
                💡 Person will appear in Finance from the month of joining date
              </Text>
              <Text style={s.label}>Reason / Note (optional)</Text>
              <TextInput style={s.input} placeholder="e.g. New hire, Transfer in..."
                placeholderTextColor={colors.mutedForeground} value={reason} onChangeText={setReason} />
              <TouchableOpacity style={[s.btn, { backgroundColor: "#2E7D32" }]} onPress={handleJoin} disabled={loading}>
                {loading ? <ActivityIndicator color="#fff" /> : <Text style={{ color: "#fff", fontFamily: "Inter_700Bold", fontSize: 15 }}>✓ Confirm Join WEF {effectiveDate}</Text>}
              </TouchableOpacity>
            </View>

            {/* LEAVE Card */}
            <View style={s.card}>
              <View style={[s.cardHeader, { backgroundColor: "#FFEBEE" }]}>
                <Feather name="user-minus" size={18} color="#B71C1C" />
                <Text style={[s.cardTitle, { color: "#B71C1C" }]}>{tabLabels[activeTab]} — Leave / Resign</Text>
              </View>
              <View style={{ height: 14 }} />
              <Text style={s.label}>Select {tabLabels[activeTab]}</Text>
              <TouchableOpacity style={s.personPicker} onPress={() => setShowPersonPicker(true)}>
                <Feather name="user" size={15} color={colors.mutedForeground} />
                <Text style={{ flex:1, fontSize:14, fontFamily:"Inter_400Regular", color: selectedPersonName ? colors.foreground : colors.mutedForeground }}>
                  {selectedPersonName || `Select active ${tabLabels[activeTab]}...`}
                </Text>
                <Feather name="chevron-down" size={15} color={colors.mutedForeground} />
              </TouchableOpacity>
              <Text style={s.label}>Last Working Date (exact)</Text>
              <TextInput style={s.input} placeholder="YYYY-MM-DD" placeholderTextColor={colors.mutedForeground}
                value={effectiveDate} onChangeText={setEffectiveDate} />
              <Text style={{ fontSize: 11, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginHorizontal: 14, marginBottom: 10 }}>
                💡 Person will be removed from Finance from next month onwards
              </Text>
              <Text style={s.label}>Reason for Leaving</Text>
              <TextInput style={s.input} placeholder="e.g. Resigned, Contract ended, Transfer out..."
                placeholderTextColor={colors.mutedForeground} value={reason} onChangeText={setReason} />
              <TouchableOpacity style={[s.btn, { backgroundColor: "#B71C1C" }]} onPress={handleLeave} disabled={loading || !selectedPersonId}>
                {loading ? <ActivityIndicator color="#fff" /> : <Text style={{ color: "#fff", fontFamily: "Inter_700Bold", fontSize: 15 }}>✗ Confirm Leave WEF {effectiveDate}</Text>}
              </TouchableOpacity>
            </View>

            {/* Active Persons List */}
            <View style={s.card}>
              <View style={[s.cardHeader, { backgroundColor: "#EDE7F6" }]}>
                <Feather name="users" size={18} color="#4A148C" />
                <Text style={[s.cardTitle, { color: "#4A148C" }]}>Currently Active {tabLabels[activeTab]}s ({activePersons.length})</Text>
              </View>
              {activePersons.length === 0 ? (
                <Text style={{ padding: 20, textAlign: "center", color: colors.mutedForeground, fontFamily: "Inter_400Regular" }}>No active {tabLabels[activeTab]}s found</Text>
              ) : activePersons.map((p: any) => (
                <View key={p.personId} style={s.personRow}>
                  <Feather name="user" size={14} color={colors.mutedForeground} style={{ marginRight: 10 }} />
                  <View style={{ flex: 1 }}>
                    <Text style={{ fontSize: 14, fontFamily: "Inter_600SemiBold", color: colors.foreground }}>{p.personName}</Text>
                    {p.activeFrom && <Text style={{ fontSize: 11, fontFamily: "Inter_400Regular", color: colors.mutedForeground }}>From: {p.activeFrom}</Text>}
                  </View>
                </View>
              ))}
            </View>
          </>
        )}

        {msg ? (
          <Text style={[s.msgTxt, { color: msg.startsWith("✓") ? "#2E7D32" : "#B71C1C" }]}>{msg}</Text>
        ) : null}

  </ScrollView>

      <PickerModal
        visible={showClassPicker}
        title="Select Class & Subject"
        items={classSubjectList.map(k => classSubjectMap[k])}
        selected={studentClass ? classSubjectMap[studentClass] : ""}
        onSelect={(val) => { const k = classSubjectList.find(k => classSubjectMap[k] === val); if (k) setStudentClass(k); setShowClassPicker(false); }}
        onClose={() => setShowClassPicker(false)}
        placeholder="Search class or subject..."
      />
      <PickerModal
        visible={showPersonPicker}
        title={`Select ${tabLabels[activeTab]}`}
        items={activePersons.map((p: any) => p.personName)}
        selected={selectedPersonName}
        onSelect={(val) => {
          const p = activePersons.find((x: any) => x.personName === val);
          if (p) { setSelectedPersonId(p.personId); setSelectedPersonName(p.personName); }
          setShowPersonPicker(false);
        }}
        onClose={() => setShowPersonPicker(false)}
        placeholder={`Search ${tabLabels[activeTab]}...`}
      />
    </View>
  );
}
