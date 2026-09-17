
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'attendance_screen.dart';
import 'homework_screen.dart';
import 'notices_screen.dart';
import 'exams_results_screen.dart';
import 'leave_screen.dart';

import '../common/notifications_screen.dart';
import '../common/profile_screen.dart';

class ParentHomeScreen extends StatelessWidget {
const ParentHomeScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Parent Dashboard'),
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

body: SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

// Welcome
const Text(
'Welcome, Parent! 👋',
style: TextStyle(
fontSize: 26,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

const Text(
'Stay updated with your child’s school activities.',
style: TextStyle(
fontSize: 15,
color: Colors.grey,
),
),

const SizedBox(height: 25),

// Student Card
StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('students')
    .where('studentId', isEqualTo: 'student_001')
    .limit(1)
    .snapshots(),

builder: (context, snapshot) {

if (snapshot.connectionState == ConnectionState.waiting) {
return const Card(
child: Padding(
padding: EdgeInsets.all(25),
child: Center(
child: CircularProgressIndicator(),
),
),
);
}

if (snapshot.hasError) {
return Card(
child: Padding(
padding: const EdgeInsets.all(18),
child: Text(
'Error loading student: ${snapshot.error}',
),
),
);
}

if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
return const Card(
child: Padding(
padding: EdgeInsets.all(18),
child: Text(
'Student information not found.',
style: TextStyle(
color: Colors.grey,
),
),
),
);
}

final student =
snapshot.data!.docs.first.data()
as Map<String, dynamic>;

final studentName =
student['name'] ?? 'Ahmed Khan';

final className =
student['className'] ?? 'Class not assigned';

return Card(
elevation: 3,
child: Padding(
padding: const EdgeInsets.all(18),
child: Row(
children: [
CircleAvatar(
radius: 32,
backgroundColor: Colors.blue.shade100,
child: Icon(
Icons.person,
size: 35,
color: Colors.blue.shade700,
),
),

const SizedBox(width: 16),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Student',
style: TextStyle(
color: Colors.grey,
),
),

const SizedBox(height: 4),

Text(
studentName,
style: const TextStyle(
fontSize: 19,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 4),

Text(
className,
style: const TextStyle(
color: Colors.grey,
),
),
],
),
),
],
),
),
);
},
),

const SizedBox(height: 25),

const Text(
'Quick Access',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

GridView.count(
crossAxisCount: 2,
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
crossAxisSpacing: 15,
mainAxisSpacing: 15,
childAspectRatio: 1.15,
children: [

_dashboardCard(
context,
icon: Icons.calendar_month,
title: 'Attendance',
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const AttendanceScreen(),
),
);
},
),

_dashboardCard(
context,
icon: Icons.menu_book,
title: 'Homework',
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const HomeworkScreen(),
),
);
},
),

_dashboardCard(
context,
icon: Icons.assignment,
title: 'Exams & Results',
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const ExamsResultsScreen(),
),
);
},
),

_dashboardCard(
context,
icon: Icons.campaign,
title: 'Notices',
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const NoticesScreen(),
),
);
},
),

_dashboardCard(
context,
icon: Icons.event_available,
title: 'Leave Request',
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const LeaveScreen(),
),
);
},
),

_dashboardCard(
context,
icon: Icons.notifications,
title: 'Notifications',
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const NotificationsScreen(),
),
);
},
),
],
),
],
),
),
);
}

Widget _dashboardCard(
BuildContext context, {
required IconData icon,
required String title,
required VoidCallback onTap,
}) {
return Card(
elevation: 3,
child: InkWell(
borderRadius: BorderRadius.circular(12),
onTap: onTap,
child: Padding(
padding: const EdgeInsets.all(15),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
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
fontSize: 15,
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
