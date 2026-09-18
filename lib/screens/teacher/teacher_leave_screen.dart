import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherLeaveScreen extends StatelessWidget {
const TeacherLeaveScreen({super.key});

final String className = 'Grade 5';
final String section = 'A';

// ---------------------------------------------------------
// APPROVE / REJECT + TEACHER NOTE
// ---------------------------------------------------------
Future<void> reviewLeave(
BuildContext context,
String documentId,
String status,
) async {
final noteController = TextEditingController();

final note = await showDialog<String>(
context: context,
barrierDismissible: false,
builder: (dialogContext) {
return AlertDialog(
title: Text(
status == 'Approved'
? 'Approve Leave Request'
    : 'Reject Leave Request',
),
content: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
status == 'Approved'
? 'Add a note for the parent.'
    : 'Add a reason for rejecting the leave.',
),

const SizedBox(height: 15),

TextField(
controller: noteController,
maxLines: 4,
decoration: const InputDecoration(
labelText: 'Teacher Note',
hintText: 'Write a note...',
border: OutlineInputBorder(),
),
),
],
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: const Text('Cancel'),
),

ElevatedButton(
onPressed: () {
Navigator.pop(
dialogContext,
noteController.text.trim(),
);
},
child: Text(
status == 'Approved'
? 'Approve'
    : 'Reject',
),
),
],
);
},
);

noteController.dispose();

if (note == null) {
return;
}

try {
await FirebaseFirestore.instance
    .collection('leave_requests')
    .doc(documentId)
    .update({
'status': status,
'teacherNote': note,
'updatedAt': FieldValue.serverTimestamp(),
});

if (!context.mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
status == 'Approved'
? 'Leave approved successfully.'
    : 'Leave rejected successfully.',
),
),
);
} catch (e) {
if (!context.mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Could not update leave request:\n$e',
),
),
);
}
}

// ---------------------------------------------------------
// LEAVE DETAILS
// ---------------------------------------------------------
void showLeaveDetails(
BuildContext context,
String documentId,
Map<String, dynamic> data,
) {
final student =
data['studentName']?.toString() ??
'Unknown Student';

final leaveType =
data['leaveType']?.toString() ??
'Leave';

final reason =
data['reason']?.toString() ??
'No reason provided';

final startDate =
data['startDate']?.toString() ??
'';

final endDate =
data['endDate']?.toString() ??
'';

final status =
data['status']?.toString() ??
'Pending';

final teacherNote =
data['teacherNote']?.toString() ??
'';

final isPending = status == 'Pending';

final statusColor =
_getStatusColor(status);

showDialog(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text(
'Leave Request Details',
),

content: SingleChildScrollView(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
mainAxisSize: MainAxisSize.min,
children: [
// STUDENT
_detailRow(
Icons.person,
'Student',
student,
),

// LEAVE TYPE
_detailRow(
Icons.category,
'Leave Type',
leaveType,
),

// START DATE
_detailRow(
Icons.calendar_today,
'Start Date',
startDate.isEmpty
? 'Not provided'
    : startDate,
),

// END DATE
_detailRow(
Icons.event,
'End Date',
endDate.isEmpty
? 'Not provided'
    : endDate,
),

// REASON
_detailRow(
Icons.description,
'Reason',
reason,
),

const SizedBox(height: 5),

// STATUS
Row(
children: [
const Icon(
Icons.info_outline,
size: 21,
),

const SizedBox(width: 12),

const Text(
'Status',
style: TextStyle(
fontWeight:
FontWeight.bold,
),
),

const Spacer(),

Container(
padding:
const EdgeInsets
    .symmetric(
horizontal: 12,
vertical: 6,
),
decoration: BoxDecoration(
color: statusColor
    .withOpacity(0.12),
borderRadius:
BorderRadius.circular(
20,
),
),
child: Text(
status,
style: TextStyle(
color: statusColor,
fontWeight:
FontWeight.bold,
),
),
),
],
),

// TEACHER NOTE
if (teacherNote.isNotEmpty) ...[
const SizedBox(height: 18),

Container(
width: double.infinity,
padding:
const EdgeInsets.all(12),
decoration: BoxDecoration(
color:
Colors.grey.shade100,
borderRadius:
BorderRadius.circular(
10,
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Teacher Note',
style: TextStyle(
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 6),

Text(teacherNote),
],
),
),
],
],
),
),

actions: [
// CLOSE
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: const Text('Close'),
),

// REJECT
if (isPending)
OutlinedButton(
onPressed: () async {
Navigator.pop(dialogContext);

await reviewLeave(
context,
documentId,
'Rejected',
);
},
style:
OutlinedButton.styleFrom(
foregroundColor: Colors.red,
),
child: const Text(
'Reject',
),
),

// APPROVE
if (isPending)
ElevatedButton(
onPressed: () async {
Navigator.pop(dialogContext);

await reviewLeave(
context,
documentId,
'Approved',
);
},
child: const Text(
'Approve',
),
),
],
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
padding:
const EdgeInsets.only(bottom: 14),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
icon,
size: 20,
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
fontWeight:
FontWeight.bold,
),
),
TextSpan(
text: value,
),
],
),
),
),
],
),
);
}

