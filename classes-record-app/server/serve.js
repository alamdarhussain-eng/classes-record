/**
 * Combined API + static file server for Classes Record app.
 * PostgreSQL version - matches backup.sql schema exactly.
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

// ── MIME types ─────────────────────────────────────────────────────────────
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
};

// ── Helpers ────────────────────────────────────────────────────────────────
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
  res.setHeader("access-control-allow-headers", "content-type,x-admin-password");
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

function addDays(days) {
  const d = new Date();
  d.setDate(d.getDate() + days);
  return d.toISOString().split("T")[0];
}

// ── Route handler ──────────────────────────────────────────────────────────
async function handleApi(method, pathname, req, res) {
  const reqUrl = new URL(req.url, `http://${req.headers.host}`);
  const body = (method === "POST" || method === "PATCH") ? await readBody(req) : {};

  if (method === "OPTIONS") { cors(res); res.writeHead(204); res.end(); return; }
  cors(res);

  // ── AUTH ──────────────────────────────────────────────────────────────────

  // POST /api/auth/register
  if (method === "POST" && pathname === "/api/auth/register") {
    // Fix sequence if needed
    await db.query("SELECT setval('public.users_id_seq', COALESCE((SELECT MAX(id) FROM public.users), 0) + 1, false)").catch(() => {});
    const { username, password, pin } = body;
    if (!username || !password) return json(res, 400, { success: false, message: "Username and password required" });
    if (password.length < 4) return json(res, 400, { success: false, message: "Password must be at least 4 characters" });
    try {
      const expiry = new Date();
      expiry.setDate(expiry.getDate() + 30);
      const expiryDate = expiry.toISOString().split("T")[0];
      await db.query(
        "INSERT INTO public.users (id, username, password, pin) VALUES (nextval('public.users_id_seq'), $1, $2, $3) RETURNING id",
        [username.trim(), password.trim(), pin ?? ""]
      );
      return json(res, 200, { success: true, expiryDate });
    } catch (e) {
      if (e.message.includes("unique") || e.message.includes("duplicate")) {
        return json(res, 409, { success: false, message: "Username already taken" });
      }
      return json(res, 500, { success: false, message: e.message });
    }
  }

  // POST /api/auth/login
  if (method === "POST" && pathname === "/api/auth/login") {
    const { username, password } = body;
    try {
      const r = await db.query(
        "SELECT * FROM public.users WHERE username = $1 AND password = $2",
        [username, password]
      );
      if (!r.rows.length) return json(res, 200, { success: false, message: "Invalid username or password" });
      const user = r.rows[0];
      return json(res, 200, { success: true, user: user.username });
    } catch (e) {
      return json(res, 500, { success: false, message: e.message });
    }
  }

  // POST /api/auth/change-password
  if (method === "POST" && pathname === "/api/auth/change-password") {
    const { username, currentPassword, newPassword } = body;
    try {
      const r = await db.query(
        "SELECT * FROM public.users WHERE username = $1 AND password = $2",
        [username, currentPassword]
      );
      if (!r.rows.length) return json(res, 200, { success: false, message: "Current password is incorrect" });
      await db.query("UPDATE public.users SET password = $1 WHERE username = $2", [newPassword, username]);
      return json(res, 200, { success: true });
    } catch (e) {
      return json(res, 500, { success: false, message: e.message });
    }
  }

  // POST /api/auth/recover-password
  if (method === "POST" && pathname === "/api/auth/recover-password") {
    const { username, pin, newPassword } = body;
    try {
      const r = await db.query(
        "SELECT * FROM public.users WHERE username = $1 AND pin = $2",
        [username, pin]
      );
      if (!r.rows.length) return json(res, 200, { success: false, message: "Username or PIN is incorrect" });
      await db.query("UPDATE public.users SET password = $1 WHERE username = $2", [newPassword, username]);
      return json(res, 200, { success: true });
    } catch (e) {
      return json(res, 500, { success: false, message: e.message });
    }
  }

  // ── ADMIN ─────────────────────────────────────────────────────────────────

  // GET /api/admin/users
  if (method === "GET" && pathname === "/api/admin/users") {
    if (!requireAdmin(req, res)) return;
    try {
      const r = await db.query(
        "SELECT id, username, password, pin FROM public.users WHERE username != $1 ORDER BY id DESC",
        [ADMIN_USERNAME]
      );
      return json(res, 200, { success: true, users: r.rows.map(u => ({
        ...u, isLocked: false, registeredAt: new Date().toISOString(), expiryDate: null, scheduleCount: 0
      }))});
    } catch (e) {
      return json(res, 500, { success: false, message: e.message });
    }
  }

  // DELETE /api/admin/users/:id
  if (method === "DELETE" && pathname.match(/^\/api\/admin\/users\/\d+$/)) {
    if (!requireAdmin(req, res)) return;
    const id = parseInt(pathname.split("/").pop());
    try {
      await db.query("DELETE FROM public.users WHERE id = $1", [id]);
      return json(res, 200, { success: true });
    } catch (e) {
      return json(res, 500, { success: false, message: e.message });
    }
  }

  // ── USER SCHEDULES ────────────────────────────────────────────────────────

  // GET /api/schedules/public
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

  // GET /api/schedules?username=...
  if (method === "GET" && pathname === "/api/schedules") {
    const username = reqUrl.searchParams.get("username");
    if (!username) return json(res, 400, { success: false, message: "username required" });
    try {
      const r = await db.query(
        "SELECT * FROM public.schedules WHERE user_id = $1 ORDER BY created_at DESC",
        [username]
      );
      return json(res, 200, r.rows.map(s => ({
        id: s.id, userId: s.user_id, name: s.name,
        startDate: s.start_date, endDate: s.end_date,
        isPublic: s.is_public, createdAt: s.created_at
      })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // POST /api/schedules
  if (method === "POST" && pathname === "/api/schedules") {
    const { username, name, startDate, endDate } = body;
    if (!username || !name) return json(res, 400, { success: false, message: "username and name required" });
    try {
      const r = await db.query(
        "INSERT INTO public.schedules (user_id, name, start_date, end_date) VALUES ($1, $2, $3, $4) RETURNING *",
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

  // DELETE /api/schedules/:id
  if (method === "DELETE" && pathname.match(/^\/api\/schedules\/\d+$/)) {
    const id = parseInt(pathname.split("/").pop());
    try {
      await db.query("DELETE FROM public.schedules WHERE id = $1", [id]);
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // PATCH /api/schedules/:id/public
  if (method === "PATCH" && pathname.match(/^\/api\/schedules\/\d+\/public$/)) {
    const id = parseInt(pathname.split("/")[3]);
    const { isPublic } = body;
    try {
      const r = await db.query(
        "UPDATE public.schedules SET is_public = $1 WHERE id = $2 RETURNING *",
        [isPublic, id]
      );
      const s = r.rows[0];
      return json(res, 200, { success: true, schedule: {
        id: s.id, userId: s.user_id, name: s.name,
        startDate: s.start_date, endDate: s.end_date,
        isPublic: s.is_public, createdAt: s.created_at
      }});
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // ── WEEKLY SCHEDULE ───────────────────────────────────────────────────────

  // GET /api/schedule?scheduleId=...
  if (method === "GET" && pathname === "/api/schedule") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    try {
      const sidInt = scheduleId && scheduleId !== "undefined" && scheduleId !== "null" && !isNaN(parseInt(scheduleId)) ? parseInt(scheduleId) : null;
      const r = sidInt
        ? await db.query("SELECT * FROM public.weekly_schedule WHERE schedule_id = $1 ORDER BY sort_key", [sidInt])
        : await db.query("SELECT * FROM public.weekly_schedule WHERE schedule_id IS NULL ORDER BY sort_key");
      return json(res, 200, r.rows.map(row => ({
        id: row.id, Faculty: row.faculty, Subject: row.subject,
        Class: row.class_name, Deptt: row.dept, Day: row.day,
        Location: row.location, Time: row.time_start, EndTime: row.time_end,
        SortKey: row.sort_key, LecLab: row.lec_lab, Type: row.type,
        EntryDate: row.entry_date, Elective: row.elective ?? ""
      })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // POST /api/schedule
  if (method === "POST" && pathname === "/api/schedule") {
    const { faculty, subject, className, dept, day, location, timeStart, timeEnd, lecLab, elective, scheduleId } = body;
    try {
      const r = await db.query(
        `INSERT INTO public.weekly_schedule (schedule_id, faculty, subject, class_name, dept, day, location, time_start, time_end, lec_lab, elective)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11) RETURNING id`,
        [scheduleId ?? null, faculty, subject, className, dept, day, location ?? "", timeStart, timeEnd, lecLab ?? "", elective ?? ""]
      );
      return json(res, 200, { success: true, id: r.rows[0].id });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // DELETE /api/schedule/:id
  if (method === "DELETE" && pathname.match(/^\/api\/schedule\/\d+$/)) {
    const id = parseInt(pathname.split("/").pop());
    try {
      await db.query("DELETE FROM public.weekly_schedule WHERE id = $1", [id]);
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // GET /api/options
  if (method === "GET" && pathname === "/api/options") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    try {
      const sidInt = scheduleId && scheduleId !== "undefined" && !isNaN(parseInt(scheduleId)) ? parseInt(scheduleId) : null;
      const q = sidInt
        ? await db.query("SELECT * FROM public.weekly_schedule WHERE schedule_id = $1", [sidInt])
        : await db.query("SELECT * FROM public.weekly_schedule");
      const rows = q.rows;
      const faculty = [...new Set(rows.map(r => r.faculty))].sort();
      const subjects = [...new Set(rows.map(r => r.subject))].sort();
      const classes = [...new Set(rows.map(r => r.class_name))].sort();
      const depts = [...new Set(rows.map(r => r.dept))].sort();
      const locations = [...new Set(rows.map(r => r.location).filter(Boolean))].sort();
      const facSubjects = {};
      const facSubClasses = {};
      const classInfo = {};
      for (const r of rows) {
        if (!facSubjects[r.faculty]) facSubjects[r.faculty] = new Set();
        facSubjects[r.faculty].add(r.subject);
        const key = `${r.faculty}|${r.subject}`;
        if (!facSubClasses[key]) facSubClasses[key] = new Set();
        facSubClasses[key].add(r.class_name);
        if (!classInfo[r.class_name]) classInfo[r.class_name] = { dept: r.dept, locations: new Set() };
        if (r.location) classInfo[r.class_name].locations.add(r.location);
      }
      return json(res, 200, {
        faculty, subjects, classes, depts, locations,
        facSubjects: Object.fromEntries(Object.entries(facSubjects).map(([k,v]) => [k, [...v]])),
        facSubClasses: Object.fromEntries(Object.entries(facSubClasses).map(([k,v]) => [k, [...v]])),
        classInfo: Object.fromEntries(Object.entries(classInfo).map(([k,v]) => [k, { dept: v.dept, locations: [...v.locations] }]))
      });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // GET /api/faculty
  if (method === "GET" && pathname === "/api/faculty") {
    try {
      const r = await db.query("SELECT DISTINCT faculty FROM public.weekly_schedule ORDER BY faculty");
      return json(res, 200, r.rows.map(r => r.faculty));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // GET /api/summary
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
      filterStart.setHours(0,0,0,0);
      filterEnd.setHours(23,59,59,999);

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

      // Build unique weekly slot map from regular (no type) rows
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
        result[item.dept][subKey] = { Faculty:item.Faculty, Subject:item.Subject, Class:displayClass, CreditHrs:item.CreditHrs, ToBeConducted:tbc, Missed:0, Makeup:0, Late:0, MissedDates:[], MakeupDates:[], LateDates:[], GrandTotal:0, _ms:new Set(), _mk:new Set(), _lt:new Set() };
      }

      // Count entries within date range
      const labBuckets = {};
      for (const r of rows) {
        if (!r.type || r.type.trim()==="") continue;
        if (!r.entry_date) continue;
        const edRaw = r.entry_date_str || (r.entry_date ? r.entry_date.toString().split("T")[0] : "");
        const ed = edRaw ? new Date(edRaw+"T00:00:00") : null;
        if (!ed) continue;
        if (ed < filterStart || ed > filterEnd) continue;
        const isElective = (r.elective||"").toLowerCase()==="elective";
        const clsBase = normalizeClass(r.class_name, isElective).toUpperCase();
        const subKey = r.faculty+"|||"+r.subject+"|||"+clsBase;
        const rec = result[r.dept] && result[r.dept][subKey];
        if (!rec) continue;
        const dtStr = r.entry_date_str || (r.entry_date ? r.entry_date.toString().split("T")[0] : "");
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
          delete rec._ms; delete rec._mk; delete rec._lt;
        }
      }
      return json(res, 200, result);
    } catch (e) { return json(res, 500, { error: e.message }); }
  }


  // POST /api/entries
  if (method === "POST" && pathname === "/api/entries") {
    const { Faculty, Subject, Class, Date: date, Location, Time, EndTime, Type, User, scheduleId } = body;
    try {
      // Find reference row to get dept and lec_lab
      const ref = await db.query(
        `SELECT dept, lec_lab, day FROM public.weekly_schedule
         WHERE faculty = $1 AND subject = $2 AND class_name = $3
         AND (type IS NULL OR type = '')
         AND (schedule_id = $4 OR schedule_id IS NULL) LIMIT 1`,
        [Faculty, Subject, Class, scheduleId ?? null]
      );
      const dept = ref.rows[0]?.dept || '';
      const lecLab = ref.rows[0]?.lec_lab || 'Lec';

      // Calculate day from date
      const dayNames = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
      const dayName = dayNames[new Date(date + 'T00:00:00').getDay()];

      // Parse hours from Time and EndTime
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
      function label(h) {
        const t12 = (h % 12) || 12;
        const ap = h >= 12 ? 'PM' : 'AM';
        return (t12 < 10 ? '0' : '') + t12 + ':00 ' + ap;
      }

      const startH = timeToHour(Time);
      const endH = timeToHour(EndTime);

      // Insert one row per hour slot
      for (let h = startH; h < endH; h++) {
        await db.query(
          `INSERT INTO public.weekly_schedule
           (faculty, subject, class_name, dept, day, location, time_start, time_end, lec_lab, type, entry_date, user_email, schedule_id)
           VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)`,
          [Faculty, Subject, Class, dept, dayName, Location || '',
           label(h), label(h+1), lecLab, Type, date, User || '', scheduleId ?? null]
        );
      }
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // ── HOLIDAYS ──────────────────────────────────────────────────────────────

  if (method === "GET" && pathname === "/api/holidays") {
    try {
      const r = await db.query("SELECT id, date::text, trim(both '\r\n' from name) as name FROM public.holidays ORDER BY date");
      return json(res, 200, r.rows);
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "POST" && pathname === "/api/holidays") {
    const { date, name } = body;
    try {
      const r = await db.query("INSERT INTO public.holidays (date, name) VALUES ($1, $2) RETURNING *", [date, name]);
      return json(res, 200, { success: true, ...r.rows[0] });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "DELETE" && pathname.match(/^\/api\/holidays\/\d+$/)) {
    const id = parseInt(pathname.split("/").pop());
    try {
      await db.query("DELETE FROM public.holidays WHERE id = $1", [id]);
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // ── STUDENTS ──────────────────────────────────────────────────────────────

  if (method === "GET" && pathname === "/api/attendance/students") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const className = reqUrl.searchParams.get("className");
    try {
      const r = await db.query(
        "SELECT * FROM public.students WHERE schedule_id = $1 AND class_name = $2 ORDER BY roll_no",
        [parseInt(scheduleId), className]
      );
      return json(res, 200, r.rows.map(s => ({
        id: s.id, scheduleId: s.schedule_id, className: s.class_name,
        rollNo: s.roll_no, name: s.name, email: s.email, createdAt: s.created_at
      })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "POST" && pathname === "/api/attendance/students") {
    const { scheduleId, className, rollNo, name, email } = body;
    try {
      const r = await db.query(
        "INSERT INTO public.students (schedule_id, class_name, roll_no, name, email) VALUES ($1,$2,$3,$4,$5) RETURNING *",
        [scheduleId, className, rollNo, name, email ?? ""]
      );
      const s = r.rows[0];
      return json(res, 200, { success: true, student: {
        id: s.id, scheduleId: s.schedule_id, className: s.class_name,
        rollNo: s.roll_no, name: s.name, email: s.email, createdAt: s.created_at
      }});
    } catch (e) {
      if (e.message.includes("unique") || e.message.includes("duplicate"))
        return json(res, 409, { success: false, error: "Student already exists" });
      return json(res, 500, { error: e.message });
    }
  }

  if (method === "DELETE" && pathname.match(/^\/api\/attendance\/students\/\d+$/)) {
    const id = parseInt(pathname.split("/").pop());
    try {
      await db.query("DELETE FROM public.students WHERE id = $1", [id]);
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // GET /api/attendance/students/bulk
  if (method === "POST" && pathname.includes("/api/attendance/students/bulk")) {
    return json(res, 200, { success: true, inserted: 0, skipped: 0 });
  }

  // GET /api/attendance/students/emails
  if (method === "GET" && pathname === "/api/attendance/students/emails") {
    const username = reqUrl.searchParams.get("username");
    const className = reqUrl.searchParams.get("className");
    try {
      const r = await db.query(
        `SELECT s.roll_no, s.name, s.email FROM public.students s
         JOIN public.schedules sc ON sc.id = s.schedule_id
         WHERE sc.user_id = $1 AND s.class_name = $2`,
        [username, className]
      );
      return json(res, 200, r.rows.map(s => ({ rollNo: s.roll_no, name: s.name, email: s.email })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // ── ATTENDANCE ────────────────────────────────────────────────────────────

  if (method === "GET" && pathname === "/api/attendance") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const className = reqUrl.searchParams.get("className");
    const date = reqUrl.searchParams.get("date");
    try {
      const r = await db.query(
        "SELECT roll_no, status FROM public.attendance WHERE schedule_id=$1 AND class_name=$2 AND date=$3",
        [parseInt(scheduleId), className, date]
      );
      return json(res, 200, r.rows.map(a => ({ rollNo: a.roll_no, status: a.status })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "POST" && pathname === "/api/attendance/mark") {
    const { scheduleId, className, date, sessionTime, records } = body;
    try {
      for (const rec of records) {
        await db.query(
          `INSERT INTO public.attendance (schedule_id, class_name, date, roll_no, status, session_time)
           VALUES ($1,$2,$3,$4,$5,$6)
           ON CONFLICT (schedule_id, class_name, date, session_time, roll_no)
           DO UPDATE SET status = $5`,
          [scheduleId, className, date, rec.rollNo, rec.status, sessionTime ?? ""]
        );
      }
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "GET" && pathname === "/api/attendance/roster") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const className = reqUrl.searchParams.get("className");
    try {
      const [studentsR, attendanceR] = await Promise.all([
        db.query("SELECT * FROM public.students WHERE schedule_id=$1 AND class_name=$2 ORDER BY roll_no", [parseInt(scheduleId), className]),
        db.query("SELECT * FROM public.attendance WHERE schedule_id=$1 AND class_name=$2 ORDER BY date", [parseInt(scheduleId), className])
      ]);
      const dates = [...new Set(attendanceR.rows.map(a => a.date?.toISOString?.().split("T")[0] ?? a.date))].sort();
      const rows = studentsR.rows.map(s => {
        const records = {};
        let presentCount = 0, absentCount = 0, leaveCount = 0;
        for (const a of attendanceR.rows) {
          const d = a.date?.toISOString?.().split("T")[0] ?? a.date;
          if (a.roll_no === s.roll_no) {
            records[d] = a.status;
            if (a.status === "P") presentCount++;
            else if (a.status === "A") absentCount++;
            else if (a.status === "L") leaveCount++;
          }
        }
        const total = presentCount + absentCount + leaveCount;
        return {
          rollNo: s.roll_no, name: s.name, email: s.email,
          records, presentCount, absentCount, leaveCount,
          total, percentage: total ? Math.round((presentCount / total) * 100) : 0
        };
      });
      return json(res, 200, { dates, rows });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "GET" && pathname === "/api/attendance/student-summary") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const regNo = reqUrl.searchParams.get("regNo");
    try {
      const studentR = await db.query(
        "SELECT * FROM public.students WHERE schedule_id=$1 AND roll_no=$2",
        [parseInt(scheduleId), regNo]
      );
      if (!studentR.rows.length) return json(res, 200, { found: false, rows: [] });
      const student = studentR.rows[0];
      const attR = await db.query(
        "SELECT class_name, status, COUNT(*) as cnt FROM public.attendance WHERE schedule_id=$1 AND roll_no=$2 GROUP BY class_name, status",
        [parseInt(scheduleId), regNo]
      );
      const byClass = {};
      for (const row of attR.rows) {
        if (!byClass[row.class_name]) byClass[row.class_name] = { present: 0, absent: 0, leave: 0 };
        if (row.status === "P") byClass[row.class_name].present = parseInt(row.cnt);
        else if (row.status === "A") byClass[row.class_name].absent = parseInt(row.cnt);
        else if (row.status === "L") byClass[row.class_name].leave = parseInt(row.cnt);
      }
      const rows = Object.entries(byClass).map(([className, s]) => {
        const total = s.present + s.absent + s.leave;
        return { className, ...s, total, percentage: total ? Math.round((s.present / total) * 100) : 0 };
      });
      return json(res, 200, { found: true, studentName: student.name, regNo: student.roll_no, rows });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // ── EXAM ──────────────────────────────────────────────────────────────────

  if (method === "GET" && pathname === "/api/exam/weights") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    try {
      const r = await db.query("SELECT * FROM public.exam_weights WHERE schedule_id=$1", [parseInt(scheduleId)]);
      if (!r.rows.length) return json(res, 200, { quiz: 10, assignment: 10, mid: 20, final: 60 });
      return json(res, 200, r.rows[0]);
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "PUT" && pathname.match(/^\/api\/exam\/weights/)) {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const { quiz, assignment, mid, final } = body;
    try {
      await db.query(
        `INSERT INTO public.exam_weights (schedule_id, quiz, assignment, mid, final) VALUES ($1,$2,$3,$4,$5)
         ON CONFLICT (schedule_id) DO UPDATE SET quiz=$2, assignment=$3, mid=$4, final=$5`,
        [parseInt(scheduleId), quiz, assignment, mid, final]
      );
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "GET" && pathname === "/api/exam/marks") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const className = reqUrl.searchParams.get("className");
    try {
      const [studentsR, marksR] = await Promise.all([
        db.query("SELECT * FROM public.students WHERE schedule_id=$1 AND class_name=$2 ORDER BY roll_no", [parseInt(scheduleId), className]),
        db.query("SELECT * FROM public.exam_marks WHERE schedule_id=$1 AND class_name=$2", [parseInt(scheduleId), className])
      ]);
      const marksMap = {};
      for (const m of marksR.rows) marksMap[m.roll_no] = m;
      return json(res, 200, studentsR.rows.map(s => ({
        id: marksMap[s.roll_no]?.id ?? null,
        rollNo: s.roll_no, name: s.name,
        quiz: marksMap[s.roll_no]?.quiz ?? null,
        assignment: marksMap[s.roll_no]?.assignment ?? null,
        mid: marksMap[s.roll_no]?.mid ?? null,
        final: marksMap[s.roll_no]?.final ?? null,
      })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "POST" && pathname === "/api/exam/marks") {
    const { scheduleId, className, rollNo, quiz, assignment, mid, final } = body;
    try {
      await db.query(
        `INSERT INTO public.exam_marks (schedule_id, class_name, roll_no, quiz, assignment, mid, final)
         VALUES ($1,$2,$3,$4,$5,$6,$7)
         ON CONFLICT (schedule_id, class_name, roll_no)
         DO UPDATE SET quiz=$4, assignment=$5, mid=$6, final=$7`,
        [scheduleId, className, rollNo, quiz, assignment, mid, final]
      );
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // ── FINANCE ───────────────────────────────────────────────────────────────

  if (method === "GET" && pathname === "/api/finance/schedules") {
    try {
      const r = await db.query("SELECT * FROM public.schedules ORDER BY created_at DESC");
      return json(res, 200, r.rows.map(s => ({
        id: s.id, userId: s.user_id, name: s.name,
        startDate: s.start_date, endDate: s.end_date,
        isPublic: s.is_public, createdAt: s.created_at
      })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "POST" && pathname === "/api/finance/login") {
    const { username, password } = body;
    try {
      const r = await db.query(
        "SELECT * FROM public.finance_accounts WHERE username=$1 AND password=$2",
        [username, password]
      );
      if (!r.rows.length) return json(res, 200, { success: false, message: "Invalid credentials" });
      return json(res, 200, { success: true, user: r.rows[0].username });
    } catch (e) { return json(res, 500, { success: false, message: e.message }); }
  }

  if (method === "POST" && pathname === "/api/finance/register") {
    const { username, password } = body;
    try {
      await db.query("INSERT INTO public.finance_accounts (username, password) VALUES ($1,$2)", [username, password]);
      return json(res, 200, { success: true, user: username });
    } catch (e) { return json(res, 500, { success: false, message: e.message }); }
  }

  if (method === "GET" && pathname === "/api/finance/staff") {
    try {
      const r = await db.query("SELECT * FROM public.support_staff ORDER BY name");
      return json(res, 200, r.rows.map(s => ({
        id: s.id, employeeId: s.employee_id, name: s.name,
        designation: s.designation, department: s.department
      })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "POST" && pathname === "/api/finance/staff") {
    const { employeeId, name, designation, department } = body;
    try {
      await db.query(
        "INSERT INTO public.support_staff (employee_id, name, designation, department) VALUES ($1,$2,$3,$4)",
        [employeeId, name, designation ?? "", department ?? ""]
      );
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "DELETE" && pathname.match(/^\/api\/finance\/staff\/\d+$/)) {
    const id = parseInt(pathname.split("/").pop());
    try {
      await db.query("DELETE FROM public.support_staff WHERE id=$1", [id]);
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "GET" && pathname.match(/^\/api\/finance\/persons\//)) {
    const type = pathname.split("/")[4];
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    try {
      if (type === "faculty") {
        const r = await db.query(
          "SELECT DISTINCT faculty as person_id, faculty as person_name FROM public.weekly_schedule WHERE schedule_id=$1 ORDER BY faculty",
          [parseInt(scheduleId)]
        );
        return json(res, 200, r.rows.map(r => ({ personId: r.person_id, personName: r.person_name })));
      } else {
        const r = await db.query(
          "SELECT roll_no as person_id, name as person_name FROM public.students WHERE schedule_id=$1 ORDER BY name",
          [parseInt(scheduleId)]
        );
        return json(res, 200, r.rows.map(r => ({ personId: r.person_id, personName: r.person_name })));
      }
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "GET" && pathname === "/api/finance/payments") {
    const { personType, period, scheduleId } = Object.fromEntries(reqUrl.searchParams);
    try {
      const r = scheduleId
        ? await db.query("SELECT * FROM public.finance_payments WHERE person_type=$1 AND period=$2 AND schedule_id=$3", [personType, period, parseInt(scheduleId)])
        : await db.query("SELECT * FROM public.finance_payments WHERE person_type=$1 AND period=$2", [personType, period]);
      return json(res, 200, r.rows.map(p => ({
        id: p.id, personType: p.person_type, personId: p.person_id,
        personName: p.person_name, scheduleId: p.schedule_id, period: p.period,
        amount: p.amount, paidAmount: p.paid_amount, paidDate: p.paid_date, notes: p.notes
      })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "POST" && pathname === "/api/finance/payments/bulk") {
    const { payments } = body;
    try {
      for (const p of payments) {
        await db.query(
          `INSERT INTO public.finance_payments (person_type, person_id, person_name, schedule_id, period, amount, paid_amount, paid_date, notes)
           VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
           ON CONFLICT DO NOTHING`,
          [p.personType, p.personId, p.personName, p.scheduleId ?? null, p.period, p.amount ?? 0, p.paidAmount ?? 0, p.paidDate ?? null, p.notes ?? ""]
        );
      }
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "GET" && pathname === "/api/finance/rates") {
    const { personType, scheduleId } = Object.fromEntries(reqUrl.searchParams);
    try {
      const r = scheduleId && scheduleId !== "null"
        ? await db.query("SELECT * FROM public.finance_rates WHERE person_type=$1 AND schedule_id=$2", [personType, parseInt(scheduleId)])
        : await db.query("SELECT * FROM public.finance_rates WHERE person_type=$1 AND schedule_id IS NULL", [personType]);
      return json(res, 200, r.rows.map(r => ({
        id: r.id, personType: r.person_type, personId: r.person_id,
        scheduleId: r.schedule_id, rate: r.rate
      })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "POST" && pathname === "/api/finance/rates/bulk") {
    const { rates } = body;
    try {
      for (const r of rates) {
        await db.query(
          `INSERT INTO public.finance_rates (person_type, person_id, schedule_id, rate)
           VALUES ($1,$2,$3,$4)
           ON CONFLICT (person_type, person_id, schedule_id) DO UPDATE SET rate=$4`,
          [r.personType, r.personId, r.scheduleId ?? null, r.rate]
        );
      }
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "GET" && pathname === "/api/finance/summary") {
    return json(res, 200, { byType: {}, overall: { totalDue: 0, totalPaid: 0, count: 0, paid: 0, partial: 0, unpaid: 0 } });
  }

  // ── FACULTY ACCESS ────────────────────────────────────────────────────────

  if (method === "GET" && pathname === "/api/faculty-access") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    try {
      const r = await db.query(
        "SELECT * FROM public.faculty_accounts WHERE schedule_id=$1 ORDER BY faculty_name",
        [parseInt(scheduleId)]
      );
      return json(res, 200, r.rows.map(f => ({
        id: f.id, scheduleId: f.schedule_id, facultyName: f.faculty_name,
        username: f.username, password: f.password, email: f.email,
        classes: [], subjects: [], createdAt: f.created_at
      })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "POST" && pathname === "/api/faculty-access/generate") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    try {
      const facultyR = await db.query(
        "SELECT DISTINCT faculty FROM public.weekly_schedule WHERE schedule_id=$1",
        [parseInt(scheduleId)]
      );
      let created = 0, skipped = 0;
      for (const row of facultyR.rows) {
        const username = row.faculty.toLowerCase().replace(/\s+/g, ".").replace(/[^a-z.]/g, "");
        const password = Math.random().toString(36).slice(2, 10);
        try {
          await db.query(
            "INSERT INTO public.faculty_accounts (schedule_id, faculty_name, username, password) VALUES ($1,$2,$3,$4)",
            [parseInt(scheduleId), row.faculty, username, password]
          );
          created++;
        } catch { skipped++; }
      }
      return json(res, 200, { created, skipped });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "POST" && pathname === "/api/faculty-access/login") {
    const { username, password } = body;
    try {
      const r = await db.query(
        `SELECT fa.*, s.name as schedule_title, s.start_date, s.end_date
         FROM public.faculty_accounts fa
         JOIN public.schedules s ON s.id = fa.schedule_id
         WHERE fa.username=$1 AND fa.password=$2`,
        [username, password]
      );
      if (!r.rows.length) {
        res.writeHead(401, { "content-type": "application/json" });
        return res.end(JSON.stringify({ error: "Invalid credentials" }));
      }
      return json(res, 200, r.rows.map(f => ({
        accountId: f.id, username: f.username, facultyName: f.faculty_name,
        scheduleId: f.schedule_id, scheduleTitle: f.schedule_title,
        startDate: f.start_date, endDate: f.end_date
      })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "PATCH" && pathname.match(/^\/api\/faculty-access\/\d+$/)) {
    const id = parseInt(pathname.split("/").pop());
    const { email } = body;
    try {
      const r = await db.query(
        "UPDATE public.faculty_accounts SET email=$1 WHERE id=$2 RETURNING *",
        [email ?? "", id]
      );
      return json(res, 200, r.rows[0]);
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "DELETE" && pathname.match(/^\/api\/faculty-access\/\d+$/)) {
    const id = parseInt(pathname.split("/").pop());
    try {
      await db.query("DELETE FROM public.faculty_accounts WHERE id=$1", [id]);
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "POST" && pathname === "/api/faculty-access/change-password") {
    const { accountId, currentPassword, newPassword } = body;
    try {
      const r = await db.query("SELECT * FROM public.faculty_accounts WHERE id=$1 AND password=$2", [accountId, currentPassword]);
      if (!r.rows.length) return json(res, 200, { success: false, error: "Current password is incorrect" });
      await db.query("UPDATE public.faculty_accounts SET password=$1 WHERE id=$2", [newPassword, accountId]);
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // ── IMPORT SAMPLE ENDPOINTS (return empty) ────────────────────────────────
  if (pathname.includes("/sample")) {
    return json(res, 200, []);
  }


  // POST /api/meeting
  if (method === "POST" && pathname === "/api/meeting") {
    const { date, start, end, faculty } = body;
    try {
      const q = await db.query("SELECT * FROM public.weekly_schedule WHERE schedule_id IS NULL");
      const rows = q.rows;
      
      // Parse time to minutes for comparison
      function timeToMin(t) {
        if (!t) return 0;
        const [time, period] = t.split(' ');
        let [h, m] = time.split(':').map(Number);
        if (period === 'PM' && h !== 12) h += 12;
        if (period === 'AM' && h === 12) h = 0;
        return h * 60 + m;
      }
      
      const dayNames = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
      const dayName = dayNames[new Date(date + 'T00:00:00').getDay()];
      const startMin = timeToMin(start);
      const endMin = timeToMin(end);
      
      // Filter rows for this day
      const dayRows = rows.filter(r => r.day === dayName && !r.type);
      
      // Find busy faculty in this time slot
      const busyFaculty = {};
      const allFaculty = [...new Set(rows.map(r => r.faculty))].sort();
      
      for (const r of dayRows) {
        const rStart = timeToMin(r.time_start);
        const rEnd = timeToMin(r.time_end);
        // Check overlap
        if (rStart < endMin && rEnd > startMin) {
          if (!busyFaculty[r.faculty]) busyFaculty[r.faculty] = [];
          busyFaculty[r.faculty].push({
            subject: r.subject,
            cls: r.class_name,
            loc: r.location,
            start: rStart,
            end: rEnd,
            type: r.lec_lab || "Lec"
          });
        }
      }
      
      // Filter by requested faculty if provided
      const targetFaculty = faculty && faculty.length > 0 ? faculty : allFaculty;
      
      const free = [];
      const busy = [];
      const summary = {};
      
      for (const f of targetFaculty) {
        if (busyFaculty[f]) {
          busy.push({ name: f, dept: rows.find(r => r.faculty === f)?.dept || '', records: busyFaculty[f] });
          summary[f] = { free: 0, busy: 1 };
        } else {
          free.push({ name: f, dept: rows.find(r => r.faculty === f)?.dept || '' });
          summary[f] = { free: 1, busy: 0 };
        }
      }
      
      return json(res, 200, {
        date, dayName, start, end,
        free, busy, summary
      });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // Unknown API route
  return json(res, 404, { error: "Not found" });
}

// ── Static file helpers ────────────────────────────────────────────────────
function getAppName() {
  try {
    const appJson = JSON.parse(fs.readFileSync(path.resolve(__dirname, "..", "app.json"), "utf-8"));
    return appJson.expo?.name || "App Landing Page";
  } catch { return "App Landing Page"; }
}

function serveManifest(platform, res) {
  const manifestPath = path.join(STATIC_ROOT, platform, "manifest.json");
  if (!fs.existsSync(manifestPath)) {
    res.writeHead(404, { "content-type": "application/json" });
    res.end(JSON.stringify({ error: `Manifest not found for platform: ${platform}` }));
    return;
  }
  const manifest = fs.readFileSync(manifestPath, "utf-8");
  res.writeHead(200, {
    "content-type": "application/json",
    "expo-protocol-version": "1",
    "expo-sfv-version": "0",
  });
  res.end(manifest);
}

function serveLandingPage(req, res, template, appName) {
  const protocol = req.headers["x-forwarded-proto"] || "https";
  const host = req.headers["x-forwarded-host"] || req.headers["host"];
  const html = template
    .replace(/BASE_URL_PLACEHOLDER/g, `${protocol}://${host}`)
    .replace(/EXPS_URL_PLACEHOLDER/g, host)
    .replace(/APP_NAME_PLACEHOLDER/g, appName);
  res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
  res.end(html);
}

function serveStaticFile(urlPath, res) {
  const safePath = path.normalize(urlPath).replace(/^(\.\.(\/|\\|$))+/, "");
  const filePath = path.join(STATIC_ROOT, safePath);
  if (!filePath.startsWith(STATIC_ROOT)) { res.writeHead(403); res.end("Forbidden"); return; }
  if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) { res.writeHead(404); res.end("Not Found"); return; }
  const contentType = MIME_TYPES[path.extname(filePath).toLowerCase()] || "application/octet-stream";
  res.writeHead(200, { "content-type": contentType });
  res.end(fs.readFileSync(filePath));
}

// ── Server ─────────────────────────────────────────────────────────────────
let landingPageTemplate = "";
try { landingPageTemplate = fs.readFileSync(TEMPLATE_PATH, "utf-8"); } catch { landingPageTemplate = "<html><body>Classes Record</body></html>"; }
const appName = getAppName();

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url || "/", `http://${req.headers.host}`);
  let pathname = url.pathname;

  if (basePath && pathname.startsWith(basePath)) {
    pathname = pathname.slice(basePath.length) || "/";
  }

  if (pathname.startsWith("/api/")) {
    try {
      await handleApi(req.method, pathname, req, res);
    } catch (e) {
      json(res, 500, { error: String(e) });
    }
    return;
  }

  if (pathname === "/" || pathname === "/manifest") {
    const platform = req.headers["expo-platform"];
    if (platform === "ios" || platform === "android") return serveManifest(platform, res);
    if (pathname === "/") return serveLandingPage(req, res, landingPageTemplate, appName);
  }

  serveStaticFile(pathname, res);
});

const port = parseInt(process.env.PORT || "3000", 10);
server.listen(port, "0.0.0.0", () => {
  console.log(`Server running on port ${port}`);
});