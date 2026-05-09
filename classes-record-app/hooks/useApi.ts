const API_BASE = `https://${process.env.EXPO_PUBLIC_DOMAIN}/api`;

export interface ScheduleRow {
  id: number;
  Faculty: string;
  Subject: string;
  Class: string;
  Deptt: string;
  Day: string;
  Location: string;
  Time: string;
  EndTime: string;
  SortKey: number;
  LecLab: string;
  Type: string;
  EntryDate: string | null;
  Elective: string;
}

export interface SummaryRecord {
  Faculty: string;
  Subject: string;
  Class: string;
  CreditHrs: string;
  ToBeConducted: number;
  Missed: number;
  Makeup: number;
  Late: number;
  MissedDates: string[];
  MakeupDates: string[];
  LateDates: string[];
  GrandTotal: number;
}

export interface MeetingResult {
  date: string;
  dayName: string;
  start: string;
  end: string;
  free: { name: string; dept: string }[];
  busy: { name: string; dept: string; records: { subject: string; cls: string; loc: string; start: number; end: number; type: string }[] }[];
  summary: Record<string, { free: number; busy: number }>;
}

export interface Holiday {
  id: number;
  date: string;
  name: string;
}

export interface UserSchedule {
  id: number;
  userId: string;
  name: string;
  startDate: string | null;
  endDate: string | null;
  isPublic: boolean;
  createdAt: string;
}

export async function fetchSchedule(scheduleId?: number): Promise<ScheduleRow[]> {
  const url = scheduleId != null
    ? `${API_BASE}/schedule?scheduleId=${scheduleId}`
    : `${API_BASE}/schedule`;
  const res = await fetch(url);
  return res.json();
}

export async function addScheduleEntry(data: {
  faculty: string; subject: string; className: string; dept: string;
  day: string; location?: string; timeStart: string; timeEnd: string;
  lecLab?: string; elective?: string; userEmail?: string; scheduleId?: number;
}) {
  const res = await fetch(`${API_BASE}/schedule`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });
  return res.json();
}

export async function saveEntry(data: {
  Faculty: string; Subject: string; Class: string; Date: string;
  Location: string; Time: string; EndTime: string; Type: string; User: string;
}) {
  const res = await fetch(`${API_BASE}/entries`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });
  return res.json();
}

export async function fetchSummary(start?: string, end?: string): Promise<Record<string, Record<string, SummaryRecord>>> {
  const params = new URLSearchParams();
  if (start) params.set("start", start);
  if (end) params.set("end", end);
  const res = await fetch(`${API_BASE}/summary?${params}`);
  return res.json();
}

export async function fetchMeeting(date: string, start: string, end: string, faculty?: string[]): Promise<MeetingResult> {
  const res = await fetch(`${API_BASE}/meeting`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ date, start, end, faculty }),
  });
  return res.json();
}

export async function fetchFaculty(): Promise<string[]> {
  const res = await fetch(`${API_BASE}/faculty`);
  return res.json();
}

export async function fetchTimeSlots(): Promise<string[]> {
  const res = await fetch(`${API_BASE}/timeslots`);
  return res.json();
}

export interface ScheduleOptions {
  faculty: string[];
  subjects: string[];
  classes: string[];
  depts: string[];
  locations: string[];
  facSubjects: Record<string, string[]>;
  facSubClasses: Record<string, string[]>;
  classInfo: Record<string, { dept: string; locations: string[] }>;
}

export async function fetchOptions(scheduleId?: number): Promise<ScheduleOptions> {
  const url = scheduleId ? `${API_BASE}/options?scheduleId=${scheduleId}` : `${API_BASE}/options`;
  const res = await fetch(url);
  return res.json();
}

export interface ImportResult {
  success: boolean;
  inserted?: number;
  faculty?: number;
  subjects?: number;
  classes?: number;
  locations?: number;
  error?: string;
}

async function buildFormData(uri: string, name: string, mimeType: string): Promise<FormData> {
  const formData = new FormData();
  if (typeof document !== "undefined") {
    // Web: uri is a blob: or data: URL — fetch it to get a real Blob
    const blobRes = await fetch(uri);
    const blob = await blobRes.blob();
    formData.append("file", blob, name);
  } else {
    // Native: React Native FormData accepts { uri, name, type }
    formData.append("file", { uri, name, type: mimeType } as unknown as Blob);
  }
  return formData;
}

