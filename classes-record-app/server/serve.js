/**
 * Combined API + static file server for Classes Record app.
 * PostgreSQL version - matches backup.sql schema exactly.
 * Updated: May 9, 2026 - Fixed sample download, date formatting, field mapping, sequences
 */

const http = require("http");
const fs = require("fs");
const path = require("path");
const { Pool } = require("pg");

const db = new Pool({ connectionString: process.env.DATABASE_URL });

const STATIC_ROOT = path.resolve(__dirname, "..", "static-build");
const TEMPLATE_PATH = path.resolve(__dirname, "templates", "landing-page.html");
const basePath = (process.env.BASE_PATH || "/").replace(/\/+$/, "");
const ADMIN_PASSWORD = "Administr@r@123";
const ADMIN_USERNAME = "patoprincipalseecs@gmail.com";

// MIME types
const MIME_TYPES = {
  ".html": "text/html; charset=utf-8",
  ".js":   "application/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".css":  "text/css; charset=utf-8",
  ".png":  "image/png",
  ".jpg":  "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif":  "image/gif",
  ".svg":  "image/svg+xml",
  ".ico":  "image/x-icon",
  ".woff": "font/woff",
  ".woff2":"font/woff2",
  ".ttf":  "font/ttf",
  ".otf":  "font/otf",
  ".map":  "application/json",
  ".csv":  "text/csv; charset=utf-8",
};

// Helpers
function json(res, statusCode, data) {
  const body = JSON.stringify(data);
  res.writeHead(statusCode, {
    "content-type": "application/json; charset=utf-8",
    "access-control-allow-origin": "*",
    "content-length": Buffer.byteLength(body),
  });
  res.end(body);
}

function cors(res) {
  res.setHeader("access-control-allow-origin", "*");
  res.setHeader("access-control-allow-methods", "GET,POST,PATCH,DELETE,OPTIONS");
  res.setHeader("access-control-allow-headers", "content-type,x-admin-password,x-requested-with");
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let body = "";
    req.on("data", (chunk) => (body += chunk));
    req.on("end", () => {
      try { resolve(body ? JSON.parse(body) : {}); }
      catch { reject(new Error("Invalid JSON")); }
    });
    req.on("error", reject);
  });
}

function requireAdmin(req, res) {
  if (req.headers["x-admin-password"] !== ADMIN_PASSWORD) {
    json(res, 401, { success: false, message: "Unauthorized" });
    return false;
  }
  return true;
}

function formatDate(dateVal) {
  if (!dateVal) return "";
  if (typeof dateVal === "string") return dateVal.split("T")[0];
  try { return dateVal.toISOString().split("T")[0]; }
  catch { return ""; }
}

function timeToHour(t) {
  if (!t) return 9;
  const m = t.match(/(\d+):(\d+)\s*(AM|PM)/i);
  if (!m) return 9;
  let h = parseInt(m[1]);
  const ap = m[3].toUpperCase();
  if (ap === 'PM' && h !== 12) h += 12;
  if (ap === 'AM' && h === 12) h = 0;
  return h;
}

function hourLabel(h) {
  if (h < 0 || h > 23) return '09:00 AM';
  const t12 = (h % 12) || 12;
  const ap = h >= 12 ? 'PM' : 'AM';
  return (t12 < 10 ? '0' : '') + t12 + ':00 ' + ap;
}

