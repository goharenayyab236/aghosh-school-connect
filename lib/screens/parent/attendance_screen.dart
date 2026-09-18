import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String selectedMonth = 'All Months';

  // Selected child
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

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  DateTime? _getDate(Map<String, dynamic> data) {
    final dateValue = data['date'];

    if (dateValue is Timestamp) {
      return dateValue.toDate();
    }

    if (dateValue is DateTime) {
      return dateValue;
    }

    if (dateValue is String) {
      final parsed = DateTime.tryParse(dateValue);

      if (parsed != null) {
        return parsed;
      }

      final parts = dateValue.split('/');

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

  String _formatDate(Map<String, dynamic> data) {
    final date = _getDate(data);

    if (date == null) {
      return data['date']?.toString() ?? 'Unknown date';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('studentId', isEqualTo: selectedStudentId)
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
                  'Error loading attendance:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final allRecords = snapshot.data?.docs ?? [];

          // Create month options from the Firebase records.
          final Set<String> monthSet = {};

          for (final document in allRecords) {
            final data = document.data() as Map<String, dynamic>;
            final date = _getDate(data);

            if (date != null) {
              monthSet.add('${date.year}-${date.month}');
            }
          }

          final sortedMonths = monthSet.toList()
            ..sort((a, b) => b.compareTo(a));

          final monthOptions = <String>['All Months'];

          for (final monthKey in sortedMonths) {
            final parts = monthKey.split('-');

            if (parts.length == 2) {
              final year = int.tryParse(parts[0]);
              final month = int.tryParse(parts[1]);

              if (year != null && month != null) {
                monthOptions.add('${_monthName(month)} $year');
              }
            }
          }

          // If the selected month no longer exists, return to All Months.
          if (!monthOptions.contains(selectedMonth)) {
            selectedMonth = 'All Months';
          }

          // Filter records according to selected month.
          final records = allRecords.where((document) {
            if (selectedMonth == 'All Months') {
              return true;
            }

            final data = document.data() as Map<String, dynamic>;
            final date = _getDate(data);

            if (date == null) {
              return false;
            }

            final recordMonth =
                '${_monthName(date.month)} ${date.year}';

            return recordMonth == selectedMonth;
          }).toList();

          // Sort newest attendance first.
          records.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;

            final dateA = _getDate(dataA);
            final dateB = _getDate(dataB);

            if (dateA == null || dateB == null) {
              return 0;
            }

            return dateB.compareTo(dateA);
          });

          int present = 0;
          int absent = 0;

          for (final document in records) {
            final data =
            document.data() as Map<String, dynamic>;

            final status =
            (data['status'] ?? '').toString().toLowerCase();

            if (status == 'present') {
              present++;
            } else if (status == 'absent') {
              absent++;
            }
          }

          final total = records.length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Attendance Summary',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // CHILD SELECTOR
              // =========================
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedStudentId,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                    ),
                    items: students.map((student) {
                      return DropdownMenuItem<String>(
                        value: student['id'],
                        child: Text(
                          student['name']!,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      final selected = students.firstWhere(
                            (student) => student['id'] == value,
                      );

                      setState(() {
                        selectedStudentId = value;
                        selectedStudentName =
                        selected['name']!;
                        selectedMonth = 'All Months';
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        child: Icon(
                          Icons.person,
                          size: 45,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        selectedStudentName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Student ID: $selectedStudentId',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                        children: [
                          _attendanceItem(
                            'Present',
                            present.toString(),
                            Colors.green,
                          ),
                          _attendanceItem(
                            'Absent',
                            absent.toString(),
                            Colors.red,
                          ),
                          _attendanceItem(
                            'Total',
                            total.toString(),
                            Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attendance History',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Month filter
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                        ),
                        items: monthOptions.map((month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(
                              month,
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedMonth = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              if (selectedMonth != 'All Months')
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Showing attendance for $selectedMonth',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ),

              if (records.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No attendance records available.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

              ...records.map((document) {
                final data =
                document.data() as Map<String, dynamic>;

                final status =
                    data['status']?.toString() ?? 'Unknown';

                final isPresent =
                    status.toLowerCase() == 'present';

                return Card(
                  margin:
                  const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPresent
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      child: Icon(
                        isPresent
                            ? Icons.check
                            : Icons.close,
                        color: isPresent
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),

                    title: Text(
                      _formatDate(data),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      selectedStudentName,
                    ),

                    trailing: Text(
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPresent
                            ? Colors.green
                            : Colors.red,
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

  Widget _attendanceItem(
      String title,
      String value,
      Color color,
      ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        Text(title),
      ],
    );
  }
}