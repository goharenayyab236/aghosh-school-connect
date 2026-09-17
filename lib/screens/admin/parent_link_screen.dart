import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParentLinkScreen extends StatefulWidget {
const ParentLinkScreen({super.key});

@override
State<ParentLinkScreen> createState() =>
_ParentLinkScreenState();
}

class _ParentLinkScreenState
extends State<ParentLinkScreen> {
final parentEmailController =
TextEditingController();

final studentNameController =
TextEditingController();

// =========================
// LINK PARENT
// =========================
Future<void> linkParent() async {
final parentEmail =
parentEmailController.text.trim().toLowerCase();

final studentName =
studentNameController.text.trim();

if (parentEmail.isEmpty ||
studentName.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Please enter parent email and student name.',
),
),
);
return;
}

try {
// Find student
final studentQuery =
await FirebaseFirestore.instance
    .collection('students')
    .where(
'name',
isEqualTo: studentName,
)
    .limit(1)
    .get();

if (studentQuery.docs.isEmpty) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Student not found.',
),
),
);
return;
}

final studentData =
studentQuery.docs.first.data();

final studentId =
studentData['studentId']?.toString();

if (studentId == null ||
studentId.isEmpty) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Student ID not found.',
),
),
);
return;
}

// Find parent account
final parentQuery =
await FirebaseFirestore.instance
    .collection('users')
    .where(
'email',
isEqualTo: parentEmail,
)
    .where(
'role',
isEqualTo: 'parent',
)
    .limit(1)
    .get();

if (parentQuery.docs.isEmpty) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Parent account not found.',
),
),
);
return;
}

final parentDocument =
parentQuery.docs.first;

// Save student link
await FirebaseFirestore.instance
    .collection('users')
    .doc(parentDocument.id)
    .update({
'studentId': studentId,
'studentName': studentData['name'],
});

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Parent linked successfully.',
),
),
);

parentEmailController.clear();
studentNameController.clear();
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Error linking parent: $e',
),
),
);
}
}

// =========================
// VIEW PARENT DETAILS
// =========================
void showParentDetails(
Map<String, dynamic> data,
) {
final name =
data['name']?.toString() ?? 'Parent';

final email =
data['email']?.toString() ?? 'No email';

final phone =
data['phone']?.toString() ?? 'No phone';

final studentName =
data['studentName']?.toString() ??
'Not linked';

final studentId =
data['studentId']?.toString() ??
'Not linked';

showDialog(
context: context,
builder: (context) {
return AlertDialog(
title: const Text(
'Parent Details',
),

content: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_detailRow(
'Parent Name',
name,
),

const SizedBox(height: 10),

_detailRow(
'Email',
email,
),

const SizedBox(height: 10),

_detailRow(
'Phone',
phone,
),

const SizedBox(height: 10),

_detailRow(
'Student',
studentName,
),

const SizedBox(height: 10),

_detailRow(
'Student ID',
studentId,
),
],
),

actions: [
TextButton(
onPressed: () {
Navigator.pop(context);
},
child: const Text('Close'),
),
],
);
},
);
}

// =========================
// DETAIL ROW
// =========================
Widget _detailRow(
String title,
String value,
) {
return RichText(
text: TextSpan(
style: const TextStyle(
color: Colors.black87,
fontSize: 15,
),
children: [
TextSpan(
text: '$title: ',
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
TextSpan(
text: value,
),
],
),
);
}

// =========================
// UNLINK PARENT
// =========================
Future<void> unlinkParent(
String documentId,
String parentName,
) async {
final confirm =
await showDialog<bool>(
context: context,
builder: (context) {
return AlertDialog(
title: const Text(
'Unlink Parent',
),

content: Text(
'Are you sure you want to unlink $parentName from the student?',
),

actions: [
TextButton(
onPressed: () {
Navigator.pop(
context,
false,
);
},
child: const Text('Cancel'),
),

ElevatedButton(
onPressed: () {
Navigator.pop(
context,
true,
);
},
child: const Text('Unlink'),
),
],
);
},
);

if (confirm != true) return;

try {
await FirebaseFirestore.instance
    .collection('users')
    .doc(documentId)
    .update({
'studentId': FieldValue.delete(),
'studentName': FieldValue.delete(),
});

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Parent unlinked successfully.',
),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Error unlinking parent: $e',
),
),
);
}
}

