import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Notices'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notices')
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
                'Error loading notices:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final notices = snapshot.data?.docs ?? [];

          if (notices.isEmpty) {
            return const Center(
              child: Text(
                'No notices available.',
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
                'Latest Notices',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              ...notices.map((document) {
                final data =
                document.data() as Map<String, dynamic>;

                final title =
                    data['title']?.toString() ??
                        'School Notice';

                final message =
                    data['message']?.toString() ??
                        'No message available.';

                final date =
                    data['date']?.toString() ??
                        'Date not available';

                final audience =
                    data['audience']?.toString() ??
                        'All Parents';

                return _noticeCard(
                  title: title,
                  message: message,
                  date: date,
                  audience: audience,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _noticeCard({
    required String title,
    required String message,
    required String date,
    required String audience,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.campaign,
                  size: 28,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                ),

                const SizedBox(width: 6),

                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              'Audience: $audience',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}