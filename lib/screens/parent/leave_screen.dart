import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final reasonController = TextEditingController();

  DateTime? selectedDate;
  bool isSubmitting = false;

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> submitRequest() async {
    if (selectedDate == null ||
        reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a date and enter a reason.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final dateString =
          '${selectedDate!.year}-'
          '${selectedDate!.month.toString().padLeft(2, '0')}-'
          '${selectedDate!.day.toString().padLeft(2, '0')}';

      await FirebaseFirestore.instance
          .collection('leave_requests')
          .add({
        'studentId': 'student_001',
        'studentName': 'Ahmed Khan',
        'reason': reasonController.text.trim(),
        'startDate': dateString,
        'endDate': dateString,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      reasonController.clear();

      setState(() {
        selectedDate = null;
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

            const Text(
              'Leave Date',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed:
              isSubmitting ? null : selectDate,

              icon: const Icon(
                Icons.calendar_today,
              ),

              label: Text(
                selectedDate == null
                    ? 'Select Date'
                    : '${selectedDate!.day}/'
                    '${selectedDate!.month}/'
                    '${selectedDate!.year}',
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
                hintText: 'Enter reason for leave',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 52,

              child: ElevatedButton.icon(
                onPressed:
                isSubmitting ? null : submitRequest,

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

            const SizedBox(height: 30),

            const Text(
              'Previous Requests',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('leave_requests')
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

                final requests =
                    snapshot.data?.docs ?? [];

                if (requests.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'No previous leave requests.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: requests.map((document) {
                    final data =
                    document.data()
                    as Map<String, dynamic>;

                    final reason =
                        data['reason']?.toString() ??
                            'No reason';

                    final startDate =
                        data['startDate']?.toString() ??
                            'Unknown date';

                    final endDate =
                        data['endDate']?.toString() ??
                            startDate;

                    final status =
                        data['status']?.toString() ??
                            'Pending';

                    final isPending =
                        status.toLowerCase() ==
                            'pending';

                    return Card(
                      margin:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),

                      elevation: 2,

                      child: Padding(
                        padding:
                        const EdgeInsets.all(16),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  child: Icon(
                                    Icons.event_note,
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                const Expanded(
                                  child: Text(
                                    'Leave Request',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Text(
                                  status,
                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                    color: isPending
                                        ? Colors.orange
                                        : status
                                        .toLowerCase() ==
                                        'approved'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            Text(
                              'Date: $startDate'
                                  '${startDate != endDate ? ' to $endDate' : ''}',
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Reason: $reason',
                            ),
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
      ),
    );
  }
}