@override
void dispose() {
parentEmailController.dispose();
studentNameController.dispose();
super.dispose();
}

// =========================
// UI
// =========================
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'Parent Link',
),
centerTitle: true,
),

body: SingleChildScrollView(
padding: const EdgeInsets.all(20),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.stretch,

children: [
const Text(
'Link Parent to Student',
style: TextStyle(
fontSize: 23,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

TextField(
controller:
parentEmailController,
keyboardType:
TextInputType.emailAddress,
decoration:
const InputDecoration(
labelText: 'Parent Email',
prefixIcon:
Icon(Icons.email),
border:
OutlineInputBorder(),
),
),

const SizedBox(height: 16),

TextField(
controller:
studentNameController,
decoration:
const InputDecoration(
labelText: 'Student Name',
prefixIcon:
Icon(Icons.person),
border:
OutlineInputBorder(),
),
),

const SizedBox(height: 25),

SizedBox(
height: 52,
child: ElevatedButton.icon(
onPressed: linkParent,
icon: const Icon(
Icons.link,
),
label: const Text(
'Link Parent',
),
),
),

const SizedBox(height: 30),

const Text(
'Linked Parents',
style: TextStyle(
fontSize: 21,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

// =========================
// LINKED PARENTS
// =========================
StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore
    .instance
    .collection('users')
    .where(
'role',
isEqualTo: 'parent',
)
    .snapshots(),

builder:
(context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child:
CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return const Card(
child: Padding(
padding:
EdgeInsets.all(16),
child: Text(
'Unable to load parents.',
),
),
);
}

final parents =
snapshot.data?.docs ?? [];

// Only show parents that
// actually have a linked student.
final linkedParents =
parents.where((doc) {
final data =
doc.data()
as Map<String, dynamic>;

final studentId =
data['studentId']
    ?.toString();

final studentName =
data['studentName']
    ?.toString();

return studentId != null &&
studentId.isNotEmpty &&
studentName != null &&
studentName.isNotEmpty;
}).toList();

if (linkedParents.isEmpty) {
return const Card(
child: Padding(
padding:
EdgeInsets.all(20),
child: Column(
children: [
Icon(
Icons.people_outline,
size: 45,
),

SizedBox(height: 10),

Text(
'No linked parents yet.',
style: TextStyle(
fontWeight:
FontWeight.bold,
),
),

SizedBox(height: 5),

Text(
'Linked parent information will appear here.',
textAlign:
TextAlign.center,
),
],
),
),
);
}

return Column(
children:
linkedParents.map((doc) {
final data =
doc.data()
as Map<String, dynamic>;

final parentName =
data['name']
    ?.toString() ??
'Parent';

final email =
data['email']
    ?.toString() ??
'No email';

final studentName =
data['studentName']
    ?.toString() ??
'Student';

final studentId =
data['studentId']
    ?.toString() ??
'';

return Card(
margin:
const EdgeInsets.only(
bottom: 14,
),

child: Padding(
padding:
const EdgeInsets.all(
6,
),

child: ListTile(
leading:
const CircleAvatar(
child: Icon(
Icons.person,
),
),

title: Text(
parentName,
style:
const TextStyle(
fontWeight:
FontWeight.bold,
fontSize: 17,
),
),

subtitle: Padding(
padding:
const EdgeInsets.only(
top: 5,
),
child: Text(
'Email: $email\n'
'Student: $studentName\n'
'Student ID: $studentId',
),
),

// THREE DOT MENU
trailing:
PopupMenuButton<
String>(
icon: const Icon(
Icons.more_vert,
),

onSelected:
(value) {
if (value ==
'details') {
showParentDetails(
data,
);
}

if (value ==
'unlink') {
unlinkParent(
doc.id,
parentName,
);
}
},

itemBuilder:
(context) =>
const [
PopupMenuItem<
String>(
value:
'details',
child: Row(
children: [
Icon(
Icons
    .visibility,
),
SizedBox(
width: 10,
),
Text(
'View Details',
),
],
),
),

PopupMenuItem<
String>(
value:
'unlink',
child: Row(
children: [
Icon(
Icons
    .link_off,
),
SizedBox(
width: 10,
),
Text(
'Unlink',
),
],
),
),
],
),
),
),
);
}).toList(),
);
},
),

],
),
),
);
}
}
