import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeacherExamsScreen extends StatefulWidget {
const TeacherExamsScreen({super.key});

@override
State<TeacherExamsScreen> createState() => _TeacherExamsScreenState();
}

class _TeacherExamsScreenState extends State<TeacherExamsScreen> {
final String className = 'Grade 5';
final String section = 'A';

String _formatDate(dynamic value) {
if (value == null) return 'No date';

if (value is Timestamp) {
final date = value.toDate();
return '${date.day.toString().padLeft(2, '0')}-'
'${date.month.toString().padLeft(2, '0')}-'
'${date.year}';
}

if (value is DateTime) {
return '${value.day.toString().padLeft(2, '0')}-'
'${value.month.toString().padLeft(2, '0')}-'
'${value.year}';
}

return value.toString();
}

String _examKey(Map<String, dynamic> data) {
return '${data['examName'] ?? ''}|'
'${data['subject'] ?? ''}|'
'${data['examDate'] ?? ''}';
}

List<Map<String, dynamic>> _groupExams(
List<QueryDocumentSnapshot> documents,
) {
final Map<String, Map<String, dynamic>> grouped = {};

for (final doc in documents) {
final data = doc.data() as Map<String, dynamic>;

final key = _examKey(data);

if (!grouped.containsKey(key)) {
grouped[key] = {
'examName': data['examName'] ?? 'Unnamed Exam',
'subject': data['subject'] ?? 'Unknown Subject',
'examDate': data['examDate'],
'totalMarks': data['totalMarks'] ?? 0,
'documents': <Map<String, dynamic>>[],
};
}

(grouped[key]!['documents'] as List<Map<String, dynamic>>).add({
'id': doc.id,
...data,
});
}

final exams = grouped.values.toList();

exams.sort((a, b) {
final aDate = a['examDate']?.toString() ?? '';
final bDate = b['examDate']?.toString() ?? '';
return bDate.compareTo(aDate);
});

return exams;
}

Future<void> _deleteExam(Map<String, dynamic> exam) async {
final examName = exam['examName'] ?? 'this exam';
final subject = exam['subject'] ?? '';

final confirmed = await showDialog<bool>(
context: context,
builder: (context) {
return AlertDialog(
title: const Text('Delete Exam'),
content: Text(
'Are you sure you want to delete "$examName"'
'${subject.toString().isNotEmpty ? ' ($subject)' : ''}?\n\n'
'This will delete the exam results for all students in this class.',
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context, false),
child: const Text('Cancel'),
),
ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
foregroundColor: Colors.white,
),
onPressed: () => Navigator.pop(context, true),
child: const Text('Delete'),
),
],
);
},
);

if (confirmed != true) return;

try {
final documents =
exam['documents'] as List<Map<String, dynamic>>;

final batch = FirebaseFirestore.instance.batch();

for (final studentExam in documents) {
final documentId = studentExam['id'] as String;

final ref = FirebaseFirestore.instance
    .collection('exams')
    .doc(documentId);

batch.delete(ref);
}

await batch.commit();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Exam deleted successfully'),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Could not delete exam: $e'),
),
);
}
}

