import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeworkScreen extends StatefulWidget {
const HomeworkScreen({super.key});

@override
State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
String selectedFilter = 'All';

// Stores homework IDs hidden by the parent.
final Set<String> hiddenHomework = {};

// Convert Firebase date into DateTime.
DateTime? _getDate(dynamic value) {
if (value is Timestamp) {
return value.toDate();
}

if (value is DateTime) {
return value;
}

if (value is String) {
final parsed = DateTime.tryParse(value);

if (parsed != null) {
return parsed;
}

// Supports dd/MM/yyyy
final parts = value.split('/');

if (parts.length == 3) {
final day = int.tryParse(parts[0]);
final month = int.tryParse(parts[1]);
final year = int.tryParse(parts[2]);

if (day != null && month != null && year != null) {
return DateTime(year, month, day);
}
}
}

return null;
}

String _formatDate(dynamic value) {
final date = _getDate(value);

if (date == null) {
return value?.toString() ?? 'Not assigned';
}

return '${date.day.toString().padLeft(2, '0')}/'
'${date.month.toString().padLeft(2, '0')}/'
'${date.year}';
}

// Checks whether the homework is due today.
bool _isToday(dynamic value) {
final dueDate = _getDate(value);

if (dueDate == null) {
return false;
}

final now = DateTime.now();

return dueDate.year == now.year &&
dueDate.month == now.month &&
dueDate.day == now.day;
}

IconData _getSubjectIcon(String subject) {
switch (subject.toLowerCase()) {
case 'mathematics':
case 'math':
return Icons.calculate;

case 'english':
return Icons.menu_book;

case 'science':
return Icons.science;

case 'computer':
case 'computer science':
return Icons.computer;

case 'urdu':
return Icons.language;

case 'islamiyat':
case 'islamic studies':
return Icons.mosque;

default:
return Icons.assignment;
}
}

void _showHomeworkDetails(
BuildContext context,
Map<String, dynamic> data,
) {
final subject =
data['subject']?.toString() ?? 'Subject';

final title =
data['title']?.toString() ?? 'Homework';

final description =
data['description']?.toString() ??
'No description available';

final dueDate = data['dueDate'];

final status =
data['status']?.toString() ?? 'Pending';

showModalBottomSheet(
context: context,
isScrollControlled: true,
shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(
top: Radius.circular(25),
),
),
builder: (context) {
return Padding(
padding: const EdgeInsets.all(24),
child: SingleChildScrollView(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Center(
child: Container(
width: 45,
height: 5,
decoration: BoxDecoration(
color: Colors.grey.shade300,
borderRadius:
BorderRadius.circular(10),
),
),
),

const SizedBox(height: 25),

Row(
children: [
CircleAvatar(
radius: 28,
child: Icon(
_getSubjectIcon(subject),
size: 28,
),
),

const SizedBox(width: 15),

Expanded(
child: Text(
title,
style: const TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),
),
],
),

const SizedBox(height: 25),

_detailRow(
Icons.book,
'Subject',
subject,
),

_detailRow(
Icons.description,
'Description',
description,
),

_detailRow(
Icons.calendar_today,
'Due Date',
_formatDate(dueDate),
),

_detailRow(
Icons.info_outline,
'Status',
status,
),

const SizedBox(height: 15),

SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () {
Navigator.pop(context);
},
child: const Text('Close'),
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
padding: const EdgeInsets.only(bottom: 18),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
icon,
color: Colors.grey,
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
fontSize: 13,
color: Colors.grey,
),
),

const SizedBox(height: 3),

Text(
value,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w500,
),
),
],
),
),
],
),
);
}

void _hideHomework(
BuildContext context,
String homeworkId,
) {
showDialog(
context: context,
builder: (context) {
return AlertDialog(
title: const Text('Hide Homework?'),
content: const Text(
'This homework will be hidden from your screen. '
'It will not be deleted from the school records.',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(context);
},
child: const Text('Cancel'),
),

ElevatedButton(
onPressed: () {
setState(() {
hiddenHomework.add(homeworkId);
});

Navigator.pop(context);

ScaffoldMessenger.of(context)
    .showSnackBar(
const SnackBar(
content: Text(
'Homework hidden from your screen.',
),
),
);
},
child: const Text('Hide'),
),
],
);
},
);
}

@override
Widget build(BuildContext context) {
// Only two filters.
const filters = [
'All',
"Today's Homework",
];

return Scaffold(
appBar: AppBar(
title: const Text('Homework'),
centerTitle: true,
),

body: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('homework')
    .where(
'studentId',
isEqualTo: 'student_001',
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
'Error loading homework:\n${snapshot.error}',
textAlign: TextAlign.center,
),
),
);
}

