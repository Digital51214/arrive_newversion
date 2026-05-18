import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../new_AI_feedback/screens/all_journals_list.dart';
import '../new_AI_feedback/screens/screen_write.dart';
import '../new_bottom_bar/bottom_nav_bar.dart';
import '../new_onboarding_screens/theme/app_theme.dart';
import '../new_quick_thoughts_screens/screens/arrive_compose_screen.dart';
import '../new_service_screens/daily_propmt_service.dart';

import '../new_service_screens/journal_streak_service.dart';
import '../new_service_screens/session_manager.dart';
import '../new_service_screens/journal_list_service.dart';

import 'shared.dart' hide GlassCard;
import 'concept_c.dart';

class ConceptBScreen extends StatefulWidget {
  const ConceptBScreen({super.key});

  @override
  State<ConceptBScreen> createState() => _ConceptBScreenState();
}

class _ConceptBScreenState extends State<ConceptBScreen> {
  int _selectedMood = 2;
  String _userName = 'Kezia';

  bool _isJournalLoading = true;
  List<Map<String, dynamic>> _todayJournals = [];

  // ── Daily Prompt ──
  String _dailyPrompt =
      '"What are you carrying today that you\'d like to set down?"';
  bool _isPromptLoading = true;

  // ── Streak ──
  int _streakCount = 0;
  bool _isStreakLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _getTodayJournals();
    _loadDailyPrompt();
    _loadStreak(); // ← ADD THIS
  }

  // ── Fetch streak ──
  Future<void> _loadStreak() async {
    setState(() => _isStreakLoading = true);

    try {
      final userId = await SessionManager.getUserId();

      print('---------- LOAD STREAK ----------');
      print('USER ID: $userId');

      if (userId == 0) {
        print('STREAK: user not logged in, skipping');
        if (mounted) setState(() => _isStreakLoading = false);
        return;
      }

      final streak = await JournalStreakService.fetchStreak(userId: userId);

      print('STREAK RESULT: $streak');
      print('---------------------------------');

      if (!mounted) return;
      setState(() {
        _streakCount = streak;
        _isStreakLoading = false;
      });
    } catch (e) {
      print('LOAD STREAK ERROR: $e');
      if (mounted) setState(() => _isStreakLoading = false);
    }
  }

  // ── Fetch daily prompt ──
  Future<void> _loadDailyPrompt() async {
    setState(() => _isPromptLoading = true);

    final prompt = await DailyPromptService.fetchTodayPrompt();

    if (!mounted) return;

    setState(() {
      if (prompt != null) _dailyPrompt = '"$prompt"';
      _isPromptLoading = false;
    });
  }

  Future<void> _loadUserName() async {
    final firstName = await SessionManager.getFirstName();

    if (!mounted) return;

    setState(() {
      _userName = firstName.trim().isEmpty ? 'Kezia' : firstName.trim();
    });
  }

  Future<void> _getTodayJournals() async {
    setState(() => _isJournalLoading = true);

    try {
      final userId = await SessionManager.getUserId();

      if (userId == 0) {
        if (!mounted) return;

        setState(() {
          _todayJournals = [];
          _isJournalLoading = false;
        });

        return;
      }

      final result = await JournalListService.getUserJournals(userId: userId);

      if (!mounted) return;

      if (result['success'] == true && result['journals'] is List) {
        final journals = (result['journals'] as List)
            .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e),
        )
            .toList();

        final now = DateTime.now();

        final todayEntries = journals.where((item) {
          final createdAt = DateTime.tryParse(
            item['created_at']?.toString() ?? '',
          );

          if (createdAt == null) return false;

          return createdAt.year == now.year &&
              createdAt.month == now.month &&
              createdAt.day == now.day;
        }).toList();

        todayEntries.sort((a, b) {
          final aDate = DateTime.tryParse(a['created_at']?.toString() ?? '') ??
              DateTime(1900);
          final bDate = DateTime.tryParse(b['created_at']?.toString() ?? '') ??
              DateTime(1900);
          return bDate.compareTo(aDate);
        });

        setState(() {
          _todayJournals = todayEntries;
          _isJournalLoading = false;
        });
      } else {
        setState(() {
          _todayJournals = [];
          _isJournalLoading = false;
        });
      }
    } catch (e) {
      print('GET TODAY JOURNALS ERROR: $e');

      if (!mounted) return;

      setState(() {
        _todayJournals = [];
        _isJournalLoading = false;
      });
    }
  }

  String _journalTitle(Map<String, dynamic> item) {
    final title = item['title']?.toString().trim();
    return title == null || title.isEmpty ? 'Untitled Entry' : title;
  }

  String _journalPreview(Map<String, dynamic> item) {
    final content = item['content']?.toString().trim();
    final body = item['body']?.toString().trim();

    if (content != null && content.isNotEmpty) return content;
    if (body != null && body.isNotEmpty) return body;

    return 'Your latest journal entry is saved here...';
  }

  String _journalEmoji(Map<String, dynamic> item) {
    final difficulties = item['difficulties']?.toString().trim();
    final emote = item['emote']?.toString().trim();

    if (difficulties != null &&
        difficulties.isNotEmpty &&
        difficulties.toLowerCase() != 'null') {
      return difficulties;
    }

    if (emote != null && emote.isNotEmpty && emote.toLowerCase() != 'null') {
      return emote;
    }

    return '📔';
  }

  String _journalDay(Map<String, dynamic> item) {
    final rawDate = item['created_at']?.toString() ?? '';
    final date = DateTime.tryParse(rawDate);

    if (date == null) return '--';

    return date.day.toString().padLeft(2, '0');
  }

  String _journalMonth(Map<String, dynamic> item) {
    final rawDate = item['created_at']?.toString() ?? '';
    final date = DateTime.tryParse(rawDate);

    if (date == null) return '';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SimpleBottomBar(currentIndex: 0),
      backgroundColor: const Color(0xFF111620),
      body: Stack(
        children: [
          const Positioned.fill(child: OrbsBackground()),
          SafeArea(
            child: Column(
              children: [
                const ArriveHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ArriveGreeting(userName: _userName),
                        const SizedBox(height: 4),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                          child: _journalSearchBar(),
                        ),

                        const _SectionRow(title: 'Your Mood'),
                        const SizedBox(height: 4),

                        _MoodBanner(
                          selected: _selectedMood,
                          onSelect: (i) => setState(() => _selectedMood = i),
                        ),

                        const SizedBox(height: 12),

                        const _SectionRow(title: 'Your Tools'),
                        const SizedBox(height: 4),
                        const _HorizontalTools(),
                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Transform.translate(
                              offset: const Offset(15, 0),
                              child: _blinkDot(ArriveTheme.green),
                            ),
                            const _SectionRow(title: 'Today\'s Prompt'),
                          ],
                        ),

                        const SizedBox(height: 4),
                        _bigJournalCard(context),
                        const SizedBox(height: 4),

                        const _SectionRow(title: 'Streak'),
                        const SizedBox(height: 4),
                        _streakMini(), // ← now uses live _streakCount
                        const SizedBox(height: 12),

                        _SectionRow(
                          title: 'Recent Entries',
                          link: 'See all →',
                          onLinkTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const JournalsScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 4),

                        if (_isJournalLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: ArriveTheme.green,
                              ),
                            ),
                          )
                        else if (_todayJournals.isNotEmpty)
                          ..._todayJournals.map((journal) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _EntryRow(
                                day: _journalDay(journal),
                                month: _journalMonth(journal),
                                title: _journalTitle(journal),
                                preview: _journalPreview(journal),
                                mood: _journalEmoji(journal),
                              ),
                            );
                          }).toList()
                        else
                          const _EmptyRecentEntry(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 24,
            child: _writeFab(
              context,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ArriveComposeScreen(),
                  ),
                ).then((_) {
                  _getTodayJournals();
                  _loadStreak(); // ← refresh streak after new journal entry
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _journalSearchBar() {
    return _glassCard(
      radius: 18,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            const Text('🔍', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                cursorColor: ArriveTheme.textSoft,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ArriveTheme.text,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: 'Search your journal entries...',
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ArriveTheme.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _writeFab(BuildContext context, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ArriveTheme.green.withOpacity(0.92),
              const Color(0xFF64C873),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: ArriveTheme.green.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text('✏️', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }

  Widget _bigJournalCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _glassCard(
        radius: 20,
        padding: const EdgeInsets.all(22),
        topLineColor: ArriveTheme.green.withOpacity(0.40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isPromptLoading)
              Container(
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
              )
            else
              Text(
                _dailyPrompt,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 26,
                  fontWeight: FontWeight.w300,
                  color: ArriveTheme.text,
                  height: 1.2,
                ),
              ),
            const SizedBox(height: 5),
            Text(
              'Tap to open your journal and start writing.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: ArriveTheme.textSoft.withOpacity(0.95),
                height: 1.5,
                fontWeight: FontWeight.w300,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WriteScreen()),
                ).then((_) => _getTodayJournals());
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: ArriveTheme.green.withOpacity(0.15),
                  border: Border.all(
                    color: ArriveTheme.green.withOpacity(0.30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✏️', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 7),
                    Text(
                      "Write today's entry",
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ArriveTheme.green,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Streak widget — live _streakCount & _isStreakLoading ──
  Widget _streakMini() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _glassCard(
        radius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        topLineColor: ArriveTheme.green.withOpacity(0.35),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: _isStreakLoading
              // ── Skeleton loader while fetching ──
                  ? Container(
                height: 18,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
              )
              // ── Live streak text ──
                  : RichText(
                text: TextSpan(
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: ArriveTheme.textSoft,
                    fontWeight: FontWeight.w300,
                  ),
                  children: [
                    TextSpan(
                      text: '$_streakCount',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: ArriveTheme.green,
                      ),
                    ),
                    const TextSpan(text: ' day streak — keep going'),
                  ],
                ),
              ),
            ),
            // ── Streak dots: filled up to streakCount, max 7 shown ──
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(7, (i) {
                final isActive = i < _streakCount.clamp(0, 7);
                final isNow = i == (_streakCount.clamp(1, 7) - 1);
                return Padding(
                  padding: EdgeInsets.only(right: i < 6 ? 5 : 0),
                  child: _streakDot(active: isActive, now: isNow),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassCard({
    required Widget child,
    double radius = 20,
    EdgeInsets padding = const EdgeInsets.all(16),
    Color? topLineColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (topLineColor != null)
            Positioned(
              top: 0,
              left: 20,
              right: 20,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      topLineColor,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _blinkDot(Color color) {
    return _BlinkDot(color: color);
  }
}

// ─── Baaqi sab widgets bilkul same — koi change nahi ─────────────────────────

class _EmptyRecentEntry extends StatelessWidget {
  const _EmptyRecentEntry();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _GlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          'No journal entries for today yet.',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: ArriveTheme.textMuted,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _BlinkDot extends StatefulWidget {
  final Color color;

  const _BlinkDot({required this.color});

  @override
  State<_BlinkDot> createState() => _BlinkDotState();
}

class _BlinkDotState extends State<_BlinkDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 1.0, end: 0.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
      ),
    );
  }
}

class _MoodBanner extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  static const _moods = [
    ('😔', 'Heavy'),
    ('😐', 'Okay'),
    ('🙂', 'Alright'),
    ('😊', 'Good'),
    ('✨', 'Thriving'),
  ];

  const _MoodBanner({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _GlassCard(
        topLineColor: ArriveTheme.gold.withOpacity(0.4),
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✦ HOW ARE YOU FEELING RIGHT NOW?',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w500,
                color: ArriveTheme.gold,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_moods.length, (i) {
                final isSel = i == selected;

                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSel
                              ? ArriveTheme.gold.withOpacity(0.20)
                              : Colors.white.withOpacity(0.055),
                          border: Border.all(
                            color: isSel
                                ? ArriveTheme.gold.withOpacity(0.50)
                                : Colors.white.withOpacity(0.10),
                          ),
                          boxShadow: isSel
                              ? [
                            BoxShadow(
                              color: ArriveTheme.gold.withOpacity(0.20),
                              blurRadius: 10,
                            ),
                          ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _moods[i].$1,
                            style: GoogleFonts.dmSans(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _moods[i].$2,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: ArriveTheme.textMuted,
                          letterSpacing: 0.3,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  final String title;
  final String? link;
  final VoidCallback? onLinkTap;

  const _SectionRow({
    required this.title,
    this.link,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final linkWidget = Text(
      link ?? '',
      style: GoogleFonts.dmSans(
        fontSize: 11,
        color: ArriveTheme.green.withOpacity(0.7),
        decoration: TextDecoration.none,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: ArriveTheme.text,
              height: 1.1,
            ),
          ),
          if (link != null)
            GestureDetector(
              onTap: onLinkTap,
              child: linkWidget,
            ),
        ],
      ),
    );
  }
}

class _HorizontalTools extends StatelessWidget {
  const _HorizontalTools();

  static const _tools = [
    ('🪞', 'AI Feedback', 'Reflect on your entry', Color(0xFFD4B896)),
    ('🌸', 'Community', 'Postpartum Mode', Color(0xFFD296AF)),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _tools.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final t = _tools[i];

          return _GlassCard(
            borderRadius: 18,
            topLineColor: t.$4.withOpacity(0.35),
            padding: const EdgeInsets.all(16),
            onTap: () {},
            child: SizedBox(
              width: 135,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.$1, style: GoogleFonts.dmSans(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    t.$2,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ArriveTheme.text,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    t.$3,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: ArriveTheme.textMuted,
                      height: 1.4,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final String day;
  final String month;
  final String title;
  final String preview;
  final String mood;

  const _EntryRow({
    required this.day,
    required this.month,
    required this.title,
    required this.preview,
    required this.mood,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _GlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        onTap: () {},
        child: Row(
          children: [
            _GlassCard(
              borderRadius: 12,
              padding: EdgeInsets.zero,
              child: SizedBox(
                width: 42,
                height: 42,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: ArriveTheme.text,
                        height: 1,
                      ),
                    ),
                    Text(
                      month,
                      style: GoogleFonts.dmSans(
                        fontSize: 8,
                        letterSpacing: 0.8,
                        color: ArriveTheme.textMuted,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ArriveTheme.text,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: ArriveTheme.textMuted,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  mood,
                  style: GoogleFonts.dmSans(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI ✦',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: ArriveTheme.green.withOpacity(0.65),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                    decoration: TextDecoration.none,
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

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? topLineColor;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const _GlassCard({
    required this.child,
    this.borderRadius = 20,
    this.topLineColor,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.07),
            Colors.white.withOpacity(0.04),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            if (topLineColor != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        topLineColor!,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return card;

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}

Widget _streakDot({required bool active, required bool now}) {
  return Container(
    width: 26,
    height: 26,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: active
          ? ArriveTheme.green.withOpacity(now ? 0.35 : 0.20)
          : Colors.white.withOpacity(0.055),
      border: Border.all(
        color: active
            ? ArriveTheme.green.withOpacity(now ? 1 : 0.4)
            : Colors.white.withOpacity(0.10),
      ),
      boxShadow: now
          ? [
        BoxShadow(
          color: ArriveTheme.green.withOpacity(0.22),
          blurRadius: 8,
        ),
      ]
          : null,
    ),
    child: Center(
      child: Text(
        now ? '✦' : '✓',
        style: TextStyle(
          fontSize: 11,
          color: ArriveTheme.text,
        ),
      ),
    ),
  );
}