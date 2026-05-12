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

export interface UserSchedule {
  id: number; userId: string; name: string;
  startDate?: string; endDate?: string;
  startHour: number; endHour: number; activeDays: string;
  isPublic: boolean; createdAt: string;
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

export interface ScheduleOptions {
  faculty: string[];
  subjects: string[];
  classes: string[];
  locations: string[];
  depts: string[];
  facSubjects: Record<string, string[]>;
  facSubClasses: Record<string, string[]>;
  classInfo: Record<string, { dept: string; locations: string[] }>;
}

export async function fetchOptions(scheduleId?: number): Promise<ScheduleOptions> {
  const rows = await fetchSchedule(scheduleId);
  const base = rows.filter(r => !r.Type && r.Faculty !== "_locations_");
  const faculty = [...new Set(base.map(r => r.Faculty).filter(Boolean))].sort();
  const subjects = [...new Set(base.map(r => r.Subject).filter(Boolean))].sort();
  const classes = [...new Set(base.map(r => r.Class).filter(Boolean))].sort();
  const locations = [...new Set(rows.filter(r => !r.Type).map(r => r.Location).filter(Boolean))].sort();
  const depts = [...new Set(base.map(r => r.Deptt).filter(Boolean))].sort();
  const facSubjects: Record<string, string[]> = {};
  const facSubClasses: Record<string, string[]> = {};
  const classInfo: Record<string, { dept: string; locations: string[] }> = {};
  base.forEach(r => {
    if (r.Faculty && r.Subject) {
      if (!facSubjects[r.Faculty]) facSubjects[r.Faculty] = [];
      if (!facSubjects[r.Faculty].includes(r.Subject)) facSubjects[r.Faculty].push(r.Subject);
    }
    if (r.Faculty && r.Subject && r.Class) {
      const key = r.Faculty + "|||" + r.Subject;
      if (!facSubClasses[key]) facSubClasses[key] = [];
      if (!facSubClasses[key].includes(r.Class)) facSubClasses[key].push(r.Class);
    }
    if (r.Class) {
      if (!classInfo[r.Class]) classInfo[r.Class] = { dept: r.Deptt || "", locations: [] };
      if (r.Location && !classInfo[r.Class].locations.includes(r.Location))
        classInfo[r.Class].locations.push(r.Location);
    }
  });
  return { faculty, subjects, classes, locations, depts, facSubjects, facSubClasses, classInfo };
}

export async function fetchSchedule(scheduleId?: number): Promise<ScheduleRow[]> {
  const url = scheduleId != null
    ? `${API_BASE}/schedule?scheduleId=${scheduleId}`
    : `${API_BASE}/schedule`;
  const res = await fetch(url);
  const rows = await res.json();
  if (!Array.isArray(rows)) return [];
  return rows.map((r: any) => ({
    id: r.id,
    // Check BOTH capitalized and lowercase field names (server now returns both)
    Faculty: r.Faculty || r.faculty || "",
    Subject: r.Subject || r.subject || "",
    Class: r.Class || r.class_name || "",
    Deptt: r.Deptt || r.dept || "",
    Day: r.Day || r.day || "",
    Location: r.Location || r.location || "",
    Time: r.Time || r.time_start || "",
    EndTime: r.EndTime || r.time_end || "",
    SortKey: r.SortKey || r.sort_key || 0,
    LecLab: r.LecLab || r.lec_lab || "",
    Type: r.Type || r.type || "",
    EntryDate: r.EntryDate || r.entry_date || "",
    Elective: r.Elective || r.elective || "",
  }));
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

export async function fetchSummary(start?: string, end?: string, scheduleId?: number) {
  const params = new URLSearchParams();
  if (start) params.set("start", start);
  if (end) params.set("end", end);
  if (scheduleId != null) params.set("scheduleId", String(scheduleId));
  const res = await fetch(`${API_BASE}/summary?${params}`);
  return res.json();
}

export async function fetchHolidays() {
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
  const res = await fetch(`${API_BASE}/holidays?id=${id}`, { method: "DELETE" });
  return res.json();
}

export async function fetchUserSchedules(username: string) {
  const res = await fetch(`${API_BASE}/schedules?username=${encodeURIComponent(username)}`);
  return res.json();
}

export async function updateScheduleSettings(id: number, startHour: number, endHour: number, activeDays: string) {
  const res = await fetch(`${API_BASE}/schedules/${id}/settings`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ startHour, endHour, activeDays }),
  });
  return res.json();
}

export async function createUserSchedule(username: string, name: string, startDate?: string, endDate?: string, startHour?: number, endHour?: number, activeDays?: string) {
  const res = await fetch(`${API_BASE}/schedules`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, name, startDate, endDate, startHour, endHour, activeDays }),
  });
  return res.json();
}

