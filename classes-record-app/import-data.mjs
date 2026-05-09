import pg from 'pg';
import fs from 'fs';
const { Client } = pg;
const client = new Client({ connectionString: "postgresql://neondb_owner:npg_zoEq1a7BIHmV@ep-soft-firefly-apwxhm4x.c-7.us-east-1.aws.neon.tech/neondb?sslmode=require" });
await client.connect();
console.log("Connected!");
const lines = fs.readFileSync('/workspaces/classes-record/classes-record-app/backup.sql','utf8').split('\n').map(l=>l.replace(/\r$/,''));
let inCopy=false,copyTable='',copyColumns=[],ok=0,fail=0,seen={};
for(const line of lines){
  if(line.startsWith('COPY public.')){inCopy=true;const m=line.match(/COPY public\.(\w+)\s*\(([^)]+)\)/);if(m){copyTable=m[1];copyColumns=m[2].split(',').map(c=>c.trim());}continue;}
  if(inCopy){
    if(line==='\\.'){inCopy=false;continue;}
    if(line.startsWith('--')||!line.trim())continue;
    const parts=line.split('\t');
    if(parts.length!==copyColumns.length)continue;
    const vals=parts.map(v=>v==='\\N'?null:v);
    try{await client.query(`INSERT INTO public.${copyTable}(${copyColumns.join(',')})VALUES(${vals.map((_,i)=>`$${i+1}`).join(',')})ON CONFLICT DO NOTHING`,vals);ok++;}
    catch(e){if(!seen[copyTable]){console.log(`FAIL[${copyTable}]:${e.message.slice(0,100)}`);seen[copyTable]=1;}fail++;}
  }
}
console.log(`Done! ${ok} ok, ${fail} fail`);
for(const t of['users','schedules','weekly_schedule','holidays','students','faculty_accounts']){const r=await client.query(`SELECT COUNT(*) FROM public.${t}`);console.log(` ${t}:${r.rows[0].count}`);}
await client.end();