export async function importScheduleExcel(uri: string, name: string, mimeType: string, scheduleId?: number): Promise<ImportResult> {
  const formData = await buildFormData(uri, name, mimeType);
  const url = scheduleId != null
    ? `${API_BASE}/import/schedule?scheduleId=${scheduleId}`
    : `${API_BASE}/import/schedule`;
  const res = await fetch(url, { method: "POST", body: formData });
  return res.json();
}

export async function importEntriesExcel(uri: string, name: string, mimeType: string): Promise<ImportResult> {
  const formData = await buildFormData(uri, name, mimeType);
  const res = await fetch(`${API_BASE}/import/entries`, { method: "POST", body: formData });
  return res.json();
}

export async function importOptionsExcel(uri: string, name: string, mimeType: string): Promise<ImportResult> {
  const formData = await buildFormData(uri, name, mimeType);
  const res = await fetch(`${API_BASE}/import/options`, { method: "POST", body: formData });
  return res.json();
}

export async function fetchHolidays(): Promise<Holiday[]> {
  const res = await fetch(`${API_BASE}/holidays`);
  return res.json();
}

export async function addHoliday(date: string, name: string) {
  const res = await fetch(`${API_BASE}/holidays`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ date, name }),
  });
  return res.json();
}

export async function deleteHoliday(id: number) {
  const res = await fetch(`${API_BASE}/holidays/${id}`, { method: "DELETE" });
  return res.json();
}

export async function deleteScheduleRow(id: number) {
  const res = await fetch(`${API_BASE}/schedule/${id}`, { method: "DELETE" });
  return res.json();
}

export interface Student {
  id: number;
  scheduleId: number;
  className: string;
  rollNo: string;
  name: string;
  email: string;
  createdAt: string;
}

export interface StudentAttendanceSummaryRow {
  className: string;
  present: number;
  absent: number;
  leave: number;
  total: number;
  percentage: number;
}

export interface StudentAttendanceSummary {
  found: boolean;
  studentName?: string;
  regNo?: string;
  rows: StudentAttendanceSummaryRow[];
}

export interface AttendanceRosterRow {
  rollNo: string;
  name: string;
  email: string;
  records: Record<string, string>;
  presentCount: number;
  absentCount: number;
  leaveCount: number;
  total: number;
  percentage: number;
}

export interface AttendanceRoster {
  dates: string[];
  rows: AttendanceRosterRow[];
}

export interface DayAttendance {
  rollNo: string;
  status: string;
}

export async function fetchStudents(scheduleId: number, className: string): Promise<Student[]> {
  const res = await fetch(`${API_BASE}/attendance/students?scheduleId=${scheduleId}&className=${encodeURIComponent(className)}`);
  return res.json();
}

export async function addStudent(
  scheduleId: number, className: string, rollNo: string, name: string, email = ""
): Promise<{ success: boolean; student?: Student; error?: string }> {
  const res = await fetch(`${API_BASE}/attendance/students`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ scheduleId, className, rollNo, name, email }),
  });
  return res.json();
}

export async function changePassword(
  username: string, currentPassword: string, newPassword: string
): Promise<{ success: boolean; message?: string }> {
  try {
    const res = await fetch(`${API_BASE}/auth/change-password`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, currentPassword, newPassword }),
    });
    return res.json();
  } catch {
    return { success: false, message: "Connection error" };
  }
}

export async function recoverPasswordWithPin(
  username: string, pin: string, newPassword: string
): Promise<{ success: boolean; message?: string }> {
  try {
    const res = await fetch(`${API_BASE}/auth/recover-password`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, pin, newPassword }),
    });
    return res.json();
  } catch {
    return { success: false, message: "Connection error" };
  }
}

export async function fetchStudentEmailsForNotify(
  username: string, className: string
): Promise<{ rollNo: string; name: string; email: string }[]> {
  const res = await fetch(
    `${API_BASE}/attendance/students/emails?username=${encodeURIComponent(username)}&className=${encodeURIComponent(className)}`
  );
  return res.json();
}

export async function fetchStudentAttendanceSummary(
  scheduleId: number, regNo: string
): Promise<StudentAttendanceSummary> {
  const res = await fetch(
    `${API_BASE}/attendance/student-summary?scheduleId=${scheduleId}&regNo=${encodeURIComponent(regNo)}`
  );
  return res.json();
}

