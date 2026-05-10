import React, { useCallback } from "react";
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity, Platform,
} from "react-native";
import { Feather } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter, useFocusEffect } from "expo-router";
import * as ScreenOrientation from "expo-screen-orientation";
import { printOrShareHtml } from "@/utils/printHtml";

import { useColors } from "@/hooks/useColors";

const TOPICS = [
  {
    icon: "calendar" as const,
    color: "#6A1B9A",
    bg: "#F3E5F5",
    title: "1. Weekly Schedule",
    body: `The Weekly Schedule shows the institution-wide timetable in a 5-column Mon–Fri grid. Each cell lists the subject, class section, and room.\n\nThis shared schedule is imported from a standard Excel file and is visible to all users as the reference timetable.\n\nTo import:\n  • Tap Upload → Import Weekly Schedule\n  • Pick your WeeklySchedule.xlsx file\n  • Tap "Download sample file" to get a blank template first\n\nExcel columns: Faculty, Subject, Class, Deptt, Day, Time, End Time, Location, Lec/Lab, Elective, Email of User`,
  },
  {
    icon: "lock" as const,
    color: "#00695C",
    bg: "#E0F2F1",
    title: "2. My Schedules & Public Schedules",
    body: `My Schedules lets each faculty member maintain their own private timetable — independent of the shared sample.\n\nTo create a private schedule:\n  1. Tap My Schedules on the home screen\n  2. Register (username + password) or sign in\n  3. Tap + to create a schedule, e.g. "Summer 2026 – BEE"\n  4. Open any schedule to view its timetable grid\n  5. Use Upload to import entries, or + to add individual slots\n\nMaking a schedule public:\n  • Open a schedule → tap the toggle to mark it as Public\n  • Public schedules appear on the home screen under "Public Schedules"\n  • Anyone can view the timetable, teaching summary, meeting availability, gazetted holidays, and student attendance roster — without logging in\n  • New Entry is hidden in public view; Attendance roster allows students to search by Reg No`,
  },
  {
    icon: "edit-3" as const,
    color: "#E65100",
    bg: "#FFF3E0",
    title: "3. New Entry — Missed · Late · Makeup",
    body: `Use New Entry to record exceptions to the regular schedule:\n\n  Missed   – A class that was not conducted on its scheduled day\n  Late     – A class that started late\n  Makeup   – An extra class conducted to compensate for a missed one\n\nHow to record:\n  1. Select Faculty (cascading → Subject → Class)\n  2. Pick the Date the exception occurred\n  3. Choose Type: Missed / Late / Makeup\n  4. Select Time and End Time\n  5. Enter Location (optional)\n  6. Tap Save Entry\n\nMakeup notification:\n  After saving a Makeup entry, a notification sheet appears with enrolled students and their emails. Tap "Open Email Client" to send a pre-filled makeup class notification via your email app.\n\nBulk import via Excel: Upload → Import Data Entries\nColumns: Faculty, Subject, Class, Deptt, Date, Time, End Time, Type, Location, Lec/Lab, Email of User`,
  },
  {
    icon: "user-check" as const,
    color: "#1565C0",
    bg: "#E3F2FD",
    title: "4. Attendance",
    body: `Accessible from any private or public schedule dashboard.\n\nSelect a class from the dropdown to begin. Three tabs are available for teachers:\n\nMark tab (teachers only)\n  • Lists every scheduled session for the semester\n  • Tap a session to expand the student list\n  • Toggle P / A / L for each student\n  • Tap "✓ All Present" to mark everyone present in one tap\n  • Sessions already marked show a green ✓ checkmark with a P/A/L summary\n  • Tap Save to record attendance\n\nRoster tab\n  • Horizontal scrollable grid: students (rows) × dates (columns)\n  • Cells colour-coded: green P, red A, amber L\n  • Rightmost columns show P / A / L counts and attendance %\n  • % coloured green (≥75%), amber (≥60%), red (below 60%)\n  • Tap Download PDF to export\n  • In public view: shows a Reg No search bar instead — students enter their Reg No to see their own attendance across all classes at once\n\nStudents tab (teachers only)\n  • View all enrolled students with Reg No, Name, and Email\n  • Add a student: enter Reg No, Name, Email (optional) → tap +\n  • Bulk upload: Students.xlsx with RollNo and Name columns\n  • Download a blank Students template from the bulk upload row`,
  },
  {
    icon: "bar-chart-2" as const,
    color: "#2E7D32",
    bg: "#E8F5E9",
    title: "5. Teaching Summary",
    body: `Shows a per-subject, per-faculty breakdown of class counts:\n\n  TBC (To Be Conducted) – Scheduled classes in the date range, minus gazetted holidays\n  Missed               – Recorded missed classes\n  Makeup               – Recorded makeup classes\n  Late                 – Recorded late classes\n  Grand Total          – TBC − Missed + Makeup  (Late shown but not subtracted)\n\nBadge colours:\n  Red    Deficit  – Grand Total < TBC (faculty owes classes)\n  Green  Surplus  – Grand Total ≥ TBC (extra classes conducted)\n  Grey   On Track – Grand Total = TBC\n\nFilters:\n  • Date range — tap quick buttons: Today, Last Week, Since Sem Start\n  • Faculty filter\n  • Department tabs (ALL / ECE / FoC / H&S …)\n\nTap Download to export the full summary as a PDF.`,
  },
  {
    icon: "users" as const,
    color: "#AD1457",
    bg: "#FCE4EC",
    title: "6. Meeting Availability",
    body: `Check which faculty members are free or busy at a given date and time slot.\n\n  1. Enter the Date\n  2. Select Start Time and End Time of the meeting\n  3. Optionally filter to specific faculty members\n  4. Tap Check Availability\n\nResult tabs:\n  Free  – Faculty with no classes in the selected slot\n  Busy  – Faculty who have classes, with subject/room details\n\nThe Department summary shows a free/busy count per department.\nTap Download to share the result as a PDF.`,
  },
  {
    icon: "sun" as const,
    color: "#F57F17",
    bg: "#FFFDE7",
    title: "7. Gazetted Holidays",
    body: `Gazetted holidays are national or institutional off-days automatically excluded from the ToBeConducted count in the Teaching Summary.\n\nManaging holidays:\n  • Tap + to add a holiday (enter date + name)\n  • Tap the delete icon to remove a holiday\n\nExamples:\n  2026-03-23  Pakistan Day\n  2026-04-21  Eid ul Fitr\n  2026-05-01  Labour Day`,
  },
  {
    icon: "upload" as const,
    color: "#0277BD",
    bg: "#E1F5FE",
    title: "8. Importing Excel Files",
    body: `Four types of Excel imports are supported:\n\n  WeeklySchedule.xlsx\n    → Weekly Schedule → Upload → Import Weekly Schedule\n    → Columns: Faculty, Subject, Class, Deptt, Day, Time, End Time, Location, Lec/Lab, Elective, Email of User\n\n  DataEntries.xlsx\n    → New Entry → Upload → Import Data Entries\n    → Columns: Faculty, Subject, Class, Deptt, Date, Time, End Time, Type, Location, Lec/Lab, Email of User\n\n  Students.xlsx\n    → Attendance → Students tab → Upload\n    → Columns: RollNo, Name  (bulk enrol students into a class)\n    → Tap "Download Template" for a blank file\n\n  Picklists (Options Override)\n    → Weekly Schedule → Upload → Import Options (Picklists)\n    → Sheets with Faculty, Subject, Class, Deptt, Location columns\n    → Overrides the built-in dropdown lists\n\nTime values in Excel can be stored as fractions (0.375 = 09:00 AM) — converted automatically.`,
  },
  {
    icon: "download" as const,
    color: "#4527A0",
    bg: "#EDE7F6",
    title: "9. PDF Reports",
    body: `Every major screen has a Download (↓) button:\n\n  Weekly Schedule      → 5-column Mon–Fri timetable grid\n  Teaching Summary     → Full faculty-wise summary with deficit/surplus badges\n  Meeting Availability → Free/busy faculty list for the selected slot\n  Attendance Roster    → Student attendance grid with P/A/L counts and percentages\n  Tutorial             → This guide as a PDF\n\nThe PDF is generated on-device and shared via the Android share sheet — save to Files, email, WhatsApp, or print directly.`,
  },
  {
    icon: "key" as const,
    color: "#4E342E",
    bg: "#EFEBE9",
    title: "10. Faculty Access — Managing Credentials",
    body: `As a schedule owner you can generate individual login credentials for every faculty member in a semester.\n\nHow to set up:\n  1. Open My Schedules → sign in → select a semester\n  2. Tap the Faculty Access tile on the schedule dashboard\n  3. Tap "Generate All" — a username and password is created automatically for every faculty name found in that schedule's weekly timetable\n     • Username is derived from the faculty name (e.g. "Dr. Ahmed Khan" → ahmed.khan)\n     • Password is a random 8-character string\n     • Running "Generate All" again is safe — existing accounts are never overwritten\n  4. Tap any faculty card to reveal the full credentials in a pop-up\n     • The password is hidden by default — tap the eye icon to show it\n  5. Optionally enter an email address on the card for reference\n  6. Tap "Download Excel" to export Faculty_Credentials_<Schedule>.xlsx with all names, usernames, passwords, emails, and assigned classes\n\nOther actions per faculty card:\n  Regenerate  – creates a new random password (old one is replaced)\n  Delete      – removes the account entirely\n\nNote: passwords are always visible to the admin in plain text, even after a faculty member changes their own password.`,
  },
  {
    icon: "user" as const,
    color: "#1A237E",
    bg: "#E8EAF6",
    title: "11. Faculty Sign In — Scoped Access",
    body: `Faculty members log in through a separate entry point and only see their own classes.\n\nSigning in:\n  1. Tap "Faculty Sign In" on the home screen\n  2. Enter the username and password provided by the schedule owner\n  3. Tap Sign In\n\nAfter signing in, a personal dashboard appears with two tiles:\n\n  Attendance\n    • Mark tab — mark P / A / L for sessions in your classes only\n    • Roster tab — view the attendance grid for your classes\n    • Students tab is hidden (roster management is the admin's responsibility)\n\n  Exam Marks\n    • Enter Marks tab — enter Quiz / Assignment / Mid / Final marks for students in your classes\n    • Weights tab is visible but read-only (weights are set by the admin)\n\nChanging your password:\n  • Tap "Change Password" on the faculty dashboard\n  • Enter your current password, then the new password twice\n  • The admin can see the updated password in Faculty Access at any time\n\nSigning out:\n  • Tap "Sign Out" on the faculty dashboard to return to the home screen\n  • Your session is cleared and no data is stored after sign-out`,
  },
  {
    icon: "globe" as const,
    color: "#1976D2",
    bg: "#E3F2FD",
    title: "12. Public Schedules",
    body: `A schedule owner can make any of their private schedules visible to everyone — no login required.\n\nHow to publish a schedule:\n  1. Open My Schedules → sign in → select a semester\n  2. On the schedule dashboard tap the Public toggle to turn it ON\n  3. The schedule immediately appears on the home screen under the "Public Schedules" section\n  4. To make it private again, tap the toggle to turn it OFF\n\nWhat visitors can see (6 tiles, no login needed):\n  Weekly Schedule      – Full Mon–Fri timetable for the semester\n  Teaching Summary     – Per-faculty class counts, deficit/surplus status\n  Meeting Availability – Check which faculty are free at a given time\n  Gazetted Holidays    – List of public holidays used in TBC calculation\n  Attendance           – Student roster with P/A/L history (read-only)\n  Exam Marks           – Student self-service marks lookup\n\nWhat is hidden in public view:\n  • New Entry tile — visitors cannot add Missed/Late/Makeup entries\n  • Students tab in Attendance — only the owner can add/remove students\n  • Weights editing in Exam Marks — weights are visible but cannot be changed\n  • Enter Marks tab — marks entry requires login as owner or faculty\n\nStudent self-service — Attendance:\n  • Open a public schedule → Attendance → Roster tab\n  • A "Search by Reg No" bar appears at the top\n  • Student enters their registration number to see their own attendance across all classes in that schedule at a glance\n  • P / A / L counts and attendance percentage are shown per class\n\nStudent self-service — Exam Marks:\n  • Open a public schedule → Exam Marks → My Marks tab\n  • Student enters their Reg No\n  • Their Quiz, Assignment, Mid, and Final marks appear for every class in the schedule, along with the weighted total score`,
  },
];

