import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassNoticesScreen extends StatefulWidget {
const ClassNoticesScreen({super.key});

@override
State<ClassNoticesScreen> createState() => _ClassNoticesScreenState();
}

class _ClassNoticesScreenState extends State<ClassNoticesScreen> {
final FirebaseFirestore firestore = FirebaseFirestore.instance;

final TextEditingController titleController = TextEditingController();
final TextEditingController descriptionController =
TextEditingController();

final String className = 'Grade 5';
final String section = 'A';

@override
void dispose() {
titleController.dispose();
descriptionController.dispose();
super.dispose();
}

// ------------------------------------------------------------
// ADD NOTICE
// ------------------------------------------------------------

void showAddNoticeDialog() {
titleController.clear();
descriptionController.clear();

bool saving = false;

showDialog(
context: context,
builder: (dialogContext) {
return StatefulBuilder(
builder: (dialogContext, setDialogState) {
return AlertDialog(
title: const Text('Create Class Notice'),

content: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Text(
'$className - Section $section',
style: const TextStyle(
color: Colors.grey,
fontWeight: FontWeight.w500,
),
),

const SizedBox(height: 20),

TextField(
controller: titleController,
enabled: !saving,
decoration: const InputDecoration(
labelText: 'Notice Title',
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.title),
),
),

const SizedBox(height: 15),

TextField(
controller: descriptionController,
enabled: !saving,
maxLines: 4,
decoration: const InputDecoration(
labelText: 'Notice Description',
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.description),
alignLabelWithHint: true,
),
),
],
),
),

actions: [
TextButton(
onPressed: saving
? null
    : () {
Navigator.pop(dialogContext);
},
child: const Text('Cancel'),
),

ElevatedButton(
onPressed: saving
? null
    : () async {
final title = titleController.text.trim();
final description =
descriptionController.text.trim();

if (title.isEmpty || description.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Please enter both title and description.',
),
),
);
return;
}

setDialogState(() {
saving = true;
});

try {
await firestore.collection('notices').add({
'title': title,
'description': description,
'className': className,
'section': section,
'createdAt': FieldValue.serverTimestamp(),
});

if (!mounted) return;

titleController.clear();
descriptionController.clear();

Navigator.pop(dialogContext);

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Notice published successfully.',
),
),
);
} catch (e) {
if (!mounted) return;

setDialogState(() {
saving = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Failed to publish notice: $e',
),
),
);
}
},
child: saving
? const SizedBox(
width: 18,
height: 18,
child: CircularProgressIndicator(
strokeWidth: 2,
),
)
    : const Text('Publish'),
),
],
);
},
);
},
);
}

// ------------------------------------------------------------
// EDIT NOTICE
// ------------------------------------------------------------

void showEditNoticeDialog(
String documentId,
Map<String, dynamic> data,
) {
titleController.text = data['title']?.toString() ?? '';
descriptionController.text =
data['description']?.toString() ?? '';

bool saving = false;

showDialog(
context: context,
builder: (dialogContext) {
return StatefulBuilder(
builder: (dialogContext, setDialogState) {
return AlertDialog(
title: const Text('Edit Notice'),

content: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Text(
'$className - Section $section',
style: const TextStyle(
color: Colors.grey,
fontWeight: FontWeight.w500,
),
),

const SizedBox(height: 20),

TextField(
controller: titleController,
enabled: !saving,
decoration: const InputDecoration(
labelText: 'Notice Title',
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.title),
),
),

const SizedBox(height: 15),

TextField(
controller: descriptionController,
enabled: !saving,
maxLines: 5,
decoration: const InputDecoration(
labelText: 'Notice Description',
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.description),
alignLabelWithHint: true,
),
),
],
),
),

actions: [
TextButton(
onPressed: saving
? null
    : () {
Navigator.pop(dialogContext);
},
child: const Text('Cancel'),
),

ElevatedButton(
onPressed: saving
? null
    : () async {
final title = titleController.text.trim();
final description =
descriptionController.text.trim();

if (title.isEmpty || description.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Please enter both title and description.',
),
),
);
return;
}

setDialogState(() {
saving = true;
});

try {
await firestore
    .collection('notices')
    .doc(documentId)
    .update({
'title': title,
'description': description,
'updatedAt':
FieldValue.serverTimestamp(),
});

if (!mounted) return;

titleController.clear();
descriptionController.clear();

Navigator.pop(dialogContext);

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Notice updated successfully.',
),
),
);
} catch (e) {
if (!mounted) return;

setDialogState(() {
saving = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Failed to update notice: $e',
),
),
);
}
},
child: saving
? const SizedBox(
width: 18,
height: 18,
child: CircularProgressIndicator(
strokeWidth: 2,
),
)
    : const Text('Save Changes'),
),
],
);
},
);
},
);
}

// ------------------------------------------------------------
// DELETE NOTICE
// ------------------------------------------------------------

Future<void> deleteNotice(
String documentId,
String title,
) async {
final confirmed = await showDialog<bool>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Delete Notice?'),

content: Text(
'Are you sure you want to delete "$title"?\n\n'
'This notice will also disappear from the Parent app.',
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
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
foregroundColor: Colors.white,
),
child: const Text('Delete'),
),
],
);
},
);

if (confirmed != true) return;

try {
await firestore
    .collection('notices')
    .doc(documentId)
    .delete();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Notice deleted successfully.',
),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Failed to delete notice: $e',
),
),
);
}
}

// ------------------------------------------------------------
// NOTICE DETAILS
// ------------------------------------------------------------