export async function deleteScheduleRow(id: number) {
  const res = await fetch(`${API_BASE}/schedule/${id}`, { method: "DELETE" });
  return res.json();
}

export async function addScheduleEntry(data: { faculty: string; subject: string; className: string; dept: string; day: string; location: string; timeStart: string; timeEnd: string; lecLab: string; elective?: string; userEmail?: string; scheduleId?: number }) {
  const res = await fetch(`${API_BASE}/schedule/entry`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ Faculty: data.faculty, Subject: data.subject, Class: data.className, Dept: data.dept, Day: data.day, Location: data.location, Time: data.timeStart, EndTime: data.timeEnd, LecLab: data.lecLab, Elective: data.elective || "", User: data.userEmail || "", scheduleId: data.scheduleId }),
  });
  return res.json();
}

export async function importSchedule(rows: any[], scheduleId?: number) {
  const res = await fetch(`${API_BASE}/import/schedule`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ rows, scheduleId }),
  });
  return res.json();
}

async function buildFormData(uri: string, name: string, mimeType: string, file?: File): Promise<FormData> {
  const formData = new FormData();
  if (file instanceof File) {
    formData.append("file", file, file.name);
  } else if (typeof document !== "undefined") {
    // On web, use XMLHttpRequest to fetch blob which works with blob: URLs
    const blob = await new Promise<Blob>((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open("GET", uri);
      xhr.responseType = "blob";
      xhr.onload = () => resolve(xhr.response);
      xhr.onerror = () => reject(new Error("Failed to read file"));
      xhr.send();
    });
    formData.append("file", new File([blob], name, { type: mimeType }), name);
  } else {
    formData.append("file", { uri, name, type: mimeType } as unknown as Blob);
  }
  return formData;
}

export async function importScheduleExcel(uri: string, name: string, mimeType: string, scheduleId?: number, file?: File) {
  const formData = await buildFormData(uri, name, mimeType, file);
  const url = scheduleId != null
    ? `${API_BASE}/import/schedule/xlsx?scheduleId=${scheduleId}`
    : `${API_BASE}/import/schedule/xlsx`;
  const res = await fetch(url, { method: "POST", body: formData });
  return res.json();
}

export async function importOptionsExcel(uri: string, name: string, mimeType: string) {
  const formData = await buildFormData(uri, name, mimeType);
  const res = await fetch(`${API_BASE}/import/options/xlsx`, { method: "POST", body: formData });
  return res.json();
}

export async function importEntriesExcel(uri: string, name: string, mimeType: string) {
  const formData = await buildFormData(uri, name, mimeType);
  const res = await fetch(`${API_BASE}/import/entries/xlsx`, { method: "POST", body: formData });
  return res.json();
}

export interface Student {
  id: number;
  scheduleId: number;
  className: string;
  rollNo: string;
  name: string;
  email: string;
  enrolledAt: string;
}

export interface StudentAttendanceSummary {
  rollNo: string;
  name: string;
  email: string;
  total: number;
  present: number;
  absent: number;
  late: number;
}

export async function fetchAllStudents(scheduleId: number): Promise<{id:number;className:string;rollNo:string;name:string;email:string;enrolledAt:string;subject:string;faculty:string}[]> {
  try {
    const res = await fetch(`${API_BASE}/attendance/students/all?scheduleId=${scheduleId}`);
    const data = await res.json();
    return Array.isArray(data) ? data : [];
  } catch { return []; }
}

export async function fetchStudents(scheduleId: number, className: string): Promise<Student[]> {
  try {
    const res = await fetch(`${API_BASE}/attendance/students?scheduleId=${scheduleId}&className=${encodeURIComponent(className)}`);
    const data = await res.json();
    return Array.isArray(data) ? data : [];
  } catch { return []; }
}

export async function addStudent(scheduleId: number, className: string, rollNo: string, name: string, email: string) {
  const res = await fetch(`${API_BASE}/attendance/students`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ scheduleId, className, rollNo, name, email }),
  });
  return res.json();
}

export async function deleteStudent(id: number) {
  const res = await fetch(`${API_BASE}/attendance/students/${id}`, { method: "DELETE" });
  return res.json();
}

export async function markAttendance(scheduleId: number, className: string, date: string, sessionTime: string, records: { studentId: number; status: string }[]) {
  const res = await fetch(`${API_BASE}/attendance/mark`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ scheduleId, className, date, sessionTime, records }),
  });
  return res.json();
}

export async function fetchRoster(scheduleId: number, className: string) {
  try {
    const res = await fetch(`${API_BASE}/attendance/roster?scheduleId=${scheduleId}&className=${encodeURIComponent(className)}`);
    const data = await res.json();
    return Array.isArray(data) ? data : [];
  } catch { return []; }
}

