
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminExamScreen extends StatefulWidget {
const AdminExamScreen({super.key});

@override
State<AdminExamScreen> createState() =>
_AdminExamScreenState();
}

class _AdminExamScreenState extends State<AdminExamScreen> {
final examController = TextEditingController();
final subjectController = TextEditingController();

DateTime? selectedDate;

// =========================
// SELECT EXAM DATE
// =========================
Future<void> selectDate() async {
final today = DateTime(
DateTime.now().year,
DateTime.now().month,
DateTime.now().day,
);

final date = await showDatePicker(
context: context,
firstDate: today,
lastDate: DateTime.now().add(
const Duration(days: 730),
),
initialDate: today,
);

if (date != null) {
setState(() {
selectedDate = date;
});
}
}

// =========================
// FORMAT DATE
// =========================
String formatDate(DateTime date) {
return '${date.year}-'
'${date.month.toString().padLeft(2, '0')}-'
'${date.day.toString().padLeft(2, '0')}';
}

// =========================
// ADD EXAM
// =========================
Future<void> addExam() async {
if (examController.text.trim().isEmpty ||
subjectController.text.trim().isEmpty ||
selectedDate == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Please enter exam name, subject and date.',
),
),
);
return;
}

try {
await FirebaseFirestore.instance
    .collection('exams')
    .add({
'studentId': 'student_001',
'studentName': 'Ahmed Khan',
'examName': examController.text.trim(),
'subject': subjectController.text.trim(),
'examDate': formatDate(selectedDate!),
'totalMarks': '100',
'obtainedMarks': '0',
'createdAt': FieldValue.serverTimestamp(),
});

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Exam added successfully.',
),
),
);

examController.clear();
subjectController.clear();

setState(() {
selectedDate = null;
});
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Error adding exam: $e',
),
),
);
}
}

// =========================
// EDIT EXAM
// =========================
Future<void> editExam(
String documentId,
String currentExamName,
String currentSubject,
String currentDate,
String currentTotalMarks,
) async {
final editExamController =
TextEditingController(text: currentExamName);

final editSubjectController =
TextEditingController(text: currentSubject);

final editTotalMarksController =
TextEditingController(text: currentTotalMarks);

DateTime selectedExamDate;

try {
selectedExamDate = DateTime.parse(currentDate);
} catch (_) {
selectedExamDate = DateTime.now();
}

final today = DateTime(
DateTime.now().year,
DateTime.now().month,
DateTime.now().day,
);

// If existing exam has a past date,
// open the picker on today's date.
if (selectedExamDate.isBefore(today)) {
selectedExamDate = today;
}

await showDialog(
context: context,
builder: (dialogContext) {
return StatefulBuilder(
builder: (context, setDialogState) {
return AlertDialog(
title: const Text('Edit Exam'),

content: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
// EXAM NAME
TextField(
controller: editExamController,
decoration: const InputDecoration(
labelText: 'Exam Name',
border: OutlineInputBorder(),
),
),

const SizedBox(height: 15),

// SUBJECT
TextField(
controller: editSubjectController,
decoration: const InputDecoration(
labelText: 'Subject',
border: OutlineInputBorder(),
),
),

const SizedBox(height: 15),

// TOTAL MARKS
TextField(
controller: editTotalMarksController,
keyboardType: TextInputType.number,
decoration: const InputDecoration(
labelText: 'Total Marks',
border: OutlineInputBorder(),
),
),

const SizedBox(height: 15),

// EXAM DATE
InkWell(
onTap: () async {
final pickedDate =
await showDatePicker(
context: context,
initialDate: selectedExamDate,
firstDate: today,
lastDate: DateTime.now().add(
const Duration(days: 730),
),
);

if (pickedDate != null) {
setDialogState(() {
selectedExamDate = pickedDate;
});
}
},

child: InputDecorator(
decoration: const InputDecoration(
labelText: 'Exam Date',
border: OutlineInputBorder(),
suffixIcon:
Icon(Icons.calendar_today),
),

child: Text(
formatDate(selectedExamDate),
),
),
),
],
),
),

actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: const Text('Cancel'),
),

ElevatedButton(
onPressed: () async {
final newExamName =
editExamController.text.trim();

final newSubject =
editSubjectController.text.trim();

final newTotalMarks =
editTotalMarksController.text.trim();

if (newExamName.isEmpty ||
newSubject.isEmpty ||
newTotalMarks.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Please fill all exam fields.',
),
),
);
return;
}

final newDate =
formatDate(selectedExamDate);

try {
await FirebaseFirestore.instance
    .collection('exams')
    .doc(documentId)
    .update({
'examName': newExamName,
'subject': newSubject,
'examDate': newDate,
'totalMarks': newTotalMarks,
});

if (!mounted) return;

Navigator.pop(dialogContext);

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Exam updated successfully.',
),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content:
Text('Error updating exam: $e'),
),
);
}
},
child: const Text('Save'),
),
],
);
},
);
},
);

