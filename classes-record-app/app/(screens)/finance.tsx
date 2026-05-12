import React, { useState, useEffect, useCallback, useMemo } from "react";
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  TextInput, ActivityIndicator, Modal, Alert, Linking, Platform,
} from "react-native";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import AsyncStorage from "@react-native-async-storage/async-storage";
import * as DocumentPicker from "expo-document-picker";

import { useColors } from "@/hooks/useColors";
import {
  financeLogin,
  fetchSupportStaff, addSupportStaff, deleteSupportStaff, importStaffExcel,
  addFinancePerson, deactivateFinancePerson,
  fetchFinancePersons, fetchFinancePayments, saveFinancePaymentsBulk,
  fetchFinanceSummary, fetchStudentFeeStatus,
  fetchFinanceSchedules,
  fetchFinanceRates, saveFinanceRatesBulk, importRatesExcel,
  FinancePayment, SupportStaff,
} from "@/hooks/useApi";

const FINANCE_KEY = "financeUser";
const STATUS_COLOR: Record<string, string> = { Paid: "#2E7D32", Partial: "#E65100", Unpaid: "#C62828", "Not Set": "#9E9E9E" };
const STATUS_BG: Record<string, string> = { Paid: "#E8F5E9", Partial: "#FFF3E0", Unpaid: "#FFEBEE", "Not Set": "#F5F5F5" };

// ── Semester definitions (HEC Pakistan academic calendar) ─────────────────
const MONTH_NAMES = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

type SemesterDef = { key: string; label: string; months: string[]; semPeriod: string };

function buildAllMonths(): string[] {
  const now = new Date();
  const months: string[] = [];
  for (let i = -2; i <= 9; i++) {
    const d = new Date(now.getFullYear(), now.getMonth() + i, 1);
    months.push(`${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`);
  }
  return months;
}
const ALL_MONTHS: string[] = buildAllMonths();
const SEMESTERS: SemesterDef[] = [{ key: "ALL", label: "All Months", months: ALL_MONTHS, semPeriod: ALL_MONTHS[2] }];

function findCurrentSemester(): SemesterDef {
  return SEMESTERS[0];
}

function monthLabel(period: string): string {
  const [, m] = period.split("-");
  const idx = parseInt(m, 10) - 1;
  return MONTH_NAMES[idx] ?? m;
}

function semLabel(key: string): string {
  return SEMESTERS.find(s => s.key === key)?.label ?? key;
}

// ── Helpers ────────────────────────────────────────────────────────────────
function payStatus(amount: string | number, paid: string | number): string {
  const a = Number(amount), p = Number(paid);
  if (a === 0) return "Not Set";
  if (p >= a) return "Paid";
  if (p > 0) return "Partial";
  return "Unpaid";
}

function fmt(n: number): string {
  return n.toLocaleString("en-PK", { minimumFractionDigits: 0, maximumFractionDigits: 0 });
}

type Tab = "summary" | "students" | "faculty" | "staff";
type PeriodMode = "semester" | "month";
type PayRow = { personId: string; personName: string; amount: string; paidAmount: string; notes: string; dirty: boolean };
type RateRow = { personId: string; personName: string; rate: string; dirty: boolean };

