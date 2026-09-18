
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoticesScreen extends StatefulWidget {
const NoticesScreen({super.key});

@override
State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
String selectedFilter = 'All Notices';

// Notices hidden by the parent.
final Set<String> hiddenNotices = {};

// ------------------------------------------------------------
// DATE HELPERS
// ------------------------------------------------------------

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
return 'Date not available';
}

return '${date.day.toString().padLeft(2, '0')}/'
'${date.month.toString().padLeft(2, '0')}/'
'${date.year}';
}

bool _isToday(dynamic value) {
final date = _getDate(value);

if (date == null) {
return false;
}

final now = DateTime.now();

return date.year == now.year &&
date.month == now.month &&
date.day == now.day;
}

// ------------------------------------------------------------
// NOTICE DETAILS
// ------------------------------------------------------------

void _showNoticeDetails(
BuildContext context,
Map<String, dynamic> data,
) {
final title =
data['title']?.toString() ?? 'School Notice';

final description =
data['description']?.toString() ??
'No description available.';

final createdAt = data['createdAt'];

final className =
data['className']?.toString() ?? 'Class not available';

final section =
data['section']?.toString() ?? '';

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
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// Drag handle
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

// Title
Row(
children: [
CircleAvatar(
radius: 28,
backgroundColor:
Colors.blue.shade100,
child: Icon(
Icons.campaign,
size: 28,
color: Colors.blue.shade700,
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

// Class
_detailRow(
Icons.class_,
'Class',
section.isEmpty
? className
    : '$className - Section $section',
),

// Date
_detailRow(
Icons.calendar_today,
'Published',
_formatDate(createdAt),
),

// Description
_detailRow(
Icons.description,
'Notice',
description,
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

// ------------------------------------------------------------
// DETAIL ROW
// ------------------------------------------------------------

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

// ------------------------------------------------------------
// HIDE NOTICE
// ------------------------------------------------------------

void _hideNotice(
BuildContext context,
String noticeId,
) {
showDialog(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Hide Notice?'),

content: const Text(
'This notice will be hidden from your screen. '
'It will not be deleted from the school records.',
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
setState(() {
hiddenNotices.add(noticeId);
});

Navigator.pop(dialogContext);

ScaffoldMessenger.of(context)
    .showSnackBar(
const SnackBar(
content: Text(
'Notice hidden from your screen.',
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

// ------------------------------------------------------------
// BUILD
// ------------------------------------------------------------

@override
Widget build(BuildContext context) {
const filters = [
'All Notices',
"Today's Notices",
];

return Scaffold(
appBar: AppBar(
title: const Text('School Notices'),
centerTitle: true,
),

body: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('notices')
    .where(
'className',
isEqualTo: 'Grade 5',
)
    .where(
'section',
isEqualTo: 'A',
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
'Error loading notices:\n${snapshot.error}',
textAlign: TextAlign.center,
),
),
);
}

final allNotices =
snapshot.data?.docs ?? [];

// ----------------------------------------------------
// FILTER NOTICES
// ----------------------------------------------------

final visibleNotices =
allNotices.where((document) {
if (hiddenNotices.contains(document.id)) {
return false;
}

final data =
document.data()
as Map<String, dynamic>;

if (selectedFilter == 'All Notices') {
return true;
}

if (selectedFilter ==
"Today's Notices") {
return _isToday(
data['createdAt'],
);
}

return true;
}).toList();

// ----------------------------------------------------
// SORT BY CREATED DATE
// ----------------------------------------------------

visibleNotices.sort((a, b) {
final dataA =
a.data() as Map<String, dynamic>;

final dataB =
b.data() as Map<String, dynamic>;

final dateA =
_getDate(dataA['createdAt']);

final dateB =
_getDate(dataB['createdAt']);

if (dateA == null && dateB == null) {
return 0;
}

if (dateA == null) {
return 1;
}

if (dateB == null) {
return -1;
}

return dateB.compareTo(dateA);
});

return ListView(
padding: const EdgeInsets.all(20),
children: [
const Text(
'Latest Notices',
style: TextStyle(
fontSize: 23,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 18),

// ------------------------------------------------
// FILTER
// ------------------------------------------------

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

if (selectedFilter !=
'All Notices')
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

// ------------------------------------------------
// EMPTY STATE
// ------------------------------------------------

if (visibleNotices.isEmpty)
const Center(
child: Padding(
padding: EdgeInsets.all(30),
child: Column(
children: [
Icon(
Icons.campaign_outlined,
size: 55,
color: Colors.grey,
),

SizedBox(height: 12),

Text(
'No notices available.',
style: TextStyle(
color: Colors.grey,
fontSize: 16,
),
),
],
),
),
),

// ------------------------------------------------
// NOTICE CARDS
// ------------------------------------------------

...visibleNotices.map((document) {
final data =
document.data()
as Map<String, dynamic>;

final title =
data['title']?.toString() ??
'School Notice';

final description =
data['description']?.toString() ??
'No description available.';

final createdAt =
data['createdAt'];

final className =
data['className']?.toString() ??
'Grade 5';

final section =
data['section']?.toString() ??
'A';

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
_showNoticeDetails(
context,
data,
);
},

child: Padding(
padding:
const EdgeInsets.all(18),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// --------------------------------------
// TITLE
// --------------------------------------

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

const SizedBox(
width: 10,
),

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

const Icon(
Icons.arrow_forward_ios,
size: 16,
color: Colors.grey,
),

// Hide menu
PopupMenuButton<String>(
onSelected:
(value) {
if (value ==
'hide') {
_hideNotice(
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
Text(
'Hide',
),
],
),
),
];
},
),
],
),

const SizedBox(height: 12),

// --------------------------------------
// DESCRIPTION
// --------------------------------------

Text(
description,
maxLines: 3,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
fontSize: 15,
height: 1.4,
),
),

const SizedBox(height: 12),

// --------------------------------------
// CLASS + DATE
// --------------------------------------

Row(
children: [
const Icon(
Icons.class_,
size: 16,
color: Colors.grey,
),

const SizedBox(width: 6),

Text(
'$className - $section',
style:
const TextStyle(
color: Colors.grey,
fontSize: 13,
),
),

const Spacer(),

const Icon(
Icons.calendar_today,
size: 14,
color: Colors.grey,
),

const SizedBox(width: 5),

Text(
_formatDate(
createdAt,
),
style:
const TextStyle(
color: Colors.grey,
fontSize: 13,
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