// Route handler
async function handleApi(method, pathname, req, res) {
  const reqUrl = new URL(req.url, 'http://' + (req.headers.host || 'localhost'));
  const isMultipart = (req.headers["content-type"]||"").includes("multipart/form-data");
  const body = (method === "POST" || method === "PATCH") && !isMultipart ? await readBody(req) : {};

  if (method === "OPTIONS") { cors(res); res.writeHead(204); res.end(); return; }
  cors(res);

  // ========== AUTH ROUTES ==========

  if (method === "POST" && pathname === "/api/auth/register") {
    await db.query("SELECT setval('public.users_id_seq', COALESCE((SELECT MAX(id) FROM public.users), 0) + 1, false)").catch(() => {});
    const { username, password, pin } = body;
    if (!username || !password) return json(res, 400, { success: false, message: "Username and password required" });
    if (password.length < 4) return json(res, 400, { success: false, message: "Password must be at least 4 characters" });
    try {
      await db.query(
        "INSERT INTO public.users (id, username, password, pin) VALUES (nextval('public.users_id_seq'), $1, $2, $3) RETURNING id",
        [username.trim(), password.trim(), pin ?? ""]
      );
      return json(res, 200, { success: true });
    } catch (e) {
      if (e.message.includes("unique") || e.message.includes("duplicate")) {
        return json(res, 409, { success: false, message: "Username already taken" });
      }
      return json(res, 500, { success: false, message: e.message });
    }
  }

  if (method === "POST" && pathname === "/api/auth/login") {
    const { username, password } = body;
    try {
      const r = await db.query("SELECT * FROM public.users WHERE username = $1 AND password = $2", [username, password]);
      if (!r.rows.length) return json(res, 200, { success: false, message: "Invalid username or password" });
      return json(res, 200, { success: true, user: r.rows[0].username });
    } catch (e) { return json(res, 500, { success: false, message: e.message }); }
  }

  if (method === "POST" && pathname === "/api/auth/change-password") {
    const { username, currentPassword, newPassword } = body;
    try {
      const r = await db.query("SELECT * FROM public.users WHERE username = $1 AND password = $2", [username, currentPassword]);
      if (!r.rows.length) return json(res, 200, { success: false, message: "Current password is incorrect" });
      await db.query("UPDATE public.users SET password = $1 WHERE username = $2", [newPassword, username]);
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { success: false, message: e.message }); }
  }

  if (method === "POST" && pathname === "/api/auth/recover-password") {
    const { username, pin, newPassword } = body;
    try {
      const r = await db.query("SELECT * FROM public.users WHERE username = $1 AND pin = $2", [username, pin]);
      if (!r.rows.length) return json(res, 200, { success: false, message: "Username or PIN is incorrect" });
      await db.query("UPDATE public.users SET password = $1 WHERE username = $2", [newPassword, username]);
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { success: false, message: e.message }); }
  }

  if (method === "GET" && pathname === "/api/admin/users") {
    if (!requireAdmin(req, res)) return;
    try {
      const r = await db.query("SELECT id, username, password, pin FROM public.users WHERE username != $1 ORDER BY id DESC", [ADMIN_USERNAME]);
      return json(res, 200, { success: true, users: r.rows.map(u => ({
        ...u, isLocked: false, registeredAt: new Date().toISOString(), expiryDate: null, scheduleCount: 0
      }))});
    } catch (e) { return json(res, 500, { success: false, message: e.message }); }
  }

  // ========== SCHEDULES ROUTES ==========

  if (method === "GET" && pathname === "/api/schedules/public") {
    try {
      const r = await db.query("SELECT * FROM public.schedules WHERE is_public = true ORDER BY created_at DESC");
      return json(res, 200, r.rows.map(s => ({
        id: s.id, userId: s.user_id, name: s.name,
        startDate: s.start_date, endDate: s.end_date,
        isPublic: s.is_public, createdAt: s.created_at
      })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "GET" && pathname === "/api/schedules") {
    const username = reqUrl.searchParams.get("username");
    if (!username) return json(res, 400, { success: false, message: "username required" });
    try {
      const r = await db.query("SELECT * FROM public.schedules WHERE user_id = $1 ORDER BY created_at DESC", [username]);
      return json(res, 200, r.rows.map(s => ({
        id: s.id, userId: s.user_id, name: s.name,
        startDate: s.start_date, endDate: s.end_date,
        isPublic: s.is_public, createdAt: s.created_at
      })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "POST" && pathname === "/api/schedules") {
    const { username, name, startDate, endDate } = body;
    if (!username || !name) return json(res, 400, { success: false, message: "username and name required" });
    try {
      const r = await db.query(
        "INSERT INTO public.schedules (id, user_id, name, start_date, end_date) VALUES (nextval('public.schedules_id_seq'), $1, $2, $3, $4) RETURNING *",
        [username, name, startDate ?? null, endDate ?? null]
      );
      const s = r.rows[0];
      return json(res, 200, { success: true, schedule: {
        id: s.id, userId: s.user_id, name: s.name,
        startDate: s.start_date, endDate: s.end_date,
        isPublic: s.is_public, createdAt: s.created_at
      }});
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "PATCH" && pathname.match(/^\/api\/schedules\/\d+\/public$/)) {
    const id = parseInt(pathname.split("/")[3]);
    const { isPublic } = body;
    try {
      const r = await db.query("UPDATE public.schedules SET is_public = $1 WHERE id = $2 RETURNING *", [isPublic, id]);
      if (!r.rows.length) return json(res, 404, { success: false, message: "Schedule not found" });
      return json(res, 200, { success: true, isPublic: r.rows[0].is_public });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "DELETE" && pathname.startsWith("/api/schedules/")) {
    const id = pathname.split("/")[3];
    try {
      await db.query("DELETE FROM public.weekly_schedule WHERE schedule_id = $1", [id]);
      await db.query("DELETE FROM public.schedules WHERE id = $1", [id]);
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // ========== WEEKLY SCHEDULE ROUTE ==========

  if (method === "GET" && pathname === "/api/schedule") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    try {
      const sidInt = scheduleId && scheduleId !== "undefined" && scheduleId !== "null" && !isNaN(parseInt(scheduleId)) ? parseInt(scheduleId) : null;
      const r = sidInt
        ? await db.query("SELECT * FROM public.weekly_schedule WHERE schedule_id = $1 ORDER BY sort_key", [sidInt])
        : await db.query("SELECT * FROM public.weekly_schedule WHERE schedule_id IS NULL ORDER BY sort_key");
      return json(res, 200, r.rows.map(row => ({
        // Capitalized (what UI components expect)
        Faculty: row.faculty || "", Subject: row.subject || "", Class: row.class_name || "",
        Deptt: row.dept || "", Day: row.day || "", Location: row.location || "",
        Time: row.time_start || "", EndTime: row.time_end || "",
        SortKey: row.sort_key || 0, LecLab: row.lec_lab || "", Type: row.type || "",
        EntryDate: formatDate(row.entry_date), Elective: row.elective || "",
        UserEmail: row.user_email || "", ScheduleId: row.schedule_id,
        // Lowercase (for useApi.ts compatibility)
        id: row.id, faculty: row.faculty || "", subject: row.subject || "",
        class_name: row.class_name || "", dept: row.dept || "", day: row.day || "",
        location: row.location || "", time_start: row.time_start || "", time_end: row.time_end || "",
        lec_lab: row.lec_lab || "", type: row.type || "", entry_date: formatDate(row.entry_date),
        elective: row.elective || "", user_email: row.user_email || "", sort_key: row.sort_key || 0,
        schedule_id: row.schedule_id
      })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // ========== SUMMARY ROUTE ==========

  if (method === "GET" && pathname === "/api/summary") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const start = reqUrl.searchParams.get("start");
    const end = reqUrl.searchParams.get("end");
    try {
      const sidInt = scheduleId && scheduleId !== "undefined" && !isNaN(parseInt(scheduleId)) ? parseInt(scheduleId) : null;
      const q = sidInt
        ? await db.query("SELECT *, to_char(entry_date, 'YYYY-MM-DD') as entry_date_str FROM public.weekly_schedule WHERE schedule_id = $1", [sidInt])
        : await db.query("SELECT *, to_char(entry_date, 'YYYY-MM-DD') as entry_date_str FROM public.weekly_schedule WHERE schedule_id IS NULL");
      const rows = q.rows;

      const filterStart = start ? new Date(start + "T00:00:00") : new Date("2026-01-19T00:00:00");
      const filterEnd = end ? new Date(end + "T23:59:59") : new Date();
      filterStart.setHours(0,0,0,0); filterEnd.setHours(23,59,59,999);

      const DAY_NAMES = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
      function countWeekday(dayName) {
        const dayIdx = DAY_NAMES.indexOf(dayName);
        if (dayIdx < 0) return 0;
        let d = new Date(filterStart), c = 0;
        while (d <= filterEnd) { if (d.getDay() === dayIdx) c++; d.setDate(d.getDate()+1); }
        return c;
      }
      function normalizeClass(cls, isElective) {
        if (!isElective) return cls;
        cls = (cls||"").toUpperCase().trim();
        const m = cls.match(/^(2K\d{2}-[A-Z]+-\d+)[A-Z]+$/);
        return m ? m[1] : cls;
      }

      const map = {};
      for (const r of rows) {
        if (r.type && r.type.trim() !== "") continue;
        if (!r.faculty || !r.subject || !r.class_name || !r.dept) continue;
        if (!r.day || !r.time_start) continue;
        const isElective = (r.elective||"").toLowerCase() === "elective";
        const clsBase = normalizeClass(r.class_name, isElective).toUpperCase();
        const key = r.dept+"|||"+r.faculty+"|||"+r.subject+"|||"+clsBase;
        if (!map[key]) map[key] = { dept:r.dept, Faculty:r.faculty, Subject:r.subject, Class:clsBase, CreditHrs:r.lec_lab||"Lec", lecSlots:new Set(), labDays:new Set(), clsSections:new Set() };
        const isLab = (r.lec_lab||"").toLowerCase().includes("lab")||(r.lec_lab||"").toLowerCase().includes("prac");
        if (isElective) { const sm = r.class_name.toUpperCase().match(/\d+([A-Z])$/); if(sm) map[key].clsSections.add(sm[1]); }
        if (isLab) map[key].labDays.add(r.day);
        else map[key].lecSlots.add(r.day+"|||"+r.time_start);
      }

      const result = {};
      for (const [key, item] of Object.entries(map)) {
        let tbc = 0;
        item.lecSlots.forEach(slot => { tbc += countWeekday(slot.split("|||")[0]); });
        item.labDays.forEach(day => { tbc += countWeekday(day); });
        let displayClass = item.Class;
        if (item.clsSections.size > 0) displayClass = item.Class + [...item.clsSections].sort().join("");
        if (!result[item.dept]) result[item.dept] = {};
        const subKey = item.Faculty+"|||"+item.Subject+"|||"+item.Class;
        result[item.dept][subKey] = {
          Faculty:item.Faculty, Subject:item.Subject, Class:displayClass,
          CreditHrs:item.CreditHrs, ToBeConducted:tbc,
          Missed:0, Makeup:0, Late:0,
          MissedDates:[], MakeupDates:[], LateDates:[],
          GrandTotal:0, _ms:new Set(), _mk:new Set(), _lt:new Set()
        };
      }

      const labBuckets = {};
      for (const r of rows) {
        if (!r.type || r.type.trim()==="") continue;
        if (!r.entry_date) continue;
        const edRaw = r.entry_date_str || formatDate(r.entry_date);
        const ed = edRaw ? new Date(edRaw+"T00:00:00") : null;
        if (!ed || ed < filterStart || ed > filterEnd) continue;
        const isElective = (r.elective||"").toLowerCase()==="elective";
        const clsBase = normalizeClass(r.class_name, isElective).toUpperCase();
        const subKey = r.faculty+"|||"+r.subject+"|||"+clsBase;
        const rec = result[r.dept] && result[r.dept][subKey];
        if (!rec) continue;
        const dtStr = r.entry_date_str || formatDate(r.entry_date);
        const typeLow = (r.type||"").toLowerCase();
        const isLab = (r.lec_lab||"").toLowerCase().includes("lab")||(r.lec_lab||"").toLowerCase().includes("prac");
        if (isLab) {
          const lk = JSON.stringify({dept:r.dept,fac:r.faculty,sub:r.subject,cls:clsBase,dt:dtStr,tp:typeLow});
          if (!labBuckets[lk]) labBuckets[lk]=[];
          labBuckets[lk].push(r.time_start||"");
          continue;
        }
        const sk = r.faculty+"|||"+r.subject+"|||"+clsBase+"|||"+dtStr+"|||"+(r.time_start||"");
        const dtShort = dtStr.split('T')[0];
        if (typeLow==="missed" && !rec._ms.has(sk)) { rec.Missed++; rec._ms.add(sk); if(!rec.MissedDates.includes(dtShort)) rec.MissedDates.push(dtShort); }
        else if (typeLow==="makeup" && !rec._mk.has(sk)) { rec.Makeup++; rec._mk.add(sk); if(!rec.MakeupDates.includes(dtShort)) rec.MakeupDates.push(dtShort); }
        else if (typeLow==="late" && !rec._lt.has(sk)) { rec.Late++; rec._lt.add(sk); if(!rec.LateDates.includes(dtShort)) rec.LateDates.push(dtShort); }
      }

      for (const [k, times] of Object.entries(labBuckets)) {
        times.sort();
        const obj = JSON.parse(k);
        const rec = result[obj.dept] && result[obj.dept][obj.fac+"|||"+obj.sub+"|||"+obj.cls];
        if (!rec) continue;
        let blocks=1;
        for (let i=1;i<times.length;i++) {
          const p=(times[i-1]||"00:00").split(":"),c=(times[i]||"00:00").split(":");
          if (parseInt(c[0])*60+parseInt(c[1]) !== parseInt(p[0])*60+parseInt(p[1])+60) blocks++;
        }
        const dtShort2 = obj.dt.split('T')[0];
        if (obj.tp==="missed") { rec.Missed+=blocks; if(!rec.MissedDates.includes(dtShort2)) rec.MissedDates.push(dtShort2); }
        else if (obj.tp==="makeup") { rec.Makeup+=blocks; if(!rec.MakeupDates.includes(dtShort2)) rec.MakeupDates.push(dtShort2); }
        else if (obj.tp==="late") { rec.Late+=blocks; if(!rec.LateDates.includes(dtShort2)) rec.LateDates.push(dtShort2); }
      }

      for (const dept of Object.keys(result)) {
        for (const rec of Object.values(result[dept])) {
          rec.GrandTotal = rec.ToBeConducted - rec.Missed + rec.Makeup + rec.Late;
          rec.MissedDates.sort(); rec.MakeupDates.sort(); rec.LateDates.sort();
          delete rec._ms; delete rec._mk; delete rec._lt;
        }
      }
      return json(res, 200, result);
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // ========== ENTRIES ROUTE ==========

  if (method === "POST" && pathname === "/api/entries") {
    const { Faculty, Subject, Class, Date: date, Location, Time, EndTime, Type, User, scheduleId } = body;
    if (!Faculty || !Subject || !Class || !date || !Type) {
      return json(res, 400, { success: false, message: "Missing required fields" });
    }
    try {
      const ref = await db.query(
        "SELECT dept, lec_lab FROM public.weekly_schedule WHERE faculty = $1 AND subject = $2 AND class_name = $3 AND (type IS NULL OR type = '') LIMIT 1",
        [Faculty, Subject, Class]
      );
      const dept = ref.rows[0]?.dept || '';
      const lecLab = ref.rows[0]?.lec_lab || 'Lec';
      const dayNames = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
      const dayName = dayNames[new Date(date + 'T00:00:00').getDay()];
      const startH = timeToHour(Time);
      const endH = timeToHour(EndTime);
      const actualEndH = endH > startH ? endH : startH + 1;

      for (let h = startH; h < actualEndH; h++) {
        await db.query(
          "INSERT INTO public.weekly_schedule (faculty, subject, class_name, dept, day, location, time_start, time_end, lec_lab, type, entry_date, user_email, schedule_id, sort_key) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)",
          [Faculty, Subject, Class, dept, dayName, Location || '', hourLabel(h), hourLabel(h+1), lecLab, Type, date, User || '', scheduleId ?? null, h * 60]
        );
      }
      return json(res, 200, { success: true, message: 'Saved ' + (actualEndH - startH) + ' hour(s) as ' + Type });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // ========== HOLIDAYS ROUTES ==========

  if (method === "GET" && pathname === "/api/holidays") {
    try {
      const r = await db.query("SELECT id, date::text as date, trim(both '\r\n' from name) as name FROM public.holidays ORDER BY date");
      return json(res, 200, r.rows);
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "POST" && pathname === "/api/holidays") {
    const { date, name } = body;
    if (!date || !name) return json(res, 400, { success: false, message: "date and name required" });
    try {
      const r = await db.query("INSERT INTO public.holidays (id, date, name) VALUES (nextval('public.holidays_id_seq'), $1, trim($2)) RETURNING id, date::text as date, name", [date, name]);
      return json(res, 200, { success: true, holiday: r.rows[0] });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "DELETE" && pathname === "/api/holidays") {
    const id = reqUrl.searchParams.get("id");
    if (!id) return json(res, 400, { success: false, message: "id required" });
    try {
      await db.query("DELETE FROM public.holidays WHERE id = $1", [id]);
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // ========== IMPORT / SAMPLE ROUTES ==========

  if (method === "POST" && pathname === "/api/import/schedule") {
    const { rows, scheduleId } = body;
    if (!rows || !Array.isArray(rows) || rows.length === 0) return json(res, 400, { success: false, message: "No rows to import" });
    try {
      let imported = 0;
      const dayOrder = { Mon: 0, Tue: 1, Wed: 2, Thu: 3, Fri: 4, Sat: 5, Sun: 6 };
      for (const row of rows) {
        const faculty = row.Faculty || row.faculty || "";
        const subject = row.Subject || row.subject || "";
        const className = row.Class || row.class_name || row["Class Name"] || "";
        const dept = row.Deptt || row.dept || row.Department || "";
        const day = row.Day || row.day || "";
        const location = row.Location || row.location || row.Room || "";
        const timeStart = row.Time || row.time_start || row["Start Time"] || "";
        const timeEnd = row.EndTime || row.time_end || row["End Time"] || "";
        const lecLab = row.LecLab || row.lec_lab || row["Lec/Lab"] || "Lec";
        const elective = row.Elective || row.elective || "";
        const userEmail = row.UserEmail || row.user_email || row["Email of User"] || "";
        if (!faculty || !subject || !className || !day) continue;
        const dayNum = dayOrder[day] || 0;
        const timeMatch = timeStart.match(/(\d+):(\d+)\s*(AM|PM)/i);
        let hourNum = 0;
        if (timeMatch) {
          let h = parseInt(timeMatch[1]);
          if (timeMatch[3].toUpperCase() === 'PM' && h !== 12) h += 12;
          if (timeMatch[3].toUpperCase() === 'AM' && h === 12) h = 0;
          hourNum = h;
        }
        const sortKey = dayNum * 100 + hourNum;
        await db.query(
          "INSERT INTO public.weekly_schedule (faculty, subject, class_name, dept, day, location, time_start, time_end, lec_lab, elective, user_email, sort_key, schedule_id) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)",
          [faculty, subject, className, dept, day, location, timeStart, timeEnd, lecLab, elective, userEmail, sortKey, scheduleId ?? null]
        );
        imported++;
      }
      return json(res, 200, { success: true, imported });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // MUST be before generic /sample catch-all
  if (method === "GET" && pathname === "/api/import/sample/schedule") {
    const csv = "Faculty,Subject,Class,Deptt,Day,Time,End Time,Location,Lec/Lab,Elective,Email of User\nDr. Example,Linear Algebra,2K24-BEE-14A,ECE,Mon,09:00 AM,10:00 AM,CR-01,Lec,,user@seecs.edu.pk\n";
    res.writeHead(200, { "Content-Type": "text/csv; charset=utf-8", "Content-Disposition": "attachment; filename=SampleWeeklySchedule.csv", "Access-Control-Allow-Origin": "*", "Cache-Control": "no-cache" });
    res.end(csv);
    return;
  }

  if (method === "GET" && pathname === "/api/import/sample/students") {
    const csv = "Class,Roll No,Name,Email\n2K25-BSCS-15A,001,Ahmed Ali,ahmed@example.com\n";
    res.writeHead(200, { "Content-Type": "text/csv; charset=utf-8", "Content-Disposition": "attachment; filename=SampleStudents.csv", "Access-Control-Allow-Origin": "*", "Cache-Control": "no-cache" });
    res.end(csv);
    return;
  }

  // Generic sample endpoints (MUST be after specific ones)
  if (pathname.includes("/sample")) return json(res, 200, []);


  // POST /api/meeting
  if (method === "POST" && pathname === "/api/meeting") {
    const { date, start, end, faculty } = body;
    try {
      const q = await db.query("SELECT * FROM public.weekly_schedule WHERE schedule_id IS NULL");
      const rows = q.rows;
      function timeToMin(t) {
        if (!t) return 0;
        const m = t.match(/(\d+):(\d+)\s*(AM|PM)/i);
        if (!m) return 0;
        let h = parseInt(m[1]); const ap = m[3].toUpperCase();
        if (ap==="PM" && h!==12) h+=12; if (ap==="AM" && h===12) h=0;
        return h*60+parseInt(m[2]);
      }
      const dayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
      const dayName = dayNames[new Date(date+"T00:00:00").getDay()];
      const startMin = timeToMin(start), endMin = timeToMin(end);
      const allFaculty = [...new Set(rows.map(r=>r.faculty))].sort();
      const targets = (faculty && faculty.length>0) ? faculty : allFaculty;
      const free=[], busy=[];
      for (const name of targets) {
        const dept = rows.find(r=>r.faculty===name)?.dept||"";
        const busyRecs = rows.filter(r => {
          if (r.faculty!==name) return false;
          const rs=timeToMin(r.time_start), re=timeToMin(r.time_end);
          if (rs>=endMin||re<=startMin) return false;
          if (!r.type||r.type==="") return r.day===dayName;
          if (r.entry_date) {
            const ed=new Date(r.entry_date); ed.setHours(0,0,0,0);
            const td=new Date(date+"T00:00:00"); td.setHours(0,0,0,0);
            return ed.getTime()===td.getTime();
          }
          return false;
        }).map(r=>({subject:r.subject,cls:r.class_name,loc:r.location,start:timeToMin(r.time_start),end:timeToMin(r.time_end),type:r.type||"Scheduled"}));
        if (busyRecs.length===0) free.push({name,dept});
        else busy.push({name,dept,records:busyRecs});
      }
      return json(res, 200, {date,dayName,start,end,free,busy,summary:{}});
    } catch(e) { return json(res, 500, {error:e.message}); }
  }


  // POST /api/import/schedule/xlsx
  if (method === "POST" && pathname === "/api/import/schedule/xlsx") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const sidInt = scheduleId && !isNaN(parseInt(scheduleId)) ? parseInt(scheduleId) : null;
    try {
      const XLSX = require("xlsx");
      const chunks = [];
      for await (const chunk of req) chunks.push(chunk);
      const buf = Buffer.concat(chunks);
      const ct = req.headers["content-type"]||"";
      let fileBuf = null;
      if (ct.includes("multipart/form-data")) {
        const boundary = ct.split("boundary=")[1]?.split(";")[0]?.trim();
        if (!boundary) return json(res, 400, {success:false,message:"No boundary"});
        const sep = Buffer.from("\r\n--"+boundary);
        let pos = buf.indexOf(Buffer.from("--"+boundary));
        while (pos !== -1) {
          const hStart = pos + boundary.length + 2 + 2;
          const hEnd = buf.indexOf(Buffer.from("\r\n\r\n"), hStart);
          if (hEnd === -1) break;
          const header = buf.slice(hStart, hEnd).toString();
          const dStart = hEnd + 4;
          const next = buf.indexOf(sep, dStart);
          const dEnd = next === -1 ? buf.length : next;
          if (header.includes("filename=")) { fileBuf = buf.slice(dStart, dEnd); break; }
          pos = next === -1 ? -1 : next + sep.length;
        }
      } else { fileBuf = buf; }
      if (!fileBuf || fileBuf.length === 0) return json(res, 400, {success:false,message:"No file found"});
      const wb = XLSX.read(fileBuf, {type:"buffer"});
      const rows = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]], {defval:""});
      const DO = {Mon:0,Tue:1,Wed:2,Thu:3,Fri:4,Sat:5,Sun:6};
      let imported = 0;
      for (const r of rows) {
        const fac=r.Faculty||r.faculty||"", sub=r.Subject||r.subject||"";
        const cls=r.Class||r.class_name||r["Class Name"]||"";
        const dept=r.Deptt||r.dept||r.Department||"";
        const day=(r.Day||r.day||"").trim();
        if (!fac||!sub||!cls||!day) continue;
        const ts=r.Time||r["Start Time"]||"", te=r["End Time"]||r.EndTime||"";
        const ll=r["Lec/Lab"]||r.LecLab||r.lec_lab||"Lec";
        const el=r.Elective||r.elective||"";
        const em=r["Email of User"]||r.UserEmail||r.user_email||"";
        const tm=ts.match(/(\d+):(\d+)\s*(AM|PM)/i);
        let h=0; if(tm){h=parseInt(tm[1]);if(tm[3].toUpperCase()==="PM"&&h!==12)h+=12;if(tm[3].toUpperCase()==="AM"&&h===12)h=0;}
        await db.query("INSERT INTO public.weekly_schedule (faculty,subject,class_name,dept,day,location,time_start,time_end,lec_lab,elective,user_email,sort_key,schedule_id) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)",
          [fac,sub,cls,dept,day,r.Location||r.location||"",ts,te,ll,el,em,((DO[day]||0)*100+h),sidInt]);
        imported++;
      }
      return json(res, 200, {success:true,imported});
    } catch(e) { return json(res, 500, {error:e.message}); }
  }

  return json(res, 404, { error: "Not found" });
}

// ========== STATIC FILE SERVER ==========
function serveStaticFile(req, res, filePath) {
  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || "application/octet-stream";
  fs.readFile(filePath, (err, data) => {
    if (err) {
      if (err.code === "ENOENT") {
        const indexPath = path.join(STATIC_ROOT, "index.html");
        fs.readFile(indexPath, (err2, data2) => {
          if (err2) { res.writeHead(404); res.end("Not Found"); }
          else { res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" }); res.end(data2); }
        });
      } else { res.writeHead(500); res.end("Server Error"); }
    } else {
      res.writeHead(200, { "Content-Type": contentType, "Cache-Control": ext === ".html" ? "no-cache" : "public, max-age=31536000", "Access-Control-Allow-Origin": "*" });
      res.end(data);
    }
  });
}

function staticBuildExists() {
  try { return fs.existsSync(path.join(STATIC_ROOT, "index.html")); } catch { return false; }
}

// ========== SERVER STARTUP ==========
const port = parseInt(process.env.PORT || "3000", 10);

async function fixSequences() {
  const tables = ['users', 'schedules', 'holidays', 'attendance', 'weekly_schedule', 'faculty_accounts', 'finance_accounts', 'finance_payments', 'finance_rates', 'students', 'exam_marks', 'exam_weights', 'support_staff'];
  for (const table of tables) {
    try { await db.query("ALTER TABLE public." + table + " ALTER COLUMN id SET DEFAULT nextval('public." + table + "_id_seq')"); console.log('✓ Sequence fixed: ' + table); }
    catch (e) { console.log('→ Skipped: ' + table); }
  }
  try {
    await db.query("SELECT setval('public.users_id_seq', COALESCE((SELECT MAX(id) FROM public.users), 0) + 1, false)");
    await db.query("SELECT setval('public.schedules_id_seq', COALESCE((SELECT MAX(id) FROM public.schedules), 0) + 1, false)");
    await db.query("SELECT setval('public.holidays_id_seq', COALESCE((SELECT MAX(id) FROM public.holidays), 0) + 1, false)");
    await db.query("SELECT setval('public.weekly_schedule_id_seq', COALESCE((SELECT MAX(id) FROM public.weekly_schedule), 0) + 1, false)");
    console.log('✓ Sequence values updated');
  } catch (e) { console.log('→ Seq update skipped'); }
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url || "/", 'http://' + (req.headers.host || 'localhost'));
  let pathname = url.pathname;
  if (basePath && pathname.startsWith(basePath)) pathname = pathname.slice(basePath.length) || "/";
  if (pathname.startsWith("/api/")) {
    try { await handleApi(req.method, pathname, req, res); } catch (e) { json(res, 500, { error: String(e) }); }
    return;
  }
  if (pathname === "/health" || pathname === "/ping") {
    res.writeHead(200, { "Content-Type": "application/json" }); res.end(JSON.stringify({ status: "ok" })); return;
  }
  if ((pathname === "/" || pathname === "/index.html") && !staticBuildExists() && fs.existsSync(TEMPLATE_PATH)) {
    fs.readFile(TEMPLATE_PATH, "utf-8", (err, html) => {
      if (err) { res.writeHead(500); res.end("Error"); }
      else { res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" }); res.end(html); }
    }); return;
  }
  let filePath = path.join(STATIC_ROOT, pathname === "/" ? "index.html" : pathname);
  filePath = path.resolve(filePath);
  if (!filePath.startsWith(path.resolve(STATIC_ROOT))) { res.writeHead(403); res.end("Forbidden"); return; }
  serveStaticFile(req, res, filePath);
});

server.listen(port, "0.0.0.0", async () => {
  console.log('Server running on port ' + port);
  await fixSequences();
});