Color _getStatusColor(
String status,
) {
switch (status.toLowerCase()) {
case 'approved':
return Colors.green;

case 'rejected':
return Colors.red;

default:
return Colors.orange;
}
}

// ---------------------------------------------------------
// MAIN SCREEN
// ---------------------------------------------------------
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title:
const Text('Leave Requests'),
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

builder:
(context, studentSnapshot) {
if (studentSnapshot
    .connectionState ==
ConnectionState.waiting) {
return const Center(
child:
CircularProgressIndicator(),
);
}

if (studentSnapshot.hasError) {
return Center(
child: Text(
'Error loading students:\n'
'${studentSnapshot.error}',
textAlign:
TextAlign.center,
),
);
}

final students =
studentSnapshot.data?.docs ??
[];

final studentIds =
students.map((doc) {
final data =
doc.data()
as Map<String, dynamic>;

return data['studentId']
    ?.toString() ??
doc.id;
}).toSet();

return StreamBuilder<
QuerySnapshot>(
stream:
FirebaseFirestore.instance
    .collection(
'leave_requests')
    .snapshots(),

builder:
(context, leaveSnapshot) {
if (leaveSnapshot
    .connectionState ==
ConnectionState.waiting) {
return const Center(
child:
CircularProgressIndicator(),
);
}

if (leaveSnapshot.hasError) {
return Center(
child: Text(
'Error loading leave requests:\n'
'${leaveSnapshot.error}',
textAlign:
TextAlign.center,
),
);
}

final allRequests =
leaveSnapshot.data
    ?.docs ??
[];

final requests =
allRequests.where(
(document) {
final data =
document.data()
as Map<String,
dynamic>;

final studentId =
data['studentId']
    ?.toString() ??
'';

return studentIds
    .contains(studentId);
},
).toList();

return ListView(
padding:
const EdgeInsets.all(
20),
children: [
Text(
'$className - Section $section',
style:
const TextStyle(
fontSize: 15,
color:
Colors.grey,
),
),

const SizedBox(
height: 5,
),

const Text(
'Student Leave Requests',
style:
TextStyle(
fontSize: 23,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 20,
),

if (requests.isEmpty)
const Padding(
padding:
EdgeInsets.all(
30),
child: Center(
child: Text(
'No leave requests found for this class.',
textAlign:
TextAlign.center,
style:
TextStyle(
color:
Colors.grey,
fontSize:
16,
),
),
),
),

...requests.map(
(document) {
final data =
document.data()
as Map<String,
dynamic>;

return _leaveCard(
context,
document.id,
data,
);
},
),
],
);
},
);
},
),
);
}

// ---------------------------------------------------------
// CLICKABLE LEAVE CARD
// ---------------------------------------------------------
Widget _leaveCard(
BuildContext context,
String documentId,
Map<String, dynamic> data,
) {
final student =
data['studentName']
    ?.toString() ??
'Unknown Student';

final leaveType =
data['leaveType']
    ?.toString() ??
'Leave';

final reason =
data['reason']
    ?.toString() ??
'No reason provided';

final startDate =
data['startDate']
    ?.toString() ??
'';

final endDate =
data['endDate']
    ?.toString() ??
'';

final status =
data['status']
    ?.toString() ??
'Pending';

final statusColor =
_getStatusColor(status);

return Card(
margin:
const EdgeInsets.only(
bottom: 15,
),
elevation: 2,

child: InkWell(
borderRadius:
BorderRadius.circular(12),

onTap: () {
showLeaveDetails(
context,
documentId,
data,
);
},

child: Padding(
padding:
const EdgeInsets.all(16),

child: Row(
children: [
const CircleAvatar(
child: Icon(
Icons.person,
),
),

const SizedBox(
width: 12,
),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
student,
style:
const TextStyle(
fontSize: 17,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 6,
),

Text(
leaveType,
style:
const TextStyle(
fontWeight:
FontWeight.w600,
),
),

const SizedBox(
height: 5,
),

Text(
startDate ==
endDate
? startDate
    : '$startDate to $endDate',
style:
const TextStyle(
color:
Colors.grey,
),
),

const SizedBox(
height: 5,
),

Text(
reason,
maxLines: 1,
overflow:
TextOverflow
    .ellipsis,
style:
const TextStyle(
color:
Colors.grey,
),
),
],
),
),

const SizedBox(
width: 10,
),

Column(
children: [
Container(
padding:
const EdgeInsets
    .symmetric(
horizontal: 10,
vertical: 5,
),
decoration:
BoxDecoration(
color: statusColor
    .withOpacity(
0.12),
borderRadius:
BorderRadius
    .circular(
20,
),
),
child: Text(
status,
style: TextStyle(
color:
statusColor,
fontSize: 12,
fontWeight:
FontWeight.bold,
),
),
),

const SizedBox(
height: 12,
),

const Icon(
Icons
    .arrow_forward_ios,
size: 15,
color:
Colors.grey,
),
],
),
],
),
),
),
);
}
}