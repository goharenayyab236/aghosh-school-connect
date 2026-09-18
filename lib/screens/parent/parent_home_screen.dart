import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'attendance_screen.dart';
import 'homework_screen.dart';
import 'notices_screen.dart';
import 'exams_results_screen.dart';
import 'leave_screen.dart';
import '../common/notifications_screen.dart';
import '../common/profile_screen.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? parentEmail =
        FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================
            // WELCOME CARD
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome, Parent!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    parentEmail ?? 'Parent',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'My Children',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // CHILD 1
            // =========================
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('students')
                  .doc('student_001')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Ahmed error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                }

                if (!snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return const Text(
                    'Ahmed Khan record not found.',
                    style: TextStyle(color: Colors.red),
                  );
                }

                final data =
                snapshot.data!.data()
                as Map<String, dynamic>;

                return _childCard(
                  name: data['name']?.toString() ?? 'Unknown',
                  className:
                  data['className']?.toString() ?? 'Unknown',
                  section:
                  data['section']?.toString() ?? 'Unknown',
                  rollNumber:
                  data['rollNumber']?.toString() ?? 'Unknown',
                  studentId:
                  data['studentId']?.toString() ?? 'student_001',
                );
              },
            ),

            // =========================
            // CHILD 2
            // =========================
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('students')
                  .doc('student_002')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Ayesha error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                }

                if (!snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return const Text(
                    'Ayesha Khan record not found.',
                    style: TextStyle(color: Colors.red),
                  );
                }

                final data =
                snapshot.data!.data()
                as Map<String, dynamic>;

                return _childCard(
                  name: data['name']?.toString() ?? 'Unknown',
                  className:
                  data['className']?.toString() ?? 'Unknown',
                  section:
                  data['section']?.toString() ?? 'Unknown',
                  rollNumber:
                  data['rollNumber']?.toString() ?? 'Unknown',
                  studentId:
                  data['studentId']?.toString() ?? 'student_002',
                );
              },
            ),

            const SizedBox(height: 20),

            // =========================
            // QUICK ACCESS
            // =========================
            const Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [

                _quickCard(
                  context,
                  Icons.calendar_month,
                  'Attendance',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const AttendanceScreen(),
                      ),
                    );
                  },
                ),

                _quickCard(
                  context,
                  Icons.menu_book,
                  'Homework',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const HomeworkScreen(),
                      ),
                    );
                  },
                ),

                _quickCard(
                  context,
                  Icons.assignment,
                  'Exams & Results',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const ExamsResultsScreen(),
                      ),
                    );
                  },
                ),

                _quickCard(
                  context,
                  Icons.campaign,
                  'Notices',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const NoticesScreen(),
                      ),
                    );
                  },
                ),

                _quickCard(
                  context,
                  Icons.event_note,
                  'Leave Request',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const LeaveScreen(),
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

  // =========================
  // CHILD CARD
  // =========================
  Widget _childCard({
    required String name,
    required String className,
    required String section,
    required String rollNumber,
    required String studentId,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade100,
            child: Icon(
              Icons.person,
              color: Colors.blue.shade700,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$className - Section $section',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Roll No: $rollNumber',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'ID: $studentId',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // QUICK CARD
  // =========================
  Widget _quickCard(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 8),
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
    );
  }
}