export default function FinanceScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const qc = useQueryClient();

  // ── Auth state ─────────────────────────────────────────────────────────
  const [finUser, setFinUser] = useState<string | null>(null);
  const [loginLoading, setLoginLoading] = useState(false);

  const [loginUser, setLoginUser] = useState("");
  const [loginPin, setLoginPin] = useState("");
  const [errorMsg, setErrorMsg] = useState("");
  const [showPersonMgmt, setShowPersonMgmt] = useState(false);
  const [personMgmtType, setPersonMgmtType] = useState<"student"|"faculty"|"staff">("student");
  const [newPersonName, setNewPersonName] = useState("");
  const [newPersonEmail, setNewPersonEmail] = useState("");
  const [personMgmtLoading, setPersonMgmtLoading] = useState(false);
  const [personMgmtMsg, setPersonMgmtMsg] = useState("");

  // ── Period state ───────────────────────────────────────────────────────
  const [activeTab, setActiveTab] = useState<Tab>("summary");
  const [selectedSem, setSelectedSem] = useState<SemesterDef>(findCurrentSemester);
  const [studentPeriodMode, setStudentPeriodMode] = useState<PeriodMode>("month");
  const [selectedMonth, setSelectedMonth] = useState<string>(ALL_MONTHS[2]);
  const [showSemPicker, setShowSemPicker] = useState(false);
  const [selectedScheduleId, setSelectedScheduleId] = useState<number | null>(null);
  const [showSchedPicker, setShowSchedPicker] = useState(false);

  // Computed active period for API calls
  const period = useMemo<string>(() => {
    if (activeTab === "students" && studentPeriodMode === "semester") return selectedSem.semPeriod;
    return selectedMonth;
  }, [activeTab, studentPeriodMode, selectedSem, selectedMonth]);

  // ── Payment rows ───────────────────────────────────────────────────────
  const [studentRows, setStudentRows] = useState<PayRow[]>([]);
  const [facultyRows, setFacultyRows] = useState<PayRow[]>([]);
  const [staffPayRows, setStaffPayRows] = useState<PayRow[]>([]);
  const [saving, setSaving] = useState(false);

  // ── Staff management ───────────────────────────────────────────────────
  const [newEmpId, setNewEmpId] = useState("");
  const [newName, setNewName] = useState("");
  const [newDesg, setNewDesg] = useState("");
  const [newDept, setNewDept] = useState("");
  const [addingStaff, setAddingStaff] = useState(false);
  const [bulkLoading, setBulkLoading] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<SupportStaff | null>(null);

  // ── Rates modal ────────────────────────────────────────────────────────
  const [showRatesModal, setShowRatesModal] = useState<"student" | "faculty" | "staff" | null>(null);
  const [rateRows, setRateRows] = useState<RateRow[]>([]);
  const [ratesLoading, setRatesLoading] = useState(false);
  const [savingRates, setSavingRates] = useState(false);
  const [ratesBulkLoading, setRatesBulkLoading] = useState(false);

  // ── Public lookup ──────────────────────────────────────────────────────
  const [lookupReg, setLookupReg] = useState("");
  const [lookupResult, setLookupResult] = useState<Awaited<ReturnType<typeof fetchStudentFeeStatus>> | null>(null);
  const [lookupLoading, setLookupLoading] = useState(false);

  useEffect(() => {
    AsyncStorage.getItem(FINANCE_KEY).then(v => v && setFinUser(v));
  }, []);

  // When semester changes, auto-select its first month for month-mode
  useEffect(() => {
    // month stays as selected, no reset needed
  }, [selectedSem]);

  // ── Login ──────────────────────────────────────────────────────────────
  async function handleAddPerson() {
    if (!newPersonName.trim() || !selectedScheduleId) return;
    setPersonMgmtLoading(true); setPersonMgmtMsg("");
    const res = await addFinancePerson(selectedScheduleId, personMgmtType, newPersonName.trim(), newPersonEmail.trim(), period);
    setPersonMgmtLoading(false);
    if (res.success) {
      setPersonMgmtMsg(`✓ Added from ${period}`);
      setNewPersonName(""); setNewPersonEmail("");
      if (personMgmtType === "student") loadPayRows("student", setStudentRows, period);
      else if (personMgmtType === "faculty") loadPayRows("faculty", setFacultyRows, period);
      else loadPayRows("staff", setStaffPayRows, period);
    } else { setPersonMgmtMsg(res.error || "Failed to add"); }
  }

  async function handleRemovePerson(personId: string, personName: string) {
    if (!selectedScheduleId) return;
    setPersonMgmtLoading(true); setPersonMgmtMsg("");
    const res = await deactivateFinancePerson(personId, personMgmtType, selectedScheduleId, period);
    setPersonMgmtLoading(false);
    if (res.success) {
      setPersonMgmtMsg(`✓ ${personName} removed WEF ${period}`);
      if (personMgmtType === "student") loadPayRows("student", setStudentRows, period);
      else if (personMgmtType === "faculty") loadPayRows("faculty", setFacultyRows, period);
      else loadPayRows("staff", setStaffPayRows, period);
    } else { setPersonMgmtMsg(res.error || "Failed"); }
  }

  async function handleLogin() {
    if (!loginUser.trim()) { setErrorMsg("Enter your username"); return; }
    if (!loginPin.trim()) { setErrorMsg("Enter your Finance PIN"); return; }
    setLoginLoading(true);
    const res = await financeLogin(loginUser.trim(), loginPin.trim());
    setLoginLoading(false);
    if (res.success && res.user) {
      await AsyncStorage.setItem(FINANCE_KEY, res.user);
      setFinUser(res.user);
      setLoginUser(""); setLoginPin("");
    } else {
      setErrorMsg(res.message ?? "Login failed");
    }
  }

  async function handleLogout() {
    await AsyncStorage.removeItem(FINANCE_KEY);
    setFinUser(null);
  }

  // ── Data queries ───────────────────────────────────────────────────────
  const { data: schedules = [] } = useQuery({
    queryKey: ["financeSchedules", finUser],
    queryFn: () => fetchFinanceSchedules(finUser ?? undefined),
    enabled: !!finUser,
  });

  const { data: summary, isLoading: summaryLoading, refetch: refetchSummary } = useQuery({
    queryKey: ["financeSummary", period],
    queryFn: () => fetchFinanceSummary(period || undefined),
    enabled: !!finUser,
  });

  const { data: staffList = [] } = useQuery({
    queryKey: ["supportStaff"],
    queryFn: fetchSupportStaff,
    enabled: !!finUser,
  });

  // ── Load payment rows (auto-fills amount from stored rate when no payment exists) ──
  const loadPayRows = useCallback(async (
    type: "student" | "faculty" | "staff",
    setter: (rows: PayRow[]) => void,
    forPeriod: string,
  ) => {
    if (type === "staff") {
      if (selectedScheduleId == null) return;
      const [staff, payments, rates] = await Promise.all([
        fetchSupportStaff(selectedScheduleId),
        fetchFinancePayments(selectedScheduleId, "staff", forPeriod),
        fetchFinanceRates(selectedScheduleId, "staff"),
      ]);
      const payMap: Record<string, FinancePayment> = {};
      for (const p of payments) payMap[p.personId] = p;
      const rateMap: Record<string, string> = {};
      for (const r of rates) rateMap[r.personId] = String(r.amount);
      setter(staff.map(s => ({
        personId: String(s.id), personName: s.name,
        amount: payMap[String(s.id)]?.amount ?? rateMap[String(s.id)] ?? "0",
        paidAmount: payMap[String(s.id)]?.paidAmount ?? "0",
        notes: payMap[String(s.id)]?.notes ?? "",
        dirty: false,
      })));
    } else if (selectedScheduleId != null) {
      const [persons, payments, rates] = await Promise.all([
        fetchFinancePersons(selectedScheduleId, type, forPeriod),
        fetchFinancePayments(selectedScheduleId, type, forPeriod),
        fetchFinanceRates(selectedScheduleId, type),
      ]);
      const payMap: Record<string, FinancePayment> = {};
      for (const p of payments) payMap[p.personId] = p;
      const rateMap: Record<string, string> = {};
      for (const r of rates) rateMap[r.personId] = String(r.amount);
      setter(persons.map(p => ({
        personId: p.personId, personName: p.personName,
        amount: String(payMap[p.personId]?.amount ?? rateMap[p.personId] ?? "0"),
        paidAmount: String(payMap[p.personId]?.paidAmount ?? "0"),
        notes: payMap[p.personId]?.notes ?? "",
        dirty: false,
      })));
    }
  }, [selectedScheduleId]);

  useEffect(() => {
    if (!finUser || !period) return;
    if (activeTab === "students") loadPayRows("student", setStudentRows, period);
    if (activeTab === "faculty") loadPayRows("faculty", setFacultyRows, period);
    if (activeTab === "staff") loadPayRows("staff", setStaffPayRows, period);
  }, [activeTab, period, selectedScheduleId, finUser, loadPayRows]);

  // ── Save all ───────────────────────────────────────────────────────────
  async function handleSaveAll(type: "student" | "faculty" | "staff") {
    const rows = type === "student" ? studentRows : type === "faculty" ? facultyRows : staffPayRows;
    const dirty = rows.filter(r => r.dirty);
    if (!dirty.length) { Alert.alert("No Changes", "No changes to save."); return; }
    setSaving(true);
    await saveFinancePaymentsBulk(dirty.map(r => ({
      personType: type,
      personId: r.personId,
      personName: r.personName,
      scheduleId: type !== "staff" ? (selectedScheduleId ?? null) : null,
      period,
      amount: r.amount,
      paidAmount: r.paidAmount,
      notes: r.notes,
    } as unknown as Partial<FinancePayment>)));
    setSaving(false);
    const setter = type === "student" ? setStudentRows : type === "faculty" ? setFacultyRows : setStaffPayRows;
    await loadPayRows(type, setter, period);
    refetchSummary();
    Alert.alert("Saved", `${dirty.length} record(s) updated.`);
  }

  function updateRow(type: "student" | "faculty" | "staff", idx: number, field: "amount" | "paidAmount" | "notes", val: string) {
    const setter = type === "student" ? setStudentRows : type === "faculty" ? setFacultyRows : setStaffPayRows;
    setter(prev => prev.map((r, i) => i === idx ? { ...r, [field]: val, dirty: true } : r));
  }

  // ── Staff upload ───────────────────────────────────────────────────────
  async function handleBulkStaff() {
    try {
      const result = await DocumentPicker.getDocumentAsync({
        type: ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.ms-excel", "*/*"],
        copyToCacheDirectory: true,
      });
      if (result.canceled || !result.assets?.length) return;
      const asset = result.assets[0];
      setBulkLoading(true);
      const res = await importStaffExcel(asset.uri, asset.name, asset.mimeType ?? "application/octet-stream");
      setBulkLoading(false);
      if (res.success) {
        Alert.alert("Import Complete", `${res.inserted ?? 0} staff added, ${res.skipped ?? 0} skipped.`);
        qc.invalidateQueries({ queryKey: ["supportStaff"] });
        loadPayRows("staff", setStaffPayRows, period);
      } else { setErrorMsg(res.error ?? "Import failed"); }
    } catch { setBulkLoading(false); setErrorMsg("Could not pick file"); }
  }

  async function handleAddStaff() {
    if (!newEmpId.trim() || !newName.trim()) { setErrorMsg("Employee ID and Name required"); return; }
    setAddingStaff(true);
    const res = await addSupportStaff(newEmpId.trim(), newName.trim(), newDesg.trim(), newDept.trim());
    setAddingStaff(false);
    if (res.success) {
      setNewEmpId(""); setNewName(""); setNewDesg(""); setNewDept("");
      loadPayRows("staff", setStaffPayRows, period);
    } else { setErrorMsg(res.error ?? "Could not add staff"); }
  }

  async function handleDeleteStaff(staff: SupportStaff) {
    await deleteSupportStaff(staff.id);
    setDeleteTarget(null);
    loadPayRows("staff", setStaffPayRows, period);
  }

  async function handleLookup() {
    if (!lookupReg.trim()) return;
    setLookupLoading(true); setLookupResult(null);
    const result = await fetchStudentFeeStatus(lookupReg.trim());
    setLookupLoading(false); setLookupResult(result);
  }

  // ── Rates modal handlers ────────────────────────────────────────────────
  async function openRatesModal(type: "student" | "faculty" | "staff") {
    setRatesLoading(true);
    setShowRatesModal(type);
    try {
      const schId = type !== "staff" ? selectedScheduleId : null;
      const [rates, persons] = await Promise.all([
        fetchFinanceRates(type, schId),
        type === "staff"
          ? fetchSupportStaff().then(s => s.map(st => ({ personId: st.employeeId, personName: st.name })))
          : selectedScheduleId != null
            ? fetchFinancePersons(selectedScheduleId ?? 0, type, period)
            : Promise.resolve([]),
      ]);
      const rateMap: Record<string, string> = {};
      for (const r of rates) rateMap[r.personId] = r.rate;
      setRateRows(persons.map(p => ({
        personId: p.personId, personName: p.personName,
        rate: rateMap[p.personId] ?? "0",
        dirty: false,
      })));
    } finally {
      setRatesLoading(false);
    }
  }

  async function handleSaveRates(type: "student" | "faculty" | "staff") {
    const dirty = rateRows.filter(r => r.dirty);
    if (!dirty.length) { Alert.alert("No Changes", "No rate changes to save."); return; }
    setSavingRates(true);
    const schId = type !== "staff" ? selectedScheduleId : null;
    await saveFinanceRatesBulk(dirty.map(r => ({
      personType: type, personId: r.personId, scheduleId: schId, rate: Number(r.rate),
    })));
    setSavingRates(false);
    setShowRatesModal(null);
    const setter = type === "student" ? setStudentRows : type === "faculty" ? setFacultyRows : setStaffPayRows;
    await loadPayRows(type, setter, period);
    Alert.alert("Rates Saved", `${dirty.length} rate(s) updated. Amounts refreshed for this period.`);
  }

  async function handleBulkRates(type: "student" | "faculty" | "staff") {
    try {
      const result = await DocumentPicker.getDocumentAsync({
        type: ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.ms-excel", "*/*"],
        copyToCacheDirectory: true,
      });
      if (result.canceled || !result.assets?.length) return;
      const asset = result.assets[0];
      setRatesBulkLoading(true);
      const schId = type !== "staff" ? selectedScheduleId : null;
      const res = await importRatesExcel(asset.uri, asset.name, asset.mimeType ?? "application/octet-stream", type, schId);
      setRatesBulkLoading(false);
      if (res.success) {
        Alert.alert("Rates Imported", `${res.saved ?? 0} rate(s) saved, ${res.skipped ?? 0} skipped.`);
        const setter = type === "student" ? setStudentRows : type === "faculty" ? setFacultyRows : setStaffPayRows;
        await loadPayRows(type, setter, period);
        if (showRatesModal === type) openRatesModal(type);
      } else { setErrorMsg(res.error ?? "Import failed"); }
    } catch { setRatesBulkLoading(false); setErrorMsg("Could not pick file"); }
  }

  // ── Styles ─────────────────────────────────────────────────────────────
  const s = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    header: {
      backgroundColor: "#1565C0",
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
    // Login
    loginCard: { margin: 20, backgroundColor: colors.card, borderRadius: 16, padding: 24, borderWidth: 1, borderColor: colors.border },
    loginTitle: { fontSize: 20, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 4 },
    loginSub: { fontSize: 13, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginBottom: 20 },
    input: {
      backgroundColor: colors.muted, borderRadius: 10, borderWidth: 1, borderColor: colors.border,
      paddingHorizontal: 14, paddingVertical: 12,
      fontFamily: "Inter_400Regular", fontSize: 14, color: colors.foreground, marginBottom: 12,
    },
    loginBtn: { backgroundColor: "#1565C0", borderRadius: 10, paddingVertical: 13, alignItems: "center", marginTop: 4 },
    loginBtnTxt: { color: "#fff", fontSize: 15, fontFamily: "Inter_700Bold" },
    switchRow: { flexDirection: "row", justifyContent: "center", marginTop: 14, gap: 4 },
    switchTxt: { fontSize: 13, fontFamily: "Inter_400Regular", color: colors.mutedForeground },
    switchLink: { fontSize: 13, fontFamily: "Inter_700Bold", color: "#00695C" },
    // Tabs
    tabRow: { flexDirection: "row", backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border },
    tab: { flex: 1, paddingVertical: 10, alignItems: "center" },
    tabActive: { borderBottomWidth: 2, borderBottomColor: "#00695C" },
    tabTxt: { fontFamily: "Inter_500Medium", fontSize: 11, color: colors.mutedForeground },
    tabTxtActive: { color: "#00695C", fontFamily: "Inter_700Bold" },
    // Period picker
    periodBox: { backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border },
    periodRow: { flexDirection: "row", gap: 8, paddingHorizontal: 10, paddingVertical: 8, alignItems: "center" },
    semBtn: {
      flex: 1, flexDirection: "row", alignItems: "center", gap: 6,
      backgroundColor: colors.muted, borderRadius: 8, borderWidth: 1, borderColor: "#00695C",
      paddingHorizontal: 10, paddingVertical: 8,
    },
    semBtnTxt: { flex: 1, fontSize: 13, fontFamily: "Inter_600SemiBold", color: "#00695C" },
    modeToggle: { flexDirection: "row", borderRadius: 8, borderWidth: 1, borderColor: "#00695C", overflow: "hidden" },
    modeBtn: { paddingHorizontal: 14, paddingVertical: 8, backgroundColor: colors.muted },
    modeBtnActive: { backgroundColor: "#1565C0" },
    modeBtnTxt: { fontSize: 12, fontFamily: "Inter_600SemiBold", color: "#00695C" },
    modeBtnTxtActive: { color: "#fff" },
    monthChipsRow: { paddingHorizontal: 10, paddingBottom: 8, gap: 6 },
    monthChip: { paddingHorizontal: 12, paddingVertical: 6, borderRadius: 20, borderWidth: 1, borderColor: colors.border, backgroundColor: colors.muted },
    monthChipActive: { backgroundColor: "#1565C0", borderColor: "#00695C" },
    monthChipTxt: { fontSize: 12, fontFamily: "Inter_500Medium", color: colors.foreground },
    monthChipTxtActive: { color: "#fff", fontFamily: "Inter_700Bold" },
    scheduleBtn: {
      flexDirection: "row", alignItems: "center", gap: 6, flex: 1.2,
      backgroundColor: colors.muted, borderRadius: 8, borderWidth: 1, borderColor: colors.border,
      paddingHorizontal: 10, paddingVertical: 8,
    },
    scheduleBtnTxt: { fontSize: 12, fontFamily: "Inter_400Regular", color: colors.foreground, flex: 1 },
    // Summary
    summaryGrid: { flexDirection: "row", flexWrap: "wrap", gap: 12, padding: 14 },
    summaryCard: { flex: 1, minWidth: "44%", borderRadius: 14, padding: 14, borderWidth: 1, borderColor: colors.border, backgroundColor: colors.card },
    summaryCardTitle: { fontSize: 11, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground, marginBottom: 6, textTransform: "uppercase" },
    summaryBig: { fontSize: 22, fontFamily: "Inter_700Bold", color: "#00695C" },
    summaryLabel: { fontSize: 11, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginTop: 2 },
    summaryRow: { flexDirection: "row", justifyContent: "space-between", marginTop: 4 },
    // Payment table
    tableHead: { flexDirection: "row", backgroundColor: "#1565C0", paddingHorizontal: 8, paddingVertical: 7 },
    thNum: { width: 28, fontSize: 10, fontFamily: "Inter_700Bold", color: "#fff" },
    thName: { flex: 1, fontSize: 10, fontFamily: "Inter_700Bold", color: "#fff" },
    thAmt: { width: 68, fontSize: 10, fontFamily: "Inter_700Bold", color: "#fff", textAlign: "center" },
    thBal: { width: 62, fontSize: 10, fontFamily: "Inter_700Bold", color: "#fff", textAlign: "center" },
    thSt: { width: 56, fontSize: 10, fontFamily: "Inter_700Bold", color: "#fff", textAlign: "center" },
    tableRow: { flexDirection: "row", alignItems: "center", paddingHorizontal: 8, paddingVertical: 6, borderBottomWidth: 1, borderBottomColor: colors.border },
    tdNum: { width: 28, fontSize: 11, fontFamily: "Inter_400Regular", color: colors.mutedForeground },
    tdName: { flex: 1 },
    tdNameTxt: { fontSize: 12, fontFamily: "Inter_500Medium", color: colors.foreground },
    tdIdTxt: { fontSize: 10, fontFamily: "Inter_400Regular", color: colors.mutedForeground },
    tdInput: {
      width: 68, borderRadius: 6, borderWidth: 1, borderColor: colors.border,
      backgroundColor: colors.muted, paddingHorizontal: 4, paddingVertical: 4,
      fontFamily: "Inter_400Regular", fontSize: 12, color: colors.foreground, textAlign: "center",
    },
    tdBal: { width: 62, fontSize: 12, fontFamily: "Inter_700Bold", textAlign: "center" },
    statusBadge: { width: 56, borderRadius: 8, paddingVertical: 3, alignItems: "center" },
    statusBadgeTxt: { fontSize: 9, fontFamily: "Inter_700Bold" },
    saveAllBtn: {
      margin: 12, backgroundColor: "#1565C0", borderRadius: 10,
      paddingVertical: 12, alignItems: "center", flexDirection: "row", justifyContent: "center", gap: 8,
    },
    saveAllBtnTxt: { color: "#fff", fontFamily: "Inter_700Bold", fontSize: 14 },
    // Staff
    addRow: { flexDirection: "row", gap: 6, padding: 10, backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border, flexWrap: "wrap" },
    addInput: {
      backgroundColor: colors.muted, borderWidth: 1, borderColor: colors.border,
      borderRadius: 8, paddingHorizontal: 10, paddingVertical: 8,
      fontFamily: "Inter_400Regular", fontSize: 12, color: colors.foreground,
    },
    addBtn: { backgroundColor: "#1565C0", borderRadius: 8, paddingHorizontal: 14, alignItems: "center", justifyContent: "center", paddingVertical: 8 },
    bulkRow: { flexDirection: "row", gap: 8, padding: 10, backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border, alignItems: "center" },
    bulkBtn: { flex: 1, flexDirection: "row", alignItems: "center", gap: 6, backgroundColor: colors.muted, borderRadius: 8, paddingHorizontal: 12, paddingVertical: 9, borderWidth: 1, borderColor: colors.border },
    bulkBtnTxt: { fontFamily: "Inter_500Medium", fontSize: 13, color: colors.foreground },
    sampleBtn: { flexDirection: "row", alignItems: "center", gap: 5, borderRadius: 8, paddingHorizontal: 10, paddingVertical: 9, borderWidth: 1, borderColor: "#00695C" },
    sampleBtnTxt: { fontFamily: "Inter_500Medium", fontSize: 12, color: "#00695C" },
    // Rates toolbar
    ratesBar: { flexDirection: "row", gap: 6, paddingHorizontal: 10, paddingVertical: 7, backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border },
    ratesBarBtn: { flexDirection: "row", alignItems: "center", gap: 5, borderRadius: 7, paddingHorizontal: 10, paddingVertical: 7, borderWidth: 1 },
    ratesBarBtnTxt: { fontSize: 12, fontFamily: "Inter_500Medium" },
    // Public lookup
    lookupRow: { flexDirection: "row", gap: 8, padding: 12, backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border },
    lookupInput: { flex: 1, backgroundColor: colors.muted, borderRadius: 8, borderWidth: 1, borderColor: colors.border, paddingHorizontal: 12, paddingVertical: 9, fontFamily: "Inter_400Regular", fontSize: 14, color: colors.foreground },
    lookupBtn: { backgroundColor: "#1565C0", borderRadius: 8, paddingHorizontal: 16, justifyContent: "center" },
    lookupBtnTxt: { color: "#fff", fontFamily: "Inter_700Bold", fontSize: 14 },
    noData: { alignItems: "center", marginTop: 60, paddingHorizontal: 32 },
    noDataTxt: { fontSize: 14, fontFamily: "Inter_400Regular", color: colors.mutedForeground, textAlign: "center", marginTop: 10 },
  });

  // ── Rates toolbar ──────────────────────────────────────────────────────
  function renderRatesBar(type: "student" | "faculty" | "staff") {
    const label = type === "student" ? "Student" : type === "faculty" ? "Faculty" : "Staff";
    const rateLabel = type === "student" ? "Fee" : "Pay";
    return (
      <View style={s.ratesBar}>
        <TouchableOpacity
          style={[s.ratesBarBtn, { backgroundColor: "#1565C0", borderColor: "#1565C0" }]}
          onPress={() => {
            setPersonMgmtType(type as "student"|"faculty"|"staff");
            setPersonMgmtMsg(""); setNewPersonName(""); setNewPersonEmail("");
            setShowPersonMgmt(true);
          }}
        >
          <Feather name="users" size={13} color="#fff" />
          <Text style={[s.ratesBarBtnTxt, { color: "#fff" }]}>Manage</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[s.ratesBarBtn, { backgroundColor: "#E0F2F1", borderColor: "#00695C" }]}
          onPress={() => openRatesModal(type)}
        >
          <Feather name="sliders" size={13} color="#00695C" />
          <Text style={[s.ratesBarBtnTxt, { color: "#00695C" }]}>Set {label} {rateLabel}s</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[s.ratesBarBtn, { backgroundColor: colors.muted, borderColor: colors.border, flex: 1 }]}
          onPress={() => handleBulkRates(type)}
          disabled={ratesBulkLoading}
        >
          {ratesBulkLoading
            ? <ActivityIndicator color="#00695C" size="small" />
            : <><Feather name="upload" size={13} color={colors.foreground} /><Text style={[s.ratesBarBtnTxt, { color: colors.foreground }]}>Bulk Upload Rates</Text></>}
        </TouchableOpacity>
        <TouchableOpacity
          style={[s.ratesBarBtn, { borderColor: "#00695C" }]}
          onPress={() => {
            const typeParam = type === "student" ? "student" : type === "faculty" ? "faculty" : "staff";
            Linking.openURL(`https://${process.env.EXPO_PUBLIC_DOMAIN}/api/finance/rates/sample?personType=${typeParam}&scheduleId=${selectedScheduleId ?? ""}`);
          }}
        >
          <Feather name="download" size={13} color="#00695C" />
          <Text style={[s.ratesBarBtnTxt, { color: "#00695C" }]}>Template</Text>
        </TouchableOpacity>
      </View>
    );
  }

  // ── Period picker UI ───────────────────────────────────────────────────
  function renderPeriodPicker(showModeToggle: boolean) {
    // show month chips for: faculty, staff (always monthly), students in month mode
    const showMonthChips = !showModeToggle || studentPeriodMode === "month";
    const displayPeriod = showModeToggle && studentPeriodMode === "semester"
      ? selectedSem.label
      : `${monthLabel(selectedMonth)} ${selectedMonth.split("-")[0]}`;

    return (
      <View style={s.periodBox}>
        <View style={s.periodRow}>
          {/* Semester selector */}
          <TouchableOpacity style={s.semBtn} onPress={() => setShowSemPicker(true)}>
            <Feather name="calendar" size={14} color="#00695C" />
            <Text style={s.semBtnTxt}>{selectedSem.label}</Text>
            <Feather name="chevron-down" size={14} color="#00695C" />
          </TouchableOpacity>

          {/* Mode toggle — students only */}
          {showModeToggle && (
            <View style={s.modeToggle}>
              <TouchableOpacity
                style={[s.modeBtn, studentPeriodMode === "semester" && s.modeBtnActive]}
                onPress={() => setStudentPeriodMode("semester")}
              >
                <Text style={[s.modeBtnTxt, studentPeriodMode === "semester" && s.modeBtnTxtActive]}>Sem</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[s.modeBtn, studentPeriodMode === "month" && s.modeBtnActive]}
                onPress={() => setStudentPeriodMode("month")}
              >
                <Text style={[s.modeBtnTxt, studentPeriodMode === "month" && s.modeBtnTxtActive]}>Month</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>

        {/* Active period display */}
        <View style={{ paddingHorizontal: 10, paddingBottom: 4 }}>
          <Text style={{ fontSize: 11, fontFamily: "Inter_400Regular", color: colors.mutedForeground }}>
            Period: <Text style={{ fontFamily: "Inter_700Bold", color: "#00695C" }}>{displayPeriod}</Text>
            {showModeToggle && studentPeriodMode === "semester" && (
              <Text style={{ color: colors.mutedForeground }}>{"  (full semester)"}</Text>
            )}
          </Text>
        </View>

        {/* Month chips — shown when not in semester mode */}
        {showMonthChips && (
          <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={s.monthChipsRow}>
            {selectedSem.months.map(m => (
              <TouchableOpacity
                key={m}
                style={[s.monthChip, selectedMonth === m && s.monthChipActive]}
                onPress={() => setSelectedMonth(m)}
              >
                <Text style={[s.monthChipTxt, selectedMonth === m && s.monthChipTxtActive]}>
                  {monthLabel(m)}
                </Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
        )}
      </View>
    );
  }

  // ── Payment table ──────────────────────────────────────────────────────
  function renderPayTable(rows: PayRow[], type: "student" | "faculty" | "staff") {
    if (type !== "staff" && selectedScheduleId == null) {
      return (
        <View style={s.noData}>
          <Feather name="briefcase" size={40} color={colors.mutedForeground} />
          <Text style={s.noDataTxt}>Select a schedule above to load persons.</Text>
        </View>
      );
    }
    if (rows.length === 0) {
      return (
        <View style={s.noData}>
          <Feather name="users" size={40} color={colors.mutedForeground} />
          <Text style={s.noDataTxt}>
            {type === "staff" ? "No support staff yet. Add them below." : "No persons found for this schedule."}
          </Text>
        </View>
      );
    }
    const totalDue = rows.reduce((sum, r) => sum + Number(r.amount), 0);
    const totalPaid = rows.reduce((sum, r) => sum + Number(r.paidAmount), 0);
    const totalBal = totalDue - totalPaid;
    return (
      <View style={{ flex: 1 }}>
        <View style={{ flexDirection: "row", gap: 10, padding: 10, backgroundColor: "#E0F2F1" }}>
          <View style={{ flex: 1 }}>
            <Text style={{ fontSize: 10, fontFamily: "Inter_400Regular", color: "#00695C" }}>Total Due</Text>
            <Text style={{ fontSize: 15, fontFamily: "Inter_700Bold", color: "#00695C" }}>Rs {fmt(totalDue)}</Text>
          </View>
          <View style={{ flex: 1 }}>
            <Text style={{ fontSize: 10, fontFamily: "Inter_400Regular", color: "#2E7D32" }}>Total Paid</Text>
            <Text style={{ fontSize: 15, fontFamily: "Inter_700Bold", color: "#2E7D32" }}>Rs {fmt(totalPaid)}</Text>
          </View>
          <View style={{ flex: 1 }}>
            <Text style={{ fontSize: 10, fontFamily: "Inter_400Regular", color: totalBal > 0 ? "#C62828" : "#9E9E9E" }}>Balance</Text>
            <Text style={{ fontSize: 15, fontFamily: "Inter_700Bold", color: totalBal > 0 ? "#C62828" : "#9E9E9E" }}>Rs {fmt(totalBal)}</Text>
          </View>
        </View>
        <ScrollView contentContainerStyle={{ paddingBottom: 80 }}>
          <View style={s.tableHead}>
            <Text style={s.thNum}>#</Text>
            <Text style={s.thName}>Name / ID</Text>
            <Text style={s.thAmt}>Due (Rs)</Text>
            <Text style={s.thAmt}>Paid (Rs)</Text>
            <Text style={s.thBal}>Balance</Text>
            <Text style={s.thSt}>Status</Text>
            {type === "staff" && <Text style={{ width: 30 }} />}
          </View>
          {rows.map((row, i) => {
            const balance = Number(row.amount) - Number(row.paidAmount);
            const status = payStatus(row.amount, row.paidAmount);
            return (
              <View key={row.personId} style={[s.tableRow, { backgroundColor: i % 2 === 0 ? colors.card : colors.muted }]}>
                <Text style={s.tdNum}>{i + 1}</Text>
                <View style={s.tdName}>
                  <Text style={s.tdNameTxt} numberOfLines={1}>{row.personName}</Text>
                  <Text style={s.tdIdTxt} numberOfLines={1}>{row.personId}</Text>
                </View>
                <TextInput
                  style={[s.tdInput, { borderColor: "#00695C" }]}
                  value={row.amount}
                  onChangeText={v => updateRow(type, i, "amount", v.replace(/[^0-9.]/g, ""))}
                  keyboardType="numeric"
                  maxLength={8}
                />
                <TextInput
                  style={[s.tdInput, { borderColor: "#2E7D32" }]}
                  value={row.paidAmount}
                  onChangeText={v => updateRow(type, i, "paidAmount", v.replace(/[^0-9.]/g, ""))}
                  keyboardType="numeric"
                  maxLength={8}
                />
                <Text style={[s.tdBal, { color: balance > 0 ? "#C62828" : "#9E9E9E" }]}>
                  {balance > 0 ? `Rs ${fmt(balance)}` : "–"}
                </Text>
                <View style={[s.statusBadge, { backgroundColor: STATUS_BG[status] }]}>
                  <Text style={[s.statusBadgeTxt, { color: STATUS_COLOR[status] }]}>{status}</Text>
                </View>
                {type === "staff" && (
                  <TouchableOpacity
                    style={{ width: 30, alignItems: "center" }}
                    onPress={() => setDeleteTarget({ id: 0, employeeId: row.personId, name: row.personName, designation: "", department: "" })}
                  >
                    <Feather name="trash-2" size={14} color={colors.destructive} />
                  </TouchableOpacity>
                )}
              </View>
            );
          })}
        </ScrollView>
        <TouchableOpacity style={s.saveAllBtn} onPress={() => handleSaveAll(type)} disabled={saving}>
          {saving
            ? <ActivityIndicator color="#fff" size="small" />
            : <><Feather name="save" size={16} color="#fff" /><Text style={s.saveAllBtnTxt}>Save All Changes</Text></>
          }
        </TouchableOpacity>
      </View>
    );
  }

  // ── Summary tab ────────────────────────────────────────────────────────
  function renderSummary() {
    if (summaryLoading) return <ActivityIndicator color="#00695C" style={{ marginTop: 40 }} size="large" />;
    const overall = summary?.overall ?? { totalDue: 0, totalPaid: 0, count: 0, paid: 0, partial: 0, unpaid: 0 };
    const byType = summary?.byType ?? {};
    const balance = overall.totalDue - overall.totalPaid;
    const catLabels: Record<string, string> = { student: "Students", faculty: "Faculty", staff: "Support Staff" };
    const catColors: Record<string, string> = { student: "#1565C0", faculty: "#6A1B9A", staff: "#00695C" };

    const periodDisplay = studentPeriodMode === "semester"
      ? selectedSem.label
      : `${monthLabel(selectedMonth)} ${selectedMonth.split("-")[0]}`;

    return (
      <ScrollView contentContainerStyle={{ paddingBottom: 30 }}>
        <View style={{ paddingHorizontal: 14, paddingTop: 12, paddingBottom: 4 }}>
          <Text style={{ fontSize: 12, fontFamily: "Inter_600SemiBold", color: colors.mutedForeground, textTransform: "uppercase", letterSpacing: 0.5 }}>
            Period · {periodDisplay}
          </Text>
        </View>
        <View style={{ marginHorizontal: 14, backgroundColor: "#1565C0", borderRadius: 16, padding: 18, marginBottom: 16 }}>
          <Text style={{ fontSize: 12, fontFamily: "Inter_600SemiBold", color: "rgba(255,255,255,0.7)", textTransform: "uppercase", marginBottom: 4 }}>Overall</Text>
          <Text style={{ fontSize: 28, fontFamily: "Inter_700Bold", color: "#fff" }}>Rs {fmt(overall.totalPaid)}</Text>
          <Text style={{ fontSize: 13, fontFamily: "Inter_400Regular", color: "rgba(255,255,255,0.8)", marginTop: 2 }}>collected of Rs {fmt(overall.totalDue)} due</Text>
          <View style={{ flexDirection: "row", gap: 8, marginTop: 12 }}>
            {[
              { label: "Balance", value: `Rs ${fmt(balance)}`, c: "#A5D6A7" },
              { label: "✓ Paid", value: String(overall.paid), c: "#A5D6A7" },
              { label: "⚠ Partial", value: String(overall.partial), c: "#FFCC80" },
              { label: "✗ Unpaid", value: String(overall.unpaid), c: "#EF9A9A" },
            ].map(item => (
              <View key={item.label} style={{ flex: 1, backgroundColor: "rgba(255,255,255,0.15)", borderRadius: 10, padding: 8 }}>
                <Text style={{ color: item.c, fontSize: 9, fontFamily: "Inter_400Regular" }}>{item.label}</Text>
                <Text style={{ color: "#fff", fontSize: 13, fontFamily: "Inter_700Bold" }}>{item.value}</Text>
              </View>
            ))}
          </View>
        </View>
        <View style={s.summaryGrid}>
          {["student", "faculty", "staff"].map(type => {
            const d = byType[type] ?? { totalDue: 0, totalPaid: 0, count: 0, paid: 0, partial: 0, unpaid: 0 };
            const bal = d.totalDue - d.totalPaid;
            const c = catColors[type];
            return (
              <View key={type} style={[s.summaryCard, { borderColor: c + "44" }]}>
                <Text style={[s.summaryCardTitle, { color: c }]}>{catLabels[type]}</Text>
                <Text style={[s.summaryBig, { color: c }]}>Rs {fmt(d.totalPaid)}</Text>
                <Text style={s.summaryLabel}>of Rs {fmt(d.totalDue)}</Text>
                <View style={{ height: 1, backgroundColor: colors.border, marginVertical: 8 }} />
                <View style={s.summaryRow}>
                  <Text style={{ fontSize: 11, fontFamily: "Inter_400Regular", color: colors.mutedForeground }}>Balance</Text>
                  <Text style={{ fontSize: 12, fontFamily: "Inter_700Bold", color: bal > 0 ? "#C62828" : "#9E9E9E" }}>Rs {fmt(bal)}</Text>
                </View>
                <View style={s.summaryRow}>
                  <Text style={{ fontSize: 11, color: "#2E7D32", fontFamily: "Inter_400Regular" }}>✓ {d.paid} paid</Text>
                  <Text style={{ fontSize: 11, color: "#C62828", fontFamily: "Inter_400Regular" }}>✗ {d.unpaid} unpaid</Text>
                </View>
                {d.partial > 0 && <Text style={{ fontSize: 10, color: "#E65100", fontFamily: "Inter_400Regular", marginTop: 2 }}>⚠ {d.partial} partial</Text>}
              </View>
            );
          })}
        </View>
      </ScrollView>
    );
  }

  // ── Staff tab ──────────────────────────────────────────────────────────
  function renderStaffTab() {
    return (
      <View style={{ flex: 1 }}>
        <View style={s.addRow}>
          <TextInput style={[s.addInput, { width: "28%" }]} placeholder="Emp ID" placeholderTextColor={colors.mutedForeground} value={newEmpId} onChangeText={setNewEmpId} />
          <TextInput style={[s.addInput, { flex: 1 }]} placeholder="Full Name" placeholderTextColor={colors.mutedForeground} value={newName} onChangeText={setNewName} />
          <TextInput style={[s.addInput, { width: "28%" }]} placeholder="Designation" placeholderTextColor={colors.mutedForeground} value={newDesg} onChangeText={setNewDesg} />
          <TextInput style={[s.addInput, { width: "28%" }]} placeholder="Department" placeholderTextColor={colors.mutedForeground} value={newDept} onChangeText={setNewDept} />
          <TouchableOpacity style={s.addBtn} onPress={handleAddStaff} disabled={addingStaff}>
            {addingStaff ? <ActivityIndicator color="#fff" size="small" /> : <Feather name="user-plus" size={18} color="#fff" />}
          </TouchableOpacity>
        </View>
        <View style={s.bulkRow}>
          <TouchableOpacity style={s.bulkBtn} onPress={handleBulkStaff} disabled={bulkLoading}>
            {bulkLoading ? <ActivityIndicator color="#00695C" size="small" /> : <><Feather name="upload" size={15} color="#00695C" /><Text style={s.bulkBtnTxt}>  Bulk Upload Staff (Excel)</Text></>}
          </TouchableOpacity>
          <TouchableOpacity style={s.sampleBtn} onPress={() => Linking.openURL(`https://${process.env.EXPO_PUBLIC_DOMAIN}/api/finance/staff/sample?scheduleId=${selectedScheduleId ?? ""}`)}>
            <Feather name="download" size={13} color="#00695C" />
            <Text style={s.sampleBtnTxt}>Template</Text>
          </TouchableOpacity>
        </View>
        {renderRatesBar("staff")}
        <View style={{ flexDirection: "row", gap: 8, paddingHorizontal: 10, paddingVertical: 6, backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border }}>
          <Text style={{ fontSize: 12, fontFamily: "Inter_400Regular", color: colors.mutedForeground }}>
            {staffList.length} staff members · Enter amounts and tap Save All
          </Text>
        </View>
        {renderPayTable(staffPayRows, "staff")}
      </View>
    );
  }

  // ── Fee result (public) ────────────────────────────────────────────────
  function renderFeeResult() {
    if (!lookupResult) return null;
    if (!lookupResult.found) return (
      <View style={s.noData}>
        <Feather name="search" size={32} color={colors.mutedForeground} />
        <Text style={s.noDataTxt}>No fee records found for "{lookupReg}".</Text>
      </View>
    );
    const rows = lookupResult.rows ?? [];
    const totalDue = rows.reduce((sum, r) => sum + r.due, 0);
    const totalPaid = rows.reduce((sum, r) => sum + r.paid, 0);
    const balance = totalDue - totalPaid;
    return (
      <View style={{ backgroundColor: colors.card, borderRadius: 14, borderWidth: 1, borderColor: colors.border, overflow: "hidden", marginTop: 8 }}>
        <View style={{ backgroundColor: "#1565C0", padding: 14 }}>
          <Text style={{ color: "#fff", fontSize: 16, fontFamily: "Inter_700Bold" }}>{lookupResult.personName}</Text>
          <Text style={{ color: "rgba(255,255,255,0.8)", fontSize: 12, fontFamily: "Inter_400Regular", marginTop: 2 }}>{lookupResult.rollNo}</Text>
        </View>
        <View style={{ flexDirection: "row", padding: 12, gap: 8 }}>
          {[
            { label: "Total Due", value: `Rs ${fmt(totalDue)}`, c: "#00695C" },
            { label: "Paid", value: `Rs ${fmt(totalPaid)}`, c: "#2E7D32" },
            { label: "Balance", value: `Rs ${fmt(balance)}`, c: balance > 0 ? "#C62828" : "#9E9E9E" },
          ].map(item => (
            <View key={item.label} style={{ flex: 1, alignItems: "center" }}>
              <Text style={{ fontSize: 10, color: colors.mutedForeground, fontFamily: "Inter_400Regular" }}>{item.label}</Text>
              <Text style={{ fontSize: 14, fontFamily: "Inter_700Bold", color: item.c }}>{item.value}</Text>
            </View>
          ))}
        </View>
        {rows.map((r, i) => (
          <View key={i} style={{ flexDirection: "row", alignItems: "center", paddingHorizontal: 14, paddingVertical: 10, borderTopWidth: 1, borderTopColor: colors.border, backgroundColor: i % 2 === 0 ? colors.muted : colors.card }}>
            <Text style={{ flex: 1, fontFamily: "Inter_600SemiBold", fontSize: 13, color: colors.foreground }}>{r.period}</Text>
            <Text style={{ width: 72, textAlign: "right", fontFamily: "Inter_400Regular", fontSize: 12, color: colors.foreground }}>Rs {fmt(r.due)}</Text>
            <Text style={{ width: 72, textAlign: "right", fontFamily: "Inter_400Regular", fontSize: 12, color: "#2E7D32" }}>Rs {fmt(r.paid)}</Text>
            <View style={[s.statusBadge, { backgroundColor: STATUS_BG[r.status], width: 60, marginLeft: 6 }]}>
              <Text style={[s.statusBadgeTxt, { color: STATUS_COLOR[r.status] }]}>{r.status}</Text>
            </View>
          </View>
        ))}
      </View>
    );
  }

  function renderErrorModal() {
    if (!errorMsg) return null;
    return (
      <Modal visible transparent animationType="fade">
        <View style={{ flex: 1, justifyContent: "center", alignItems: "center", backgroundColor: "rgba(0,0,0,0.45)", padding: 32 }}>
          <View style={{ backgroundColor: colors.card, borderRadius: 16, padding: 24, width: "100%", alignItems: "center" }}>
            <Feather name="alert-circle" size={32} color={colors.destructive} style={{ marginBottom: 10 }} />
            <Text style={{ fontSize: 15, fontFamily: "Inter_400Regular", color: colors.foreground, textAlign: "center", marginBottom: 20 }}>{errorMsg}</Text>
            <TouchableOpacity onPress={() => setErrorMsg("")} style={{ backgroundColor: "#1565C0", borderRadius: 10, paddingVertical: 11, paddingHorizontal: 32 }}>
              <Text style={{ color: "#fff", fontSize: 15, fontFamily: "Inter_700Bold" }}>OK</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    );
  }

  // ── Logged-out view ────────────────────────────────────────────────────
  if (!finUser) {
    return (
      <View style={s.container}>
        <View style={s.header}>
          <View style={s.headerRow}>
            <TouchableOpacity style={s.navBtn} onPress={() => router.back()}>
              <Feather name="chevron-left" size={14} color="#fff" />
              <Text style={s.navBtnTxt}>Home</Text>
            </TouchableOpacity>
          </View>
          <Text style={s.headerTitle}>Account & Finance</Text>
          <Text style={s.headerSub}>Fees · Salary · Payments</Text>
        </View>
        <ScrollView contentContainerStyle={{ paddingBottom: 30 }}>
          <View style={s.loginCard}>
            <Feather name="dollar-sign" size={32} color="#00695C" style={{ marginBottom: 10 }} />
            <Text style={s.loginTitle}>Finance Login</Text>
            <Text style={s.loginSub}>Enter your username and Finance PIN to access finance records.</Text>
            <TextInput style={s.input} placeholder="Username (My Schedules)" placeholderTextColor={colors.mutedForeground} value={loginUser} onChangeText={setLoginUser} autoCapitalize="none" />
            <TextInput style={s.input} placeholder="Finance PIN" placeholderTextColor={colors.mutedForeground} value={loginPin} onChangeText={setLoginPin} secureTextEntry />
            <View style={{ backgroundColor: "#E8F5E9", borderRadius: 8, padding: 10, marginBottom: 12, flexDirection: "row", alignItems: "flex-start", gap: 8 }}>
              <Feather name="info" size={14} color="#2E7D32" style={{ marginTop: 1 }} />
              <Text style={{ fontSize: 12, fontFamily: "Inter_400Regular", color: "#2E7D32", flex: 1 }}>Finance PIN is set by the schedule owner in My Schedules → Finance PIN button.</Text>
            </View>
            <TouchableOpacity style={s.loginBtn} onPress={handleLogin} disabled={loginLoading}>
              {loginLoading ? <ActivityIndicator color="#fff" size="small" /> : <Text style={s.loginBtnTxt}>Sign In to Finance</Text>}
            </TouchableOpacity>
          </View>

          {/* Public student fee lookup */}
          <View style={{ marginHorizontal: 20 }}>
            <Text style={{ fontSize: 14, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 10 }}>
              Student Fee Status (Public)
            </Text>
            <View style={s.lookupRow}>
              <TextInput
                style={s.lookupInput}
                placeholder="Enter your Reg No"
                placeholderTextColor={colors.mutedForeground}
                value={lookupReg}
                onChangeText={setLookupReg}
                autoCapitalize="characters"
                returnKeyType="search"
                onSubmitEditing={handleLookup}
              />
              <TouchableOpacity style={s.lookupBtn} onPress={handleLookup} disabled={lookupLoading}>
                {lookupLoading ? <ActivityIndicator color="#fff" size="small" /> : <Text style={s.lookupBtnTxt}>Check</Text>}
              </TouchableOpacity>
            </View>
            {lookupResult && renderFeeResult()}
          </View>
        </ScrollView>
        {renderErrorModal()}
      </View>
    );
  }

  // ── Semester picker modal ──────────────────────────────────────────────
  const selectedSched = schedules.find(sc => sc.id === selectedScheduleId);

  // ── Logged-in view ─────────────────────────────────────────────────────
  return (
    <View style={s.container}>
      <View style={s.header}>
        <View style={s.headerRow}>
          <TouchableOpacity style={s.navBtn} onPress={() => router.back()}>
            <Feather name="chevron-left" size={14} color="#fff" />
            <Text style={s.navBtnTxt}>Home</Text>
          </TouchableOpacity>
          <TouchableOpacity style={s.navBtn} onPress={handleLogout}>
            <Feather name="log-out" size={13} color="#fff" />
            <Text style={s.navBtnTxt}>Logout</Text>
          </TouchableOpacity>
        </View>
        <Text style={s.headerTitle}>Account & Finance</Text>
        <Text style={s.headerSub}>Logged in as {finUser}</Text>
      </View>

      {/* Period picker */}
      {renderPeriodPicker(activeTab === "students")}

      {/* Schedule picker row — students & faculty only */}
      {(activeTab === "students" || activeTab === "faculty") && (
        <View style={{ flexDirection: "row", gap: 8, paddingHorizontal: 10, paddingVertical: 8, backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border }}>
          <TouchableOpacity style={s.scheduleBtn} onPress={() => setShowSchedPicker(true)}>
            <Feather name="briefcase" size={13} color="#00695C" />
            <Text style={s.scheduleBtnTxt} numberOfLines={1}>
              {selectedSched ? selectedSched.name : "Select Schedule ▾"}
            </Text>
            <Feather name="chevron-down" size={13} color={colors.mutedForeground} />
          </TouchableOpacity>
        </View>
      )}

      {/* Tab bar */}
      <View style={s.tabRow}>
        {(([["summary", "Summary"], ["students", "Students"], ["faculty", "Faculty"], ["staff", "Staff"]] as [Tab, string][])).map(([key, label]) => (
          <TouchableOpacity key={key} style={[s.tab, activeTab === key && s.tabActive]} onPress={() => setActiveTab(key)}>
            <Text style={[s.tabTxt, activeTab === key && s.tabTxtActive]}>{label}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {activeTab === "summary" && renderSummary()}
      {activeTab === "students" && (
        <View style={{ flex: 1 }}>
          {renderRatesBar("student")}
          {renderPayTable(studentRows, "student")}
        </View>
      )}
      {activeTab === "faculty" && (
        <View style={{ flex: 1 }}>
          {renderRatesBar("faculty")}
          {renderPayTable(facultyRows, "faculty")}
        </View>
      )}
      {activeTab === "staff" && renderStaffTab()}

      {/* Semester picker modal */}
      <Modal visible={showSemPicker} transparent animationType="slide">
        <View style={{ flex: 1, justifyContent: "flex-end", backgroundColor: "rgba(0,0,0,0.5)" }}>
          <View style={{ backgroundColor: colors.card, borderTopLeftRadius: 20, borderTopRightRadius: 20, padding: 20, maxHeight: "70%" }}>
            <Text style={{ fontSize: 16, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 14 }}>Select Semester</Text>
            <ScrollView>
              {ALL_MONTHS.map(m => (
                <TouchableOpacity
                  key={m}
                  style={{
                    padding: 14, borderBottomWidth: 1, borderBottomColor: colors.border,
                    flexDirection: "row", alignItems: "center",
                    backgroundColor: selectedMonth === m ? "#E0F2F1" : colors.card,
                  }}
                  onPress={() => { setSelectedMonth(m); setShowSemPicker(false); }}
                >
                  <View style={{ flex: 1 }}>
                    <Text style={{ fontSize: 15, fontFamily: "Inter_600SemiBold", color: selectedMonth === m ? "#00695C" : colors.foreground }}>
                      {MONTH_NAMES[parseInt(m.split("-")[1])-1]} {m.split("-")[0]}
                    </Text>
                    <Text style={{ fontSize: 11, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginTop: 2 }}>
                      {m}
                    </Text>
                  </View>
                  {selectedMonth === m && <Feather name="check" size={18} color="#00695C" />}
                </TouchableOpacity>
              ))}
            </ScrollView>
            <TouchableOpacity
              style={{ backgroundColor: colors.muted, borderRadius: 10, paddingVertical: 12, alignItems: "center", marginTop: 10 }}
              onPress={() => setShowSemPicker(false)}
            >
              <Text style={{ fontSize: 14, fontFamily: "Inter_600SemiBold", color: colors.foreground }}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>

      {/* Schedule picker modal */}
      <Modal visible={showSchedPicker} transparent animationType="slide">
        <View style={{ flex: 1, justifyContent: "flex-end", backgroundColor: "rgba(0,0,0,0.5)" }}>
          <View style={{ backgroundColor: colors.card, borderTopLeftRadius: 20, borderTopRightRadius: 20, padding: 20, maxHeight: "60%" }}>
            <Text style={{ fontSize: 16, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 14 }}>Select Schedule</Text>
            <ScrollView>
              {schedules.length === 0 && (
                <Text style={{ fontSize: 14, color: colors.mutedForeground, fontFamily: "Inter_400Regular", textAlign: "center", marginVertical: 20 }}>
                  No schedules found. Log in to the main app first.
                </Text>
              )}
              {schedules.map(sch => (
                <TouchableOpacity
                  key={sch.id}
                  style={{ padding: 14, borderBottomWidth: 1, borderBottomColor: colors.border, flexDirection: "row", alignItems: "center" }}
                  onPress={() => { setSelectedScheduleId(sch.id); setShowSchedPicker(false); }}
                >
                  <Feather name="briefcase" size={16} color="#00695C" style={{ marginRight: 10 }} />
                  <Text style={{ fontSize: 14, fontFamily: "Inter_500Medium", color: colors.foreground, flex: 1 }}>{sch.name}</Text>
                  {selectedScheduleId === sch.id && <Feather name="check" size={16} color="#00695C" />}
                </TouchableOpacity>
              ))}
            </ScrollView>
            <TouchableOpacity
              style={{ backgroundColor: colors.muted, borderRadius: 10, paddingVertical: 12, alignItems: "center", marginTop: 10 }}
              onPress={() => setShowSchedPicker(false)}
            >
              <Text style={{ fontSize: 14, fontFamily: "Inter_600SemiBold", color: colors.foreground }}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>

      {/* Delete staff confirm */}
      <Modal visible={!!deleteTarget} transparent animationType="fade">
        <View style={{ flex: 1, justifyContent: "center", alignItems: "center", backgroundColor: "rgba(0,0,0,0.45)", padding: 32 }}>
          <View style={{ backgroundColor: colors.card, borderRadius: 16, padding: 24, width: "100%" }}>
            <Text style={{ fontSize: 17, fontFamily: "Inter_700Bold", color: colors.foreground, marginBottom: 8 }}>Remove Staff Member</Text>
            <Text style={{ fontSize: 14, fontFamily: "Inter_400Regular", color: colors.mutedForeground, marginBottom: 24 }}>
              Remove {deleteTarget?.name} ({deleteTarget?.employeeId}) from the list?
            </Text>
            <View style={{ flexDirection: "row", gap: 12 }}>
              <TouchableOpacity onPress={() => setDeleteTarget(null)} style={{ flex: 1, backgroundColor: colors.secondary, borderRadius: 10, paddingVertical: 12, alignItems: "center" }}>
                <Text style={{ fontSize: 15, fontFamily: "Inter_600SemiBold", color: colors.foreground }}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity
                onPress={() => deleteTarget && handleDeleteStaff(deleteTarget)}
                style={{ flex: 1, backgroundColor: colors.destructive, borderRadius: 10, paddingVertical: 12, alignItems: "center" }}
              >
                <Text style={{ fontSize: 15, fontFamily: "Inter_700Bold", color: "#fff" }}>Remove</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      {/* Rates modal */}
      <Modal visible={!!showRatesModal} transparent animationType="slide">
        <View style={{ flex: 1, justifyContent: "flex-end", backgroundColor: "rgba(0,0,0,0.5)" }}>
          <View style={{ backgroundColor: colors.card, borderTopLeftRadius: 20, borderTopRightRadius: 20, maxHeight: "85%", paddingBottom: insets.bottom + 12 }}>
            <View style={{ flexDirection: "row", alignItems: "center", padding: 16, borderBottomWidth: 1, borderBottomColor: colors.border }}>
              <Feather name="sliders" size={18} color="#00695C" style={{ marginRight: 8 }} />
              <Text style={{ flex: 1, fontSize: 16, fontFamily: "Inter_700Bold", color: colors.foreground }}>
                {showRatesModal === "student" ? "Student Fees" : showRatesModal === "faculty" ? "Faculty Monthly Pay" : "Staff Monthly Pay"}
              </Text>
              <TouchableOpacity onPress={() => setShowRatesModal(null)}>
                <Feather name="x" size={22} color={colors.mutedForeground} />
              </TouchableOpacity>
            </View>

            {/* Bulk upload strip inside modal */}
            <View style={{ flexDirection: "row", gap: 8, padding: 10, borderBottomWidth: 1, borderBottomColor: colors.border }}>
              <TouchableOpacity
                style={[s.bulkBtn, { flex: 1 }]}
                onPress={() => showRatesModal && handleBulkRates(showRatesModal)}
                disabled={ratesBulkLoading}
              >
                {ratesBulkLoading
                  ? <ActivityIndicator color="#00695C" size="small" />
                  : <><Feather name="upload" size={14} color="#00695C" /><Text style={[s.bulkBtnTxt, { color: "#00695C" }]}>  Bulk Upload Excel</Text></>}
              </TouchableOpacity>
              <TouchableOpacity
                style={s.sampleBtn}
                onPress={() => {
                  if (!showRatesModal) return;
                  Linking.openURL(`https://${process.env.EXPO_PUBLIC_DOMAIN}/api/finance/rates/sample?personType=${showRatesModal}&scheduleId=${selectedScheduleId ?? ""}`);
                }}
              >
                <Feather name="download" size={13} color="#00695C" />
                <Text style={s.sampleBtnTxt}>Template</Text>
              </TouchableOpacity>
            </View>

            {/* Column header */}
            <View style={{ flexDirection: "row", backgroundColor: "#1565C0", paddingHorizontal: 14, paddingVertical: 7 }}>
              <Text style={{ flex: 1, fontSize: 10, fontFamily: "Inter_700Bold", color: "#fff" }}>Name / ID</Text>
              <Text style={{ width: 100, fontSize: 10, fontFamily: "Inter_700Bold", color: "#fff", textAlign: "center" }}>
                {showRatesModal === "student" ? "Fee (Rs)" : "Monthly Pay (Rs)"}
              </Text>
            </View>

            {ratesLoading ? (
              <ActivityIndicator color="#00695C" size="large" style={{ marginTop: 40 }} />
            ) : rateRows.length === 0 ? (
              <View style={s.noData}>
                <Feather name="users" size={36} color={colors.mutedForeground} />
                <Text style={s.noDataTxt}>No persons found. Add persons first.</Text>
              </View>
            ) : (
              <ScrollView contentContainerStyle={{ paddingBottom: 10 }}>
                {rateRows.map((row, i) => (
                  <View
                    key={row.personId}
                    style={{ flexDirection: "row", alignItems: "center", paddingHorizontal: 14, paddingVertical: 8, borderBottomWidth: 1, borderBottomColor: colors.border, backgroundColor: row.dirty ? "#E8F5E9" : i % 2 === 0 ? colors.card : colors.muted }}
                  >
                    <View style={{ flex: 1 }}>
                      <Text style={{ fontSize: 13, fontFamily: "Inter_500Medium", color: colors.foreground }} numberOfLines={1}>{row.personName}</Text>
                      <Text style={{ fontSize: 10, fontFamily: "Inter_400Regular", color: colors.mutedForeground }}>{row.personId}</Text>
                    </View>
                    <TextInput
                      style={{ width: 100, borderRadius: 8, borderWidth: 1.5, borderColor: row.dirty ? "#00695C" : colors.border, backgroundColor: colors.muted, paddingHorizontal: 8, paddingVertical: 6, fontFamily: "Inter_600SemiBold", fontSize: 13, color: colors.foreground, textAlign: "center" }}
                      value={row.rate}
                      onChangeText={v => setRateRows(prev => prev.map((r, idx) => idx === i ? { ...r, rate: v.replace(/[^0-9.]/g, ""), dirty: true } : r))}
                      keyboardType="numeric"
                      maxLength={9}
                    />
                  </View>
                ))}
              </ScrollView>
            )}

            <View style={{ flexDirection: "row", gap: 10, padding: 12 }}>
              <TouchableOpacity
                style={{ flex: 1, backgroundColor: colors.muted, borderRadius: 10, paddingVertical: 12, alignItems: "center", borderWidth: 1, borderColor: colors.border }}
                onPress={() => setShowRatesModal(null)}
              >
                <Text style={{ fontSize: 14, fontFamily: "Inter_600SemiBold", color: colors.foreground }}>Close</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={{ flex: 2, backgroundColor: "#1565C0", borderRadius: 10, paddingVertical: 12, alignItems: "center", flexDirection: "row", justifyContent: "center", gap: 8 }}
                onPress={() => showRatesModal && handleSaveRates(showRatesModal)}
                disabled={savingRates}
              >
                {savingRates
                  ? <ActivityIndicator color="#fff" size="small" />
                  : <><Feather name="save" size={15} color="#fff" /><Text style={{ color: "#fff", fontSize: 14, fontFamily: "Inter_700Bold" }}>Save Rates</Text></>}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      {renderErrorModal()}

      {/* ── Manage Persons Modal (Add/Remove WEF) ── */}
      <Modal visible={showPersonMgmt} transparent animationType="slide">
        <View style={{ flex:1, justifyContent:"flex-end", backgroundColor:"rgba(0,0,0,0.45)" }}>
          <View style={{ backgroundColor:colors.card, borderTopLeftRadius:20, borderTopRightRadius:20, padding:24, maxHeight:"85%" }}>
            <Text style={{ fontSize:18, fontFamily:"Inter_700Bold", color:"#1565C0", marginBottom:4 }}>
              Manage {personMgmtType === "student" ? "Students" : personMgmtType === "faculty" ? "Faculty" : "Staff"}
            </Text>
            <Text style={{ fontSize:13, fontFamily:"Inter_400Regular", color:colors.mutedForeground, marginBottom:16 }}>
              Add or remove persons WEF: <Text style={{ fontFamily:"Inter_600SemiBold", color:"#1565C0" }}>{period}</Text>
            </Text>

            {/* Add new person */}
            <Text style={{ fontSize:12, fontFamily:"Inter_600SemiBold", color:colors.foreground, marginBottom:8, textTransform:"uppercase" }}>
              ➕ Add New {personMgmtType === "student" ? "Student" : personMgmtType === "faculty" ? "Faculty Member" : "Staff Member"}
            </Text>
            <TextInput
              style={{ borderWidth:1, borderColor:colors.border, borderRadius:8, paddingHorizontal:12, paddingVertical:10, fontSize:14, fontFamily:"Inter_400Regular", color:colors.foreground, backgroundColor:colors.background, marginBottom:8 }}
              placeholder={personMgmtType === "student" ? "Roll No (e.g. 2K24-BEE-001)" : "Full Name"}
              placeholderTextColor={colors.mutedForeground}
              value={newPersonName} onChangeText={setNewPersonName}
            />
            <TextInput
              style={{ borderWidth:1, borderColor:colors.border, borderRadius:8, paddingHorizontal:12, paddingVertical:10, fontSize:14, fontFamily:"Inter_400Regular", color:colors.foreground, backgroundColor:colors.background, marginBottom:12 }}
              placeholder="Email (optional)"
              placeholderTextColor={colors.mutedForeground}
              value={newPersonEmail} onChangeText={setNewPersonEmail}
              autoCapitalize="none" keyboardType="email-address"
            />
            <TouchableOpacity
              style={{ backgroundColor:"#2E7D32", borderRadius:10, paddingVertical:11, alignItems:"center", marginBottom:16 }}
              onPress={handleAddPerson} disabled={personMgmtLoading || !newPersonName.trim()}>
              <Text style={{ color:"#fff", fontFamily:"Inter_700Bold", fontSize:14 }}>Add WEF {period}</Text>
            </TouchableOpacity>

            {/* Remove existing persons */}
            <Text style={{ fontSize:12, fontFamily:"Inter_600SemiBold", color:colors.foreground, marginBottom:8, textTransform:"uppercase" }}>
              🗑 Remove Person (WEF {period})
            </Text>
            <ScrollView style={{ maxHeight:180, marginBottom:12 }}>
              {(personMgmtType === "student" ? studentRows : personMgmtType === "faculty" ? facultyRows : staffPayRows).map(row => (
                <View key={row.personId} style={{ flexDirection:"row", alignItems:"center", paddingVertical:8, borderBottomWidth:1, borderBottomColor:colors.border }}>
                  <Text style={{ flex:1, fontSize:13, fontFamily:"Inter_500Medium", color:colors.foreground }}>{row.personName}</Text>
                  <TouchableOpacity
                    onPress={() => handleRemovePerson(row.personId, row.personName)}
                    style={{ backgroundColor:"#B71C1C", borderRadius:6, paddingHorizontal:10, paddingVertical:5 }}
                    disabled={personMgmtLoading}>
                    <Text style={{ color:"#fff", fontSize:12, fontFamily:"Inter_600SemiBold" }}>Remove</Text>
                  </TouchableOpacity>
                </View>
              ))}
              {(personMgmtType === "student" ? studentRows : personMgmtType === "faculty" ? facultyRows : staffPayRows).length === 0 && (
                <Text style={{ color:colors.mutedForeground, fontFamily:"Inter_400Regular", fontSize:13, textAlign:"center", paddingVertical:16 }}>No active persons for {period}</Text>
              )}
            </ScrollView>

            {personMgmtMsg ? (
              <Text style={{ fontSize:13, fontFamily:"Inter_600SemiBold", color: personMgmtMsg.startsWith("✓") ? "#2E7D32" : "#B71C1C", textAlign:"center", marginBottom:8 }}>{personMgmtMsg}</Text>
            ) : null}

            <TouchableOpacity
              style={{ backgroundColor:colors.muted, borderRadius:10, paddingVertical:12, alignItems:"center" }}
              onPress={() => { setShowPersonMgmt(false); setPersonMgmtMsg(""); }}>
              <Text style={{ fontFamily:"Inter_600SemiBold", color:colors.foreground }}>Close</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>

    </View>
  );
}