function buildHtml(colors: { primary: string; foreground: string; background: string }) {
  const topicRows = TOPICS.map((t) => `
    <div style="margin-bottom:28px; padding:20px; background:#fff; border-radius:12px; border-left:5px solid ${t.color}; box-shadow:0 1px 4px rgba(0,0,0,0.08);">
      <h2 style="margin:0 0 10px 0; font-size:17px; color:${t.color};">${t.title}</h2>
      <p style="margin:0; font-size:14px; color:#333; line-height:1.7; white-space:pre-wrap;">${t.body}</p>
    </div>
  `).join("");

  return `
<!DOCTYPE html><html><head><meta charset="utf-8">
<style>
  body { font-family: 'Helvetica Neue', Arial, sans-serif; margin:0; padding:24px; background:#f5f5f5; }
  h1 { font-size:26px; color:${colors.primary}; margin-bottom:6px; }
  .sub { font-size:14px; color:#666; margin-bottom:28px; }
  .footer { text-align:center; font-size:11px; color:#aaa; margin-top:32px; }
</style></head><body>
  <h1>Classes Record — User Guide</h1>
  <p class="sub">Faculty Management System · ${new Date().toLocaleDateString("en-PK", { day: "numeric", month: "long", year: "numeric" })}</p>
  ${topicRows}
  <p class="footer">Generated by Classes Record App</p>
</body></html>
  `;
}

