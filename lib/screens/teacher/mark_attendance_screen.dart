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

  String todayDate() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> saveAttendance() async {
    setState(() {
      isSaving = true;
    });

    try {
      final studentsSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where(
        'studentId',
        isEqualTo: 'student_001',
      )
          .get();

      if (studentsSnapshot.docs.isEmpty) {
        throw Exception('Student not found.');
      }

      final studentDocument = studentsSnapshot.docs.first;

      final data =
      studentDocument.data();

      final studentName =
          data['name']?.toString() ?? 'Ahmed Khan';

      final status =
      attendance['student_001'] == true
          ? 'Present'
          : 'Absent';

      await FirebaseFirestore.instance
          .collection('attendance')
          .add({
        'studentId': 'student_001',
        'studentName': studentName,
        'date': todayDate(),
        'status': status,
      });

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
            return Center(
              child: Text(
                'Error loading student:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final students = snapshot.data?.docs ?? [];

          if (students.isEmpty) {
            return const Center(
              child: Text(
                'No students found.',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Grade 5',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Text(
                      todayDate(),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final document = students[index];

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

                    final isPresent =
                        attendance[studentId] ?? true;

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),

                      child: SwitchListTile(
                        title: Text(
                          studentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        subtitle: Text(
                          isPresent
                              ? 'Present'
                              : 'Absent',
                        ),

                        value: isPresent,

                        onChanged: (value) {
                          setState(() {
                            attendance[studentId] =
                                value;
                          });
                        },

                        secondary: const Icon(
                          Icons.person,
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed:
                    isSaving
                        ? null
                        : saveAttendance,

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