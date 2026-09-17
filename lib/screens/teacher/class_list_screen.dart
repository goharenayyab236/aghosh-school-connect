import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassListScreen extends StatelessWidget {
  const ClassListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
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
                'Error loading classes:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final classes = snapshot.data?.docs ?? [];

          if (classes.isEmpty) {
            return const Center(
              child: Text(
                'No classes found.',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final document = classes[index];

              final data =
              document.data() as Map<String, dynamic>;

              final className =
                  data['className']?.toString() ??
                      'Unknown Class';

              final section =
                  data['section']?.toString() ?? '';

              final teacherName =
                  data['teacherName']?.toString() ??
                      'Teacher not assigned';

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      '${index + 1}',
                    ),
                  ),

                  title: Text(
                    section.isEmpty
                        ? className
                        : '$className - Section $section',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Padding(
                    padding:
                    const EdgeInsets.only(top: 5),
                    child: Text(
                      'Teacher: $teacherName',
                    ),
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}