Future<void> _editExam(Map<String, dynamic> exam) async {
final documents =
exam['documents'] as List<Map<String, dynamic>>;

final firstStudent =
documents.isNotEmpty ? documents.first : <String, dynamic>{};

final examNameController = TextEditingController(
text: exam['examName']?.toString() ?? '',
);

final subjectController = TextEditingController(
text: exam['subject']?.toString() ?? '',
);

final totalMarksController = TextEditingController(
text: exam['totalMarks']?.toString() ?? '',
);

final Map<String, TextEditingController> marksControllers = {};

for (final student in documents) {
final studentId = student['studentId']?.toString() ?? '';

marksControllers[studentId] = TextEditingController(
text: student['obtainedMarks']?.toString() ?? '0',
);
}

final result = await showDialog<bool>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Edit Exam'),
content: SizedBox(
width: 500,
child: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(
controller: examNameController,
decoration: const InputDecoration(
labelText: 'Exam Name',
border: OutlineInputBorder(),
),
),
const SizedBox(height: 12),

TextField(
controller: subjectController,
decoration: const InputDecoration(
labelText: 'Subject',
border: OutlineInputBorder(),
),
),
const SizedBox(height: 12),

TextField(
controller: totalMarksController,
keyboardType: TextInputType.number,
decoration: const InputDecoration(
labelText: 'Total Marks',
border: OutlineInputBorder(),
),
),

const SizedBox(height: 20),

const Align(
alignment: Alignment.centerLeft,
child: Text(
'Student Marks',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
),

const SizedBox(height: 10),

...documents.map((student) {
final studentId =
student['studentId']?.toString() ?? '';

final studentName =
student['studentName']?.toString() ??
'Student';

return Padding(
padding:
const EdgeInsets.only(bottom: 12),
child: TextField(
controller:
marksControllers[studentId],
keyboardType:
const TextInputType.numberWithOptions(
decimal: true,
),
decoration: InputDecoration(
labelText: '$studentName - Marks',
border: const OutlineInputBorder(),
),
),
);
}),
],
),
),
),
actions: [
TextButton(
onPressed: () => Navigator.pop(dialogContext, false),
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () {
if (examNameController.text.trim().isEmpty ||
subjectController.text.trim().isEmpty ||
totalMarksController.text.trim().isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Please fill all exam information.',
),
),
);
return;
}

Navigator.pop(dialogContext, true);
},
child: const Text('Save'),
),
],
);
},
);

if (result != true) {
examNameController.dispose();
subjectController.dispose();
totalMarksController.dispose();

for (final controller in marksControllers.values) {
controller.dispose();
}

return;
}

try {
final totalMarks =
num.tryParse(totalMarksController.text.trim());

if (totalMarks == null) {
throw Exception('Invalid total marks');
}

final batch = FirebaseFirestore.instance.batch();

for (final student in documents) {
final studentId =
student['studentId']?.toString() ?? '';

final documentId =
student['id']?.toString() ?? '';

final obtainedMarks =
num.tryParse(
marksControllers[studentId]?.text.trim() ?? '0',
) ??
0;

final ref = FirebaseFirestore.instance
    .collection('exams')
    .doc(documentId);

batch.update(ref, {
'examName': examNameController.text.trim(),
'subject': subjectController.text.trim(),
'totalMarks': totalMarks,
'obtainedMarks': obtainedMarks,
'updatedAt': FieldValue.serverTimestamp(),
'className': className,
'section': section,
});
}

await batch.commit();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Exam updated successfully'),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Could not update exam: $e'),
),
);
}

examNameController.dispose();
subjectController.dispose();
totalMarksController.dispose();

for (final controller in marksControllers.values) {
controller.dispose();
}

// Avoid unused-variable warning for the first student reference.
firstStudent;
}

