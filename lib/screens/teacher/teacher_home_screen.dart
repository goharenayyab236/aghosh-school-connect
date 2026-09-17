import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'class_list_screen.dart';
import 'mark_attendance_screen.dart';
import 'homework_marks_screen.dart';
import 'teacher_leave_screen.dart';

import '../common/notifications_screen.dart';
import '../common/profile_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  String teacherName = 'Teacher';
  String teacherEmail = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTeacherProfile();
  }

  Future<void> loadTeacherProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final document = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (document.exists) {
        final data = document.data();

        setState(() {
          teacherName = data?['name']?.toString() ?? 'Teacher';
          teacherEmail =
              data?['email']?.toString() ?? user.email ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          teacherName = 'Teacher';
          teacherEmail = user.email ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $teacherName! 👋',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Manage your classes, attendance and homework.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                        Icons.school,
                        size: 35,
                        color: Colors.blue.shade700,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Teacher',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            teacherName,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            teacherEmail,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Teacher Tools',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.15,
              children: [
                _toolCard(
                  context,
                  Icons.groups,
                  'My Classes',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const ClassListScreen(),
                      ),
                    );
                  },
                ),

                _toolCard(
                  context,
                  Icons.fact_check,
                  'Attendance',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const MarkAttendanceScreen(),
                      ),
                    );
                  },
                ),

                _toolCard(
                  context,
                  Icons.menu_book,
                  'Homework & Marks',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const HomeworkMarksScreen(),
                      ),
                    );
                  },
                ),

                _toolCard(
                  context,
                  Icons.event_note,
                  'Leave Requests',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const TeacherLeaveScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolCard(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 38,
                color: Colors.blue,
              ),

              const SizedBox(height: 12),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}