
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceScreen extends StatelessWidget {
const AttendanceScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Attendance'),
centerTitle: true,
),

body: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('attendance')
    .where('studentId', isEqualTo: 'student_001')
    .snapshots(),

builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return Center(
child: Text(
'Error loading attendance:\n${snapshot.error}',
textAlign: TextAlign.center,
),
);
}

final records = snapshot.data?.docs ?? [];

int present = 0;
int absent = 0;

for (final document in records) {
final data = document.data() as Map<String, dynamic>;

final status =
(data['status'] ?? '').toString().toLowerCase();

if (status == 'present') {
present++;
} else if (status == 'absent') {
absent++;
}
}

final total = records.length;

return ListView(
padding: const EdgeInsets.all(20),
children: [
const Text(
'Attendance Summary',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

Card(
elevation: 3,
child: Padding(
padding: const EdgeInsets.all(20),
child: Column(
children: [
const CircleAvatar(
radius: 40,
child: Icon(
Icons.person,
size: 45,
),
),

const SizedBox(height: 12),

const Text(
'Ahmed Khan',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 5),

const Text(
'Student ID: student_001',
style: TextStyle(
color: Colors.grey,
),
),

const SizedBox(height: 25),

Row(
mainAxisAlignment:
MainAxisAlignment.spaceAround,
children: [
_attendanceItem(
'Present',
present.toString(),
Colors.green,
),

_attendanceItem(
'Absent',
absent.toString(),
Colors.red,
),

_attendanceItem(
'Total',
total.toString(),
Colors.blue,
),
],
),
],
),
),
),

const SizedBox(height: 25),

const Text(
'Attendance History',
style: TextStyle(
fontSize: 19,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

if (records.isEmpty)
const Center(
child: Padding(
padding: EdgeInsets.all(20),
child: Text(
'No attendance records available.',
style: TextStyle(
color: Colors.grey,
),
),
),
),

...records.map((document) {
final data =
document.data() as Map<String, dynamic>;

final date =
data['date']?.toString() ?? 'Unknown date';

final status =
data['status']?.toString() ?? 'Unknown';

final isPresent =
status.toLowerCase() == 'present';

return Card(
margin: const EdgeInsets.only(bottom: 12),
child: ListTile(
leading: CircleAvatar(
child: Icon(
isPresent
? Icons.check
    : Icons.close,
),
),

title: Text(
date,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),

subtitle: Text('Ahmed Khan'),

trailing: Text(
status,
style: TextStyle(
fontWeight: FontWeight.bold,
color: isPresent
? Colors.green
    : Colors.red,
),
),
),
);
}),
],
);
},
),
);
}

Widget _attendanceItem(
String title,
String value,
Color color,
) {
return Column(
children: [
Text(
value,
style: TextStyle(
fontSize: 26,
fontWeight: FontWeight.bold,
color: color,
),
),

const SizedBox(height: 5),

Text(title),
],
);
}
}