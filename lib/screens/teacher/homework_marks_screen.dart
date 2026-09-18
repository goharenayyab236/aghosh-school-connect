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
  // =========================================================
  // HOMEWORK
  // =========================================================

  final subjectController = TextEditingController();
  final titleController = TextEditingController();
  final instructionsController = TextEditingController();

  DateTime? selectedDueDate;
  bool isSavingHomework = false;

  // =========================================================
  // EXAM MARKS
  // =========================================================

  final examSubjectController = TextEditingController();
  final examTitleController = TextEditingController();
  final totalMarksController = TextEditingController();

  DateTime? selectedExamDate;

  final Map<String, TextEditingController> marksControllers = {};

  bool isSavingMarks = false;

  // =========================================================
  // CURRENT CLASS
  // =========================================================

  final String className = 'Grade 5';
  final String section = 'A';

  // =========================================================
  // DATE FUNCTIONS
  // =========================================================

  Future<void> selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDueDate = pickedDate;
      });
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  Future<void> selectExamDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedExamDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      setState(() {
        selectedExamDate = pickedDate;
      });
    }
  }

  String formatExamDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // =========================================================
  // SAVE HOMEWORK
  // =========================================================

  Future<void> saveHomework() async {
    final subject = subjectController.text.trim();
    final title = titleController.text.trim();
    final instructions =
    instructionsController.text.trim();

    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the subject name.'),
        ),
      );
      return;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a homework title.'),
        ),
      );
      return;
    }

    if (instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter homework instructions.',
          ),
        ),
      );
      return;
    }

    if (selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a due date.'),
        ),
      );
      return;
    }

    setState(() {
      isSavingHomework = true;
    });

    try {
      // =====================================================
      // GET ALL STUDENTS FROM THIS CLASS
      // =====================================================

      final studentSnapshot = await FirebaseFirestore
          .instance
          .collection('students')
          .where(
        'className',
        isEqualTo: className,
      )
          .where(
        'section',
        isEqualTo: section,
      )
          .get();

      // =====================================================
      // SAVE HOMEWORK
      // =====================================================

      final homeworkReference =
      await FirebaseFirestore.instance
          .collection('homework')
          .add({
        'className': className,
        'section': section,
        'subject': subject,
        'title': title,
        'description': instructions,
        'instructions': instructions,
        'dueDate': formatDate(selectedDueDate!),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // =====================================================
      // CREATE NOTIFICATION FOR EACH STUDENT
      // =====================================================

      final batch =
      FirebaseFirestore.instance.batch();

      for (final studentDocument
      in studentSnapshot.docs) {
        final studentData =
        studentDocument.data();

        final studentId =
            studentData['studentId']?.toString() ??
                studentDocument.id;

        final studentName =
            studentData['name']?.toString() ??
                'Student';

        final notificationReference =
        FirebaseFirestore.instance
            .collection('notifications')
            .doc();

        batch.set(
          notificationReference,
          {
            'type': 'homework',
            'studentId': studentId,
            'studentName': studentName,
            'title': 'New Homework',
            'message':
            '$subject - $title has been assigned.',
            'homeworkId': homeworkReference.id,
            'className': className,
            'section': section,
            'createdAt':
            FieldValue.serverTimestamp(),
          },
        );
      }

      await batch.commit();

      if (!mounted) return;

      subjectController.clear();
      titleController.clear();
      instructionsController.clear();

      setState(() {
        selectedDueDate = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Homework added successfully.',
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
          isSavingHomework = false;
        });
      }
    }
  }

  // =========================================================
  // EDIT HOMEWORK
  // =========================================================

  Future<void> editHomework(
      String documentId,
      Map<String, dynamic> data,
      ) async {
    final editSubjectController =
    TextEditingController(
      text: data['subject']?.toString() ?? '',
    );

    final editTitleController =
    TextEditingController(
      text: data['title']?.toString() ?? '',
    );

    final editInstructionsController =
    TextEditingController(
      text: data['instructions']?.toString() ??
          data['description']?.toString() ??
          '',
    );

    DateTime? editDueDate = _parseHomeworkDate(
      data['dueDate'],
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Homework'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller:
                      editSubjectController,
                      decoration:
                      const InputDecoration(
                        labelText: 'Subject',
                        border:
                        OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller:
                      editTitleController,
                      decoration:
                      const InputDecoration(
                        labelText: 'Homework Title',
                        border:
                        OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () async {
                        final pickedDate =
                        await showDatePicker(
                          context: context,
                          initialDate:
                          editDueDate ??
                              DateTime.now(),
                          firstDate:
                          DateTime.now(),
                          lastDate:
                          DateTime(2035),
                        );

                        if (pickedDate != null) {
                          setDialogState(() {
                            editDueDate =
                                pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration:
                        const InputDecoration(
                          labelText: 'Due Date',
                          border:
                          OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.calendar_today,
                          ),
                        ),
                        child: Text(
                          editDueDate == null
                              ? 'Select due date'
                              : formatDate(
                              editDueDate!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller:
                      editInstructionsController,
                      maxLines: 5,
                      decoration:
                      const InputDecoration(
                        labelText: 'Instructions',
                        border:
                        OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  child:
                  const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      editSubjectController.dispose();
      editTitleController.dispose();
      editInstructionsController.dispose();
      return;
    }

    final subject =
    editSubjectController.text.trim();
    final title =
    editTitleController.text.trim();
    final instructions =
    editInstructionsController.text.trim();

    if (subject.isEmpty ||
        title.isEmpty ||
        instructions.isEmpty ||
        editDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all homework fields.',
          ),
        ),
      );

      editSubjectController.dispose();
      editTitleController.dispose();
      editInstructionsController.dispose();
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('homework')
          .doc(documentId)
          .update({
        'subject': subject,
        'title': title,
        'description': instructions,
        'instructions': instructions,
        'dueDate': formatDate(editDueDate!),
        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Homework updated successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating homework: $e',
          ),
        ),
      );
    }

    editSubjectController.dispose();
    editTitleController.dispose();
    editInstructionsController.dispose();
  }

  // =========================================================
  // DELETE HOMEWORK
  // =========================================================

  Future<void> deleteHomework(
      String documentId,
      String title,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Homework?'),
          content: Text(
            'Are you sure you want to permanently delete '
                '"$title"?\n\n'
                'This homework will also disappear from the '
                'parent app.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('homework')
          .doc(documentId)
          .delete();

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Homework deleted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting homework: $e',
          ),
        ),
      );
    }
  }

  // =========================================================
  // HOMEWORK DETAILS
  // =========================================================

  void showHomeworkDetails(
      String documentId,
      Map<String, dynamic> data,
      ) {
    final subject =
        data['subject']?.toString() ?? 'Subject';

    final title =
        data['title']?.toString() ?? 'Homework';

    final instructions =
        data['instructions']?.toString() ??
            data['description']?.toString() ??
            '';

    final dueDate =
        data['dueDate']?.toString() ??
            'Not specified';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(title),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  Navigator.pop(context);

                  if (value == 'edit') {
                    editHomework(
                      documentId,
                      data,
                    );
                  }

                  if (value == 'delete') {
                    deleteHomework(
                      documentId,
                      title,
                    );
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                          ),
                          SizedBox(width: 10),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Subject: $subject',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Due Date: $dueDate',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Instructions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(instructions),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  DateTime? _parseHomeworkDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final parts = value.split('-');

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

  // =========================================================
  // SAVE EXAM MARKS
  // =========================================================

  Future<void> saveExamMarks(
      List<QueryDocumentSnapshot> students,
      ) async {
    final examSubject =
    examSubjectController.text.trim();

    final examTitle =
    examTitleController.text.trim();

    final totalMarksText =
    totalMarksController.text.trim();

    if (examSubject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the subject name.',
          ),
        ),
      );
      return;
    }

    if (examTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the test/exam name.',
          ),
        ),
      );
      return;
    }

    if (selectedExamDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select the exam date.',
          ),
        ),
      );
      return;
    }

    if (totalMarksText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter total marks.',
          ),
        ),
      );
      return;
    }

    final totalMarks =
    int.tryParse(totalMarksText);

    if (totalMarks == null || totalMarks <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid total marks.',
          ),
        ),
      );
      return;
    }

    for (final document in students) {
      final data =
      document.data()
      as Map<String, dynamic>;

      final studentId =
          data['studentId']?.toString() ??
              document.id;

      final marksController =
      marksControllers[studentId];

      final marksText =
          marksController?.text.trim() ?? '';

      if (marksText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter marks for ${data['name']}.',
            ),
          ),
        );
        return;
      }

      final obtainedMarks =
      int.tryParse(marksText);

      if (obtainedMarks == null ||
          obtainedMarks < 0 ||
          obtainedMarks > totalMarks) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid marks for ${data['name']}. '
                  'Marks must be between 0 and $totalMarks.',
            ),
          ),
        );
        return;
      }
    }

    setState(() {
      isSavingMarks = true;
    });

    try {
      final examDateString =
      formatExamDate(selectedExamDate!);

      for (final document in students) {
        final data =
        document.data()
        as Map<String, dynamic>;

        final studentId =
            data['studentId']?.toString() ??
                document.id;

        final studentName =
            data['name']?.toString() ??
                'Unknown Student';

        final obtainedMarks =
        int.parse(
          marksControllers[studentId]!
              .text
              .trim(),
        );

        // =====================================================
        // SAVE EXAM RESULT
        // =====================================================

        final examReference =
        await FirebaseFirestore.instance
            .collection('exams')
            .add({
          'examDate': examDateString,
          'examName': examTitle,
          'obtainedMarks':
          obtainedMarks.toString(),
          'studentId': studentId,
          'studentName': studentName,
          'subject': examSubject,
          'totalMarks':
          totalMarks.toString(),
          'className': className,
          'section': section,
        });

        // =====================================================
        // CREATE EXAM NOTIFICATION
        // =====================================================

        final notificationDocumentId =
            'exam_${examReference.id}';

        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(notificationDocumentId)
            .set({
          'type': 'exam',
          'studentId': studentId,
          'studentName': studentName,
          'title': 'New Exam Result',
          'message':
          '$examSubject - $examTitle marks have been added.',
          'examId': examReference.id,
          'examDate': examDateString,
          'className': className,
          'section': section,
          'createdAt':
          FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      examSubjectController.clear();
      examTitleController.clear();
      totalMarksController.clear();

      for (final controller
      in marksControllers.values) {
        controller.clear();
      }

      setState(() {
        selectedExamDate = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Exam marks saved successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving exam marks: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingMarks = false;
        });
      }
    }
  }

  // =========================================================
  // EXAM DETAILS
  // =========================================================

  void showExamDetails(
      Map<String, dynamic> data,
      ) {
    final studentName =
        data['studentName']?.toString() ??
            'Student';

    final examName =
        data['examName']?.toString() ??
            'Exam';

    final subject =
        data['subject']?.toString() ??
            'Subject';

    final examDate =
        data['examDate']?.toString() ??
            'Not specified';

    final obtainedMarks =
        data['obtainedMarks']?.toString() ??
            '0';

    final totalMarks =
        data['totalMarks']?.toString() ??
            '0';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(examName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Student: $studentName',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text('Subject: $subject'),
              const SizedBox(height: 10),
              Text('Exam Date: $examDate'),
              const SizedBox(height: 10),
              Text(
                'Marks: '
                    '$obtainedMarks / $totalMarks',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Homework & Marks',
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .where(
          'className',
          isEqualTo: className,
        )
            .where(
          'section',
          isEqualTo: section,
        )
            .snapshots(),
        builder:
            (context, studentSnapshot) {
          if (studentSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (studentSnapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Text(
                  'Error loading students:\n'
                      '${studentSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final students =
              studentSnapshot.data?.docs ?? [];

          if (students.isEmpty) {
            return const Center(
              child: Text(
                'No students found in this class.',
              ),
            );
          }

          for (final document in students) {
            final data =
            document.data()
            as Map<String, dynamic>;

            final studentId =
                data['studentId']?.toString() ??
                    document.id;

            marksControllers.putIfAbsent(
              studentId,
                  () => TextEditingController(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                // =================================================
                // CLASS
                // =================================================

                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.class_,
                      size: 32,
                    ),
                    title: Text(
                      '$className - Section $section',
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${students.length} student'
                          '${students.length == 1 ? '' : 's'}',
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // ADD HOMEWORK
                // =================================================

                const Text(
                  '📝 Add Homework',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller:
                  subjectController,
                  decoration:
                  const InputDecoration(
                    labelText: 'Subject',
                    hintText:
                    'e.g. Mathematics, Islamiat',
                    border:
                    OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.menu_book,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller:
                  titleController,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Homework Title',
                    hintText:
                    'e.g. Fractions Exercise',
                    border:
                    OutlineInputBorder(),
                    prefixIcon:
                    Icon(Icons.title),
                  ),
                ),

                const SizedBox(height: 16),

                InkWell(
                  onTap: selectDueDate,
                  child: InputDecorator(
                    decoration:
                    const InputDecoration(
                      labelText: 'Due Date',
                      border:
                      OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.calendar_today,
                      ),
                    ),
                    child: Text(
                      selectedDueDate == null
                          ? 'Select due date'
                          : formatDate(
                          selectedDueDate!),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller:
                  instructionsController,
                  maxLines: 5,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Instructions',
                    hintText:
                    'Enter homework instructions...',
                    border:
                    OutlineInputBorder(),
                    alignLabelWithHint: true,
                    prefixIcon:
                    Icon(Icons.edit_note),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 52,
                  child:
                  ElevatedButton.icon(
                    onPressed:
                    isSavingHomework
                        ? null
                        : saveHomework,
                    icon: isSavingHomework
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(
                      Icons.save,
                    ),
                    label: Text(
                      isSavingHomework
                          ? 'Saving...'
                          : 'Post Homework',
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // =================================================
                // RECENT HOMEWORK
                // =================================================

                const Text(
                  'Recent Homework',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                StreamBuilder<QuerySnapshot>(
                  stream:
                  FirebaseFirestore.instance
                      .collection(
                      'homework')
                      .where(
                    'className',
                    isEqualTo: className,
                  )
                      .where(
                    'section',
                    isEqualTo: section,
                  )
                      .snapshots(),
                  builder:
                      (context, snapshot) {
                    if (snapshot
                        .connectionState ==
                        ConnectionState
                            .waiting) {
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
                        ),
                      );
                    }

                    return Column(
                      children:
                      homework.map(
                            (document) {
                          final data =
                          document.data()
                          as Map<String,
                              dynamic>;

                          final subject =
                              data['subject']
                                  ?.toString() ??
                                  'Subject';

                          final title =
                              data['title']
                                  ?.toString() ??
                                  'Homework';

                          final dueDate =
                              data['dueDate']
                                  ?.toString() ??
                                  'Not specified';

                          return Card(
                            margin:
                            const EdgeInsets
                                .only(
                              bottom: 12,
                            ),
                            child: ListTile(
                              leading:
                              const CircleAvatar(
                                child: Icon(
                                  Icons.menu_book,
                                ),
                              ),
                              title: Text(
                                title,
                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                              subtitle: Text(
                                '$subject\n'
                                    'Due: $dueDate',
                              ),
                              trailing:
                              const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                showHomeworkDetails(
                                  document.id,
                                  data,
                                );
                              },
                            ),
                          );
                        },
                      ).toList(),
                    );
                  },
                ),

                const SizedBox(height: 45),

                // =================================================
                // EXAM MARKS
                // =================================================

                const Text(
                  '📊 Enter Exam Marks',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller:
                  examSubjectController,
                  decoration:
                  const InputDecoration(
                    labelText: 'Subject',
                    hintText:
                    'e.g. Mathematics, Islamiat',
                    border:
                    OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.menu_book,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller:
                  examTitleController,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Test / Exam Name',
                    hintText:
                    'e.g. Mid Term Examination',
                    border:
                    OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.assignment,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                InkWell(
                  onTap: selectExamDate,
                  child: InputDecorator(
                    decoration:
                    const InputDecoration(
                      labelText: 'Exam Date',
                      border:
                      OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.event,
                      ),
                    ),
                    child: Text(
                      selectedExamDate == null
                          ? 'Select exam date'
                          : formatExamDate(
                          selectedExamDate!),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller:
                  totalMarksController,
                  keyboardType:
                  TextInputType.number,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Total Marks',
                    hintText: 'e.g. 100',
                    border:
                    OutlineInputBorder(),
                    prefixIcon:
                    Icon(Icons.score),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Students',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ...students.map(
                      (document) {
                    final data =
                    document.data()
                    as Map<String,
                        dynamic>;

                    final studentId =
                        data['studentId']
                            ?.toString() ??
                            document.id;

                    final studentName =
                        data['name']
                            ?.toString() ??
                            'Unknown Student';

                    final rollNumber =
                        data['rollNumber']
                            ?.toString() ??
                            'Not assigned';

                    return Card(
                      margin:
                      const EdgeInsets
                          .only(
                        bottom: 12,
                      ),
                      child: Padding(
                        padding:
                        const EdgeInsets
                            .all(15),
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: Text(
                                rollNumber,
                                style:
                                const TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child:
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    studentName,
                                    style:
                                    const TextStyle(
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                  Text(
                                    'Roll No: '
                                        '$rollNumber',
                                    style:
                                    const TextStyle(
                                      color:
                                      Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child:
                              TextField(
                                controller:
                                marksControllers[
                                studentId],
                                keyboardType:
                                TextInputType
                                    .number,
                                decoration:
                                const InputDecoration(
                                  labelText:
                                  'Marks',
                                  border:
                                  OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 15),

                SizedBox(
                  height: 52,
                  child:
                  ElevatedButton.icon(
                    onPressed:
                    isSavingMarks
                        ? null
                        : () {
                      saveExamMarks(
                        students,
                      );
                    },
                    icon: isSavingMarks
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(
                      Icons.save,
                    ),
                    label: Text(
                      isSavingMarks
                          ? 'Saving...'
                          : 'Save Exam Marks',
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // RECENT EXAM MARKS
                // =================================================

                const Text(
                  'Recent Exam Marks',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                StreamBuilder<QuerySnapshot>(
                  stream:
                  FirebaseFirestore.instance
                      .collection('exams')
                      .snapshots(),
                  builder:
                      (context, snapshot) {
                    if (snapshot
                        .connectionState ==
                        ConnectionState
                            .waiting) {
                      return const Center(
                        child:
                        CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Text(
                        'Error loading exam marks:\n'
                            '${snapshot.error}',
                      );
                    }

                    final studentIds =
                    students.map(
                          (document) {
                        final data =
                        document.data()
                        as Map<String,
                            dynamic>;

                        return data['studentId']
                            ?.toString() ??
                            document.id;
                      },
                    ).toSet();

                    final marks =
                    (snapshot.data?.docs ??
                        [])
                        .where(
                          (document) {
                        final data =
                        document.data()
                        as Map<String,
                            dynamic>;

                        final studentId =
                        data['studentId']
                            ?.toString();

                        return studentId != null &&
                            studentIds.contains(
                              studentId,
                            );
                      },
                    ).toList();

                    if (marks.isEmpty) {
                      return const Card(
                        child: ListTile(
                          leading:
                          Icon(Icons.score),
                          title: Text(
                            'No exam marks entered yet',
                          ),
                        ),
                      );
                    }

                    return Column(
                      children:
                      marks.map(
                            (document) {
                          final data =
                          document.data()
                          as Map<String,
                              dynamic>;

                          final studentName =
                              data['studentName']
                                  ?.toString() ??
                                  'Student';

                          final examName =
                              data['examName']
                                  ?.toString() ??
                                  'Test';

                          final subject =
                              data['subject']
                                  ?.toString() ??
                                  'Subject';

                          final examDate =
                              data['examDate']
                                  ?.toString() ??
                                  'No date';

                          final obtained =
                              data['obtainedMarks']
                                  ?.toString() ??
                                  '0';

                          final total =
                              data['totalMarks']
                                  ?.toString() ??
                                  '0';

                          return Card(
                            margin:
                            const EdgeInsets
                                .only(
                              bottom: 10,
                            ),
                            child: ListTile(
                              leading:
                              const CircleAvatar(
                                child: Icon(
                                  Icons.score,
                                ),
                              ),
                              title: Text(
                                studentName,
                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                              subtitle: Text(
                                '$examName • $subject\n'
                                    'Date: $examDate\n'
                                    'Marks: '
                                    '$obtained / $total',
                              ),
                              trailing:
                              const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                showExamDetails(
                                  data,
                                );
                              },
                            ),
                          );
                        },
                      ).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    subjectController.dispose();
    titleController.dispose();
    instructionsController.dispose();

    examSubjectController.dispose();
    examTitleController.dispose();
    totalMarksController.dispose();

    for (final controller
    in marksControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }
}