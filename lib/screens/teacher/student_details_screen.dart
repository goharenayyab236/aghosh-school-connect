import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDetailsScreen extends StatefulWidget {
final String studentDocumentId;
final Map<String, dynamic> studentData;

const StudentDetailsScreen({
super.key,
required this.studentDocumentId,
required this.studentData,
});

@override
State<StudentDetailsScreen> createState() =>
_StudentDetailsScreenState();
}

class _StudentDetailsScreenState
extends State<StudentDetailsScreen> {
bool isSaving = false;

late TextEditingController nameController;
late TextEditingController rollNumberController;
late TextEditingController studentIdController;
late TextEditingController parentNameController;
late TextEditingController parentPhoneController;

@override
void initState() {
super.initState();

nameController = TextEditingController(
text: widget.studentData['name']?.toString() ?? '',
);

rollNumberController = TextEditingController(
text:
widget.studentData['rollNumber']?.toString() ??
'',
);

studentIdController = TextEditingController(
text:
widget.studentData['studentId']?.toString() ??
widget.studentDocumentId,
);

parentNameController = TextEditingController(
text:
widget.studentData['parentName']?.toString() ??
'',
);

parentPhoneController = TextEditingController(
text:
widget.studentData['parentPhone']?.toString() ??
'',
);
}

@override
void dispose() {
nameController.dispose();
rollNumberController.dispose();
studentIdController.dispose();
parentNameController.dispose();
parentPhoneController.dispose();

super.dispose();
}

Future<void> saveStudent() async {
final name = nameController.text.trim();
final rollNumber =
rollNumberController.text.trim();
final studentId =
studentIdController.text.trim();

if (name.isEmpty || rollNumber.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Please enter student name and roll number.',
),
),
);
return;
}

setState(() {
isSaving = true;
});

try {
await FirebaseFirestore.instance
    .collection('students')
    .doc(widget.studentDocumentId)
    .update({
'name': name,
'rollNumber': rollNumber,
'studentId': studentId,
'parentName':
parentNameController.text.trim(),
'parentPhone':
parentPhoneController.text.trim(),
'updatedAt':
FieldValue.serverTimestamp(),
});

if (!mounted) return;

Navigator.pop(context);

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Student updated successfully.',
),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Error updating student:\n$e',
),
),
);
} finally {
if (mounted) {
setState(() {
isSaving = false;
});
}
}
}

void showEditDialog() {
showDialog(
context: context,
builder: (context) {
return AlertDialog(
title: const Text('Edit Student'),
content: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(
controller: nameController,
decoration: const InputDecoration(
labelText: 'Student Name',
prefixIcon:
Icon(Icons.person_outline),
),
),

const SizedBox(height: 12),

TextField(
controller: rollNumberController,
decoration: const InputDecoration(
labelText: 'Roll Number',
prefixIcon:
Icon(Icons.confirmation_number_outlined),
),
),

const SizedBox(height: 12),

TextField(
controller: studentIdController,
decoration: const InputDecoration(
labelText: 'Student ID',
prefixIcon:
Icon(Icons.badge_outlined),
),
),

const SizedBox(height: 12),

TextField(
controller: parentNameController,
decoration: const InputDecoration(
labelText: 'Parent Name',
prefixIcon:
Icon(Icons.family_restroom),
),
),

const SizedBox(height: 12),

TextField(
controller: parentPhoneController,
keyboardType:
TextInputType.phone,
decoration: const InputDecoration(
labelText: 'Parent Phone',
prefixIcon:
Icon(Icons.phone_outlined),
),
),
],
),
),
actions: [
TextButton(
onPressed: isSaving
? null
    : () {
Navigator.pop(context);
},
child: const Text('Cancel'),
),

ElevatedButton(
onPressed: isSaving
? null
    : () async {
Navigator.pop(context);
await saveStudent();
},
child: isSaving
? const SizedBox(
width: 18,
height: 18,
child:
CircularProgressIndicator(
strokeWidth: 2,
),
)
    : const Text('Save'),
),
],
);
},
);
}

@override
Widget build(BuildContext context) {
final className =
widget.studentData['className']
    ?.toString() ??
'Not assigned';

final section =
widget.studentData['section']
    ?.toString() ??
'';

return Scaffold(
appBar: AppBar(
title: const Text('Student Details'),
centerTitle: true,
actions: [
PopupMenuButton<String>(
onSelected: (value) {
if (value == 'edit') {
showEditDialog();
}
},
itemBuilder: (context) => const [
PopupMenuItem(
value: 'edit',
child: Row(
children: [
Icon(Icons.edit),
SizedBox(width: 10),
Text('Edit Student'),
],
),
),
],
),
],
),

body: StreamBuilder<DocumentSnapshot>(
stream: FirebaseFirestore.instance
    .collection('students')
    .doc(widget.studentDocumentId)
    .snapshots(),
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

final data =
snapshot.data?.data()
as Map<String, dynamic>? ??
widget.studentData;

final currentName =
data['name']?.toString() ??
nameController.text;

final currentRollNumber =
data['rollNumber']?.toString() ??
rollNumberController.text;

final currentStudentId =
data['studentId']?.toString() ??
studentIdController.text;

final currentParentName =
data['parentName']?.toString() ??
parentNameController.text;

final currentParentPhone =
data['parentPhone']?.toString() ??
parentPhoneController.text;

return ListView(
padding: const EdgeInsets.all(20),
children: [
// =========================
// PROFILE HEADER
// =========================
Card(
elevation: 3,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(18),
),
child: Padding(
padding:
const EdgeInsets.all(22),
child: Column(
children: [
CircleAvatar(
radius: 42,
child: Text(
currentName.isNotEmpty
? currentName[0]
    .toUpperCase()
    : '?',
style: const TextStyle(
fontSize: 30,
fontWeight:
FontWeight.bold,
),
),
),

const SizedBox(height: 14),

Text(
currentName,
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 23,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 5),

Text(
'$className - Section $section',
style: const TextStyle(
color: Colors.grey,
fontSize: 15,
),
),
],
),
),
),

const SizedBox(height: 22),

const Text(
'Student Information',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 12),

_informationCard(
Icons.person_outline,
'Student Name',
currentName,
),

_informationCard(
Icons.confirmation_number_outlined,
'Roll Number',
currentRollNumber,
),

_informationCard(
Icons.badge_outlined,
'Student ID',
currentStudentId,
),

_informationCard(
Icons.class_outlined,
'Class',
'$className - Section $section',
),

const SizedBox(height: 15),

const Text(
'Parent Information',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 12),

_informationCard(
Icons.family_restroom,
'Parent Name',
currentParentName.isEmpty
? 'Not added'
    : currentParentName,
),

_informationCard(
Icons.phone_outlined,
'Parent Phone',
currentParentPhone.isEmpty
? 'Not added'
    : currentParentPhone,
),

const SizedBox(height: 20),

SizedBox(
width: double.infinity,
height: 52,
child: ElevatedButton.icon(
onPressed: showEditDialog,
icon: const Icon(Icons.edit),
label: const Text(
'Edit Student',
),
),
),
],
);
},
),
);
}

Widget _informationCard(
IconData icon,
String title,
String value,
) {
return Card(
margin: const EdgeInsets.only(
bottom: 10,
),
child: ListTile(
leading: Icon(icon),
title: Text(
title,
style: const TextStyle(
fontSize: 12,
color: Colors.grey,
),
),
subtitle: Padding(
padding:
const EdgeInsets.only(top: 3),
child: Text(
value,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
),
),
),
),
);
}
}