export default function TutorialScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();

  useFocusEffect(
    useCallback(() => {
      if (Platform.OS !== "web") {
        ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.PORTRAIT_UP).catch(() => {});
      }
    }, [])
  );

  async function handleDownload() {
    try {
      const html = buildHtml({ primary: colors.primary, foreground: colors.foreground, background: colors.background });
      await printOrShareHtml(html, "Save Tutorial PDF");
    } catch {
      // ignore
    }
  }

  const s = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    header: {
      backgroundColor: colors.primary,
      paddingTop: insets.top + (Platform.OS === "web" ? 67 : 16),
      paddingBottom: 20,
      paddingHorizontal: 20,
    },
    headerRow: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 10 },
    pill: {
      flexDirection: "row", alignItems: "center", gap: 5,
      backgroundColor: "rgba(255,255,255,0.2)", borderRadius: 20,
      paddingHorizontal: 12, paddingVertical: 6,
    },
    pillTxt: { color: "#fff", fontSize: 13, fontFamily: "Inter_600SemiBold" },
    headerTitle: { color: "#fff", fontSize: 22, fontFamily: "Inter_700Bold" },
    headerSub: { color: "rgba(255,255,255,0.75)", fontSize: 13, fontFamily: "Inter_400Regular", marginTop: 2 },

    scroll: { flex: 1 },
    topicCard: {
      marginHorizontal: 16, marginTop: 14,
      backgroundColor: colors.card,
      borderRadius: 14, borderWidth: 1, borderColor: colors.border,
      overflow: "hidden",
    },
    topicHeader: {
      flexDirection: "row", alignItems: "center", gap: 10,
      padding: 14, borderBottomWidth: 1, borderBottomColor: colors.border,
    },
    topicIcon: {
      width: 36, height: 36, borderRadius: 18,
      alignItems: "center", justifyContent: "center",
    },
    topicTitle: { fontSize: 15, fontFamily: "Inter_700Bold", color: colors.foreground, flex: 1 },
    topicBody: {
      padding: 14, fontSize: 13, fontFamily: "Inter_400Regular",
      color: colors.mutedForeground, lineHeight: 20,
    },
  });

  return (
    <View style={s.container}>
      <View style={s.header}>
        <View style={s.headerRow}>
          <View style={{ flexDirection: "row", gap: 8 }}>
            <TouchableOpacity style={s.pill} onPress={() => router.back()}>
              <Feather name="chevron-left" size={13} color="#fff" />
              <Text style={s.pillTxt}>Back</Text>
            </TouchableOpacity>
            <TouchableOpacity style={s.pill} onPress={() => router.replace("/" as never)}>
              <Feather name="home" size={13} color="#fff" />
              <Text style={s.pillTxt}>Home</Text>
            </TouchableOpacity>
          </View>
          <TouchableOpacity style={s.pill} onPress={handleDownload}>
            <Feather name="download" size={13} color="#fff" />
            <Text style={s.pillTxt}>Download PDF</Text>
          </TouchableOpacity>
        </View>
        <Text style={s.headerTitle}>Tutorial</Text>
        <Text style={s.headerSub}>App guide · 12 topics</Text>
      </View>

      <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 40 }}>
        {TOPICS.map((topic) => (
          <View key={topic.title} style={s.topicCard}>
            <View style={s.topicHeader}>
              <View style={[s.topicIcon, { backgroundColor: topic.bg }]}>
                <Feather name={topic.icon} size={18} color={topic.color} />
              </View>
              <Text style={s.topicTitle}>{topic.title}</Text>
            </View>
            <Text style={s.topicBody}>{topic.body}</Text>
          </View>
        ))}
      </ScrollView>
    </View>
  );
}
