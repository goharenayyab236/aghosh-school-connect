
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_notices_screen.dart';
import 'admin_exam_screen.dart';
import 'parent_link_screen.dart';
import 'admin_report_screen.dart';

import '../common/notifications_screen.dart';
import '../common/profile_screen.dart';

class AdminHomeScreen extends StatelessWidget {
const AdminHomeScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Admin Dashboard'),
centerTitle: true,
actions: [
IconButton(
icon: const Icon(Icons.notifications_outlined),
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const NotificationsScreen(),
),
);
},
),
IconButton(
icon: const Icon(Icons.person_outline),
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const ProfileScreen(),
),
);
},
),
],
),

body: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('students')
    .snapshots(),

builder: (context, studentSnapshot) {
final studentCount =
studentSnapshot.data?.docs.length ?? 0;

return StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('users')
    .where(
'role',
isEqualTo: 'teacher',
)
    .snapshots(),

builder: (context, teacherSnapshot) {
final teacherCount =
teacherSnapshot.data?.docs.length ?? 0;

return SingleChildScrollView(
padding: const EdgeInsets.all(20),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

// =========================
// WELCOME ADMIN CARD
// =========================

Card(
elevation: 3,
child: Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(
horizontal: 20,
vertical: 25,
),

child: Column(
mainAxisAlignment:
MainAxisAlignment.center,

children: [
CircleAvatar(
radius: 28,
child: const Icon(
Icons.admin_panel_settings,
size: 32,
),
),

const SizedBox(height: 12),

const Text(
'Welcome, Admin! 👋',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 25,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

const Text(
'Manage school information and records from your dashboard.',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.grey,
fontSize: 14,
),
),
],
),
),
),

const SizedBox(height: 25),

// =========================
// STATISTICS
// =========================

Row(
children: [
Expanded(
child: _statCard(
'Students',
studentCount.toString(),
Icons.people,
),
),

const SizedBox(width: 12),

Expanded(
child: _statCard(
'Teachers',
teacherCount.toString(),
Icons.school,
),
),
],
),

const SizedBox(height: 25),

// =========================
// ADMINISTRATION
// =========================

const Text(
'Administration',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

GridView.count(
crossAxisCount: 2,
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),

crossAxisSpacing: 15,
mainAxisSpacing: 15,

childAspectRatio: 1.15,

children: [
_adminCard(
context,
Icons.campaign,
'Notices',
() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const AdminNoticesScreen(),
),
);
},
),

_adminCard(
context,
Icons.event,
'Exams',
() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const AdminExamScreen(),
),
);
},
),

_adminCard(
context,
Icons.link,
'Parent Link',
() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const ParentLinkScreen(),
),
);
},
),

_adminCard(
context,
Icons.bar_chart,
'Reports',
() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const AdminReportScreen(),
),
);
},
),
],
),
],
),
);
},
);
},
),
);
}

// =========================
// STAT CARD
// =========================

Widget _statCard(
String title,
String value,
IconData icon,
) {
return Card(
elevation: 2,

child: Padding(
padding: const EdgeInsets.all(18),

child: Column(
children: [
Icon(
icon,
size: 32,
color: Colors.blue,
),

const SizedBox(height: 8),

Text(
value,
style: const TextStyle(
fontSize: 25,
fontWeight: FontWeight.bold,
),
),

Text(
title,
style: const TextStyle(
color: Colors.grey,
),
),
],
),
),
);
}

// =========================
// ADMIN CARD
// =========================

Widget _adminCard(
BuildContext context,
IconData icon,
String title,
VoidCallback onTap,
) {
return Card(
elevation: 3,

child: InkWell(
onTap: onTap,

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
