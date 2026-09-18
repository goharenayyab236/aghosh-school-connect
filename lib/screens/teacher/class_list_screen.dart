
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'student_details_screen.dart';

class ClassListScreen extends StatelessWidget {
const ClassListScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('My Classes'),
centerTitle: true,
),
body: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('classes')
    .snapshots(),
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return Center(
child: Padding(
padding: const EdgeInsets.all(20),
child: Text(
'Error loading classes:\n${snapshot.error}',
textAlign: TextAlign.center,
),
),
);
}

final classes = snapshot.data?.docs ?? [];

if (classes.isEmpty) {
return const Center(
child: Text(
'No classes found.',
style: TextStyle(
fontSize: 17,
color: Colors.grey,
),
),
);
}

return ListView.builder(
padding: const EdgeInsets.all(20),
itemCount: classes.length,
itemBuilder: (context, index) {
final document = classes[index];

final data =
document.data() as Map<String, dynamic>;

final className =
data['className']?.toString() ??
'Unknown Class';

final section =
data['section']?.toString() ?? '';

final teacherName =
data['teacherName']?.toString() ??
'Teacher not assigned';

return Card(
margin: const EdgeInsets.only(bottom: 15),
elevation: 3,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
child: InkWell(
borderRadius: BorderRadius.circular(14),
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
ClassStudentsScreen(
className: className,
section: section,
teacherName: teacherName,
),
),
);
},
child: Padding(
padding: const EdgeInsets.all(15),
child: Row(
children: [
CircleAvatar(
radius: 28,
child: Text(
'${index + 1}',
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
),

const SizedBox(width: 15),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
section.isEmpty
? className
    : '$className - Section $section',
style: const TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 6),
Text(
'Teacher: $teacherName',
style: const TextStyle(
color: Colors.grey,
),
),
],
),
),

const Icon(
Icons.arrow_forward_ios,
size: 16,
),
],
),
),
),
);
},
);
},
),
);
}
}

// =========================================================
// CLASS STUDENTS SCREEN
// =========================================================

class ClassStudentsScreen extends StatelessWidget {
final String className;
final String section;
final String teacherName;

const ClassStudentsScreen({
super.key,
required this.className,
required this.section,
required this.teacherName,
});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text(
section.isEmpty
? className
    : '$className - Section $section',
),
centerTitle: true,
),
body: StreamBuilder<QuerySnapshot>(
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
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return Center(
child: Padding(
padding: const EdgeInsets.all(20),
child: Text(
'Error loading students:\n${snapshot.error}',
textAlign: TextAlign.center,
),
),
);
}

final students = snapshot.data?.docs ?? [];

return ListView(
padding: const EdgeInsets.all(20),
children: [
// =========================
// CLASS INFORMATION CARD
// =========================
Card(
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
child: Padding(
padding: const EdgeInsets.all(18),
child: Column(
children: [
const Icon(
Icons.class_,
size: 42,
),

const SizedBox(height: 10),

Text(
section.isEmpty
? className
    : '$className - Section $section',
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

Text(
'Class Teacher: $teacherName',
style: const TextStyle(
color: Colors.grey,
),
),

const SizedBox(height: 5),

Text(
'${students.length} student${students.length == 1 ? '' : 's'}',
style: const TextStyle(
color: Colors.grey,
),
),
],
),
),
),

const SizedBox(height: 25),

const Text(
'Students',
style: TextStyle(
fontSize: 21,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 12),

if (students.isEmpty)
const Padding(
padding: EdgeInsets.all(20),
child: Center(
child: Text(
'No students found in this class.',
style: TextStyle(
color: Colors.grey,
),
),
),
),

// =========================
// STUDENT CARDS
// =========================
...students.map((document) {
final data =
document.data()
as Map<String, dynamic>;

final name =
data['name']?.toString() ??
'Unknown Student';

final rollNumber =
data['rollNumber']?.toString() ??
'Not assigned';

final studentId =
data['studentId']?.toString() ??
document.id;

return Card(
margin: const EdgeInsets.only(
bottom: 12,
),
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(14),
),
child: InkWell(
borderRadius:
BorderRadius.circular(14),
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
StudentDetailsScreen(
studentDocumentId:
document.id,
studentData: data,
),
),
);
},
child: Padding(
padding:
const EdgeInsets.all(15),
child: Row(
children: [
CircleAvatar(
radius: 27,
child: Text(
rollNumber,
style:
const TextStyle(
fontSize: 12,
fontWeight:
FontWeight.bold,
),
),
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
name,
style:
const TextStyle(
fontSize: 17,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 5),

Text(
'Roll No: $rollNumber',
style:
const TextStyle(
color: Colors.grey,
),
),

const SizedBox(height: 2),

Text(
'Student ID: $studentId',
style:
const TextStyle(
color: Colors.grey,
fontSize: 12,
),
),
],
),
),

const Icon(
Icons.arrow_forward_ios,
size: 16,
),
],
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
}
