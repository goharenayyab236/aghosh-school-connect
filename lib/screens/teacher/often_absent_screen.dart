import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OftenAbsentScreen extends StatelessWidget {
  const OftenAbsentScreen({super.key});

  final String className = 'Grade 5';
  final String section = 'A';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Often Absent'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('className', isEqualTo: className)
            .where('section', isEqualTo: section)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading attendance:\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final records = snapshot.data?.docs ?? [];

          if (records.isEmpty) {
            return _emptyState(
              icon: Icons.person_search,
              title: 'No attendance records yet',
              message: 'Attendance data will appear here.',
            );
          }

          // ------------------------------------------------------------
          // Calculate attendance for every student
          // ------------------------------------------------------------

          final Map<String, Map<String, dynamic>> studentStats = {};

          for (final document in records) {
            final data =
            document.data() as Map<String, dynamic>;

            final studentId =
                data['studentId']?.toString() ?? document.id;

            final studentName =
                data['studentName']?.toString() ??
                    'Unknown Student';

            final rollNumber =
                data['rollNumber']?.toString() ??
                    'Not assigned';

            final status =
                data['status']?.toString() ?? '';

            if (!studentStats.containsKey(studentId)) {
              studentStats[studentId] = {
                'studentName': studentName,
                'rollNumber': rollNumber,
                'present': 0,
                'absent': 0,
              };
            }

            if (status == 'Present') {
              studentStats[studentId]!['present'] =
                  (studentStats[studentId]!['present'] as int) + 1;
            } else if (status == 'Absent') {
              studentStats[studentId]!['absent'] =
                  (studentStats[studentId]!['absent'] as int) + 1;
            }
          }

          // ------------------------------------------------------------
          // Convert to list
          // ------------------------------------------------------------

          final students = studentStats.entries.toList();

          // ------------------------------------------------------------
          // Only students with 3 or more absences
          // ------------------------------------------------------------

          final oftenAbsentStudents =
          students.where((student) {
            final absent =
            student.value['absent'] as int;

            return absent >= 3;
          }).toList();

          // Most absences first
          oftenAbsentStudents.sort((a, b) {
            final absentA =
            a.value['absent'] as int;

            final absentB =
            b.value['absent'] as int;

            return absentB.compareTo(absentA);
          });

          if (oftenAbsentStudents.isEmpty) {
            return _noOftenAbsentState();
          }

          // ------------------------------------------------------------
          // Summary values
          // ------------------------------------------------------------

          final totalOftenAbsent =
              oftenAbsentStudents.length;

          final highestAbsence =
          oftenAbsentStudents.first.value['absent'] as int;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --------------------------------------------------------
              // Class Header
              // --------------------------------------------------------

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.class_,
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
                              '$className - Section $section',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Students with frequent absences',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --------------------------------------------------------
              // Summary
              // --------------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      title: 'Often Absent',
                      value: '$totalOftenAbsent',
                      icon: Icons.person_off,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _summaryCard(
                      title: 'Highest Absences',
                      value: '$highestAbsence',
                      icon: Icons.warning_amber_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Students Needing Attention',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Students with 3 or more recorded absences',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------------
              // Student Cards
              // --------------------------------------------------------

              ...oftenAbsentStudents.map((student) {
                final data = student.value;

                final studentName =
                data['studentName'] as String;

                final rollNumber =
                data['rollNumber'] as String;

                final present =
                data['present'] as int;

                final absent =
                data['absent'] as int;

                final total = present + absent;

                final percentage = total == 0
                    ? 0
                    : ((present / total) * 100).round();

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Student information
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 27,
                              child: Text(
                                rollNumber,
                                textAlign:
                                TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    studentName,
                                    style:
                                    const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    'Roll No: $rollNumber',
                                    style:
                                    const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                Colors.orange.shade100,
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Often Absent',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        const Divider(),

                        const SizedBox(height: 10),

                        // Statistics
                        Row(
                          children: [
                            Expanded(
                              child: _stat(
                                'Present',
                                '$present',
                                Icons.check_circle,
                                Colors.green,
                              ),
                            ),

                            Expanded(
                              child: _stat(
                                'Absent',
                                '$absent',
                                Icons.cancel,
                                Colors.red,
                              ),
                            ),

                            Expanded(
                              child: _stat(
                                'Attendance',
                                '$percentage%',
                                Icons.percent,
                                Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // ------------------------------------------------------------------
  // Summary Card
  // ------------------------------------------------------------------

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Statistics
  // ------------------------------------------------------------------

  Widget _stat(
      String title,
      String value,
      IconData icon,
      Color iconColor,
      ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 21,
          color: iconColor,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Empty state
  // ------------------------------------------------------------------

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 65,
              color: Colors.grey,
            ),

            const SizedBox(height: 16),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // No Often Absent Students
  // ------------------------------------------------------------------

  Widget _noOftenAbsentState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 65,
              color: Colors.green,
            ),

            const SizedBox(height: 16),

            const Text(
              'No Often Absent Students',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'No student has 3 or more recorded absences.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}