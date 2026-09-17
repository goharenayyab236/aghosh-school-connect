
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatefulWidget {
const NotificationsScreen({super.key});

@override
State<NotificationsScreen> createState() =>
_NotificationsScreenState();
}

class _NotificationsScreenState
extends State<NotificationsScreen> {

// Stores notification IDs that the user has removed
// from this screen.
final Set<String> deletedNotifications = {};

// =========================
// DELETE / HIDE NOTIFICATION
// =========================

Future<void> deleteNotification(String notificationId) async {
final shouldDelete = await showDialog<bool>(
context: context,
builder: (context) {
return AlertDialog(
title: const Text('Delete Notification?'),
content: const Text(
'Are you sure you want to remove this notification?',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(context, false);
},
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () {
Navigator.pop(context, true);
},
child: const Text('Delete'),
),
],
);
},
);

if (shouldDelete == true) {
setState(() {
deletedNotifications.add(notificationId);
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Notification removed.'),
),
);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Notifications'),
centerTitle: true,
),

body: ListView(
padding: const EdgeInsets.all(20),

children: [
const Text(
'Notifications',
style: TextStyle(
fontSize: 23,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

// =========================
// SCHOOL NOTICES
// =========================

const Text(
'School Notices',
style: TextStyle(
fontSize: 19,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 12),

StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('notices')
    .snapshots(),

builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return Text(
'Error loading notices:\n${snapshot.error}',
);
}

final notices =
snapshot.data?.docs ?? [];

final visibleNotices =
notices.where((document) {
return !deletedNotifications.contains(
'notice_${document.id}',
);
}).toList();

if (visibleNotices.isEmpty) {
return const Card(
child: Padding(
padding: EdgeInsets.all(16),
child: Text(
'No school notices.',
style: TextStyle(
color: Colors.grey,
),
),
),
);
}

return Column(
children:
visibleNotices.map((document) {
final data =
document.data()
as Map<String, dynamic>;

final title =
data['title']?.toString() ??
'School Notice';

final message =
data['message']?.toString() ??
'New school notice.';

final date =
data['date']?.toString() ?? '';

return _notificationCard(
notificationId:
'notice_${document.id}',
icon: Icons.campaign,
title: title,
message: message,
time: date,
);
}).toList(),
);
},
),

const SizedBox(height: 25),

// =========================
// HOMEWORK
// =========================

const Text(
'Homework Updates',
style: TextStyle(
fontSize: 19,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 12),

StreamBuilder<QuerySnapshot>(
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
return Text(
'Error loading homework:\n${snapshot.error}',
);
}

final homework =
snapshot.data?.docs ?? [];

final visibleHomework =
homework.where((document) {
return !deletedNotifications.contains(
'homework_${document.id}',
);
}).toList();

if (visibleHomework.isEmpty) {
return const Card(
child: Padding(
padding: EdgeInsets.all(16),
child: Text(
'No homework updates.',
style: TextStyle(
color: Colors.grey,
),
),
),
);
}

return Column(
children:
visibleHomework.map((document) {
final data =
document.data()
as Map<String, dynamic>;

final subject =
data['subject']?.toString() ??
'Subject';

final title =
data['title']?.toString() ??
'Homework';

final dueDate =
data['dueDate']?.toString() ??
'';

return _notificationCard(
notificationId:
'homework_${document.id}',
icon: Icons.menu_book,
title: '$subject - $title',
message:
'New homework has been assigned.',
time: 'Due: $dueDate',
);
}).toList(),
);
},
),

const SizedBox(height: 25),

// =========================
// ATTENDANCE
// =========================

const Text(
'Attendance Updates',
style: TextStyle(
fontSize: 19,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 12),

StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('attendance')
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
return Text(
'Error loading attendance:\n${snapshot.error}',
);
}

final attendance =
snapshot.data?.docs ?? [];

final visibleAttendance =
attendance.where((document) {
return !deletedNotifications.contains(
'attendance_${document.id}',
);
}).toList();

if (visibleAttendance.isEmpty) {
return const Card(
child: Padding(
padding: EdgeInsets.all(16),
child: Text(
'No attendance updates.',
style: TextStyle(
color: Colors.grey,
),
),
),
);
}

return Column(
children:
visibleAttendance.map((document) {
final data =
document.data()
as Map<String, dynamic>;

final status =
data['status']?.toString() ??
'Unknown';

final date =
data['date']?.toString() ?? '';

return _notificationCard(
notificationId:
'attendance_${document.id}',
icon: Icons.calendar_month,
title:
'Attendance: $status',
message:
'Attendance has been updated.',
time: date,
);
}).toList(),
);
},
),
],
),
);
}

// =========================
// NOTIFICATION CARD
// =========================

Widget _notificationCard({
required String notificationId,
required IconData icon,
required String title,
required String message,
required String time,
}) {
return Card(
margin: const EdgeInsets.only(
bottom: 12,
),

elevation: 2,

child: ListTile(
leading: CircleAvatar(
child: Icon(icon),
),

title: Text(
title,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),

subtitle: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(message),

if (time.isNotEmpty) ...[
const SizedBox(height: 4),
Text(
time,
style: const TextStyle(
color: Colors.grey,
fontSize: 12,
),
),
],
],
),

trailing: PopupMenuButton<String>(
icon: const Icon(
Icons.more_vert,
),

onSelected: (value) {
if (value == 'delete') {
deleteNotification(
notificationId,
);
}
},

itemBuilder: (context) => const [
PopupMenuItem<String>(
value: 'delete',

child: Row(
children: [
Icon(
Icons.delete_outline,
),

SizedBox(width: 10),

Text('Delete'),
],
),
),
],
),
),
);
}
}