editExamController.dispose();
editSubjectController.dispose();
editTotalMarksController.dispose();
}

// =========================
// DELETE EXAM
// =========================
Future<void> deleteExam(String documentId) async {
final shouldDelete = await showDialog<bool>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Delete Exam'),

content: const Text(
'Are you sure you want to delete this exam?\n\n'
'It will be removed from the exam schedule.',
),

actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext, false);
},
child: const Text('Cancel'),
),

ElevatedButton(
onPressed: () {
Navigator.pop(dialogContext, true);
},
child: const Text('Delete'),
),
],
);
},
);

if (shouldDelete != true) return;

try {
await FirebaseFirestore.instance
    .collection('exams')
    .doc(documentId)
    .delete();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Exam deleted successfully.',
),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Error deleting exam: $e',
),
),
);
}
}

@override
void dispose() {
examController.dispose();
subjectController.dispose();
super.dispose();
}

// =========================
// UI
// =========================
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Exam Management'),
centerTitle: true,
),

body: SingleChildScrollView(
padding: const EdgeInsets.all(20),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.stretch,

children: [
const Text(
'Add Examination',
style: TextStyle(
fontSize: 23,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

TextField(
controller: examController,
decoration: const InputDecoration(
labelText: 'Exam Name',
hintText: 'e.g. Final Term Examination',
border: OutlineInputBorder(),
),
),

const SizedBox(height: 15),

TextField(
controller: subjectController,
decoration: const InputDecoration(
labelText: 'Subject',
hintText: 'e.g. Mathematics',
border: OutlineInputBorder(),
),
),

const SizedBox(height: 15),

OutlinedButton.icon(
onPressed: selectDate,
icon: const Icon(
Icons.calendar_today,
),
label: Text(
selectedDate == null
? 'Select Exam Date'
    : formatDate(selectedDate!),
),
),

const SizedBox(height: 20),

SizedBox(
height: 52,
child: ElevatedButton.icon(
onPressed: addExam,
icon: const Icon(Icons.add),
label: const Text('Add Exam'),
),
),

const SizedBox(height: 30),

const Text(
'Exam Schedule',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('exams')
    .snapshots(),

builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return const Card(
child: Padding(
padding: EdgeInsets.all(16),
child: Text(
'Unable to load exams.',
),
),
);
}

final exams =
snapshot.data?.docs ?? [];

if (exams.isEmpty) {
return const Card(
child: ListTile(
leading: Icon(Icons.event),
title: Text(
'No exams added yet',
),
subtitle: Text(
'Exam schedule will appear here.',
),
),
);
}

return Column(
children: exams.map((doc) {
final data =
doc.data()
as Map<String, dynamic>;

final examName =
data['examName']?.toString() ??
'Exam';

final subject =
data['subject']?.toString() ??
'';

final examDate =
data['examDate']?.toString() ??
'';

final totalMarks =
data['totalMarks']?.toString() ??
'100';

return Card(
margin:
const EdgeInsets.only(
bottom: 12,
),

child: ListTile(
leading: const CircleAvatar(
child: Icon(Icons.event),
),

title: Text(
examName,
style: const TextStyle(
fontWeight:
FontWeight.bold,
),
),

subtitle: Text(
'Subject: $subject\n'
'Date: $examDate\n'
'Total Marks: $totalMarks',
),

// THREE-DOT MENU
trailing:
PopupMenuButton<String>(
icon: const Icon(
Icons.more_vert,
),

onSelected: (value) {
if (value == 'edit') {
editExam(
doc.id,
examName,
subject,
examDate,
totalMarks,
);
}

if (value == 'delete') {
deleteExam(doc.id);
}
},

itemBuilder: (context) =>
const [
PopupMenuItem<String>(
value: 'edit',
child: Row(
children: [
Icon(Icons.edit),
SizedBox(width: 10),
Text('Edit'),
],
),
),

PopupMenuItem<String>(
value: 'delete',
child: Row(
children: [
Icon(Icons.delete),
SizedBox(width: 10),
Text('Delete'),
],
),
),
],
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
