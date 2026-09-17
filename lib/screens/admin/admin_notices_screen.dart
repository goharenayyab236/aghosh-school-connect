import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNoticesScreen extends StatefulWidget {
const AdminNoticesScreen({super.key});

@override
State<AdminNoticesScreen> createState() =>
_AdminNoticesScreenState();
}

class _AdminNoticesScreenState
extends State<AdminNoticesScreen> {
final titleController = TextEditingController();
final messageController = TextEditingController();

// =========================
// PUBLISH NOTICE
// =========================
Future<void> publishNotice() async {
if (titleController.text.trim().isEmpty ||
messageController.text.trim().isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Please enter title and message.'),
),
);
return;
}

try {
await FirebaseFirestore.instance
    .collection('notices')
    .add({
'title': titleController.text.trim(),
'message': messageController.text.trim(),
'date': DateTime.now().toString().split(' ')[0],
'audience': 'All Parents',
'createdAt': FieldValue.serverTimestamp(),
});

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Notice published successfully.'),
),
);

titleController.clear();
messageController.clear();
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Error publishing notice: $e'),
),
);
}
}

// =========================
// EDIT NOTICE
// =========================
Future<void> editNotice(
String documentId,
String currentTitle,
String currentMessage,
) async {
final editTitleController =
TextEditingController(text: currentTitle);

final editMessageController =
TextEditingController(text: currentMessage);

await showDialog(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Edit Notice'),
content: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(
controller: editTitleController,
decoration: const InputDecoration(
labelText: 'Notice Title',
border: OutlineInputBorder(),
),
),
const SizedBox(height: 15),
TextField(
controller: editMessageController,
maxLines: 5,
decoration: const InputDecoration(
labelText: 'Notice Message',
border: OutlineInputBorder(),
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
final newTitle =
editTitleController.text.trim();

final newMessage =
editMessageController.text.trim();

if (newTitle.isEmpty || newMessage.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content:
Text('Please enter title and message.'),
),
);
return;
}

try {
await FirebaseFirestore.instance
    .collection('notices')
    .doc(documentId)
    .update({
'title': newTitle,
'message': newMessage,
});

if (!mounted) return;

Navigator.pop(dialogContext);

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content:
Text('Notice updated successfully.'),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content:
Text('Error updating notice: $e'),
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

editTitleController.dispose();
editMessageController.dispose();
}

// =========================
// DELETE NOTICE
// =========================
Future<void> deleteNotice(String documentId) async {
final shouldDelete = await showDialog<bool>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Delete Notice'),
content: const Text(
'Are you sure you want to delete this notice?\n\n'
'It will be removed for everyone.',
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
    .collection('notices')
    .doc(documentId)
    .delete();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Notice deleted successfully.'),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Error deleting notice: $e'),
),
);
}
}

@override
void dispose() {
titleController.dispose();
messageController.dispose();
super.dispose();
}

// =========================
// UI
// =========================
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('School Notices'),
centerTitle: true,
),

body: SingleChildScrollView(
padding: const EdgeInsets.all(20),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.stretch,

children: [
const Text(
'Create Notice',
style: TextStyle(
fontSize: 23,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

TextField(
controller: titleController,
decoration: const InputDecoration(
labelText: 'Notice Title',
border: OutlineInputBorder(),
),
),

const SizedBox(height: 15),

TextField(
controller: messageController,
maxLines: 5,
decoration: const InputDecoration(
labelText: 'Notice Message',
border: OutlineInputBorder(),
),
),

const SizedBox(height: 20),

SizedBox(
height: 52,
child: ElevatedButton.icon(
onPressed: publishNotice,
icon: const Icon(Icons.publish),
label: const Text('Publish Notice'),
),
),

const SizedBox(height: 30),

const Text(
'Published Notices',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

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
return const Card(
child: Padding(
padding: EdgeInsets.all(16),
child: Text(
'Unable to load notices.',
),
),
);
}

final notices =
snapshot.data?.docs ?? [];

if (notices.isEmpty) {
return const Card(
child: ListTile(
leading: Icon(Icons.campaign),
title: Text('No notices yet'),
subtitle: Text(
'Published notices will appear here.',
),
),
);
}

return Column(
children: notices.map((doc) {
final data =
doc.data() as Map<String, dynamic>;

final title =
data['title']?.toString() ??
'Notice';

final message =
data['message']?.toString() ??
'';

final date =
data['date']?.toString() ??
'';

return Card(
margin:
const EdgeInsets.only(
bottom: 12,
),

child: ListTile(
leading: const CircleAvatar(
child: Icon(Icons.campaign),
),

title: Text(
title,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),

subtitle: Text(
'$message\nDate: $date',
),

// THREE-DOT MENU
trailing: PopupMenuButton<String>(
icon: const Icon(Icons.more_vert),
onSelected: (value) {
if (value == 'edit') {
editNotice(
doc.id,
title,
message,
);
}

if (value == 'delete') {
deleteNotice(doc.id);
}
},
itemBuilder: (context) => const [
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
