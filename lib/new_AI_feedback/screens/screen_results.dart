import 'package:arrive_newversion/new_AI_feedback/screens/screen_write.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../new_bottom_bar/bottom_nav_bar.dart';
import '../constants.dart';
import 'screen_loading.dart';

class ResultsScreen extends StatefulWidget {
  final int userId;
  final int journalId;
  final String mode;
  final String modeIcon;
  final Map<String, dynamic>? feedback;
  final String title;
  final String body;
  final List<String> tags;

  const ResultsScreen({
    super.key,
    required this.userId,
    required this.journalId,
    required this.mode,
    required this.modeIcon,
    required this.feedback,
    required this.title,
    required this.body,
    required this.tags,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();

    print('========== RESULTS SCREEN LOADED ==========');
    print('Mode: ${widget.mode}');
    print('User ID: ${widget.userId}');
    print('Journal ID: ${widget.journalId}');
    print('Feedback Data: ${widget.feedback}');
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _retry() {
    print('Retry AI Feedback Clicked');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoadingScreen(
          userId: widget.userId,
          journalId: widget.journalId,
          title: widget.title,
          body: widget.body,
          tags: widget.tags,
          mode: widget.mode,
          modeIcon: widget.modeIcon,
        ),
      ),
    );
  }

  Future<void> _openSpotifyLink(String? link) async {
    if (link == null || link.trim().isEmpty) {
      print('Spotify link not found');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Spotify link not found',
            style: dmSans(size: 13, color: kText),
          ),
          backgroundColor: kGlass,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(link);

      print('Opening Spotify Link: $link');

      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        print('Could not open Spotify link');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open Spotify link',
              style: dmSans(size: 13, color: kText),
            ),
            backgroundColor: kGlass,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      print('Spotify Link Open Error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong opening the song',
            style: dmSans(size: 13, color: kText),
          ),
          backgroundColor: kGlass,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.feedback;
    final hasError = data == null;
    final music = data?['music'] as Map<String, dynamic>?;

    final spotifyLink = music?['link']?.toString();
    final musicTitle = music?['query']?.toString() ?? '';
    final musicReason = music?['reason']?.toString() ?? '';

