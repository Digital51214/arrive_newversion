import 'package:flutter/material.dart';

import '../../new_bottom_bar/bottom_nav_bar.dart';
import '../../new_service_screens/journal_list_service.dart';
import '../../new_service_screens/session_manager.dart';
import '../constants.dart';

class JournalsScreen extends StatefulWidget {
  const JournalsScreen({super.key});

  @override
  State<JournalsScreen> createState() => _JournalsScreenState();
}

class _JournalsScreenState extends State<JournalsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _journals = [];

  @override
  void initState() {
    super.initState();
    _getJournals();
  }

  Future<void> _getJournals() async {
    setState(() => _isLoading = true);

    try {
      final userId = await SessionManager.getUserId();

      print('SESSION USER ID FOR JOURNALS: $userId');

      if (userId == 0) {
        if (!mounted) return;

        setState(() {
          _journals = [];
          _isLoading = false;
        });

        return;
      }

      final result = await JournalListService.getUserJournals(
        userId: userId,
      );

      print('FINAL JOURNALS RESULT: $result');

      if (!mounted) return;

      if (result['success'] == true) {
        final journalsList = result['journals'];

        setState(() {
          _journals = journalsList is List
              ? journalsList
              .map<Map<String, dynamic>>(
                (e) => Map<String, dynamic>.from(e),
          )
              .toList()
              : [];

          _isLoading = false;
        });

        print('TOTAL JOURNALS FETCHED: ${_journals.length}');
      } else {
        setState(() {
          _journals = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('GET JOURNALS SCREEN ERROR: $e');

      if (!mounted) return;

      setState(() {
        _journals = [];
        _isLoading = false;
      });
    }
  }

  String _formatDate(String rawDate) {
    if (rawDate.trim().isEmpty) return '';

    try {
      final date = DateTime.parse(rawDate.replaceFirst(' ', 'T'));

      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return rawDate;
    }
  }

  String _getJournalEmoji(Map<String, dynamic> item) {
    final difficulties = item['difficulties'];

    if (difficulties != null &&
        difficulties.toString().trim().isNotEmpty &&
        difficulties.toString().trim().toLowerCase() != 'null') {
      return difficulties.toString().trim();
    }

    final emote = item['emote'];

    if (emote != null &&
        emote.toString().trim().isNotEmpty &&
        emote.toString().trim().toLowerCase() != 'null') {
      return emote.toString().trim();
    }

    return '📔';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SimpleBottomBar(currentIndex: 2),
      backgroundColor: kBg,
      body: Stack(
        children: [
          _orbWidget(
            top: -60,
            left: -60,
            size: 280,
            color: kGreen.withOpacity(0.22),
          ),
          _orbWidget(
            bottom: 120,
            right: -50,
            size: 240,
            color: kBlue.withOpacity(0.28),
          ),
          _orbWidget(
            top: MediaQuery.of(context).size.height * 0.45,
            left: 40,
            size: 180,
            color: kPink.withOpacity(0.22),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ArriveHeader(),

                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JOURNALS',
                        style: dmSans(
                          size: 10,
                          weight: FontWeight.w600,
                          color: kGreen,
                        ).copyWith(letterSpacing: 1.3),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Journals',
                        style: cormorant(
                          size: 34,
                          color: kText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_journals.length} saved entr${_journals.length == 1 ? 'y' : 'ies'}',
                        style: dmSans(
                          size: 12,
                          color: kTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                    child: _isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: kGreen,
                      ),
                    )
                        : _journals.isEmpty
                        ? Container(
                      width: double.infinity,
                      decoration: glassBox(radius: 24),
                      child: _emptyState(),
                    )
                        : RefreshIndicator(
                      color: kGreen,
                      backgroundColor: kBg,
                      onRefresh: _getJournals,
                      child: ListView.separated(
                        physics:
                        const AlwaysScrollableScrollPhysics(),
                        padding:
                        const EdgeInsets.only(bottom: 16),
                        itemCount: _journals.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = _journals[index];

                          final title =
                          item['title']
                              ?.toString()
                              .trim()
                              .isNotEmpty ==
                              true
                              ? item['title'].toString()
                              : 'Untitled Entry';

                          final content =
                              item['content']?.toString().trim() ??
                                  '';

                          final createdAt =
                              item['created_at']?.toString() ?? '';

                          final tags = item['tags'] is List
                              ? List<String>.from(item['tags'])
                              : <String>[];

                          final images = item['images'] is List
                              ? List<String>.from(item['images'])
                              : <String>[];

                          return _journalItem(
                            title: title,
                            content: content,
                            emoji: _getJournalEmoji(item),
                            date: _formatDate(createdAt),
                            tags: tags,
                            images: images,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _journalItem({
    required String title,
    required String content,
    required String emoji,
    required String date,
    required List<String> tags,
    required List<String> images,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kGlass,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: kGlassBorder.withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kGreen.withOpacity(0.35),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: cormorant(
                          size: 22,
                          color: kText,
                        ),
                      ),

                      if (date.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 11,
                              color: kTextMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              date,
                              style: dmSans(
                                size: 11,
                                color: kTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ─────────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 1,
            color: kGlassBorder.withOpacity(0.4),
          ),

          // ── Content ─────────────────────────────────────────────
          if (content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: dmSans(
                  size: 13,
                  color: kTextMuted,
                ).copyWith(height: 1.6),
              ),
            ),

          // ── Images ──────────────────────────────────────────────
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      images[index],
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: kGreen.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: kGreen.withOpacity(0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: kTextMuted,
                          size: 28,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // ── Tags ────────────────────────────────────────────────
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 7,
                runSpacing: 7,
                children: tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: kGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: kGreen.withOpacity(0.35),
                      ),
                    ),
                    child: Text(
                      '# $tag',
                      style: dmSans(
                        size: 11,
                        weight: FontWeight.w500,
                        color: kGreen,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '✍️',
              style: TextStyle(fontSize: 34),
            ),

            const SizedBox(height: 12),

            Text(
              'No journals yet',
              style: cormorant(
                size: 26,
                color: kText,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Your saved entries will appear here.',
              textAlign: TextAlign.center,
              style: dmSans(
                size: 13,
                color: kTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _orbWidget({
  double? top,
  double? left,
  double? right,
  double? bottom,
  required double size,
  required Color color,
}) {
  return Positioned(
    top: top,
    left: left,
    right: right,
    bottom: bottom,
    child: IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              Colors.transparent,
            ],
            stops: const [0.0, 0.7],
          ),
        ),
      ),
    ),
  );
}