final allHomework =
snapshot.data?.docs ?? [];

final visibleHomework =
allHomework.where((document) {
// Hide only from parent's current screen.
if (hiddenHomework.contains(document.id)) {
return false;
}

final data =
document.data()
as Map<String, dynamic>;

// All homework.
if (selectedFilter == 'All') {
return true;
}

// Today's homework only.
if (selectedFilter ==
"Today's Homework") {
return _isToday(data['dueDate']);
}

return true;
}).toList();

return ListView(
padding: const EdgeInsets.all(20),
children: [
const Text(
'Homework',
style: TextStyle(
fontSize: 23,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 18),

// Filter
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 15,
),
decoration: BoxDecoration(
border: Border.all(
color: Colors.grey.shade400,
),
borderRadius:
BorderRadius.circular(12),
),
child:
DropdownButtonHideUnderline(
child: DropdownButton<String>(
value: selectedFilter,
isExpanded: true,
icon: const Icon(
Icons.keyboard_arrow_down,
),
items: filters.map((filter) {
return DropdownMenuItem<String>(
value: filter,
child: Text(filter),
);
}).toList(),
onChanged: (value) {
if (value != null) {
setState(() {
selectedFilter = value;
});
}
},
),
),
),

const SizedBox(height: 20),

if (selectedFilter != 'All')
Padding(
padding:
const EdgeInsets.only(
bottom: 15,
),
child: Text(
'Showing: $selectedFilter',
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 14,
),
),
),

if (visibleHomework.isEmpty)
const Center(
child: Padding(
padding: EdgeInsets.all(30),
child: Column(
children: [
Icon(
Icons.assignment_outlined,
size: 55,
color: Colors.grey,
),

SizedBox(height: 12),

Text(
'No homework available.',
style: TextStyle(
color: Colors.grey,
fontSize: 16,
),
),
],
),
),
),

...visibleHomework.map((document) {
final data =
document.data()
as Map<String, dynamic>;

final subject =
data['subject']?.toString() ??
'Subject';

final title =
data['title']?.toString() ??
'Homework';

final description =
data['description']?.toString() ??
'No description available';

final dueDate =
data['dueDate'];

final status =
data['status']?.toString() ??
'Pending';

return Card(
margin:
const EdgeInsets.only(
bottom: 15,
),
elevation: 2,
child: InkWell(
borderRadius:
BorderRadius.circular(12),

// Click the homework to see details.
onTap: () {
_showHomeworkDetails(
context,
data,
);
},

child: Padding(
padding:
const EdgeInsets.all(16),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
CircleAvatar(
child: Icon(
_getSubjectIcon(
subject,
),
),
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
title,
style:
const TextStyle(
fontSize: 17,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 4,
),

Text(
subject,
style:
const TextStyle(
color:
Colors.grey,
),
),
],
),
),

// Arrow shows that the card
// can be clicked.
const Icon(
Icons.arrow_forward_ios,
size: 16,
color: Colors.grey,
),

// Hide menu.
PopupMenuButton<String>(
onSelected: (value) {
if (value == 'hide') {
_hideHomework(
context,
document.id,
);
}
},
itemBuilder:
(context) {
return const [
PopupMenuItem(
value: 'hide',
child: Row(
children: [
Icon(
Icons
    .visibility_off,
),
SizedBox(
width: 10,
),
Text('Hide'),
],
),
),
];
},
),
],
),

const SizedBox(height: 15),

Text(
description,
maxLines: 2,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
fontSize: 15,
),
),

const SizedBox(height: 12),

Row(
children: [
const Icon(
Icons.calendar_today,
size: 18,
color: Colors.grey,
),

const SizedBox(width: 8),

Expanded(
child: Text(
'Due: ${_formatDate(dueDate)}',
style:
const TextStyle(
color: Colors.grey,
),
),
),

// Show Firebase status only.
// The app does not decide whether
// the student completed the work.
if (status.isNotEmpty)
Container(
padding:
const EdgeInsets
    .symmetric(
horizontal: 9,
vertical: 5,
),
decoration:
BoxDecoration(
color: Colors
    .grey
    .withOpacity(0.12),
borderRadius:
BorderRadius
    .circular(8),
),
child: Text(
status,
style:
const TextStyle(
fontSize: 12,
fontWeight:
FontWeight.bold,
color: Colors.grey,
),
),
),
],
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
