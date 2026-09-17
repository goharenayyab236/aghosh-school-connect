import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeworkMarksScreen extends StatefulWidget {
  const HomeworkMarksScreen({super.key});

  @override
  State<HomeworkMarksScreen> createState() =>
      _HomeworkMarksScreenState();
}

class _HomeworkMarksScreenState
    extends State<HomeworkMarksScreen> {
  final homeworkController = TextEditingController();
  final marksController = TextEditingController();

  String selectedSubject = 'Mathematics';
  bool isSaving = false;

  Future<void> saveHomework() async {
    if (homeworkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter homework details.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('homework')
          .add({
        'studentId': 'student_001',
        'studentName': 'Ahmed Khan',
        'subject': selectedSubject,
        'title': 'Homework',
        'description':
        homeworkController.text.trim(),
        'dueDate': '',
        'status': 'Pending',
        'marks': marksController.text.trim(),
        'createdAt':
        FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      homeworkController.clear();
      marksController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Homework saved successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving homework: $e',
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
  void dispose() {
    homeworkController.dispose();
    marksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework & Marks'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Homework',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Mathematics',
                  child: Text('Mathematics'),
                ),
                DropdownMenuItem(
                  value: 'English',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'Science',
                  child: Text('Science'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedSubject = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: homeworkController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Homework',
                hintText:
                'Enter homework details',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: marksController,
              keyboardType:
              TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Marks (optional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed:
                isSaving ? null : saveHomework,
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
                      : 'Save Homework',
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Recent Homework',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('homework')
                  .where(
                'studentId',
                isEqualTo: 'student_001',
              )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Error loading homework:\n'
                        '${snapshot.error}',
                  );
                }

                final homework =
                    snapshot.data?.docs ?? [];

                if (homework.isEmpty) {
                  return const Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.menu_book,
                      ),
                      title: Text(
                        'No homework added yet',
                      ),
                      subtitle: Text(
                        'Saved homework will appear here.',
                      ),
                    ),
                  );
                }

                return Column(
                  children: homework.map((document) {
                    final data =
                    document.data()
                    as Map<String, dynamic>;

                    final subject =
                        data['subject']
                            ?.toString() ??
                            'Subject';

                    final description =
                        data['description']
                            ?.toString() ??
                            '';

                    final status =
                        data['status']
                            ?.toString() ??
                            'Pending';

                    final marks =
                        data['marks']
                            ?.toString() ??
                            '';

                    return Card(
                      margin:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(
                            Icons.menu_book,
                          ),
                        ),
                        title: Text(
                          subject,
                          style: const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding:
                          const EdgeInsets.only(
                            top: 5,
                          ),
                          child: Text(
                            '$description\n'
                                'Status: $status'
                                '${marks.isNotEmpty ? '\nMarks: $marks' : ''}',
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