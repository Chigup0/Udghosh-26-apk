import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:udghosh/api.dart';
import 'dart:convert';
import '../model/Notice.dart';
import '../../utils.dart';
import 'package:udghosh/widgets/widgets.dart';

class NoticesPage extends StatefulWidget {
  const NoticesPage({Key? key}) : super(key: key);

  @override
  State<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends State<NoticesPage> {
  List<Notice> notices = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/notices'), // Remove pagination parameters
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> noticesJson = json.decode(response.body);
        final List<Notice> fetchedNotices = noticesJson
            .map((json) => Notice.fromJson(json))
            .toList();

        setState(() {
          notices = fetchedNotices;
        });
      }
    } catch (e) {
      print('Error loading notices: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshNotices() async {
    setState(() {
      notices.clear();
    });
    await _loadNotices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.black,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Row(
              children: [const SizedBox(width: 16), pageTitleText("Notices")],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: containerDecoration,
        child: RefreshIndicator(
          onRefresh: _refreshNotices,
          color: const Color.fromARGB(255, 45, 48, 200),
          backgroundColor: Colors.black,
          child: notices.isEmpty && isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color.fromARGB(255, 45, 48, 200),
                    ),
                  ),
                )
              : notices.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 64,
                            color: const Color.fromARGB(
                              255,
                              45,
                              48,
                              200,
                            ).withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notices available',
                            style: TextStyle(
                              fontFamily: globalFontFamily,
                              fontSize: 18,
                              color: const Color.fromARGB(
                                255,
                                45,
                                48,
                                200,
                              ).withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: notices.length + 1, // add 1 for the spacer
                    itemBuilder: (context, index) {
                      if (index == notices.length) {
                        // Last element: just give it empty space
                        return const SizedBox(height: 150);
                      }
                      return NoticeCard(notice: notices[index]);
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

class NoticeCard extends StatelessWidget {
  final Notice notice;

  const NoticeCard({Key? key, required this.notice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 1, 3, 41).withValues(alpha: 0.7),
            const Color.fromARGB(255, 12, 40, 63).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 61, 63, 171),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(
              255,
              45,
              48,
              200,
            ).withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              notice.title,
              style: TextStyle(
                fontFamily: globalFontFamily,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: const Color.fromARGB(
                      255,
                      45,
                      48,
                      200,
                    ).withValues(alpha: 0.5),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Content
            Text(
              notice.content,
              style: TextStyle(
                fontFamily: globalFontFamily,
                fontSize: 14,
                color: const Color.fromARGB(255, 203, 203, 203),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Date
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: const Color.fromARGB(255, 191, 192, 255),
                ),
                const SizedBox(width: 8),
                Text(
                  notice.createdAt == null
                      ? ''
                      : _formatDate(notice.createdAt!),
                  style: TextStyle(
                    fontFamily: globalFontFamily,
                    fontSize: 12,
                    color: const Color.fromARGB(255, 191, 192, 255),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