    return Scaffold(
      bottomNavigationBar: const SimpleBottomBar(currentIndex: 1),
      backgroundColor: kBg,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: _orbWidget(280, kLavender.withOpacity(0.18)),
          ),
          Positioned(
            bottom: 120,
            right: -50,
            child: _orbWidget(240, kPink.withOpacity(0.2)),
          ),
          SafeArea(
            child: Column(
              children: [
                ArriveHeader(onBack: () => Navigator.of(context).pop()),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                            const EdgeInsets.fromLTRB(22, 22, 22, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        color: kLavender,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'AI FEEDBACK',
                                      style: dmSans(
                                        size: 10,
                                        weight: FontWeight.w500,
                                        color: kLavender,
                                      ).copyWith(letterSpacing: 1.2),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Here's what came back",
                                  style: cormorant(size: 26),
                                ),
                                const SizedBox(height: 4),
                                RichText(
                                  text: TextSpan(
                                    style: dmSans(
                                      size: 12,
                                      color: kTextMuted,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Viewed through your ',
                                      ),
                                      TextSpan(
                                        text: widget.mode,
                                        style: dmSans(
                                          size: 12,
                                          color: kLavender,
                                        ),
                                      ),
                                      const TextSpan(text: ' lens'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (hasError) ...[
                            Padding(
                              padding:
                              const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color:
                                  const Color(0xFFD46464).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFD46464)
                                        .withOpacity(0.25),
                                  ),
                                ),
                                child: Text(
                                  'Something went wrong reading your entry. Your original is safe — tap below to try again.',
                                  style: dmSans(
                                    size: 13,
                                    color: const Color(0xFFE6B4B4),
                                  ).copyWith(height: 1.6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                              child: GestureDetector(
                                onTap: _retry,
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                                  decoration: glassBox(radius: 12),
                                  child: Text(
                                    'Try Again →',
                                    textAlign: TextAlign.center,
                                    style: dmSans(
                                      size: 14,
                                      weight: FontWeight.w500,
                                      color: kTextSoft,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],

                          if (!hasError) ...[
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  _resultCard(
                                    type: 'letter',
                                    delay: 50,
                                    accentColor: kLavender,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _rcEyebrow(
                                          '✦ Letter to Yourself',
                                          kLavender,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          data!['letter_to_yourself'] ?? '',
                                          style: dmSans(
                                            size: 14,
                                            color: kTextSoft,
                                            weight: FontWeight.w300,
                                          ).copyWith(height: 1.75),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  _resultCard(
                                    type: 'intention',
                                    delay: 100,
                                    accentColor: kGreen,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _rcEyebrow(
                                          '☀ Daily Intention',
                                          kGreen,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          data['daily_intention'] ?? '',
                                          style: cormorant(size: 20),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  _resultCard(
                                    type: 'reframe',
                                    delay: 150,
                                    accentColor: kGold,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _rcEyebrow(
                                          '↻ Thought Reframe',
                                          kGold,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          data['thought_reframe'] ?? '',
                                          style: dmSans(
                                            size: 14,
                                            color: kTextSoft,
                                            weight: FontWeight.w300,
                                          ).copyWith(height: 1.75),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  _resultCard(
                                    type: 'music',
                                    delay: 200,
                                    accentColor: kBlue,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _rcEyebrow(
                                          '♪ Music Suggestion',
                                          kBlue,
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 52,
                                              height: 52,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    kBlue.withOpacity(0.25),
                                                    kBlue.withOpacity(0.08),
                                                  ],
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(14),
                                                border: Border.all(
                                                  color:
                                                  kBlue.withOpacity(0.3),
                                                ),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  '🎵',
                                                  style:
                                                  TextStyle(fontSize: 22),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    musicTitle,
                                                    style:
                                                    cormorant(size: 18),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    musicReason,
                                                    style: dmSans(
                                                      size: 13,
                                                      color: kTextSoft,
                                                      weight: FontWeight.w300,
                                                    ).copyWith(height: 1.6),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  GestureDetector(
                                                    onTap: () =>
                                                        _openSpotifyLink(
                                                          spotifyLink,
                                                        ),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 14,
                                                        vertical: 9,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: kBlue
                                                            .withOpacity(0.12),
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(12),
                                                        border: Border.all(
                                                          color: kBlue
                                                              .withOpacity(
                                                            0.35,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                        MainAxisSize.min,
                                                        children: [
                                                          const Text(
                                                            '🎧',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 7),
                                                          Text(
                                                            'Listen Song',
                                                            style: dmSans(
                                                              size: 12,
                                                              weight: FontWeight
                                                                  .w600,
                                                              color: kBlue,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  _resultCard(
                                    type: 'mirror',
                                    delay: 250,
                                    accentColor: kPink,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        _rcEyebrow(
                                          '🪞 Mirror Affirmation',
                                          kPink,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          data['mirror_affirmation'] ?? '',
                                          textAlign: TextAlign.center,
                                          style: cormorant(
                                            size: 22,
                                            style: FontStyle.italic,
                                          ).copyWith(height: 1.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          Padding(
                            padding:
                            const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WriteScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding:
                                const EdgeInsets.symmetric(vertical: 15),
                                decoration: glassBox(),
                                child: Text(
                                  '+ New Entry',
                                  textAlign: TextAlign.center,
                                  style: dmSans(
                                    size: 15,
                                    weight: FontWeight.w500,
                                    color: kTextSoft,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _resultCard({
    required String type,
    required int delay,
    required Color accentColor,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + delay),
      curve: Curves.easeOut,
      builder: (context, value, c) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: c,
          ),
        );
      },
      child: Container(
        decoration: glassBox(),
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
                      accentColor.withOpacity(0.55),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _rcEyebrow(String text, Color color) {
    return Text(
      text,
      style: dmSans(
        size: 10,
        weight: FontWeight.w500,
        color: color,
      ).copyWith(letterSpacing: 1.0),
    );
  }

  Widget _orbWidget(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
            stops: const [0.0, 0.7],
          ),
        ),
      ),
    );
  }
}