import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportScreen extends StatelessWidget {
const AdminReportScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('School Reports'),
centerTitle: true,
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

return StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('attendance')
    .snapshots(),

builder: (context, attendanceSnapshot) {
final attendanceCount =
attendanceSnapshot.data?.docs.length ?? 0;

return StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('homework')
    .snapshots(),

builder: (context, homeworkSnapshot) {
final homeworkCount =
homeworkSnapshot.data?.docs.length ?? 0;

return StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('leave_requests')
    .snapshots(),

builder: (context, leaveSnapshot) {
final leaveCount =
leaveSnapshot.data?.docs.length ?? 0;

return ListView(
padding: const EdgeInsets.all(20),

children: [
const Text(
'Reports Overview',
style: TextStyle(
fontSize: 23,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

const Text(
'Tap a report to view detailed information.',
style: TextStyle(
color: Colors.grey,
),
),

const SizedBox(height: 20),

// STUDENTS
_reportCard(
context,
Icons.people,
'Total Students',
studentCount.toString(),
() {
_showStudentsReport(
context,
studentSnapshot.data?.docs ?? [],
);
},
),

// TEACHERS
_reportCard(
context,
Icons.school,
'Total Teachers',
teacherCount.toString(),
() {
_showTeachersReport(
context,
teacherSnapshot.data?.docs ?? [],
);
},
),

// ATTENDANCE
_reportCard(
context,
Icons.calendar_month,
'Attendance Records',
attendanceCount.toString(),
() {
_showAttendanceReport(
context,
attendanceSnapshot.data?.docs ?? [],
);
},
),

// HOMEWORK
_reportCard(
context,
Icons.menu_book,
'Homework Records',
homeworkCount.toString(),
() {
_showHomeworkReport(
context,
homeworkSnapshot.data?.docs ?? [],
);
},
),

// LEAVE REQUESTS
_reportCard(
context,
Icons.event_note,
'Leave Requests',
leaveCount.toString(),
() {
_showLeaveReport(
context,
leaveSnapshot.data?.docs ?? [],
);
},
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
},
),
);
}

// ============================================================
// REPORT CARD
// ============================================================

Widget _reportCard(
BuildContext context,
IconData icon,
String title,
String value,
VoidCallback onTap,
) {
return Card(
margin: const EdgeInsets.only(
bottom: 12,
),

child: ListTile(
onTap: onTap,

leading: CircleAvatar(
child: Icon(icon),
),

title: Text(
title,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),

subtitle: const Text(
'Tap to view details',
),

trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
Text(
value,
style: const TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(width: 10),

const Icon(
Icons.arrow_forward_ios,
size: 16,
),
],
),
),
);
}

// ============================================================
// STUDENTS REPORT
// ============================================================

void _showStudentsReport(
BuildContext context,
List<QueryDocumentSnapshot> docs,
) {
showModalBottomSheet(
context: context,
isScrollControlled: true,

builder: (context) {
return _reportSheet(
context,
'Student Report',
Icons.people,

docs.isEmpty
? const Center(
child: Padding(
padding: EdgeInsets.all(30),
child: Text(
'No students found.',
),
),
)
    : ListView.builder(
itemCount: docs.length,

itemBuilder: (context, index) {
final data =
docs[index].data()
as Map<String, dynamic>;

final name =
data['name']?.toString() ??
'Unknown Student';

final studentId =
data['studentId']?.toString() ??
'No ID';

final className =
data['className']?.toString() ??
'No class';

return Card(
child: ListTile(
leading: const CircleAvatar(
child: Icon(Icons.person),
),

title: Text(
name,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),

subtitle: Text(
'Student ID: $studentId\n'
'Class: $className',
),
),
);
},
),
);
},
);
}

// ============================================================
// TEACHERS REPORT
// ============================================================

void _showTeachersReport(
BuildContext context,
List<QueryDocumentSnapshot> docs,
) {
showModalBottomSheet(
context: context,
isScrollControlled: true,

builder: (context) {
return _reportSheet(
context,
'Teacher Report',
Icons.school,

docs.isEmpty
? const Center(
child: Padding(
padding: EdgeInsets.all(30),
child: Text(
'No teachers found.',
),
),
)
    : ListView.builder(
itemCount: docs.length,

itemBuilder: (context, index) {
final data =
docs[index].data()
as Map<String, dynamic>;

final name =
data['name']?.toString() ??
'Unknown Teacher';

final email =
data['email']?.toString() ??
'No email';

final phone =
data['phone']?.toString() ??
'No phone';

return Card(
child: ListTile(
leading: const CircleAvatar(
child: Icon(Icons.person),
),

title: Text(
name,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),

subtitle: Text(
'Email: $email\n'
'Phone: $phone',
),
),
);
},
),
);
},
);
}

// ============================================================
// ATTENDANCE REPORT
// ============================================================

void _showAttendanceReport(
BuildContext context,
List<QueryDocumentSnapshot> docs,
) {
int present = 0;
int absent = 0;

for (final doc in docs) {
final data =
doc.data() as Map<String, dynamic>;

final status =
data['status']?.toString().toLowerCase();

if (status == 'present') {
present++;
} else if (status == 'absent') {
absent++;
}
}

showModalBottomSheet(
context: context,
isScrollControlled: true,

builder: (context) {
return _reportSheet(
context,
'Attendance Report',
Icons.calendar_month,

Column(
children: [
Card(
child: ListTile(
leading: const Icon(
Icons.check_circle,
),
title: const Text(
'Present',
),
trailing: Text(
present.toString(),
style: const TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
),
),

Card(
child: ListTile(
leading: const Icon(
Icons.cancel,
),
title: const Text(
'Absent',
),
trailing: Text(
absent.toString(),
style: const TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
),
),

const SizedBox(height: 10),

const Align(
alignment: Alignment.centerLeft,
child: Text(
'Attendance History',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
),

const SizedBox(height: 10),

Expanded(
child: docs.isEmpty
? const Center(
child: Text(
'No attendance records.',
),
)
    : ListView.builder(
itemCount: docs.length,

itemBuilder: (context, index) {
final data =
docs[index].data()
as Map<String, dynamic>;

final studentName =
data['studentName']
    ?.toString() ??
'Student';

final date =
data['date']?.toString() ??
'No date';

final status =
data['status']?.toString() ??
'Unknown';

return Card(
child: ListTile(
title: Text(
studentName,
),
subtitle: Text(
'Date: $date',
),
trailing: Text(
status,
style: const TextStyle(
fontWeight:
FontWeight.bold,
),
),
),
);
},
),
),
],
),
);
},
);
}

// ============================================================
// HOMEWORK REPORT
// ============================================================

void _showHomeworkReport(
BuildContext context,
List<QueryDocumentSnapshot> docs,
) {
showModalBottomSheet(
context: context,
isScrollControlled: true,

builder: (context) {
return _reportSheet(
context,
'Homework Report',
Icons.menu_book,

docs.isEmpty
? const Center(
child: Padding(
padding: EdgeInsets.all(30),
child: Text(
'No homework records.',
),
),
)
    : ListView.builder(
itemCount: docs.length,

itemBuilder: (context, index) {
final data =
docs[index].data()
as Map<String, dynamic>;

final subject =
data['subject']?.toString() ??
'Subject';

final title =
data['title']?.toString() ??
'Homework';

final studentName =
data['studentName']
    ?.toString() ??
'Student';

final status =
data['status']?.toString() ??
'Pending';

final marks =
data['marks']?.toString() ??
'';

return Card(
child: ListTile(
leading: const CircleAvatar(
child: Icon(
Icons.menu_book,
),
),

title: Text(
title,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),

subtitle: Text(
'Student: $studentName\n'
'Subject: $subject\n'
'Status: $status'
'${marks.isNotEmpty ? '\nMarks: $marks' : ''}',
),
),
);
},
),
);
},
);
}

// ============================================================
// LEAVE REQUEST REPORT
// ============================================================

void _showLeaveReport(
BuildContext context,
List<QueryDocumentSnapshot> docs,
) {
showModalBottomSheet(
context: context,
isScrollControlled: true,

builder: (context) {
return _reportSheet(
context,
'Leave Request Report',
Icons.event_note,

docs.isEmpty
? const Center(
child: Padding(
padding: EdgeInsets.all(30),
child: Text(
'No leave requests found.',
),
),
)
    : ListView.builder(
itemCount: docs.length,

itemBuilder: (context, index) {
final data =
docs[index].data()
as Map<String, dynamic>;

final studentName =
data['studentName']
    ?.toString() ??
'Student';

final reason =
data['reason']?.toString() ??
'No reason';

final startDate =
data['startDate']?.toString() ??
'';

final endDate =
data['endDate']?.toString() ??
'';

final status =
data['status']?.toString() ??
'Pending';

return Card(
child: ListTile(
leading: const CircleAvatar(
child: Icon(
Icons.event_note,
),
),

title: Text(
studentName,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),

subtitle: Text(
'Reason: $reason\n'
'From: $startDate\n'
'To: $endDate',
),

trailing: Text(
status,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
),
);
},
),
);
},
);
}

// ============================================================
// COMMON REPORT SHEET
// ============================================================

Widget _reportSheet(
BuildContext context,
String title,
IconData icon,
Widget content,
) {
return SafeArea(
child: SizedBox(
height: MediaQuery.of(context).size.height * 0.75,

child: Padding(
padding: const EdgeInsets.all(20),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [
Row(
children: [
CircleAvatar(
child: Icon(icon),
),

const SizedBox(width: 12),

Expanded(
child: Text(
title,
style: const TextStyle(
fontSize: 21,
fontWeight: FontWeight.bold,
),
),
),

IconButton(
onPressed: () {
Navigator.pop(context);
},
icon: const Icon(Icons.close),
),
],
),

const SizedBox(height: 15),

Expanded(
child: content,
),
],
),
),
),
);
}
}