export async function deleteStudent(id: number): Promise<{ success: boolean }> {
  const res = await fetch(`${API_BASE}/attendance/students/${id}`, { method: "DELETE" });
  return res.json();
}

export async function fetchDayAttendance(scheduleId: number, className: string, date: string): Promise<DayAttendance[]> {
  const res = await fetch(`${API_BASE}/attendance?scheduleId=${scheduleId}&className=${encodeURIComponent(className)}&date=${date}`);
  return res.json();
}

export async function markAttendance(
  scheduleId: number, className: string, date: string, sessionTime: string, records: DayAttendance[]
): Promise<{ success: boolean }> {
  const res = await fetch(`${API_BASE}/attendance/mark`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ scheduleId, className, date, sessionTime, records }),
  });
  return res.json();
}

export async function fetchRoster(scheduleId: number, className: string): Promise<AttendanceRoster> {
  const res = await fetch(`${API_BASE}/attendance/roster?scheduleId=${scheduleId}&className=${encodeURIComponent(className)}`);
  return res.json();
}

export async function importStudentsExcel(
  scheduleId: number, className: string, uri: string, name: string, mimeType: string
): Promise<{ success: boolean; inserted?: number; skipped?: number; error?: string }> {
  const formData = new FormData();
  if (typeof document !== "undefined") {
    const blobRes = await fetch(uri);
    const blob = await blobRes.blob();
    formData.append("file", blob, name);
  } else {
    formData.append("file", { uri, name, type: mimeType } as unknown as Blob);
  }
  const res = await fetch(
    `${API_BASE}/attendance/students/bulk?scheduleId=${scheduleId}&className=${encodeURIComponent(className)}`,
    { method: "POST", body: formData }
  );
  return res.json();
}

export async function fetchUserSchedules(username: string): Promise<UserSchedule[]> {
  const res = await fetch(`${API_BASE}/schedules?username=${encodeURIComponent(username)}`);
  return res.json();
}

export async function fetchPublicSchedules(): Promise<UserSchedule[]> {
  const res = await fetch(`${API_BASE}/schedules/public`);
  return res.json();
}

export async function toggleSchedulePublic(id: number, isPublic: boolean): Promise<{ success: boolean; schedule?: UserSchedule }> {
  const res = await fetch(`${API_BASE}/schedules/${id}/public`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ isPublic }),
  });
  return res.json();
}

export async function createUserSchedule(
  username: string,
  name: string,
  startDate?: string,
  endDate?: string,
): Promise<{ success: boolean; schedule?: UserSchedule; error?: string }> {
  const res = await fetch(`${API_BASE}/schedules`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, name, startDate, endDate }),
  });
  return res.json();
}

export async function deleteUserSchedule(id: number): Promise<{ success: boolean }> {
  const res = await fetch(`${API_BASE}/schedules/${id}`, { method: "DELETE" });
  return res.json();
}

// ── Exam ───────────────────────────────────────────────────────────────────

export type ExamWeights = { quiz: number; assignment: number; mid: number; final: number };

export type ExamMarkRow = {
  id: number | null;
  rollNo: string;
  name: string;
  quiz: string | null;
  assignment: string | null;
  mid: string | null;
  final: string | null;
};

export type StudentExamResult = {
  found: boolean;
  studentName?: string;
  rollNo?: string;
  weights?: ExamWeights;
  rows?: { className: string; quiz: number | null; assignment: number | null; mid: number | null; final: number | null; total: number | null }[];
};

export async function fetchExamWeights(scheduleId: number): Promise<ExamWeights> {
  const res = await fetch(`${API_BASE}/exam/weights?scheduleId=${scheduleId}`);
  return res.json();
}

