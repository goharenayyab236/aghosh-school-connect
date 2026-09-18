import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'class_list_screen.dart';
import 'mark_attendance_screen.dart';
import 'homework_marks_screen.dart';
import 'teacher_exams_screen.dart';
import 'teacher_leave_screen.dart';
import 'class_notices_screen.dart';
import 'often_absent_screen.dart';

import '../common/notifications_screen.dart';
import '../common/profile_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
const TeacherHomeScreen({super.key});

@override
State<TeacherHomeScreen> createState() =>
_TeacherHomeScreenState();
}

class _TeacherHomeScreenState
extends State<TeacherHomeScreen> {
String teacherName = 'Teacher';
String teacherEmail = '';

bool isLoading = true;

// Current teacher's class
final String className = 'Grade 5';
final String section = 'A';

@override
void initState() {
super.initState();
loadTeacherProfile();
}

Future<void> loadTeacherProfile() async {
try {
final user = FirebaseAuth.instance.currentUser;

if (user == null) {
if (!mounted) return;

setState(() {
isLoading = false;
});

return;
}

final document = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .get();

if (!mounted) return;

if (document.exists) {
final data = document.data();

setState(() {
teacherName =
data?['name']?.toString() ?? 'Teacher';

teacherEmail =
data?['email']?.toString() ??
user.email ??
'';

isLoading = false;
});
} else {
setState(() {
teacherName = 'Teacher';
teacherEmail = user.email ?? '';
isLoading = false;
});
}
} catch (e) {
if (!mounted) return;

setState(() {
isLoading = false;
});
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Teacher Dashboard'),
centerTitle: true,
actions: [
IconButton(
tooltip: 'Notifications',
icon: const Icon(
Icons.notifications_outlined,
),
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const NotificationsScreen(),
),
);
},
),
IconButton(
tooltip: 'Profile',
icon: const Icon(
Icons.person_outline,
),
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const ProfileScreen(),
),
);
},
),
],
),

body: isLoading
? const Center(
child: CircularProgressIndicator(),
)
    : RefreshIndicator(
onRefresh: loadTeacherProfile,
child: SingleChildScrollView(
physics:
const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// =========================
// WELCOME CARD
// =========================

Card(
elevation: 4,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(18),
),
child: Padding(
padding:
const EdgeInsets.all(20),
child: Column(
children: [
Row(
children: [
CircleAvatar(
radius: 32,
backgroundColor:
Colors.blue.shade100,
child: Icon(
Icons.school,
size: 34,
color:
Colors.blue.shade700,
),
),

const SizedBox(width: 16),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Welcome back! 👋',
style: TextStyle(
color: Colors.grey,
fontSize: 14,
),
),

const SizedBox(
height: 4,
),

Text(
teacherName,
style:
const TextStyle(
fontSize: 23,
fontWeight:
FontWeight.bold,
),
),
],
),
),
],
),

const SizedBox(height: 18),

Container(
width: double.infinity,
padding:
const EdgeInsets.all(15),
decoration: BoxDecoration(
color:
Colors.blue.shade50,
borderRadius:
BorderRadius.circular(
12,
),
),
child: Row(
children: [
Icon(
Icons.class_,
color:
Colors.blue.shade700,
),

const SizedBox(width: 10),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
const Text(
'Assigned Class',
style: TextStyle(
color: Colors.grey,
fontSize: 12,
),
),

const SizedBox(
height: 3,
),

Text(
'$className - Section $section',
style:
const TextStyle(
fontWeight:
FontWeight.bold,
fontSize: 16,
),
),
],
),
),
],
),
),

if (teacherEmail.isNotEmpty) ...[
const SizedBox(height: 12),

Row(
children: [
const Icon(
Icons.email_outlined,
size: 18,
color: Colors.grey,
),

const SizedBox(width: 8),

Expanded(
child: Text(
teacherEmail,
style:
const TextStyle(
color: Colors.grey,
),
overflow:
TextOverflow.ellipsis,
),
),
],
),
],
],
),
),
),

const SizedBox(height: 25),

// =========================
// OVERVIEW
// =========================

const Text(
'Class Overview',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 14),

_buildOverviewGrid(),

const SizedBox(height: 28),

