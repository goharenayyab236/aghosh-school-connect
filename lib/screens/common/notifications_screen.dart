import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Stores notification IDs that the user has removed
  // from this screen.
  final Set<String> deletedNotifications = {};

  // =========================
  // CURRENT STUDENT
  // =========================

  String selectedStudentId = 'student_001';
  String selectedStudentName = 'Ahmed Khan';

  final List<Map<String, String>> students = [
    {
      'id': 'student_001',
      'name': 'Ahmed Khan',
    },
    {
      'id': 'student_002',
      'name': 'Ayesha Khan',
    },
  ];

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

  // =========================
  // FORMAT DATE / TIME
  // =========================

  String formatDate(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is Timestamp) {
      final date = value.toDate();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    if (value is DateTime) {
      return '${value.day.toString().padLeft(2, '0')}/'
          '${value.month.toString().padLeft(2, '0')}/'
          '${value.year}';
    }

    return value.toString();
  }

  // =========================
  // NOTIFICATION TYPE ICON
  // =========================

  IconData getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'homework':
        return Icons.menu_book;

      case 'attendance':
        return Icons.calendar_month;

      case 'exam':
        return Icons.assignment;

      case 'leave':
        return Icons.event_note;

      case 'notice':
        return Icons.campaign;

      default:
        return Icons.notifications;
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
          // SELECT STUDENT
          // =========================

          const Text(
            'Select Student',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: selectedStudentId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            items: students.map((student) {
              return DropdownMenuItem<String>(
                value: student['id'],
                child: Text(student['name']!),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              final selectedStudent = students.firstWhere(
                    (student) => student['id'] == value,
              );

              setState(() {
                selectedStudentId = value;
                selectedStudentName = selectedStudent['name']!;
              });
            },
          ),

          const SizedBox(height: 25),

          // =========================
          // FIRESTORE NOTIFICATIONS
          // =========================

          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where(
              'studentId',
              isEqualTo: selectedStudentId,
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
                  'Error loading notifications:\n${snapshot.error}',
                );
              }

              final notifications =
                  snapshot.data?.docs ?? [];

              final visibleNotifications =
              notifications.where((document) {
                return !deletedNotifications.contains(
                  'notification_${document.id}',
                );
              }).toList();

              if (visibleNotifications.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No notifications.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children:
                visibleNotifications.map((document) {
                  final data =
                  document.data()
                  as Map<String, dynamic>;

                  final type =
                      data['type']?.toString() ??
                          'notification';

                  final title =
                      data['title']?.toString() ??
                          'Notification';

                  final message =
                      data['message']?.toString() ??
                          data['description']?.toString() ??
                          '';

                  final date =
                  formatDate(
                    data['createdAt'] ??
                        data['date'],
                  );

                  return _notificationCard(
                    notificationId:
                    'notification_${document.id}',
                    icon: getNotificationIcon(type),
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
                      data['description']?.toString() ??
                          data['message']?.toString() ??
                          'New school notice.';

                  final date =
                  formatDate(
                    data['createdAt'] ??
                        data['date'],
                  );

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
              isEqualTo: selectedStudentId,
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
              isEqualTo: selectedStudentId,
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
                  formatDate(
                    data['date'],
                  );

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