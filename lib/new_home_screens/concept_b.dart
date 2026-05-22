import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../new_AI_feedback/screens/all_journals_list.dart';
import '../new_AI_feedback/screens/screen_write.dart';
import '../new_AI_feedback/screens/screen_mode.dart';
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

  // ── Search ──
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Daily Prompt ──
  String _dailyPrompt =
      '"What are you carrying today that you\'d like to set down?"';
  bool _isPromptLoading = true;

  // ── Streak ──
  int _streakCount = 0;
  bool _isStreakLoading = true;

  // ── Gender ──
  // 'female' ya kuch bhi — SessionManager se fetch karo
  String _userGender = '';
  bool _isCommunityExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _getTodayJournals();
    _loadDailyPrompt();
    _loadStreak();
    _loadUserGender();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtered journals for search ──
  List<Map<String, dynamic>> get _filteredJournals {
    if (_searchQuery.isEmpty) return _todayJournals;
    return _todayJournals.where((item) {
      final title = item['title']?.toString().toLowerCase() ?? '';
      final content = item['content']?.toString().toLowerCase() ?? '';
      final body = item['body']?.toString().toLowerCase() ?? '';
      return title.contains(_searchQuery) ||
          content.contains(_searchQuery) ||
          body.contains(_searchQuery);
    }).toList();
  }

  // ── Load user gender ──
  Future<void> _loadUserGender() async {
    // SessionManager.getGender() — apne API ke hisaab se implement karo
    // Yahan 'female' / 'male' / 'other' expected hai
    try {
      final gender = await SessionManager.getGender(); // apna method
      if (!mounted) return;
      setState(() => _userGender = (gender ?? '').toLowerCase().trim());
    } catch (_) {
      // agar method na ho, default empty
    }
  }

  bool get _isFemale => _userGender == 'female';

  // ── Fetch streak ──
  Future<void> _loadStreak() async {
    setState(() => _isStreakLoading = true);
    try {
      final userId = await SessionManager.getUserId();
      if (userId == 0) {
        if (mounted) setState(() => _isStreakLoading = false);
        return;
      }
      final streak = await JournalStreakService.fetchStreak(userId: userId);
      if (!mounted) return;
      setState(() {
        _streakCount = streak;
        _isStreakLoading = false;
      });
    } catch (e) {
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
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();

        final now = DateTime.now();
        final todayEntries = journals.where((item) {
          final createdAt =
          DateTime.tryParse(item['created_at']?.toString() ?? '');
          if (createdAt == null) return false;
          return createdAt.year == now.year &&
              createdAt.month == now.month &&
              createdAt.day == now.day;
        }).toList();

        todayEntries.sort((a, b) {
          final aDate =
              DateTime.tryParse(a['created_at']?.toString() ?? '') ??
                  DateTime(1900);
          final bDate =
              DateTime.tryParse(b['created_at']?.toString() ?? '') ??
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
        difficulties.toLowerCase() != 'null') return difficulties;
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

  void _openAiFeedback(Map<String, dynamic> journal) {
    final journalId =
        int.tryParse(journal['id']?.toString() ?? '') ??
            int.tryParse(journal['journal_id']?.toString() ?? '') ??
            0;

    SessionManager.getUserId().then((userId) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ModeScreen(
            userId: userId,
            journalId: journalId,
            title: _journalTitle(journal),
            body: _journalPreview(journal),
            tags: [],
          ),
        ),
      );
    });
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
                        _HorizontalTools(
                          isFemale: _isFemale,
                          isCommunityExpanded: _isCommunityExpanded,
                          onCommunityArrowTap: () {
                            setState(() =>
                            _isCommunityExpanded = !_isCommunityExpanded);
                          },
                        ),
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
                        _streakMini(),
                        const SizedBox(height: 12),

                        // ── Recent Entries heading ──
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

                        // ── Search results / entries ──
                        if (_isJournalLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: ArriveTheme.green,
                              ),
                            ),
                          )
                        else if (_searchQuery.isNotEmpty &&
                            _filteredJournals.isEmpty)
                          _noSearchResults()
                        else if (_filteredJournals.isNotEmpty)
                            ..._filteredJournals.map((journal) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _EntryRow(
                                  day: _journalDay(journal),
                                  month: _journalMonth(journal),
                                  title: _journalTitle(journal),
                                  preview: _journalPreview(journal),
                                  mood: _journalEmoji(journal),
                                  searchQuery: _searchQuery,
                                  onTap: () => _openAiFeedback(journal),
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
                  _loadStreak();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _noSearchResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _glassCard(
        radius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            const Text('🔍', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No entries found for "$_searchQuery"',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: ArriveTheme.textMuted,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _journalSearchBar() {
    return _glassCard(
      radius: 18,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            const Text('🔍', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
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
            // Clear button
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.10),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 13,
                    color: Colors.white54,
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
                  ? Container(
                height: 18,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
              )
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

  Widget _blinkDot(Color color) => _BlinkDot(color: color);
}

// ─────────────────────────────────────────────────────────────────────────────

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
        decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
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

  const _MoodBanner({required this.selected, required this.onSelect});

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

  const _SectionRow({required this.title, this.link, this.onLinkTap});

  @override
  Widget build(BuildContext context) {
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
              child: Text(
                link!,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: ArriveTheme.green.withOpacity(0.7),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── _HorizontalTools — gender-aware community card ───────────────────────────

class _HorizontalTools extends StatelessWidget {
  final bool isFemale;
  final bool isCommunityExpanded;
  final VoidCallback onCommunityArrowTap;

  const _HorizontalTools({
    required this.isFemale,
    required this.isCommunityExpanded,
    required this.onCommunityArrowTap,
  });

  // AI Feedback card — same for all genders
  static const _aiFeedback = (
  '🪞',
  'AI Feedback',
  'Reflect on your entry',
  Color(0xFFD4B896),
  );

  @override
  Widget build(BuildContext context) {
    // Community card values based on gender
    final communityEmoji = isFemale
        ? (isCommunityExpanded ? '🌏' : '🌸')
        : '🌏';
    final communityTitle = isFemale
        ? (isCommunityExpanded ? 'Feed' : 'Community')
        : 'Feed';
    final communitySubtitle = isFemale
        ? (isCommunityExpanded ? 'Speak freely mode' : 'Postpartum Mode')
        : 'Speak freely mode';
    const communityColor = Color(0xFFD296AF);

    return SizedBox(
      height: 116,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // ── AI Feedback Card ──
          _GlassCard(
            borderRadius: 18,
            topLineColor: _aiFeedback.$4.withOpacity(0.35),
            padding: const EdgeInsets.all(16),
            onTap: () {},
            child: SizedBox(
              width: 135,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_aiFeedback.$1,
                      style: GoogleFonts.dmSans(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    _aiFeedback.$2,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ArriveTheme.text,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _aiFeedback.$3,
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
          ),

          const SizedBox(width: 10),

          // ── Community Card ──
          _CommunityToolCard(
            emoji: communityEmoji,
            title: communityTitle,
            subtitle: communitySubtitle,
            accentColor: communityColor,
            isFemale: isFemale,
            isExpanded: isCommunityExpanded,
            onArrowTap: onCommunityArrowTap,
            onCardTap: () {},
          ),
        ],
      ),
    );
  }
}

// ── Dedicated Community Card with arrow toggle ────────────────────────────────

class _CommunityToolCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accentColor;
  final bool isFemale;
  final bool isExpanded;
  final VoidCallback onArrowTap;
  final VoidCallback onCardTap;

  const _CommunityToolCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.isFemale,
    required this.isExpanded,
    required this.onArrowTap,
    required this.onCardTap,
  });

  @override
  State<_CommunityToolCard> createState() => _CommunityToolCardState();
}

class _CommunityToolCardState extends State<_CommunityToolCard> {
  bool isArrowTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onCardTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        width: 165,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.07),
              Colors.white.withOpacity(0.04),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
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
                        widget.accentColor.withOpacity(0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Text(
                            widget.emoji,
                            key: ValueKey(widget.emoji),
                            style: GoogleFonts.dmSans(fontSize: 22),
                          ),
                        ),

                        if (widget.isFemale)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isArrowTapped = !isArrowTapped;
                              });
                              widget.onArrowTap();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isArrowTapped
                                    ? Colors.lightBlueAccent.withOpacity(0.15)
                                    : widget.accentColor.withOpacity(0.15),
                                border: Border.all(
                                  color:isArrowTapped
                                      ? Colors.lightBlueAccent.withOpacity(0.35)
                                      : widget.accentColor.withOpacity(0.35),
                                ),
                              ),
                              child: Center(
                                child: AnimatedRotation(
                                  turns: widget.isExpanded ? 0.5 : 0.0,
                                  duration: const Duration(milliseconds: 260),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 10,
                                    color: isArrowTapped
                                        ? Colors.lightBlueAccent.withOpacity(0.85)
                                        : widget.accentColor.withOpacity(0.85),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.title,
                          key: ValueKey(widget.title),
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ArriveTheme.text,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 3),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.subtitle,
                          key: ValueKey(widget.subtitle),
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: ArriveTheme.textMuted,
                            height: 1.4,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _EntryRow — search highlight support ─────────────────────────────────────

class _EntryRow extends StatelessWidget {
  final String day;
  final String month;
  final String title;
  final String preview;
  final String mood;
  final String searchQuery;
  final VoidCallback? onTap;

  const _EntryRow({
    required this.day,
    required this.month,
    required this.title,
    required this.preview,
    required this.mood,
    this.searchQuery = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _GlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        onTap: onTap,
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
                  _highlightText(
                    title,
                    maxLines: 1,
                    baseStyle: GoogleFonts.cormorantGaramond(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ArriveTheme.text,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _highlightText(
                    preview,
                    maxLines: 1,
                    baseStyle: GoogleFonts.dmSans(
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
                Text(mood, style: GoogleFonts.dmSans(fontSize: 16)),
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

  // Highlight matching text in search results
  Widget _highlightText(
      String text, {
        required TextStyle baseStyle,
        int maxLines = 1,
      }) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final before = text.substring(0, matchIndex);
    final match = text.substring(matchIndex, matchIndex + searchQuery.length);
    final after = text.substring(matchIndex + searchQuery.length);

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: baseStyle.copyWith(
              color: ArriveTheme.green,
              backgroundColor: ArriveTheme.green.withOpacity(0.12),
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
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
        border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
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
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
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
        style: TextStyle(fontSize: 11, color: ArriveTheme.text),
      ),
    ),
  );
}