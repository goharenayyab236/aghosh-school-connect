import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamsResultsScreen extends StatefulWidget {
  const ExamsResultsScreen({super.key});

  @override
  State<ExamsResultsScreen> createState() =>
      _ExamsResultsScreenState();
}

class _ExamsResultsScreenState
    extends State<ExamsResultsScreen> {
  String examFilter = 'All Exams';
  String resultFilter = 'All Results';

  // Convert Firestore date/string into DateTime.
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

        if (day != null &&
            month != null &&
            year != null) {
          return DateTime(year, month, day);
        }
      }
    }

    return null;
  }

  String _formatDate(dynamic value) {
    final date = _getDate(value);

    if (date == null) {
      return value?.toString() ?? 'Date not assigned';
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

  bool _isUpcoming(dynamic value) {
    final date = _getDate(value);

    if (date == null) {
      return false;
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final examDay = DateTime(
      date.year,
      date.month,
      date.day,
    );

    return examDay.isAfter(today);
  }

  // =========================
  // EXAM DETAILS
  // =========================

  void _showExamDetails(
      BuildContext context,
      Map<String, dynamic> data,
      ) {
    final examName =
        data['examName']?.toString() ??
            'Examination';

    final subject =
        data['subject']?.toString() ??
            'Subject';

    final examDate = data['examDate'];

    final totalMarks =
        data['totalMarks']?.toString() ??
            'Not available';

    final syllabus =
        data['syllabus']?.toString() ??
            data['description']?.toString() ??
            'No additional information available.';

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

                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      child: Icon(
                        Icons.event,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Text(
                        examName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                _detailRow(
                  Icons.book,
                  'Subject',
                  subject,
                ),

                _detailRow(
                  Icons.calendar_today,
                  'Exam Date',
                  _formatDate(examDate),
                ),

                _detailRow(
                  Icons.grade,
                  'Total Marks',
                  totalMarks,
                ),

                _detailRow(
                  Icons.description,
                  'Syllabus / Information',
                  syllabus,
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

  // =========================
  // RESULT DETAILS
  // =========================

  void _showResultDetails(
      BuildContext context,
      Map<String, dynamic> data,
      ) {
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
            'No remarks available.';

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

                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      child: Icon(
                        Icons.assessment,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Text(
                        examName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                _detailRow(
                  Icons.book,
                  'Subject',
                  subject,
                ),

                _detailRow(
                  Icons.bar_chart,
                  'Marks Obtained',
                  '$obtainedMarks / $totalMarks',
                ),

                _detailRow(
                  Icons.grade,
                  'Grade',
                  grade,
                ),

                _detailRow(
                  Icons.comment,
                  'Remarks',
                  remarks,
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
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          // EXAMS
          // =========================

          const Text(
            'Exams',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Exam filter
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
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: examFilter,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'All Exams',
                    child: Text('All Exams'),
                  ),
                  DropdownMenuItem(
                    value: "Today's Exams",
                    child: Text("Today's Exams"),
                  ),
                  DropdownMenuItem(
                    value: 'Upcoming Exams',
                    child: Text('Upcoming Exams'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      examFilter = value;
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 18),

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
                    child:
                    CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Text(
                  'Error loading exams:\n${snapshot.error}',
                );
              }

              final allExams =
                  snapshot.data?.docs ?? [];

              final exams = allExams.where(
                    (document) {
                  final data =
                  document.data()
                  as Map<String, dynamic>;

                  final examDate =
                  data['examDate'];

                  if (examFilter ==
                      "Today's Exams") {
                    return _isToday(examDate);
                  }

                  if (examFilter ==
                      'Upcoming Exams') {
                    return _isUpcoming(examDate);
                  }

                  return true;
                },
              ).toList();

              if (exams.isEmpty) {
                return Card(
                  child: Padding(
                    padding:
                    const EdgeInsets.all(20),
                    child: Text(
                      examFilter == 'All Exams'
                          ? 'No exams available.'
                          : 'No exams found for this filter.',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: exams.map((document) {
                  final data =
                  document.data()
                  as Map<String, dynamic>;

                  final examName =
                      data['examName']?.toString() ??
                          'Examination';

                  final subject =
                      data['subject']?.toString() ??
                          'Subject';

                  final examDate =
                  data['examDate'];

                  final totalMarks =
                      data['totalMarks']?.toString() ??
                          'Not available';

                  return Card(
                    margin:
                    const EdgeInsets.only(
                      bottom: 12,
                    ),
                    elevation: 2,
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(12),
                      onTap: () {
                        _showExamDetails(
                          context,
                          data,
                        );
                      },
                      child: ListTile(
                        leading:
                        const CircleAvatar(
                          child: Icon(Icons.event),
                        ),

                        title: Text(
                          examName,
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          '$subject\n'
                              'Date: ${_formatDate(examDate)}\n'
                              'Total Marks: $totalMarks',
                        ),

                        isThreeLine: true,

                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 30),

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

          // Result filter
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
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: resultFilter,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'All Results',
                    child: Text('All Results'),
                  ),
                  DropdownMenuItem(
                    value: 'Latest Results',
                    child: Text('Latest Results'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      resultFilter = value;
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 18),

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
                    child:
                    CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Text(
                  'Error loading results:\n${snapshot.error}',
                );
              }

              var results =
                  snapshot.data?.docs ?? [];

              // Latest Results:
              // show only the most recent result.
              if (resultFilter ==
                  'Latest Results' &&
                  results.length > 1) {
                results = results.take(1).toList();
              }

              if (results.isEmpty) {
                return const Card(
                  child: Padding(
                    padding:
                    EdgeInsets.all(20),
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
                children:
                results.map((document) {
                  final data =
                  document.data()
                  as Map<String, dynamic>;

                  final examName =
                      data['examName']
                          ?.toString() ??
                          'Examination';

                  final subject =
                      data['subject']
                          ?.toString() ??
                          'Subject';

                  final totalMarks =
                      data['totalMarks']
                          ?.toString() ??
                          '0';

                  final obtainedMarks =
                      data['obtainedMarks']
                          ?.toString() ??
                          '0';

                  final grade =
                      data['grade']?.toString() ??
                          'N/A';

                  final remarks =
                      data['remarks']?.toString() ??
                          '';

                  return Card(
                    margin:
                    const EdgeInsets.only(
                      bottom: 12,
                    ),
                    elevation: 2,
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(12),
                      onTap: () {
                        _showResultDetails(
                          context,
                          data,
                        );
                      },
                      child: Padding(
                        padding:
                        const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  child: Icon(
                                    Icons.assessment,
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                Expanded(
                                  child: Text(
                                    examName,
                                    style:
                                    const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                ),

                                const Icon(
                                  Icons
                                      .arrow_forward_ios,
                                  size: 16,
                                  color:
                                  Colors.grey,
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            Text(
                              'Subject: $subject',
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Marks: '
                                  '$obtainedMarks / $totalMarks',
                              style:
                              const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Grade: $grade',
                              style:
                              const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            if (remarks.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Remarks: $remarks',
                                style:
                                const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
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