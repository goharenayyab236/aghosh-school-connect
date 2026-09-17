import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamsResultsScreen extends StatelessWidget {
  const ExamsResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams & Results'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Examination Information',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // =========================
          // UPCOMING EXAMS
          // =========================

          const Text(
            'Upcoming Exams',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('exams')
                .where(
              'studentId',
              isEqualTo: 'student_001',
            )
                .snapshots(),

            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Text(
                  'Error loading exams:\n${snapshot.error}',
                );
              }

              final exams = snapshot.data?.docs ?? [];

              if (exams.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No upcoming exams available.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: exams.map((document) {
                  final data =
                  document.data() as Map<String, dynamic>;

                  final examName =
                      data['examName']?.toString() ??
                          'Examination';

                  final subject =
                      data['subject']?.toString() ??
                          'Subject';

                  final examDate =
                      data['examDate']?.toString() ??
                          'Date not assigned';

                  final totalMarks =
                      data['totalMarks']?.toString() ??
                          'Not available';

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.event),
                      ),
                      title: Text(
                        examName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '$subject\nDate: $examDate\nTotal Marks: $totalMarks',
                      ),
                      isThreeLine: true,
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 25),

          // =========================
          // RESULTS
          // =========================

          const Text(
            'Results',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('results')
                .where(
              'studentId',
              isEqualTo: 'student_001',
            )
                .snapshots(),

            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Text(
                  'Error loading results:\n${snapshot.error}',
                );
              }

              final results = snapshot.data?.docs ?? [];

              if (results.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No examination results available yet.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: results.map((document) {
                  final data =
                  document.data() as Map<String, dynamic>;

                  final examName =
                      data['examName']?.toString() ??
                          'Examination';

                  final subject =
                      data['subject']?.toString() ??
                          'Subject';

                  final totalMarks =
                      data['totalMarks']?.toString() ??
                          '0';

                  final obtainedMarks =
                      data['obtainedMarks']?.toString() ??
                          '0';

                  final grade =
                      data['grade']?.toString() ??
                          'N/A';

                  final remarks =
                      data['remarks']?.toString() ??
                          '';

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                child: Icon(
                                  Icons.assessment,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  examName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          Text(
                            'Subject: $subject',
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Marks: $obtainedMarks / $totalMarks',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Grade: $grade',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          if (remarks.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Remarks: $remarks',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
    );
  }
}