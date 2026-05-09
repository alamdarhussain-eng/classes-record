import pg from 'pg';
import fs from 'fs';

const { Client } = pg;
const client = new Client({
  connectionString: "postgresql://neondb_owner:npg_zoEq1a7BIHmV@ep-soft-firefly-apwxhm4x.c-7.us-east-1.aws.neon.tech/neondb?sslmode=require"
});

await client.connect();
console.log("✓ Connected!");

const raw = fs.readFileSync('/workspaces/classes-record/classes-record-app/backup.sql', 'utf8');
const lines = raw.split('\n').map(l => l.replace(/\r$/, ''));

let inCopy = false;
let copyTable = '';
let copyColumns = [];
let ok = 0, fail = 0;

for (const line of lines) {
  if (line.startsWith('COPY public.')) {
    inCopy = true;
    const m = line.match(/COPY public\.(\w+)\s*\(([^)]+)\)/);
    if (m) { copyTable = m[1]; copyColumns = m[2].split(',').map(c => c.trim()); }
    continue;
  }
  if (inCopy) {
    if (line === '\\.') { inCopy = false; continue; }
    if (line.startsWith('--') || !line.trim()) continue;
    const parts = line.split('\t');
    if (parts.length !== copyColumns.length) continue;
    const vals = parts.map(v => v === '\\N' ? null : v);
    const placeholders = vals.map((_, i) => `$${i + 1}`).join(', ');
    try {
      await client.query(
        `INSERT INTO public.${copyTable} (${copyColumns.join(', ')}) VALUES (${placeholders}) ON CONFLICT DO NOTHING`,
        vals
      );
      ok++;
    } catch(e) {
      // Only log first failure per table
      if (fail < 3) console.log(`FAIL [${copyTable}]: ${e.message.substring(0, 120)}`);
      fail++;
    }
  }
}

console.log(`\n✓ Done! ${ok} rows inserted, ${fail} failed`);
const tables = ['users','schedules','weekly_schedule','holidays','students','faculty_accounts'];
for (const t of tables) {
  const r = await client.query(`SELECT COUNT(*) FROM public.${t}`);
  console.log(`  ${t}: ${r.rows[0].count} rows`);
}
await client.end();