void showNoticeDetails(
String documentId,
Map<String, dynamic> data,
) {
final title = data['title']?.toString() ?? 'Notice';

final description =
data['description']?.toString() ?? '';

DateTime? createdAt;

if (data['createdAt'] is Timestamp) {
createdAt =
(data['createdAt'] as Timestamp).toDate();
}

DateTime? updatedAt;

if (data['updatedAt'] is Timestamp) {
updatedAt =
(data['updatedAt'] as Timestamp).toDate();
}

showDialog(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: Row(
children: [
CircleAvatar(
backgroundColor: Colors.blue.shade100,
child: Icon(
Icons.campaign,
color: Colors.blue.shade700,
),
),

const SizedBox(width: 12),

Expanded(
child: Text(
title,
style: const TextStyle(
fontSize: 19,
fontWeight: FontWeight.bold,
),
),
),
],
),

content: SingleChildScrollView(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Class',
style: TextStyle(
fontWeight: FontWeight.bold,
color: Colors.grey,
),
),

const SizedBox(height: 4),

Text('$className - Section $section'),

const SizedBox(height: 18),

const Text(
'Notice',
style: TextStyle(
fontWeight: FontWeight.bold,
color: Colors.grey,
),
),

const SizedBox(height: 6),

Text(
description,
style: const TextStyle(
fontSize: 15,
height: 1.5,
),
),

if (createdAt != null) ...[
const SizedBox(height: 18),

const Text(
'Published',
style: TextStyle(
fontWeight: FontWeight.bold,
color: Colors.grey,
),
),

const SizedBox(height: 4),

Text(
'${createdAt.day}/${createdAt.month}/${createdAt.year}',
),
],

if (updatedAt != null) ...[
const SizedBox(height: 12),

const Text(
'Last Updated',
style: TextStyle(
fontWeight: FontWeight.bold,
color: Colors.grey,
),
),

const SizedBox(height: 4),

Text(
'${updatedAt.day}/${updatedAt.month}/${updatedAt.year}',
),
],
],
),
),

actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: const Text('Close'),
),

ElevatedButton(
onPressed: () {
Navigator.pop(dialogContext);

showEditNoticeDialog(
documentId,
data,
);
},
child: const Text('Edit'),
),
],
);
},
);
}

// ------------------------------------------------------------
// BUILD
// ------------------------------------------------------------

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Class Notices'),
centerTitle: true,
),

floatingActionButton:
FloatingActionButton.extended(
onPressed: showAddNoticeDialog,
icon: const Icon(Icons.add),
label: const Text('Add Notice'),
),

body: StreamBuilder<QuerySnapshot>(
stream: firestore
    .collection('notices')
    .where(
'className',
isEqualTo: className,
)
    .where(
'section',
isEqualTo: section,
)
    .orderBy(
'createdAt',
descending: true,
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
'Unable to load notices.\n\n${snapshot.error}',
textAlign: TextAlign.center,
),
),
);
}

final notices =
snapshot.data?.docs ?? [];

if (notices.isEmpty) {
return const Center(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.campaign_outlined,
size: 60,
color: Colors.grey,
),

SizedBox(height: 15),

Text(
'No notices yet',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),

SizedBox(height: 5),

Text(
'Tap "Add Notice" to create one.',
style: TextStyle(
color: Colors.grey,
),
),
],
),
);
}

return ListView.builder(
padding: const EdgeInsets.fromLTRB(
16,
16,
16,
90,
),

itemCount: notices.length,

itemBuilder: (context, index) {
final document = notices[index];

final data =
document.data()
as Map<String, dynamic>;

final title =
data['title']?.toString() ??
'Notice';

final description =
data['description']?.toString() ??
'';

DateTime? createdAt;

if (data['createdAt'] is Timestamp) {
createdAt =
(data['createdAt'] as Timestamp)
    .toDate();
}

return Card(
elevation: 2,
margin:
const EdgeInsets.only(bottom: 12),

child: InkWell(
borderRadius:
BorderRadius.circular(12),

onTap: () {
showNoticeDetails(
document.id,
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
backgroundColor:
Colors.blue.shade100,

child: Icon(
Icons.campaign,
color:
Colors.blue.shade700,
),
),

const SizedBox(width: 12),

Expanded(
child: Text(
title,
style:
const TextStyle(
fontSize: 17,
fontWeight:
FontWeight.bold,
),
),
),

PopupMenuButton<String>(
onSelected: (value) {
if (value == 'edit') {
showEditNoticeDialog(
document.id,
data,
);
}

if (value == 'delete') {
deleteNotice(
document.id,
title,
);
}
},

itemBuilder: (context) {
return const [
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
Icon(
Icons.delete,
color: Colors.red,
),
SizedBox(width: 10),
Text('Delete'),
],
),
),
];
},
),
],
),

const SizedBox(height: 12),

Text(
description,
maxLines: 3,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 15,
height: 1.4,
),
),

const SizedBox(height: 12),

Row(
children: [
const Icon(
Icons.class_,
size: 16,
color: Colors.grey,
),

const SizedBox(width: 5),

Text(
'$className - $section',
style:
const TextStyle(
color: Colors.grey,
),
),

const Spacer(),

if (createdAt != null)
Text(
'${createdAt.day}/${createdAt.month}/${createdAt.year}',
style:
const TextStyle(
color: Colors.grey,
fontSize: 12,
),
),

const SizedBox(width: 6),

const Icon(
Icons.arrow_forward_ios,
size: 14,
color: Colors.grey,
),
],
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
