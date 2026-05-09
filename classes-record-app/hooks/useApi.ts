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

export async function createUserSchedule(username: string, name: string, startDate?: string, endDate?: string) {
  const res = await fetch(`${API_BASE}/schedules`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, name, startDate, endDate }),
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
