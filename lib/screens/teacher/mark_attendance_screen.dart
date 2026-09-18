import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState
    extends State<MarkAttendanceScreen> {
  final Map<String, bool> attendance = {};

  bool isSaving = false;

  // Current class
  final String className = 'Grade 5';
  final String section = 'A';

  String todayDate() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> saveAttendance(
      List<QueryDocumentSnapshot> students) async {
    setState(() {
      isSaving = true;
    });

    try {
      final date = todayDate();

      for (final document in students) {
        final data =
        document.data() as Map<String, dynamic>;

        final studentId =
            data['studentId']?.toString() ??
                document.id;

        final studentName =
            data['name']?.toString() ??
                'Unknown Student';

        final rollNumber =
            data['rollNumber']?.toString() ??
                'Not assigned';

        final status =
        attendance[studentId] == true
            ? 'Present'
            : 'Absent';

        // Use a fixed document ID so saving again
        // updates today's attendance instead of
        // creating duplicate records.
        final attendanceDocumentId =
            '${studentId}_$date';

        await FirebaseFirestore.instance
            .collection('attendance')
            .doc(attendanceDocumentId)
            .set({
          'studentId': studentId,
          'studentName': studentName,
          'rollNumber': rollNumber,
          'className': className,
          'section': section,
          'date': date,
          'status': status,
          'updatedAt':
          FieldValue.serverTimestamp(),
        });

        // --------------------------------------------------
        // CREATE ABSENT NOTIFICATION
        // --------------------------------------------------
        if (status == 'Absent') {
          final notificationDocumentId =
              'attendance_${studentId}_$date';

          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(notificationDocumentId)
              .set({
            'type': 'attendance',
            'studentId': studentId,
            'studentName': studentName,
            'title': 'Attendance Alert',
            'message':
            '$studentName was marked absent on $date.',
            'className': className,
            'section': section,
            'attendanceId': attendanceDocumentId,
            'date': date,
            'createdAt':
            FieldValue.serverTimestamp(),
          });
        }

        // --------------------------------------------------
        // REMOVE ABSENT NOTIFICATION IF CHANGED TO PRESENT
        // --------------------------------------------------
        if (status == 'Present') {
          final notificationDocumentId =
              'attendance_${studentId}_$date';

          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(notificationDocumentId)
              .delete()
              .catchError((_) {});
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Attendance saved successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving attendance: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
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
                  'Error loading students:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final students =
              snapshot.data?.docs ?? [];

          if (students.isEmpty) {
            return const Center(
              child: Text(
                'No students found in this class.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                ),
              ),
            );
          }

          // Make every student Present by default.
          for (final document in students) {
            final data =
            document.data()
            as Map<String, dynamic>;

            final studentId =
                data['studentId']?.toString() ??
                    document.id;

            attendance.putIfAbsent(
              studentId,
                  () => true,
            );
          }

          final presentCount =
              students.where((document) {
                final data =
                document.data()
                as Map<String, dynamic>;

                final studentId =
                    data['studentId']?.toString() ??
                        document.id;

                return attendance[studentId] ?? true;
              }).length;

          final absentCount =
              students.length - presentCount;

          return Column(
            children: [
              // Class information
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  10,
                ),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding:
                    const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.class_,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '$className - Section $section',
                                style:
                                const TextStyle(
                                  fontSize: 19,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                          children: [
                            Text(
                              'Date: ${todayDate()}',
                              style:
                              const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${students.length} student${students.length == 1 ? '' : 's'}',
                              style:
                              const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Attendance summary
              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding:
                          const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Text(
                                '$presentCount',
                                style:
                                const TextStyle(
                                  fontSize: 22,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                              const Text('Present'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding:
                          const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Text(
                                '$absentCount',
                                style:
                                const TextStyle(
                                  fontSize: 22,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                              const Text('Absent'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),

              // Student list
              Expanded(
                child: ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  itemCount: students.length,
                  itemBuilder:
                      (context, index) {
                    final document =
                    students[index];

                    final data =
                    document.data()
                    as Map<String, dynamic>;

                    final studentId =
                        data['studentId']
                            ?.toString() ??
                            document.id;

                    final studentName =
                        data['name']
                            ?.toString() ??
                            'Unknown Student';

                    final rollNumber =
                        data['rollNumber']
                            ?.toString() ??
                            'Not assigned';

                    final isPresent =
                        attendance[studentId] ??
                            true;

                    return Card(
                      margin:
                      const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: SwitchListTile(
                        title: Text(
                          studentName,
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Roll No: $rollNumber\n'
                              '${isPresent ? 'Present' : 'Absent'}',
                        ),
                        value: isPresent,
                        onChanged: (value) {
                          setState(() {
                            attendance[studentId] =
                                value;
                          });
                        },
                        secondary: CircleAvatar(
                          child: Text(
                            rollNumber,
                            style:
                            const TextStyle(
                              fontSize: 11,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Save button
              Padding(
                padding:
                const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isSaving
                        ? null
                        : () {
                      saveAttendance(
                        students,
                      );
                    },
                    icon: isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.save),
                    label: Text(
                      isSaving
                          ? 'Saving...'
                          : 'Save Attendance',
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}