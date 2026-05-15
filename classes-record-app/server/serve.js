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
const ADMIN_EMAIL = "alamdar.hussain@seecs.edu.pk";
const RESEND_API_KEY = process.env.RESEND_API_KEY || "";
const otpStore = {};
async function sendOtpEmail(otp) {
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { "Content-Type": "application/json", "Authorization": "Bearer " + RESEND_API_KEY },
    body: JSON.stringify({
      from: "Classes Record <onboarding@resend.dev>",
      to: [ADMIN_EMAIL],
      subject: "Admin Login OTP - Classes Record",
      html: '<div style="font-family:sans-serif;padding:24px;max-width:400px"><h2 style="color:#1565C0">Classes Record Admin OTP</h2><p>Your one-time login code:</p><div style="font-size:42px;font-weight:bold;letter-spacing:12px;color:#1565C0;background:#E3F2FD;padding:20px;border-radius:8px;text-align:center">' + otp + '</div><p style="color:#666;font-size:13px;margin-top:16px">Expires in <b>5 minutes</b>. Do not share.</p></div>'
    })
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.message || "Resend API error");
}
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
  console.log("Admin check - received:", req.headers["x-admin-password"], "expected:", ADMIN_PASSWORD);
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

  // ========== FINANCE AUTH ROUTES ==========

  // POST /api/finance/auth/set-pin  (My Schedule user sets their finance PIN)
  if (method === "POST" && pathname === "/api/finance/auth/set-pin") {
    const { username, password, financePin } = body;
    if (!username || !password || !financePin) return json(res, 400, { success: false, message: "username, password and financePin required" });
    if (financePin.length < 4) return json(res, 400, { success: false, message: "Finance PIN must be at least 4 characters" });
    try {
      const r = await db.query("SELECT * FROM public.users WHERE username=$1 AND password=$2", [username.trim(), password.trim()]);
      if (!r.rows.length) return json(res, 200, { success: false, message: "Invalid username or password" });
      await db.query("UPDATE public.users SET finance_pin=$1 WHERE username=$2", [financePin.trim(), username.trim()]);
      return json(res, 200, { success: true, message: "Finance PIN set successfully" });
    } catch(e) { return json(res, 500, { success: false, message: String(e) }); }
  }

  // POST /api/finance/auth/login  (Finance login: username + finance_pin only)
  if (method === "POST" && pathname === "/api/finance/auth/login") {
    const { username, financePin } = body;
    if (!username || !financePin) return json(res, 400, { success: false, message: "Username and Finance PIN required" });
    try {
      const r = await db.query("SELECT * FROM public.users WHERE username=$1", [username.trim()]);
      if (!r.rows.length) return json(res, 200, { success: false, message: "Username not found" });
      const user = r.rows[0];
      if (!user.finance_pin || user.finance_pin.trim() === "") return json(res, 200, { success: false, message: "No Finance PIN set. Ask the schedule owner to set a Finance PIN from My Schedules → Finance PIN." });
      if (user.finance_pin.trim() !== financePin.trim()) return json(res, 200, { success: false, message: "Incorrect Finance PIN" });
      return json(res, 200, { success: true, user: username.trim(), message: "Finance login successful" });
    } catch(e) { return json(res, 500, { success: false, message: String(e) }); }
  }

  // ========== FINANCE DATA ROUTES ==========

  if (method === "GET" && pathname === "/api/finance/schedules") {
    const username = reqUrl.searchParams.get("username");
    try {
      const r = username
        ? await db.query("SELECT id, name, start_date, end_date FROM public.schedules WHERE user_id=$1 ORDER BY id DESC", [username])
        : await db.query("SELECT id, name, start_date, end_date FROM public.schedules ORDER BY id DESC");
      return json(res, 200, r.rows.map(s => ({ id: s.id, name: s.name, startDate: s.start_date, endDate: s.end_date })));
    } catch(e) { return json(res, 200, []); }
  }

  if (method === "GET" && pathname === "/api/finance/persons") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const personType = reqUrl.searchParams.get("personType");
    if (!scheduleId || !personType) return json(res, 200, []);
    try {
      let rows = [];
      if (personType === "student") {
        const r = await db.query("SELECT roll_no, name FROM public.students WHERE schedule_id=$1 ORDER BY roll_no", [parseInt(scheduleId)]);
        rows = r.rows.map((x) => ({ personId: x.roll_no, personName: `${x.name} (${x.roll_no})` }));
      } else if (personType === "faculty") {
        const r = await db.query("SELECT DISTINCT faculty FROM public.weekly_schedule WHERE schedule_id=$1 AND faculty != '_locations_' AND (type IS NULL OR type='') ORDER BY faculty", [parseInt(scheduleId)]);
        rows = r.rows.filter(x => x.faculty).map((x) => ({ personId: x.faculty, personName: x.faculty }));
      } else if (personType === "staff") {
        const r = await db.query("SELECT id, name FROM public.support_staff WHERE schedule_id=$1 ORDER BY name", [parseInt(scheduleId)]);
        rows = r.rows.map((x) => ({ personId: String(x.id), personName: x.name }));
      }
      return json(res, 200, rows);
    } catch(e) { return json(res, 200, []); }
  }

  if (method === "GET" && pathname === "/api/finance/payments") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const personType = reqUrl.searchParams.get("personType");
    const period = reqUrl.searchParams.get("period");
    if (!scheduleId || !personType || !period) return json(res, 200, []);
    try {
      const r = await db.query(
        "SELECT id, person_type, person_name, schedule_id, period, amount, status, note FROM public.finance_payments WHERE schedule_id=$1 AND person_type=$2 AND period=$3 ORDER BY person_name",
        [parseInt(scheduleId), personType, period]
      );
      return json(res, 200, r.rows.map(p => ({ id: p.id, personType: p.person_type, personName: p.person_name, scheduleId: p.schedule_id, period: p.period, amount: parseFloat(p.amount)||0, status: p.status, note: p.note||"" })));
    } catch(e) { return json(res, 200, []); }
  }

  // POST /api/finance/persons - add new person WEF a month
  // ========== FACULTY PORTAL ROUTES ==========

  if (method === "POST" && pathname === "/api/faculty-portal/login") {
    const { username, password } = body;
    if (!username || !password) return json(res, 400, { success: false, message: "Username and password required" });
    try {
      const r = await db.query(
        `SELECT fa.id, fa.schedule_id, fa.faculty_name, fa.username, fa.password, s.name as schedule_name
         FROM public.faculty_accounts fa
         JOIN public.schedules s ON s.id = fa.schedule_id
         WHERE fa.username=$1`,
        [username.trim()]
      );
      if (!r.rows.length) return json(res, 200, { success: false, message: "Username not found" });
      const account = r.rows[0];
      if (account.password !== password.trim()) return json(res, 200, { success: false, message: "Incorrect password" });
      const sessions = r.rows.map(a => ({
        id: a.id, scheduleId: a.schedule_id, scheduleName: a.schedule_name,
        facultyName: a.faculty_name, username: a.username
      }));
      return json(res, 200, { success: true, sessions });
    } catch(e) { return json(res, 500, { success: false, message: String(e) }); }
  }

  if (method === "POST" && pathname === "/api/faculty-portal/change-password") {
    const { username, currentPassword, newPassword } = body;
    try {
      const r = await db.query("SELECT id, password FROM public.faculty_accounts WHERE username=$1 LIMIT 1", [username]);
      if (!r.rows.length) return json(res, 200, { success: false, message: "Account not found" });
      if (r.rows[0].password !== currentPassword) return json(res, 200, { success: false, message: "Current password incorrect" });
      await db.query("UPDATE public.faculty_accounts SET password=$1 WHERE username=$2", [newPassword, username]);
      return json(res, 200, { success: true });
    } catch(e) { return json(res, 500, { success: false, message: String(e) }); }
  }

  // ========== FACULTY ACCESS ROUTES ==========

  // GET /api/faculty-access
  if (method === "GET" && pathname === "/api/faculty-access") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    if (!scheduleId) return json(res, 200, []);
    try {
      const r = await db.query(
        "SELECT id, schedule_id, faculty_name, username, password, email, created_at FROM public.faculty_accounts WHERE schedule_id=$1 ORDER BY faculty_name",
        [parseInt(scheduleId)]
      );
      return json(res, 200, r.rows.map(a => ({
        id: a.id, scheduleId: a.schedule_id, facultyName: a.faculty_name,
        username: a.username, password: a.password, email: a.email||"",
        createdAt: a.created_at
      })));
    } catch(e) { return json(res, 200, []); }
  }

  // POST /api/faculty-access/generate
  if (method === "POST" && pathname === "/api/faculty-access/generate") {
    const { scheduleId } = body;
    if (!scheduleId) return json(res, 400, { error: "scheduleId required" });
    try {
      // Get all faculty from weekly_schedule
      const faculty = await db.query(
        "SELECT DISTINCT faculty FROM public.weekly_schedule WHERE schedule_id=$1 AND faculty != '_locations_' AND (type IS NULL OR type='') ORDER BY faculty",
        [parseInt(scheduleId)]
      );
      let created = 0;
      for (const f of faculty.rows.filter(r => r.faculty)) {
        const name = f.faculty;
        // Check if already exists
        const existing = await db.query("SELECT id FROM public.faculty_accounts WHERE schedule_id=$1 AND faculty_name=$2", [parseInt(scheduleId), name]);
        if (existing.rows.length > 0) continue;
        // Generate username and password
        const nameParts = name.toLowerCase().replace(/[^a-z0-9 ]/g, '').split(' ').filter(Boolean);
        const username = (nameParts[nameParts.length-1] || 'faculty') + Math.floor(Math.random()*900+100);
        const chars = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
        const password = Array.from({length:8}, () => chars[Math.floor(Math.random()*chars.length)]).join('');
        await db.query(
          "INSERT INTO public.faculty_accounts (schedule_id, faculty_name, username, password, email) SELECT $1,$2,$3,$4,'' WHERE NOT EXISTS (SELECT 1 FROM public.faculty_accounts WHERE schedule_id=$1 AND faculty_name=$2)",
          [parseInt(scheduleId), name, username, password]
        );
        created++;
      }
      return json(res, 200, { success: true, created });
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  // PATCH /api/faculty-access/:id
  if (method === "PATCH" && pathname.match(/^\/api\/faculty-access\/\d+$/)) {
    const id = parseInt(pathname.split("/").pop());
    const { email, regenerate } = body;
    try {
      if (regenerate) {
        const chars = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
        const password = Array.from({length:8}, () => chars[Math.floor(Math.random()*chars.length)]).join('');
        await db.query("UPDATE public.faculty_accounts SET password=$1 WHERE id=$2", [password, id]);
      }
      if (email !== undefined) {
        await db.query("UPDATE public.faculty_accounts SET email=$1 WHERE id=$2", [email, id]);
      }
      return json(res, 200, { success: true });
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  // DELETE /api/faculty-access/:id
  if (method === "DELETE" && pathname.match(/^\/api\/faculty-access\/\d+$/)) {
    const id = parseInt(pathname.split("/").pop());
    try {
      await db.query("DELETE FROM public.faculty_accounts WHERE id=$1", [id]);
      return json(res, 200, { success: true });
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  // GET /api/faculty-access/download
  if (method === "GET" && pathname === "/api/faculty-access/download") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    if (!scheduleId) return json(res, 400, { error: "scheduleId required" });
    try {
      const r = await db.query(
        "SELECT faculty_name, username, password, email FROM public.faculty_accounts WHERE schedule_id=$1 ORDER BY faculty_name",
        [parseInt(scheduleId)]
      );
      let csv = "Faculty Name,Username,Password,Email\n";
      r.rows.forEach(a => { csv += `"${a.faculty_name}","${a.username}","${a.password}","${a.email||""}"\n`; });
      res.writeHead(200, { "Content-Type": "text/csv; charset=utf-8", "Content-Disposition": "attachment; filename=faculty-credentials.csv", "Access-Control-Allow-Origin": "*" });
      res.end(csv); return;
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  if (method === "POST" && pathname === "/api/finance/persons") {
    const { scheduleId, personType, name, email, activeFrom } = body;
    if (!scheduleId || !personType || !name) return json(res, 400, { error: "required" });
    try {
      if (personType === "faculty") {
        await db.query("INSERT INTO public.finance_faculty (schedule_id, name, email, active_from) VALUES ($1,$2,$3,$4) ON CONFLICT (schedule_id, name) DO UPDATE SET active_from=$4, active_to=NULL, email=$3", [scheduleId, name, email||"", activeFrom||null]);
      } else if (personType === "staff") {
        await db.query("INSERT INTO public.support_staff (schedule_id, name, role, email, active_from) VALUES ($1,$2,'Staff',$3,$4)", [scheduleId, name, email||"", activeFrom||null]);
      } else if (personType === "student") {
        await db.query("UPDATE public.students SET active_from=$1, active_to=NULL WHERE schedule_id=$2 AND roll_no=$3", [activeFrom||null, scheduleId, name]);
      }
      return json(res, 200, { success: true });
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  // PATCH /api/finance/persons/:id/deactivate - remove WEF a month
  if (method === "PATCH" && pathname.match(/^\/api\/finance\/persons\/[^/]+\/deactivate$/)) {
    const parts = pathname.split("/");
    const personId = parts[4];
    const { personType, scheduleId, activeTo } = body;
    try {
      if (personType === "faculty") {
        await db.query("UPDATE public.finance_faculty SET active_to=$1 WHERE id=$2", [activeTo, parseInt(personId)]);
      } else if (personType === "staff") {
        await db.query("UPDATE public.support_staff SET active_to=$1 WHERE id=$2", [activeTo, parseInt(personId)]);
      } else if (personType === "student") {
        await db.query("UPDATE public.students SET active_to=$1 WHERE schedule_id=$2 AND roll_no=$3", [activeTo, parseInt(scheduleId), personId]);
      }
      return json(res, 200, { success: true });
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  if (method === "POST" && pathname === "/api/finance/payments") {
    const { payments } = body;
    if (!Array.isArray(payments)) return json(res, 400, { error: "payments array required" });
    try {
      for (const p of payments) {
        await db.query(
          `INSERT INTO public.finance_payments (person_type, person_name, schedule_id, period, amount, status, note)
           VALUES ($1,$2,$3,$4,$5,$6,$7)
           ON CONFLICT (person_type, person_name, schedule_id, period)
           DO UPDATE SET amount=$5, status=$6, note=$7`,
          [p.personType, p.personName, p.scheduleId, p.period, p.amount||0, p.status||"Unpaid", p.note||""]
        );
      }
      return json(res, 200, { success: true });
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  if (method === "GET" && pathname === "/api/finance/summary") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const period = reqUrl.searchParams.get("period");
    if (!scheduleId || !period) return json(res, 200, { student: {}, faculty: {}, staff: {} });
    try {
      const r = await db.query(
        "SELECT person_type, status, COUNT(*) as cnt, SUM(amount) as total FROM public.finance_payments WHERE schedule_id=$1 AND period=$2 GROUP BY person_type, status",
        [parseInt(scheduleId), period]
      );
      const summary = { student: {}, faculty: {}, staff: {} };
      r.rows.forEach((row) => {
        if (!summary[row.person_type]) summary[row.person_type] = {};
        summary[row.person_type][row.status] = { count: parseInt(row.cnt), total: parseFloat(row.total)||0 };
      });
      return json(res, 200, summary);
    } catch(e) { return json(res, 200, { student: {}, faculty: {}, staff: {} }); }
  }

  if (method === "GET" && pathname === "/api/finance/rates") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const personType = reqUrl.searchParams.get("personType");
    if (!scheduleId || !personType) return json(res, 200, []);
    try {
      const r = await db.query("SELECT id, schedule_id, person_type, label, amount FROM public.finance_rates WHERE schedule_id=$1 AND person_type=$2 ORDER BY label", [parseInt(scheduleId), personType]);
      return json(res, 200, r.rows.map(r => ({ id: r.id, scheduleId: r.schedule_id, personType: r.person_type, label: r.label, amount: parseFloat(r.amount)||0 })));
    } catch(e) { return json(res, 200, []); }
  }

  if (method === "POST" && pathname === "/api/finance/rates") {
    const { scheduleId, personType, rates } = body;
    if (!scheduleId || !personType || !Array.isArray(rates)) return json(res, 400, { error: "required fields missing" });
    try {
      await db.query("DELETE FROM public.finance_rates WHERE schedule_id=$1 AND person_type=$2", [scheduleId, personType]);
      for (const rate of rates) {
        await db.query("INSERT INTO public.finance_rates (schedule_id, person_type, label, amount) VALUES ($1,$2,$3,$4)", [scheduleId, personType, rate.label, rate.amount||0]);
      }
      return json(res, 200, { success: true });
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  if (method === "GET" && pathname === "/api/finance/staff") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    if (!scheduleId || scheduleId === "undefined" || scheduleId === "[object Object]") return json(res, 200, []);
    try {
      const r = await db.query("SELECT id, schedule_id, name, role, contact FROM public.support_staff WHERE schedule_id=$1 ORDER BY name", [parseInt(scheduleId)]);
      return json(res, 200, r.rows.map(s => ({ id: s.id, scheduleId: s.schedule_id, name: s.name, role: s.role, contact: s.contact||"" })));
    } catch(e) { return json(res, 200, []); }
  }

  if (method === "POST" && pathname === "/api/finance/staff") {
    const { scheduleId, name, role, contact } = body;
    if (!scheduleId || !name) return json(res, 400, { error: "scheduleId and name required" });
    try {
      const r = await db.query("INSERT INTO public.support_staff (schedule_id, name, role, contact) VALUES ($1,$2,$3,$4) RETURNING id", [scheduleId, name, role||"", contact||""]);
      return json(res, 200, { success: true, id: r.rows[0].id });
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  if (method === "DELETE" && pathname.match(/^\/api\/finance\/staff\/\d+$/)) {
    const id = parseInt(pathname.split("/").pop());
    try {
      await db.query("DELETE FROM public.support_staff WHERE id=$1", [id]);
      return json(res, 200, { success: true });
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  if (method === "GET" && pathname === "/api/finance/student-fee") {
    const regNo = reqUrl.searchParams.get("regNo");
    if (!regNo) return json(res, 200, null);
    try {
      const r = await db.query(
        "SELECT fp.*, s.name as student_name FROM public.finance_payments fp LEFT JOIN public.students s ON s.roll_no=fp.person_name WHERE fp.person_type='student' AND fp.person_name=$1 ORDER BY fp.period DESC LIMIT 12",
        [regNo]
      );
      return json(res, 200, r.rows.length ? { regNo, name: r.rows[0].student_name||regNo, payments: r.rows } : null);
    } catch(e) { return json(res, 200, null); }
  }

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
      const u = r.rows[0];
      if (u.is_locked) return json(res, 200, { success: false, message: "Account is locked. Contact admin." });
      if (u.expiry_date && new Date(u.expiry_date) < new Date()) return json(res, 200, { success: false, message: "Account has expired. Contact admin." });
      return json(res, 200, { success: true, user: u.username });
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

  if (method === "POST" && pathname === "/api/admin/otp") {
    const { username, password } = body;
    if (username?.trim().toLowerCase() !== ADMIN_USERNAME.toLowerCase() || password?.trim() !== ADMIN_PASSWORD) return json(res, 401, { success:false, message:"Invalid username or password" });
    const otp = String(Math.floor(100000 + Math.random() * 900000));
    otpStore[ADMIN_EMAIL] = { otp, expires: Date.now() + 5*60*1000 };
    try { await sendOtpEmail(otp); return json(res, 200, { success:true, message:"OTP sent to " + ADMIN_EMAIL }); }
    catch(e) { return json(res, 500, { success:false, message:"Email error: " + e.message }); }
  }
  if (method === "POST" && pathname === "/api/admin/verify-otp") {
    const { otp } = body;
    const r = otpStore[ADMIN_EMAIL];
    if (!r) return json(res, 400, { success:false, message:"No OTP requested" });
    if (Date.now() > r.expires) { delete otpStore[ADMIN_EMAIL]; return json(res, 400, { success:false, message:"OTP expired" }); }
    if (r.otp !== String(otp).trim()) return json(res, 400, { success:false, message:"Incorrect OTP" });
    delete otpStore[ADMIN_EMAIL];
    return json(res, 200, { success:true, message:"Verified" });
  }
  if (method === "GET" && pathname === "/api/admin/test") {
    try {
      const r = await db.query("SELECT COUNT(*) as cnt FROM public.users");
      return json(res, 200, { success: true, count: r.rows[0].cnt });
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }
  if (method === "GET" && pathname === "/api/admin/users") {
    if (!requireAdmin(req, res)) return;
    try {
      const r = await db.query("SELECT id, username, password, pin, is_locked, expiry_date, created_at FROM public.users WHERE username != $1 ORDER BY id DESC", [ADMIN_USERNAME]);
      // Get schedule count for each user
      const schedCounts = await db.query("SELECT user_id, COUNT(*) as cnt FROM public.schedules GROUP BY user_id");
      const countMap = {};
      schedCounts.rows.forEach(s => { countMap[s.user_id] = parseInt(s.cnt); });
      const users = r.rows.map(u => ({
        id: u.id, username: u.username, password: u.password, pin: u.pin,
        isLocked: u.is_locked || false, registeredAt: u.created_at || null, expiryDate: u.expiry_date || null,
        scheduleCount: countMap[u.username] || 0
      }));
      console.log("Admin users found:", users.length);
      return json(res, 200, { success: true, users });
    } catch (e) { console.error('Admin users DB error:', String(e)); return json(res, 500, { success: false, message: String(e) }); }
  }

    // DELETE /api/admin/users/:id
  if (method === "DELETE" && pathname.match(/^\/api\/admin\/users\/\d+$/)) {
    const id = parseInt(pathname.split("/")[4]);
    try {
      const r = await db.query("DELETE FROM public.users WHERE id = $1 AND username != $2 RETURNING id", [id, ADMIN_USERNAME]);
      if (r.rows.length === 0) return json(res, 404, { success: false, message: "User not found or cannot delete admin" });
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // PATCH /api/admin/users/:id/password
  if (method === "PATCH" && pathname.match(/^\/api\/admin\/users\/\d+\/password$/)) {
    const id = parseInt(pathname.split("/")[4]);
    const { newPassword } = body;
    if (!newPassword) return json(res, 400, { success: false, message: "Missing newPassword" });
    try {
      const r = await db.query("UPDATE public.users SET password = $1 WHERE id = $2 AND username != $3 RETURNING id", [newPassword, id, ADMIN_USERNAME]);
      if (r.rows.length === 0) return json(res, 404, { success: false, message: "User not found" });
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // PATCH /api/admin/users/:id/lock
  if (method === "PATCH" && pathname.match(/^\/api\/admin\/users\/\d+\/lock$/)) {
    const id = parseInt(pathname.split("/")[4]);
    const { isLocked } = body;
    try {
      const r = await db.query("UPDATE public.users SET is_locked = $1 WHERE id = $2 RETURNING id, is_locked", [isLocked, id]);
      if (r.rows.length === 0) return json(res, 404, { success: false, message: "User not found" });
      return json(res, 200, { success: true, isLocked: r.rows[0].is_locked });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // PATCH /api/admin/users/:id/expiry
  if (method === "PATCH" && pathname.match(/^\/api\/admin\/users\/\d+\/expiry$/)) {
    const id = parseInt(pathname.split("/")[4]);
    const { expiryDate } = body;
    try {
      const r = await db.query("UPDATE public.users SET expiry_date = $1 WHERE id = $2 RETURNING id", [expiryDate || null, id]);
      if (r.rows.length === 0) return json(res, 404, { success: false, message: "User not found" });
      return json(res, 200, { success: true });
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  // ========== SCHEDULES ROUTES ==========

  if (method === "GET" && pathname === "/api/schedules/public") {
    try {
      const r = await db.query("SELECT * FROM public.schedules WHERE is_public = true ORDER BY created_at DESC");
      return json(res, 200, r.rows.map(s => ({
        id: s.id, userId: s.user_id, name: s.name,
        startDate: s.start_date, endDate: s.end_date,
        startHour: s.start_hour ?? 9, endHour: s.end_hour ?? 17, activeDays: s.active_days ?? 'Mon,Tue,Wed,Thu,Fri',
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
        startHour: s.start_hour ?? 9, endHour: s.end_hour ?? 17, activeDays: s.active_days ?? 'Mon,Tue,Wed,Thu,Fri',
        isPublic: s.is_public, createdAt: s.created_at
      })));
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "POST" && pathname === "/api/schedules") {
    const { username, name, startDate, endDate, startHour, endHour, activeDays } = body;
    if (!username || !name) return json(res, 400, { success: false, message: "username and name required" });
    try {
      const r = await db.query(
        "INSERT INTO public.schedules (id, user_id, name, start_date, end_date, start_hour, end_hour, active_days) VALUES (nextval('public.schedules_id_seq'), $1, $2, $3, $4, $5, $6, $7) RETURNING *",
        [username, name, startDate ?? null, endDate ?? null, startHour ?? 9, endHour ?? 17, activeDays ?? 'Mon,Tue,Wed,Thu,Fri']
      );
      const s = r.rows[0];
      return json(res, 200, { success: true, schedule: {
        id: s.id, userId: s.user_id, name: s.name,
        startDate: s.start_date, endDate: s.end_date,
        startHour: s.start_hour ?? 9, endHour: s.end_hour ?? 17, activeDays: s.active_days ?? 'Mon,Tue,Wed,Thu,Fri',
        isPublic: s.is_public, createdAt: s.created_at
      }});
    } catch (e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "PATCH" && pathname.match(/^\/api\/schedules\/\d+\/settings$/)) {
    const id = parseInt(pathname.split("/")[3]);
    const { startHour, endHour, activeDays } = body;
    try {
      await db.query(
        "UPDATE public.schedules SET start_hour = $1, end_hour = $2, active_days = $3 WHERE id = $4",
        [startHour ?? 9, endHour ?? 17, activeDays ?? 'Mon,Tue,Wed,Thu,Fri', id]
      );
      return json(res, 200, { success: true });
    } catch(e) { return json(res, 500, { error: e.message }); }
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

  if (method === "POST" && pathname === "/api/schedule/entry") {
    const { Faculty, Subject, Class, Dept, Day, Location, Time, EndTime, LecLab, Elective, User, scheduleId } = body;
    if (!Faculty || !Subject || !Class || !Day || !Time) return json(res, 400, { error: "Missing required fields" });
    try {
      function timeToHour2(t) {
        if (!t) return 9;
        const m = String(t).match(/(\d+):(\d+)\s*(AM|PM)/i);
        if (!m) return 9;
        let h = parseInt(m[1]);
        if (m[3].toUpperCase() === "PM" && h !== 12) h += 12;
        if (m[3].toUpperCase() === "AM" && h === 12) h = 0;
        return h;
      }
      const startH = timeToHour2(Time);
      const endH = timeToHour2(EndTime);
      const actualEndH = endH > startH ? endH : startH + 1;
      const sid = scheduleId != null && !isNaN(parseInt(scheduleId)) ? parseInt(scheduleId) : null;
      for (let h = startH; h < actualEndH; h++) {
        function hourLabel2(n) { const h12 = n % 12 || 12; const ap = n >= 12 ? "PM" : "AM"; return (h12 < 10 ? "0" : "") + h12 + ":00 " + ap; }
        await db.query(
          "INSERT INTO public.weekly_schedule (faculty, subject, class_name, dept, day, location, time_start, time_end, lec_lab, elective, user_email, sort_key, schedule_id) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)",
          [Faculty, Subject, Class, Dept || "", Day, Location || "", hourLabel2(h), hourLabel2(h+1), LecLab || "Lec", Elective || "", User || "", h * 60, sid]
        );
      }
      return json(res, 200, { success: true, inserted: actualEndH - startH });
    } catch(e) { return json(res, 500, { error: e.message }); }
  }

  if (method === "DELETE" && pathname.startsWith("/api/schedule/") && !pathname.startsWith("/api/schedules/")) {
    const id = parseInt(pathname.split("/").pop());
    if (!isNaN(id)) {
      try {
        await db.query("DELETE FROM public.weekly_schedule WHERE id = $1", [id]);
        return json(res, 200, { success: true });
      } catch(e) { return json(res, 500, { error: e.message }); }
    }
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
        ? await db.query("SELECT * FROM public.weekly_schedule WHERE (schedule_id = $1 OR schedule_id IS NULL) ORDER BY sort_key", [sidInt])
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

  // ========== STUDENTS & ATTENDANCE ROUTES ==========

  // GET /api/attendance/students/all - summary grouped by class
  if (method === "GET" && pathname === "/api/attendance/students/all") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    if (!scheduleId) return json(res, 400, { error: "scheduleId required" });
    try {
      const r = await db.query(
        `SELECT s.id, s.class_name, s.roll_no, s.name, s.email, s.created_at,
                w.subject, w.faculty
         FROM public.students s
         LEFT JOIN (
           SELECT DISTINCT class_name, subject, faculty FROM public.weekly_schedule
           WHERE schedule_id = $1 AND (type IS NULL OR type = '') AND class_name != '_ref_'
         ) w ON w.class_name = s.class_name
         WHERE s.schedule_id = $1
         ORDER BY s.class_name, w.subject, s.roll_no`,
        [parseInt(scheduleId)]
      );
      return json(res, 200, r.rows.map(s => ({
        id: s.id, className: s.class_name, rollNo: s.roll_no, name: s.name,
        email: s.email || "", enrolledAt: s.created_at ? s.created_at.toISOString().split("T")[0] : "",
        subject: s.subject || "", faculty: s.faculty || ""
      })));
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  // GET /api/attendance/students
  if (method === "GET" && pathname === "/api/attendance/students") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const className = reqUrl.searchParams.get("className");
    if (!scheduleId || !className) return json(res, 400, { error: "scheduleId and className required" });
    try {
      const r = await db.query(
        "SELECT id, schedule_id, class_name, roll_no, name, email, created_at FROM public.students WHERE schedule_id=$1 AND class_name=$2 ORDER BY roll_no",
        [parseInt(scheduleId), className]
      );
      return json(res, 200, r.rows.map(s => ({
        id: s.id, scheduleId: s.schedule_id, className: s.class_name,
        rollNo: s.roll_no, name: s.name, email: s.email || "",
        enrolledAt: s.created_at ? s.created_at.toISOString().split("T")[0] : ""
      })));
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  // POST /api/attendance/students
  if (method === "POST" && pathname === "/api/attendance/students") {
    const { scheduleId, className, rollNo, name, email } = body;
    if (!scheduleId || !className || !rollNo || !name) return json(res, 400, { error: "scheduleId, className, rollNo, name required" });
    try {
      const r = await db.query(
        "INSERT INTO public.students (schedule_id, class_name, roll_no, name, email, created_at) VALUES ($1,$2,$3,$4,$5,NOW()) RETURNING id, schedule_id, class_name, roll_no, name, email, created_at",
        [scheduleId, className, rollNo.toUpperCase(), name, email || ""]
      );
      const s = r.rows[0];
      return json(res, 200, { success: true, student: {
        id: s.id, scheduleId: s.schedule_id, className: s.class_name,
        rollNo: s.roll_no, name: s.name, email: s.email || "",
        enrolledAt: s.created_at ? s.created_at.toISOString().split("T")[0] : ""
      }});
    } catch(e) {
      if (String(e).includes("unique") || String(e).includes("duplicate")) return json(res, 409, { error: "Student already enrolled" });
      return json(res, 500, { error: String(e) });
    }
  }

  // DELETE /api/attendance/students/:id
  if (method === "DELETE" && pathname.match(/^\/api\/attendance\/students\/\d+$/)) {
    const id = parseInt(pathname.split("/").pop());
    try {
      await db.query("DELETE FROM public.students WHERE id=$1", [id]);
      return json(res, 200, { success: true });
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  // POST /api/attendance/mark
  if (method === "POST" && pathname === "/api/attendance/mark") {
    const { scheduleId, className, date, sessionTime, records } = body;
    if (!scheduleId || !className || !date || !records) return json(res, 400, { error: "Missing required fields" });
    try {
      for (const rec of records) {
        await db.query(
          `INSERT INTO public.attendance (schedule_id, class_name, student_id, date, session_time, status)
           VALUES ($1,$2,$3,$4,$5,$6)
           ON CONFLICT (schedule_id, class_name, student_id, date, session_time)
           DO UPDATE SET status=$6`,
          [scheduleId, className, rec.studentId, date, sessionTime || "", rec.status]
        );
      }
      return json(res, 200, { success: true });
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  // GET /api/attendance/roster
  if (method === "GET" && pathname === "/api/attendance/roster") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const className = reqUrl.searchParams.get("className");
    if (!scheduleId || !className) return json(res, 400, { error: "scheduleId and className required" });
    try {
      const r = await db.query(
        `SELECT a.student_id, a.date, a.session_time, a.status, s.roll_no, s.name
         FROM public.attendance a
         JOIN public.students s ON s.id = a.student_id
         WHERE a.schedule_id=$1 AND a.class_name=$2
         ORDER BY a.date, a.session_time, s.roll_no`,
        [parseInt(scheduleId), className]
      );
      return json(res, 200, r.rows.map(row => ({
        studentId: row.student_id, date: row.date, sessionTime: row.session_time,
        status: row.status, rollNo: row.roll_no, name: row.name
      })));
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  // GET /api/attendance/summary
  if (method === "GET" && pathname === "/api/attendance/summary") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    const className = reqUrl.searchParams.get("className");
    if (!scheduleId || !className) return json(res, 400, { error: "scheduleId and className required" });
    try {
      const r = await db.query(
        `SELECT s.roll_no, s.name, s.email,
                COUNT(a.id) as total,
                SUM(CASE WHEN a.status='P' THEN 1 ELSE 0 END) as present,
                SUM(CASE WHEN a.status='A' THEN 1 ELSE 0 END) as absent,
                SUM(CASE WHEN a.status='L' THEN 1 ELSE 0 END) as late
         FROM public.students s
         LEFT JOIN public.attendance a ON a.student_id=s.id AND a.schedule_id=$1 AND a.class_name=$2
         WHERE s.schedule_id=$1 AND s.class_name=$2
         GROUP BY s.id, s.roll_no, s.name, s.email
         ORDER BY s.roll_no`,
        [parseInt(scheduleId), className]
      );
      return json(res, 200, r.rows.map(row => ({
        rollNo: row.roll_no, name: row.name, email: row.email || "",
        total: parseInt(row.total)||0, present: parseInt(row.present)||0,
        absent: parseInt(row.absent)||0, late: parseInt(row.late)||0
      })));
    } catch(e) { return json(res, 500, { error: String(e) }); }
  }

  if (method === "GET" && pathname === "/api/import/sample/students") {
    const csv = "Class,Roll No,Name,Email\n2K25-BSCS-15A,001,Ahmed Ali,ahmed@example.com\n";
    res.writeHead(200, { "Content-Type": "text/csv; charset=utf-8", "Content-Disposition": "attachment; filename=SampleStudents.csv", "Access-Control-Allow-Origin": "*", "Cache-Control": "no-cache" });
    res.end(csv);
    return;
  }

  // Finance sample CSV downloads - dynamic with actual data
  if (method === "GET" && pathname === "/api/finance/rates/sample") {
    const personType = reqUrl.searchParams.get("personType") || "student";
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    let csv = "";
    try {
      if (personType === "student" && scheduleId) {
        const r = await db.query("SELECT roll_no, name, email FROM public.students WHERE schedule_id=$1 ORDER BY roll_no", [parseInt(scheduleId)]);
        csv = "Name / ID,Fee (Rs),Email,WhatsApp\n";
        if (r.rows.length > 0) {
          r.rows.forEach(s => { csv += `"${s.name} (${s.roll_no})",0,"${s.email||""}",""\n`; });
        } else {
          csv += "Ali Khan (2K24-001),15000,ali.khan@example.com,03001234567\n";
        }
      } else if (personType === "faculty" && scheduleId) {
        const r = await db.query("SELECT DISTINCT faculty FROM public.weekly_schedule WHERE schedule_id=$1 AND faculty != '_locations_' AND (type IS NULL OR type='') ORDER BY faculty", [parseInt(scheduleId)]);
        csv = "Name / ID,Pay (Rs),Email,WhatsApp\n";
        if (r.rows.length > 0) {
          r.rows.filter(f => f.faculty).forEach(f => { csv += `"${f.faculty}",0,"",""\n`; });
        } else {
          csv += "Dr. Ahmad Shah,80000,ahmad.shah@university.edu,03001234567\n";
        }
      } else if (personType === "staff" && scheduleId) {
        const r = await db.query("SELECT name, role, contact FROM public.support_staff WHERE schedule_id=$1 ORDER BY name", [parseInt(scheduleId)]);
        csv = "Name / ID,Pay (Rs),Email,WhatsApp\n";
        if (r.rows.length > 0) {
          r.rows.forEach(s => { csv += `"${s.name}",0,"","${s.contact||""}"\n`; });
        } else {
          csv += "John Security,25000,john@example.com,03001234567\n";
        }
      } else {
        if (personType === "student") csv = "Name / ID,Fee (Rs),Email,WhatsApp\nAli Khan (2K24-001),15000,ali.khan@example.com,03001234567\n";
        else csv = "Name / ID,Pay (Rs),Email,WhatsApp\nDr. Ahmad Shah,80000,ahmad.shah@university.edu,03001234567\n";
      }
    } catch(e) { csv = "Name / ID,Fee (Rs),Email,WhatsApp\n"; }
    res.writeHead(200, { "Content-Type": "text/csv; charset=utf-8", "Content-Disposition": `attachment; filename=${personType}-rates-template.csv`, "Access-Control-Allow-Origin": "*" });
    res.end(csv); return;
  }

  if (method === "GET" && pathname === "/api/finance/staff/sample") {
    const scheduleId = reqUrl.searchParams.get("scheduleId");
    let csv = "Name,Role,Pay (Rs),Contact,Email,WhatsApp\n";
    try {
      if (scheduleId) {
        const r = await db.query("SELECT name, role, contact FROM public.support_staff WHERE schedule_id=$1 ORDER BY name", [parseInt(scheduleId)]);
        if (r.rows.length > 0) {
          r.rows.forEach(s => { csv += `"${s.name}","${s.role||""}",0,"${s.contact||""}","",""\n`; });
        } else {
          csv += "John Security,Security Guard,25000,0300-1234567,john@example.com,03001234567\n";
        }
      } else {
        csv += "John Security,Security Guard,25000,0300-1234567,john@example.com,03001234567\n";
      }
    } catch(e) {}
    res.writeHead(200, { "Content-Type": "text/csv; charset=utf-8", "Content-Disposition": "attachment; filename=staff-template.csv", "Access-Control-Allow-Origin": "*" });
    res.end(csv); return;
  }

  if (method === "GET" && pathname === "/api/attendance/students/sample") {
    const csv = "Reg No,Student Name,Email,WhatsApp\n2K24-BEE-001,Ali Hassan,ali@example.com,03001234567\n2K24-BEE-002,Sara Ahmed,sara@example.com,03012345678\n";
    res.writeHead(200, { "Content-Type": "text/csv; charset=utf-8", "Content-Disposition": "attachment; filename=SampleStudents.csv", "Access-Control-Allow-Origin": "*" });
    res.end(csv); return;
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


  
  
    // POST /api/fix-null-schedule-ids — update NULL schedule_id rows
  if (method === "POST" && pathname === "/api/fix-null-schedule-ids") {
    try {
      const chunks = []; for await (const c of req) chunks.push(c);
      const body = JSON.parse(Buffer.concat(chunks).toString());
      const sid = parseInt(body.scheduleId);
      if (!sid || isNaN(sid)) return json(res, 400, { error: "scheduleId required" });
      const r = await db.query("UPDATE public.weekly_schedule SET schedule_id=$1 WHERE schedule_id IS NULL", [sid]);
      return json(res, 200, { success: true, updated: r.rowCount });
    } catch(e) { return json(res, 500, { error: e.message }); }
  }

  // POST /api/import/schedule — JSON bulk import (rows with camelCase or CSV column names)
  if (method === "POST" && pathname === "/api/import/schedule") {
    try {
      const chunks = []; for await (const c of req) chunks.push(c);
      const body = JSON.parse(Buffer.concat(chunks).toString());
      const { scheduleId, rows } = body;
      if (!scheduleId || !Array.isArray(rows) || !rows.length)
        return json(res, 400, { error: "scheduleId and rows[] required" });
      const sid = parseInt(scheduleId);
      if (isNaN(sid)) return json(res, 400, { error: "Invalid scheduleId" });
      let inserted = 0;
      for (const r of rows) {
        const faculty   = r.Faculty   || r.faculty   || "";
        const subject   = r.Subject   || r.subject   || "";
        const className = r.Class     || r.className || r.class_name || "";
        const dept      = r.Deptt     || r.dept      || r.Department  || "";
        const day       = r.Day       || r.day       || "";
        const location  = r.Location  || r.location  || "";
        const timeStart = r.Time      || r.timeStart || r.time_start  || "";
        const timeEnd   = r["End Time"] || r.EndTime || r.timeEnd || r.time_end || "";
        const lecLab    = r["Lec/Lab"] || r.LecLab   || r.lec_lab    || "Lec";
        const elective  = r.Elective  || r.elective  || "";
        const userEmail = r["Email of User"] || r.UserEmail || r.user_email || "";
        const sortKey   = r.SortKey   || r.sort_key  || 0;
        await db.query(
          `INSERT INTO public.weekly_schedule (faculty,subject,class_name,dept,day,location,time_start,time_end,lec_lab,elective,user_email,sort_key,schedule_id) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)`,
          [faculty, subject, className, dept, day, location, timeStart, timeEnd, lecLab, elective, userEmail, sortKey, sid]
        );
        inserted++;
      }
      return json(res, 200, { success: true, inserted });
    } catch(e) { return json(res, 500, { error: e.message }); }
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
        function excelTimeToStr(t) {
          if (typeof t === "number") {
            const totalMin = Math.round(t * 24 * 60);
            const h = Math.floor(totalMin / 60) % 24;
            const m = totalMin % 60;
            const ap = h >= 12 ? "PM" : "AM";
            const h12 = h % 12 || 12;
            return (h12 < 10 ? "0" : "") + h12 + ":" + (m < 10 ? "0" : "") + m + " " + ap;
          }
          return String(t||"");
        }
        const tsStr = excelTimeToStr(ts);
        const teStr = excelTimeToStr(te);
        const tm=tsStr.match(/(\d+):(\d+)\s*(AM|PM)/i);
        let h=0; if(tm){h=parseInt(tm[1]);if(tm[3].toUpperCase()==="PM"&&h!==12)h+=12;if(tm[3].toUpperCase()==="AM"&&h===12)h=0;}
        await db.query("INSERT INTO public.weekly_schedule (faculty,subject,class_name,dept,day,location,time_start,time_end,lec_lab,elective,user_email,sort_key,schedule_id) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)",
          [fac,sub,cls,dept,day,r.Location||r.location||"",tsStr,teStr,ll,el,em,(h*60),sidInt]);
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
  // Add new columns if they don't exist
  try {
    await db.query(`CREATE TABLE IF NOT EXISTS public.students (
      id SERIAL PRIMARY KEY,
      schedule_id INTEGER REFERENCES public.schedules(id) ON DELETE CASCADE,
      class_name TEXT NOT NULL,
      roll_no TEXT NOT NULL,
      name TEXT NOT NULL,
      email TEXT DEFAULT '',
      created_at TIMESTAMPTZ DEFAULT NOW(),
      UNIQUE(schedule_id, class_name, roll_no)
    ) ON CONFLICT DO NOTHING`);
    await db.query(`CREATE TABLE IF NOT EXISTS public.attendance (
      id SERIAL PRIMARY KEY,
      schedule_id INTEGER REFERENCES public.schedules(id) ON DELETE CASCADE,
      class_name TEXT NOT NULL,
      student_id INTEGER REFERENCES public.students(id) ON DELETE CASCADE,
      date DATE NOT NULL,
      session_time TEXT DEFAULT '',
      status TEXT NOT NULL DEFAULT 'P',
      UNIQUE(schedule_id, class_name, student_id, date, session_time)
    )`);
    console.log("\u2713 Attendance tables ensured");
  } catch(e) { console.log("Attendance table warning:", e.message); }

  try {
    await db.query(`CREATE TABLE IF NOT EXISTS public.finance_payments (
      id SERIAL PRIMARY KEY,
      person_type TEXT NOT NULL,
      person_name TEXT NOT NULL,
      schedule_id INTEGER REFERENCES public.schedules(id) ON DELETE CASCADE,
      period TEXT NOT NULL,
      amount NUMERIC(12,2) DEFAULT 0,
      status TEXT DEFAULT 'Unpaid',
      note TEXT DEFAULT '',
      UNIQUE(person_type, person_name, schedule_id, period)
    )`);
    await db.query(`CREATE TABLE IF NOT EXISTS public.finance_rates (
      id SERIAL PRIMARY KEY,
      schedule_id INTEGER REFERENCES public.schedules(id) ON DELETE CASCADE,
      person_type TEXT NOT NULL,
      label TEXT NOT NULL,
      amount NUMERIC(12,2) DEFAULT 0
    )`);
    await db.query(`CREATE TABLE IF NOT EXISTS public.support_staff (
      id SERIAL PRIMARY KEY,
      schedule_id INTEGER REFERENCES public.schedules(id) ON DELETE CASCADE,
      name TEXT NOT NULL,
      role TEXT DEFAULT '',
      contact TEXT DEFAULT ''
    )`);
    console.log("\u2713 Finance tables ensured");
  } catch(e) { console.log("Finance table warning:", e.message); }

  try {
    // Add active_from/active_to to students
    await db.query("ALTER TABLE public.students ADD COLUMN IF NOT EXISTS active_from TEXT DEFAULT NULL");
    await db.query("ALTER TABLE public.students ADD COLUMN IF NOT EXISTS active_to TEXT DEFAULT NULL");
    // Create finance_faculty table for tracking faculty with effective dates
    await db.query(`CREATE TABLE IF NOT EXISTS public.finance_faculty (
      id SERIAL PRIMARY KEY,
      schedule_id INTEGER REFERENCES public.schedules(id) ON DELETE CASCADE,
      name TEXT NOT NULL,
      email TEXT DEFAULT '',
      active_from TEXT DEFAULT NULL,
      active_to TEXT DEFAULT NULL,
      UNIQUE(schedule_id, name)
    )`);
    // Add active_from/active_to to support_staff
    await db.query("ALTER TABLE public.support_staff ADD COLUMN IF NOT EXISTS active_from TEXT DEFAULT NULL");
    await db.query("ALTER TABLE public.support_staff ADD COLUMN IF NOT EXISTS active_to TEXT DEFAULT NULL");
    await db.query("ALTER TABLE public.support_staff ADD COLUMN IF NOT EXISTS schedule_id INTEGER DEFAULT NULL");
    await db.query("ALTER TABLE public.support_staff ADD COLUMN IF NOT EXISTS email TEXT DEFAULT ''");
    console.log("\u2713 Finance effective date columns ensured");
  } catch(e) { console.log("Finance date columns warning:", e.message); }

  try {
    await db.query("ALTER TABLE public.users ADD COLUMN IF NOT EXISTS finance_pin TEXT DEFAULT ''");
  await db.query("ALTER TABLE public.users ADD COLUMN IF NOT EXISTS is_locked BOOLEAN DEFAULT FALSE");
  await db.query("ALTER TABLE public.users ADD COLUMN IF NOT EXISTS expiry_date TIMESTAMP DEFAULT NULL");
  await db.query("ALTER TABLE public.users ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW()");
    console.log("\u2713 finance_pin column ensured");
  } catch(e) { console.log("finance_pin warning:", e.message); }

  try {
    await db.query("ALTER TABLE public.schedules ADD COLUMN IF NOT EXISTS start_hour INTEGER DEFAULT 9");
    await db.query("ALTER TABLE public.schedules ADD COLUMN IF NOT EXISTS end_hour INTEGER DEFAULT 17");
    await db.query("ALTER TABLE public.schedules ADD COLUMN IF NOT EXISTS active_days TEXT DEFAULT 'Mon,Tue,Wed,Thu,Fri'");
    console.log("\u2713 Schedule columns ensured");
  } catch(e) { console.log("Column migration warning:", e.message); }

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
    try { await handleApi(req.method, pathname, req, res); } catch (e) { console.error('handleApi error:', e); json(res, 500, { success: false, message: String(e) }); }
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
