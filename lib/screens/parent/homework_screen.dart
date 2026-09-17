import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeworkScreen extends StatelessWidget {
  const HomeworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework'),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('homework')
            .where('studentId', isEqualTo: 'student_001')
            .snapshots(),

        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading homework:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final homework = snapshot.data?.docs ?? [];

          // No homework
          if (homework.isEmpty) {
            return const Center(
              child: Text(
                'No homework available.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Homework',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              ...homework.map((document) {
                final data =
                document.data() as Map<String, dynamic>;

                final subject =
                    data['subject']?.toString() ?? 'Subject';

                final title =
                    data['title']?.toString() ?? 'Homework';

                final description =
                    data['description']?.toString() ??
                        'No description available';

                final dueDate =
                    data['dueDate']?.toString() ??
                        'Not assigned';

                final status =
                    data['status']?.toString() ?? 'Pending';

                return _homeworkCard(
                  subject: subject,
                  title: title,
                  description: description,
                  dueDate: dueDate,
                  status: status,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _homeworkCard({
    required String subject,
    required String title,
    required String description,
    required String dueDate,
    required String status,
  }) {
    IconData icon;

    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        icon = Icons.calculate;
        break;

      case 'english':
        icon = Icons.menu_book;
        break;

      case 'science':
        icon = Icons.science;
        break;

      default:
        icon = Icons.assignment;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(icon),
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
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subject,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: status.toLowerCase() == 'completed'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.grey,
                ),

                const SizedBox(width: 8),

                Text(
                  'Due: $dueDate',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}