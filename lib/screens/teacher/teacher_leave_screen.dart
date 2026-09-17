import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherLeaveScreen extends StatelessWidget {
  const TeacherLeaveScreen({super.key});

  Future<void> updateLeaveStatus(
      BuildContext context,
      String documentId,
      String status,
      ) async {
    try {
      await FirebaseFirestore.instance
          .collection('leave_requests')
          .doc(documentId)
          .update({
        'status': status,
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Leave request $status successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating leave request: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leave_requests')
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
                'Error loading leave requests:\n'
                    '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final requests =
              snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Student Leave Requests',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              if (requests.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'No leave requests found.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

              ...requests.map((document) {
                final data =
                document.data()
                as Map<String, dynamic>;

                final student =
                    data['studentName']
                        ?.toString() ??
                        'Unknown Student';

                final reason =
                    data['reason']
                        ?.toString() ??
                        'No reason provided';

                final status =
                    data['status']
                        ?.toString() ??
                        'Pending';

                final startDate =
                    data['startDate']
                        ?.toString() ??
                        '';

                final endDate =
                    data['endDate']
                        ?.toString() ??
                        '';

                return _leaveCard(
                  context,
                  document.id,
                  student,
                  reason,
                  status,
                  startDate,
                  endDate,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _leaveCard(
      BuildContext context,
      String documentId,
      String student,
      String reason,
      String status,
      String startDate,
      String endDate,
      ) {
    final isPending = status == 'Pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    student,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(20),
                    color: status == 'Approved'
                        ? Colors.green.shade100
                        : status == 'Rejected'
                        ? Colors.red.shade100
                        : Colors.orange.shade100,
                  ),

                  child: Text(
                    status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: status == 'Approved'
                          ? Colors.green.shade700
                          : status == 'Rejected'
                          ? Colors.red.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Reason: $reason',
              style: const TextStyle(
                fontSize: 15,
              ),
            ),

            if (startDate.isNotEmpty) ...[
              const SizedBox(height: 8),

              Text(
                'Start Date: $startDate',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],

            if (endDate.isNotEmpty) ...[
              const SizedBox(height: 4),

              Text(
                'End Date: $endDate',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],

            if (isPending) ...[
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        updateLeaveStatus(
                          context,
                          documentId,
                          'Rejected',
                        );
                      },
                      child: const Text('Reject'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        updateLeaveStatus(
                          context,
                          documentId,
                          'Approved',
                        );
                      },
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}