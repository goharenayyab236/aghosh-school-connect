import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final reasonController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  // =========================================================
  // SELECTED CHILD
  // =========================================================

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

  String selectedLeaveType = 'Medical';
  String selectedFilter = 'All Requests';

  bool isSubmitting = false;

  final List<String> leaveTypes = [
    'Medical',
    'Personal',
    'Family',
    'Other',
  ];

  final List<String> filters = [
    'All Requests',
    'Pending',
    'Approved',
    'Rejected',
  ];

  Future<void> selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      initialDate: startDate ?? DateTime.now(),
    );

    if (date != null) {
      setState(() {
        startDate = date;

        if (endDate != null && endDate!.isBefore(date)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> selectEndDate() async {
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select the start date first.',
          ),
        ),
      );
      return;
    }

    final date = await showDatePicker(
      context: context,
      firstDate: startDate!,
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      initialDate: endDate ?? startDate!,
    );

    if (date != null) {
      setState(() {
        endDate = date;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Select Date';
    }

    return '${date.day}/'
        '${date.month}/'
        '${date.year}';
  }

  String firestoreDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> submitRequest() async {
    if (startDate == null ||
        endDate == null ||
        reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select dates and enter a reason.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('leave_requests')
          .add({
        'studentId': selectedStudentId,
        'studentName': selectedStudentName,
        'leaveType': selectedLeaveType,
        'reason': reasonController.text.trim(),
        'startDate': firestoreDate(startDate!),
        'endDate': firestoreDate(endDate!),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      reasonController.clear();

      setState(() {
        startDate = null;
        endDate = null;
        selectedLeaveType = 'Medical';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Leave request submitted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error submitting leave request:\n$e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void showRequestDetails(
      BuildContext context,
      Map<String, dynamic> data,
      ) {
    final leaveType =
        data['leaveType']?.toString() ?? 'Not specified';

    final reason =
        data['reason']?.toString() ?? 'No reason';

    final startDate =
        data['startDate']?.toString() ?? 'Unknown date';

    final endDate =
        data['endDate']?.toString() ?? startDate;

    final status =
        data['status']?.toString() ?? 'Pending';

    final studentName =
        data['studentName']?.toString() ?? 'Unknown Student';

    Color statusColor;

    if (status.toLowerCase() == 'approved') {
      statusColor = Colors.green;
    } else if (status.toLowerCase() == 'rejected') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Leave Request Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _detailRow(
                  Icons.person,
                  'Student',
                  studentName,
                ),

                _detailRow(
                  Icons.category,
                  'Leave Type',
                  leaveType,
                ),

                _detailRow(
                  Icons.date_range,
                  'Leave Date',
                  startDate == endDate
                      ? startDate
                      : '$startDate to $endDate',
                ),

                _detailRow(
                  Icons.description,
                  'Reason',
                  reason,
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color:
                        statusColor.withOpacity(0.12),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
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
      padding:
      const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Request'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Submit Leave Request',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // CHILD SELECTOR
            // =================================================

            const Text(
              'Select Student',
              style: TextStyle(
                fontWeight: FontWeight.w600,
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
                  child: Text(
                    student['name']!,
                  ),
                );
              }).toList(),
              onChanged: isSubmitting
                  ? null
                  : (value) {
                if (value == null) {
                  return;
                }

                final selected =
                students.firstWhere(
                      (student) =>
                  student['id'] == value,
                );

                setState(() {
                  selectedStudentId = value;
                  selectedStudentName =
                  selected['name']!;

                  selectedFilter =
                  'All Requests';
                });
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Leave Type',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedLeaveType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon:
                Icon(Icons.category),
              ),
              items: leaveTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: isSubmitting
                  ? null
                  : (value) {
                if (value != null) {
                  setState(() {
                    selectedLeaveType =
                        value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Start Date',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: isSubmitting
                  ? null
                  : selectStartDate,
              icon: const Icon(
                Icons.calendar_today,
              ),
              label: Text(
                formatDate(startDate),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'End Date',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: isSubmitting
                  ? null
                  : selectEndDate,
              icon: const Icon(
                Icons.event,
              ),
              label: Text(
                formatDate(endDate),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Reason',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: reasonController,
              maxLines: 5,
              enabled: !isSubmitting,
              decoration: const InputDecoration(
                hintText:
                'Enter reason for leave',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isSubmitting
                    ? null
                    : submitRequest,
                icon: isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.send),
                label: Text(
                  isSubmitting
                      ? 'Submitting...'
                      : 'Submit Leave Request',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              'My Leave Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            SingleChildScrollView(
              scrollDirection:
              Axis.horizontal,
              child: Row(
                children: filters.map((filter) {
                  final isSelected =
                      selectedFilter == filter;

                  return Padding(
                    padding:
                    const EdgeInsets.only(
                      right: 8,
                    ),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedFilter =
                              filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 18),

            // =================================================
            // LEAVE REQUESTS
            // =================================================

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('leave_requests')
                  .where(
                'studentId',
                isEqualTo: selectedStudentId,
              )
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding:
                      EdgeInsets.all(25),
                      child:
                      CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(20),
                      child: Text(
                        'Error loading requests:\n'
                            '${snapshot.error}',
                      ),
                    ),
                  );
                }

                final allRequests =
                    snapshot.data?.docs ?? [];

                final requests =
                allRequests.where((doc) {
                  final data = doc.data()
                  as Map<String, dynamic>;

                  final status =
                      data['status']
                          ?.toString() ??
                          'Pending';

                  if (selectedFilter ==
                      'All Requests') {
                    return true;
                  }

                  return status.toLowerCase() ==
                      selectedFilter
                          .toLowerCase();
                }).toList();

                if (requests.isEmpty) {
                  return Card(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          selectedFilter ==
                              'All Requests'
                              ? 'No previous leave requests.'
                              : 'No $selectedFilter leave requests.',
                          style:
                          const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children:
                  requests.map((document) {
                    final data = document.data()
                    as Map<String, dynamic>;

                    final reason =
                        data['reason']
                            ?.toString() ??
                            'No reason';

                    final startDate =
                        data['startDate']
                            ?.toString() ??
                            'Unknown date';

                    final endDate =
                        data['endDate']
                            ?.toString() ??
                            startDate;

                    final leaveType =
                        data['leaveType']
                            ?.toString() ??
                            'Not specified';

                    final status =
                        data['status']
                            ?.toString() ??
                            'Pending';

                    final statusColor =
                    getStatusColor(
                      status,
                    );

                    return Card(
                      margin:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),
                      elevation: 2,

                      child: InkWell(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                        onTap: () {
                          showRequestDetails(
                            context,
                            data,
                          );
                        },

                        child: Padding(
                          padding:
                          const EdgeInsets.all(
                            16,
                          ),

                          child: Row(
                            children: [
                              const CircleAvatar(
                                child: Icon(
                                  Icons.event_note,
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      leaveType,
                                      style:
                                      const TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                        FontWeight
                                            .bold,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 6,
                                    ),

                                    Text(
                                      startDate ==
                                          endDate
                                          ? startDate
                                          : '$startDate to $endDate',
                                    ),

                                    const SizedBox(
                                      height: 6,
                                    ),

                                    Text(
                                      reason,
                                      maxLines: 1,
                                      overflow:
                                      TextOverflow
                                          .ellipsis,
                                      style:
                                      const TextStyle(
                                        color:
                                        Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              Column(
                                children: [
                                  Container(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration:
                                    BoxDecoration(
                                      color:
                                      statusColor
                                          .withOpacity(
                                        0.12,
                                      ),
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                        20,
                                      ),
                                    ),
                                    child: Text(
                                      status,
                                      style:
                                      TextStyle(
                                        color:
                                        statusColor,
                                        fontSize:
                                        12,
                                        fontWeight:
                                        FontWeight
                                            .bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  const Icon(
                                    Icons
                                        .arrow_forward_ios,
                                    size: 16,
                                  ),
                                ],
                              ),
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
      ),
    );
  }
}