// =========================
// TEACHER TOOLS
// =========================

const Text(
'Teacher Tools',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 14),

GridView.count(
crossAxisCount: 2,
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
crossAxisSpacing: 15,
mainAxisSpacing: 15,
childAspectRatio: 1.15,
children: [
_toolCard(
context,
Icons.groups,
'My Classes',
() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const ClassListScreen(),
),
);
},
),

_toolCard(
context,
Icons.fact_check,
'Attendance',
() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const MarkAttendanceScreen(),
),
);
},
),

_toolCard(
context,
Icons.menu_book,
'Homework & Marks',
() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const HomeworkMarksScreen(),
),
);
},
),

// =========================
// EXAMS
// =========================

_toolCard(
context,
Icons.assignment,
'Exams',
() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const TeacherExamsScreen(),
),
);
},
),

_toolCard(
context,
Icons.event_note,
'Leave Requests',
() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const TeacherLeaveScreen(),
),
);
},
),

_toolCard(
context,
Icons.campaign,
'Class Notices',
() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const ClassNoticesScreen(),
),
);
},
),

_toolCard(
context,
Icons.person_search,
'Often Absent',
() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const OftenAbsentScreen(),
),
);
},
),
],
),

const SizedBox(height: 15),
],
),
),
),
);
}

// =========================================================
// CLASS OVERVIEW
// =========================================================

Widget _buildOverviewGrid() {
return StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('students')
    .where(
'className',
isEqualTo: className,
)
    .where(
'section',
isEqualTo: section,
)
    .snapshots(),
builder: (context, studentSnapshot) {
final studentCount =
studentSnapshot.data?.docs.length ?? 0;

return StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('homework')
    .where(
'className',
isEqualTo: className,
)
    .where(
'section',
isEqualTo: section,
)
    .snapshots(),
builder: (context, homeworkSnapshot) {
final homeworkCount =
homeworkSnapshot.data?.docs.length ?? 0;

return StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('exams')
    .where(
'className',
isEqualTo: className,
)
    .where(
'section',
isEqualTo: section,
)
    .snapshots(),
builder: (context, examSnapshot) {
final examCount =
examSnapshot.data?.docs.length ?? 0;

return StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('leave_requests')
    .where(
'status',
isEqualTo: 'Pending',
)
    .snapshots(),
builder:
(context, leaveSnapshot) {
final pendingLeaves =
leaveSnapshot.data?.docs.length ??
0;

return GridView.count(
crossAxisCount: 2,
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
crossAxisSpacing: 12,
mainAxisSpacing: 12,
childAspectRatio: 1.65,
children: [
_overviewCard(
Icons.groups,
'Students',
'$studentCount',
),

_overviewCard(
Icons.menu_book,
'Homework',
'$homeworkCount',
),

_overviewCard(
Icons.assignment,
'Exams',
'$examCount',
),

_overviewCard(
Icons.pending_actions,
'Pending Leaves',
'$pendingLeaves',
),
],
);
},
);
},
);
},
);
},
);
}

Widget _overviewCard(
IconData icon,
String title,
String value,
) {
return Card(
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
child: Padding(
padding: const EdgeInsets.all(14),
child: Row(
children: [
CircleAvatar(
radius: 22,
backgroundColor: Colors.blue.shade50,
child: Icon(
icon,
color: Colors.blue.shade700,
size: 23,
),
),

const SizedBox(width: 10),

Expanded(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
value,
style: const TextStyle(
fontSize: 21,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 2),

Text(
title,
style: const TextStyle(
color: Colors.grey,
fontSize: 12,
),
maxLines: 2,
overflow:
TextOverflow.ellipsis,
),
],
),
),
],
),
),
);
}

// =========================================================
// TOOL CARD
// =========================================================

Widget _toolCard(
BuildContext context,
IconData icon,
String title,
VoidCallback onTap,
) {
return Card(
elevation: 3,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
child: InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(14),
child: Padding(
padding: const EdgeInsets.all(15),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
icon,
size: 38,
color: Colors.blue,
),

const SizedBox(height: 12),

Text(
title,
textAlign: TextAlign.center,
style: const TextStyle(
fontWeight: FontWeight.w600,
),
),
],
),
),
),
);
}
}