export async function saveExamWeights(
  scheduleId: number, weights: ExamWeights
): Promise<{ success: boolean; error?: string }> {
  const res = await fetch(`${API_BASE}/exam/weights?scheduleId=${scheduleId}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(weights),
  });
  return res.json();
}

export async function fetchExamMarks(scheduleId: number, className: string): Promise<ExamMarkRow[]> {
  const res = await fetch(
    `${API_BASE}/exam/marks?scheduleId=${scheduleId}&className=${encodeURIComponent(className)}`
  );
  return res.json();
}

export async function saveExamMark(
  scheduleId: number, className: string, rollNo: string,
  quiz: number | null, assignment: number | null, mid: number | null, final: number | null
): Promise<{ success: boolean }> {
  const res = await fetch(`${API_BASE}/exam/marks`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ scheduleId, className, rollNo, quiz, assignment, mid, final }),
  });
  return res.json();
}

export async function importExamMarksExcel(
  scheduleId: number, className: string, uri: string, name: string, mimeType: string
): Promise<{ success: boolean; updated?: number; skipped?: number; error?: string }> {
  const formData = new FormData();
  if (typeof document !== "undefined") {
    const blobRes = await fetch(uri);
    const blob = await blobRes.blob();
    formData.append("file", blob, name);
  } else {
    formData.append("file", { uri, name, type: mimeType } as unknown as Blob);
  }
  const res = await fetch(
    `${API_BASE}/exam/marks/bulk?scheduleId=${scheduleId}&className=${encodeURIComponent(className)}`,
    { method: "POST", body: formData }
  );
  return res.json();
}

export async function fetchStudentExamResult(scheduleId: number, rollNo: string): Promise<StudentExamResult> {
  const res = await fetch(
    `${API_BASE}/exam/student?scheduleId=${scheduleId}&rollNo=${encodeURIComponent(rollNo)}`
  );
  return res.json();
}

// ── Finance ────────────────────────────────────────────────────────────────

export type SupportStaff = { id: number; employeeId: string; name: string; designation: string; department: string };
export type FinancePayment = {
  id: number; personType: string; personId: string; personName: string;
  scheduleId: number | null; period: string;
  amount: string; paidAmount: string; paidDate: string | null; notes: string;
};
export type FinancePerson = { personId: string; personName: string };
export type FinanceSummary = {
  byType: Record<string, { totalDue: number; totalPaid: number; count: number; paid: number; partial: number; unpaid: number }>;
  overall: { totalDue: number; totalPaid: number; count: number; paid: number; partial: number; unpaid: number };
};
export type StudentFeeStatus = {
  found: boolean; personName?: string; rollNo?: string;
  rows?: { period: string; due: number; paid: number; balance: number; status: string; paidDate: string | null }[];
};

export async function fetchFinanceSchedules(): Promise<UserSchedule[]> {
  const res = await fetch(`${API_BASE}/finance/schedules`);
  return res.json();
}

export async function financeLogin(username: string, password: string): Promise<{ success: boolean; user?: string; message?: string }> {
  try {
    const res = await fetch(`${API_BASE}/finance/login`, {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password }),
    });
    return res.json();
  } catch { return { success: false, message: "Connection error" }; }
}

export async function financeRegister(username: string, password: string): Promise<{ success: boolean; user?: string; message?: string }> {
  try {
    const res = await fetch(`${API_BASE}/finance/register`, {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password }),
    });
    return res.json();
  } catch { return { success: false, message: "Connection error" }; }
}

export async function fetchSupportStaff(): Promise<SupportStaff[]> {
  const res = await fetch(`${API_BASE}/finance/staff`);
  return res.json();
}

export async function addSupportStaff(employeeId: string, name: string, designation: string, department: string): Promise<{ success?: boolean; error?: string }> {
  const res = await fetch(`${API_BASE}/finance/staff`, {
    method: "POST", headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ employeeId, name, designation, department }),
  });
  return res.json();
}

export async function deleteSupportStaff(id: number): Promise<{ success: boolean }> {
  const res = await fetch(`${API_BASE}/finance/staff/${id}`, { method: "DELETE" });
  return res.json();
}

export async function importStaffExcel(uri: string, name: string, mimeType: string): Promise<{ success: boolean; inserted?: number; skipped?: number; error?: string }> {
  const formData = new FormData();
  if (typeof document !== "undefined") {
    const blobRes = await fetch(uri); const blob = await blobRes.blob();
    formData.append("file", blob, name);
  } else {
    formData.append("file", { uri, name, type: mimeType } as unknown as Blob);
  }
  const res = await fetch(`${API_BASE}/finance/staff/bulk`, { method: "POST", body: formData });
  return res.json();
}

export async function fetchFinancePersons(type: "students" | "faculty", scheduleId: number): Promise<FinancePerson[]> {
  const res = await fetch(`${API_BASE}/finance/persons/${type}?scheduleId=${scheduleId}`);
  return res.json();
}

export async function fetchFinancePayments(personType: string, period: string, scheduleId?: number): Promise<FinancePayment[]> {
  const params = `personType=${personType}&period=${encodeURIComponent(period)}${scheduleId != null ? `&scheduleId=${scheduleId}` : ""}`;
  const res = await fetch(`${API_BASE}/finance/payments?${params}`);
  return res.json();
}

export async function saveFinancePaymentsBulk(payments: Partial<FinancePayment>[]): Promise<{ success: boolean }> {
  const res = await fetch(`${API_BASE}/finance/payments/bulk`, {
    method: "POST", headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ payments }),
  });
  return res.json();
}

export async function fetchFinanceSummary(period?: string, scheduleId?: number): Promise<FinanceSummary> {
  const params = new URLSearchParams();
  if (period) params.set("period", period);
  if (scheduleId != null) params.set("scheduleId", String(scheduleId));
  const res = await fetch(`${API_BASE}/finance/summary?${params}`);
  return res.json();
}

export async function fetchStudentFeeStatus(rollNo: string): Promise<StudentFeeStatus> {
  const res = await fetch(`${API_BASE}/finance/student-status?rollNo=${encodeURIComponent(rollNo)}`);
  return res.json();
}

export type FinanceRate = { id: number; personType: string; personId: string; scheduleId: number | null; rate: string };

export async function fetchFinanceRates(personType: string, scheduleId?: number | null): Promise<FinanceRate[]> {
  const schParam = scheduleId != null ? `&scheduleId=${scheduleId}` : "&scheduleId=null";
  const res = await fetch(`${API_BASE}/finance/rates?personType=${encodeURIComponent(personType)}${schParam}`);
  return res.json();
}

export async function saveFinanceRatesBulk(rates: Array<{ personType: string; personId: string; scheduleId?: number | null; rate: number }>): Promise<{ success: boolean }> {
  const res = await fetch(`${API_BASE}/finance/rates/bulk`, {
    method: "POST", headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ rates }),
  });
  return res.json();
}

export async function importRatesExcel(uri: string, name: string, mimeType: string, personType: string, scheduleId?: number | null): Promise<{ success: boolean; saved?: number; skipped?: number; error?: string }> {
  const formData = new FormData();
  if (typeof document !== "undefined") {
    const blobRes = await fetch(uri); const blob = await blobRes.blob();
    formData.append("file", blob, name);
  } else {
    formData.append("file", { uri, name, type: mimeType } as unknown as Blob);
  }
  const schParam = scheduleId != null ? `&scheduleId=${scheduleId}` : "";
  const res = await fetch(`${API_BASE}/finance/rates/import?personType=${encodeURIComponent(personType)}${schParam}`, { method: "POST", body: formData });
  return res.json();
}

// ── Faculty Access ───────────────────────────────────────────────────────────

export interface FacultyAccount {
  id: number;
  scheduleId: number;
  facultyName: string;
  username: string;
  password: string;
  email: string;
  classes: string[];
  subjects: string[];
  createdAt: string;
}

export interface FacultySession {
  accountId: number;
  username: string;
  facultyName: string;
  scheduleId: number;
  scheduleTitle: string;
  startDate: string | null;
  endDate: string | null;
}

export async function fetchFacultyAccounts(scheduleId: number): Promise<FacultyAccount[]> {
  const res = await fetch(`${API_BASE}/faculty-access?scheduleId=${scheduleId}`);
  return res.json();
}

export async function generateFacultyAccounts(scheduleId: number): Promise<{ created: number; skipped: number }> {
  const res = await fetch(`${API_BASE}/faculty-access/generate?scheduleId=${scheduleId}`, { method: "POST" });
  return res.json();
}

export async function updateFacultyAccount(id: number, data: { email?: string; regenerate?: boolean }): Promise<FacultyAccount> {
  const res = await fetch(`${API_BASE}/faculty-access/${id}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });
  return res.json();
}

export async function deleteFacultyAccount(id: number): Promise<{ success: boolean }> {
  const res = await fetch(`${API_BASE}/faculty-access/${id}`, { method: "DELETE" });
  return res.json();
}

export async function facultyLogin(username: string, password: string): Promise<FacultySession[]> {
  const res = await fetch(`${API_BASE}/faculty-access/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, password }),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({})) as { error?: string };
    throw new Error(err.error ?? "Login failed");
  }
  return res.json();
}

export async function changeFacultyPassword(accountId: number, currentPassword: string, newPassword: string): Promise<{ success: boolean; error?: string }> {
  const res = await fetch(`${API_BASE}/faculty-access/change-password`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ accountId, currentPassword, newPassword }),
  });
  return res.json();
}