void _showExamDetails(Map<String, dynamic> exam) {
final documents =
exam['documents'] as List<Map<String, dynamic>>;

showModalBottomSheet(
context: context,
isScrollControlled: true,
shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(
top: Radius.circular(24),
),
),
builder: (context) {
return SafeArea(
child: Padding(
padding: const EdgeInsets.all(20),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
const CircleAvatar(
radius: 24,
child: Icon(Icons.assignment),
),
const SizedBox(width: 12),
Expanded(
child: Text(
exam['examName'] ?? 'Exam',
style: const TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
),
PopupMenuButton<String>(
onSelected: (value) {
Navigator.pop(context);

if (value == 'edit') {
_editExam(exam);
} else if (value == 'delete') {
_deleteExam(exam);
}
},
itemBuilder: (context) => const [
PopupMenuItem(
value: 'edit',
child: Row(
children: [
Icon(Icons.edit),
SizedBox(width: 8),
Text('Edit'),
],
),
),
PopupMenuItem(
value: 'delete',
child: Row(
children: [
Icon(
Icons.delete,
color: Colors.red,
),
SizedBox(width: 8),
Text('Delete'),
],
),
),
],
),
],
),

const SizedBox(height: 20),

_detailRow(
Icons.subject,
'Subject',
exam['subject']?.toString() ?? 'Unknown',
),

_detailRow(
Icons.calendar_today,
'Exam Date',
_formatDate(exam['examDate']),
),

_detailRow(
Icons.school,
'Class',
'$className - Section $section',
),

_detailRow(
Icons.score,
'Total Marks',
exam['totalMarks']?.toString() ?? '0',
),

const SizedBox(height: 18),

const Text(
'Student Results',
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

Flexible(
child: ListView.builder(
shrinkWrap: true,
itemCount: documents.length,
itemBuilder: (context, index) {
final student = documents[index];

final studentName =
student['studentName']?.toString() ??
'Student';

final obtained =
student['obtainedMarks']?.toString() ??
'0';

final total =
student['totalMarks']?.toString() ??
'0';

return Card(
margin:
const EdgeInsets.only(bottom: 8),
child: ListTile(
leading: const CircleAvatar(
child: Icon(Icons.person),
),
title: Text(studentName),
subtitle: Text(
'Marks: $obtained / $total',
),
),
);
},
),
),

const SizedBox(height: 10),
],
),
),
);
},
);
}

Widget _detailRow(
IconData icon,
String title,
String value,
) {
return Padding(
padding: const EdgeInsets.only(bottom: 12),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(
icon,
size: 20,
color: Colors.indigo,
),
const SizedBox(width: 10),
Expanded(
child: RichText(
text: TextSpan(
style: const TextStyle(
color: Colors.black87,
fontSize: 14,
),
children: [
TextSpan(
text: '$title: ',
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
TextSpan(text: value),
],
),
),
),
],
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Exams'),
),
body: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('exams')
    .where('className', isEqualTo: className)
    .where('section', isEqualTo: section)
    .snapshots(),
builder: (context, snapshot) {
if (snapshot.hasError) {
return Center(
child: Padding(
padding: const EdgeInsets.all(20),
child: Text(
'Error loading exams:\n${snapshot.error}',
textAlign: TextAlign.center,
),
),
);
}

if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

final documents = snapshot.data?.docs ?? [];

if (documents.isEmpty) {
return const Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.assignment_outlined,
size: 70,
color: Colors.grey,
),
SizedBox(height: 12),
Text(
'No exams found',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
SizedBox(height: 6),
Text(
'Add exam marks from Homework & Marks.',
textAlign: TextAlign.center,
),
],
),
);
}

final exams = _groupExams(documents);

return ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: exams.length,
itemBuilder: (context, index) {
final exam = exams[index];

final examName =
exam['examName']?.toString() ??
'Unnamed Exam';

final subject =
exam['subject']?.toString() ??
'Unknown Subject';

final date = _formatDate(exam['examDate']);

final students =
exam['documents'] as List<Map<String, dynamic>>;

return Card(
margin: const EdgeInsets.only(bottom: 12),
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
child: ListTile(
contentPadding: const EdgeInsets.all(16),
leading: const CircleAvatar(
radius: 25,
child: Icon(Icons.assignment),
),
title: Text(
examName,
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 16,
),
),
subtitle: Padding(
padding:
const EdgeInsets.only(top: 8),
child: Text(
'$subject\n$date • '
'${students.length} student'
'${students.length == 1 ? '' : 's'}',
),
),
isThreeLine: true,
trailing: const Icon(
Icons.arrow_forward_ios,
size: 16,
),
onTap: () => _showExamDetails(exam),
),
);
},
);
},
),
);
}
}