export async function fetchStudentAttendanceSummary(scheduleId: number, className: string): Promise<StudentAttendanceSummary[]> {
  try {
    const res = await fetch(`${API_BASE}/attendance/summary?scheduleId=${scheduleId}&className=${encodeURIComponent(className)}`);
    const data = await res.json();
    return Array.isArray(data) ? data : [];
  } catch { return []; }
}

// ========== FINANCE API ==========

export interface FinancePayment {
  id?: number;
  personType: string;
  personName: string;
  scheduleId?: number;
  period: string;
  amount: number;
  status: string;
  note?: string;
}

export interface SupportStaff {
  id: number;
  name: string;
  role: string;
  contact?: string;
}

export async function financeLogin(username: string, financePin: string) {
  const res = await fetch(`${API_BASE}/finance/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, financePin }),
  });
  return res.json();
}

export async function setFinancePin(username: string, password: string, financePin: string) {
  const res = await fetch(`${API_BASE}/finance/auth/set-pin`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, password, financePin }),
  });
  return res.json();
}

export async function fetchFinanceSchedules(username?: string) {
  try {
    const url = username
      ? `${API_BASE}/finance/schedules?username=${encodeURIComponent(username)}`
      : `${API_BASE}/finance/schedules`;
    const res = await fetch(url);
    const data = await res.json();
    return Array.isArray(data) ? data : [];
  } catch { return []; }
}

export async function fetchFinancePersons(scheduleId: number, personType: string) {
  const res = await fetch(`${API_BASE}/finance/persons?scheduleId=${scheduleId}&personType=${encodeURIComponent(personType)}`);
  return res.json();
}

export async function fetchFinancePayments(scheduleId: number, personType: string, period: string) {
  const res = await fetch(`${API_BASE}/finance/payments?scheduleId=${scheduleId}&personType=${encodeURIComponent(personType)}&period=${encodeURIComponent(period)}`);
  const data = await res.json();
  return Array.isArray(data) ? data : [];
}

export async function saveFinancePaymentsBulk(payments: FinancePayment[]) {
  const res = await fetch(`${API_BASE}/finance/payments`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ payments }),
  });
  return res.json();
}

export async function fetchFinanceSummary(scheduleId: number, period: string) {
  const res = await fetch(`${API_BASE}/finance/summary?scheduleId=${scheduleId}&period=${encodeURIComponent(period)}`);
  return res.json();
}

export async function fetchStudentFeeStatus(regNo: string) {
  const res = await fetch(`${API_BASE}/finance/student-fee?regNo=${encodeURIComponent(regNo)}`);
  return res.json();
}

export async function fetchFinanceRates(scheduleId: number, personType: string) {
  const res = await fetch(`${API_BASE}/finance/rates?scheduleId=${scheduleId}&personType=${encodeURIComponent(personType)}`);
  const data = await res.json();
  return Array.isArray(data) ? data : [];
}

export async function saveFinanceRatesBulk(scheduleId: number, personType: string, rates: any[]) {
  const res = await fetch(`${API_BASE}/finance/rates`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ scheduleId, personType, rates }),
  });
  return res.json();
}

export async function importRatesExcel(uri: string, name: string, mimeType: string, scheduleId: number, personType: string) {
  const formData = await buildFormData(uri, name, mimeType);
  const res = await fetch(`${API_BASE}/finance/rates/import?scheduleId=${scheduleId}&personType=${encodeURIComponent(personType)}`, { method: "POST", body: formData });
  return res.json();
}

export async function fetchSupportStaff(scheduleId: number) {
  const res = await fetch(`${API_BASE}/finance/staff?scheduleId=${scheduleId}`);
  const data = await res.json();
  return Array.isArray(data) ? data : [];
}

export async function addSupportStaff(scheduleId: number, name: string, role: string, contact: string) {
  const res = await fetch(`${API_BASE}/finance/staff`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ scheduleId, name, role, contact }),
  });
  return res.json();
}

export async function deleteSupportStaff(id: number) {
  const res = await fetch(`${API_BASE}/finance/staff/${id}`, { method: "DELETE" });
  return res.json();
}

export async function importStaffExcel(uri: string, name: string, mimeType: string, scheduleId: number) {
  const formData = await buildFormData(uri, name, mimeType);
  const res = await fetch(`${API_BASE}/finance/staff/import?scheduleId=${scheduleId}`, { method: "POST", body: formData });
  return res.json();
}

export async function importStudentsExcel(scheduleId: number, className: string, uri: string, name: string, mimeType: string) {
  const formData = await buildFormData(uri, name, mimeType);
  const res = await fetch(`${API_BASE}/import/students/xlsx?scheduleId=${scheduleId}&className=${encodeURIComponent(className)}`, { method: "POST", body: formData });
  return res.json();
}

