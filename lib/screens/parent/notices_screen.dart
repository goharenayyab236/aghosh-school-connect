import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  String selectedFilter = 'All Notices';

  // Notices hidden by the parent.
  final Set<String> hiddenNotices = {};

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
      return value?.toString() ?? 'Date not available';
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

  // =========================
  // NOTICE DETAILS
  // =========================

  void _showNoticeDetails(
      BuildContext context,
      Map<String, dynamic> data,
      ) {
    final title =
        data['title']?.toString() ??
            'School Notice';

    final message =
        data['message']?.toString() ??
            'No message available.';

    final date = data['date'];

    final audience =
        data['audience']?.toString() ??
            'All Parents';

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
                        Icons.campaign,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Text(
                        title,
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
                  Icons.calendar_today,
                  'Date',
                  _formatDate(date),
                ),

                _detailRow(
                  Icons.people,
                  'Audience',
                  audience,
                ),

                _detailRow(
                  Icons.description,
                  'Notice',
                  message,
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

  // =========================
  // HIDE NOTICE
  // =========================

  void _hideNotice(
      BuildContext context,
      String noticeId,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hide Notice?'),
          content: const Text(
            'This notice will be hidden from your screen. '
                'It will not be deleted from the school records.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  hiddenNotices.add(noticeId);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Notice hidden from your screen.',
                    ),
                  ),
                );
              },
              child: const Text('Hide'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const filters = [
      'All Notices',
      "Today's Notices",
    ];

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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading notices:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final allNotices =
              snapshot.data?.docs ?? [];

          final visibleNotices =
          allNotices.where((document) {
            if (hiddenNotices.contains(document.id)) {
              return false;
            }

            final data =
            document.data()
            as Map<String, dynamic>;

            if (selectedFilter == 'All Notices') {
              return true;
            }

            if (selectedFilter ==
                "Today's Notices") {
              return _isToday(data['date']);
            }

            return true;
          }).toList();

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

              const SizedBox(height: 18),

              // =========================
              // FILTER
              // =========================

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
                child:
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                    ),
                    items: filters.map((filter) {
                      return DropdownMenuItem<String>(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedFilter = value;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (selectedFilter != 'All Notices')
                Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 15,
                  ),
                  child: Text(
                    'Showing: $selectedFilter',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),

              // =========================
              // EMPTY STATE
              // =========================

              if (visibleNotices.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Icon(
                          Icons
                              .campaign_outlined,
                          size: 55,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 12),

                        Text(
                          'No notices available.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // =========================
              // NOTICE CARDS
              // =========================

              ...visibleNotices.map((document) {
                final data =
                document.data()
                as Map<String, dynamic>;

                final title =
                    data['title']?.toString() ??
                        'School Notice';

                final message =
                    data['message']?.toString() ??
                        'No message available.';

                final date =
                data['date'];

                final audience =
                    data['audience']?.toString() ??
                        'All Parents';

                return Card(
                  margin:
                  const EdgeInsets.only(
                    bottom: 15,
                  ),
                  elevation: 2,
                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(12),

                    // Tap to see complete notice.
                    onTap: () {
                      _showNoticeDetails(
                        context,
                        data,
                      );
                    },

                    child: Padding(
                      padding:
                      const EdgeInsets.all(18),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.campaign,
                                size: 28,
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              Expanded(
                                child: Text(
                                  title,
                                  style:
                                  const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),

                              // Shows that the card
                              // is clickable.
                              const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),

                              // Hide menu.
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value ==
                                      'hide') {
                                    _hideNotice(
                                      context,
                                      document.id,
                                    );
                                  }
                                },
                                itemBuilder:
                                    (context) {
                                  return const [
                                    PopupMenuItem(
                                      value: 'hide',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons
                                                .visibility_off,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Hide',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ];
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Text(
                            message,
                            maxLines: 3,
                            overflow:
                            TextOverflow.ellipsis,
                            style:
                            const TextStyle(
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                _formatDate(date),
                                style:
                                const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(width: 15),

                              Expanded(
                                child: Text(
                                  'Audience: $audience',
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                  style:
                                  const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
}