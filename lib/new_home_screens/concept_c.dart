import 'dart:math' as math;


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../new_AI_feedback/screens/screen_write.dart';
import '../new_bottom_bar/bottom_nav_bar.dart';
import '../new_community/screens/community_main_screen.dart';
import '../new_onboarding_screens/theme/app_theme.dart';
import '../new_quick_thoughts_screens/screens/arrive_compose_screen.dart';
import 'shared.dart';

class ConceptCScreen extends StatefulWidget {
  final Widget? nextScreen;

  const ConceptCScreen({
    super.key,
    this.nextScreen,
  });

  @override
  State<ConceptCScreen> createState() => _ConceptCScreenState();
}

class _ConceptCScreenState extends State<ConceptCScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ring1;
  late final AnimationController _ring2;
  late final AnimationController _breathe;

  @override
  void initState() {
    super.initState();

    _ring1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _ring2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ring1.dispose();
    _ring2.dispose();
    _breathe.dispose();
    super.dispose();
  }

  void _goNext() {
    if (widget.nextScreen == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => widget.nextScreen!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFF111620),
      body: Stack(
        children: [
          const Positioned.fill(child: OrbsBackground()),
          SafeArea(
            child: Column(
              children: [
                const _ConceptHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _GreetingBlock(),
                        const SizedBox(height: 18),
                        _HubCenter(
                          ring1: _ring1,
                          ring2: _ring2,
                          breathe: _breathe,
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Text(
                            'WHERE HEALING BEGINS',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              letterSpacing: 1.1,
                              color: ArriveTheme.textMuted.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: _HubToolsGrid(),
                        ),
                        const SizedBox(height: 14),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: _HubStreakCard(),
                        ),
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
            child: _writeFab(onTap: (){
             Navigator.push(context, MaterialPageRoute(builder: (context) => ArriveComposeScreen()));
            }),
          ),
        ],
      ),
    );
  }
  Widget _writeFab({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 114,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              ArriveTheme.green.withOpacity(0.95),
              const Color(0xFF69CE78),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
          child: Text(
            '✏️',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }}
class _ConceptHeader extends StatelessWidget {
  const _ConceptHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 26,
                height: 26,
                child: Center(
                  child: ArriveLogo(
                    size: 22,
                    color: ArriveTheme.green,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                'Arrive',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 21,
                  fontWeight: FontWeight.w300,
                  color: ArriveTheme.text,
                  letterSpacing: 0.8,
                  height: 1,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    '🔔',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Positioned(
                  top: 7,
                  right: 8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ArriveTheme.green,
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
}

class _GreetingBlock extends StatelessWidget {
  const _GreetingBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GOOD MORNING',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              letterSpacing: 1.2,
              color: ArriveTheme.textMuted.withOpacity(0.85),
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: GoogleFonts.cormorantGaramond(
                fontSize: 34,
                fontWeight: FontWeight.w300,
                color: ArriveTheme.text,
                height: 1.1,
              ),
              children: [
                const TextSpan(text: 'Welcome back, '),
                TextSpan(
                  text: 'Kezia.',
                  style: TextStyle(
                    color: ArriveTheme.green,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubCenter extends StatelessWidget {
  final AnimationController ring1;
  final AnimationController ring2;
  final AnimationController breathe;

  const _HubCenter({
    required this.ring1,
    required this.ring2,
    required this.breathe,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 176,
        height: 176,
        child: AnimatedBuilder(
          animation: Listenable.merge([ring1, ring2, breathe]),
          builder: (_, __) {
            final glow = 18.0 + (12.0 * breathe.value);

            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: ring1.value * 2 * math.pi,
                  child: Container(
                    width: 144,
                    height: 144,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ArriveTheme.green.withOpacity(0.10),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -ring2.value * 2 * math.pi,
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ArriveTheme.green.withOpacity(0.14),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ArriveTheme.green.withOpacity(0.08),
                    border: Border.all(
                      color: ArriveTheme.green.withOpacity(0.30),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ArriveTheme.green.withOpacity(0.10),
                        blurRadius: glow,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: ArriveLogo(
                      size: 42,
                      color: ArriveTheme.green,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HubToolsGrid extends StatelessWidget {
  const _HubToolsGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children:  [
        Row(
          children: [
            Expanded(
              child: _HubTile(
                icon: '✏️',
                title: 'Journal',
                subtitle: 'Write &\nreflect',
                accent: Color(0xFF7DDE8A),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WriteScreen(),
                    ),
                  );
                },
                child: _HubTile(
                  icon: '🪞',
                  title: 'AI\nFeedback',
                  subtitle: 'Friend · Coach\n· Therapist',
                  accent: Color(0xFFD4B896),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _HubTile(
                icon: '😊',
                title: 'Mood',
                subtitle: 'Daily\ncheck-in',
                accent: Color(0xFFD4A0B8),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CommunityMainScreen(),
                    ),
                  );
                },
                child: _HubTile(
                  icon: '🌸',
                  title: 'Community',
                  subtitle: 'Postpartum\nMode',
                  accent: Color(0xFFD4A0B8),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14),
        _HubWideTile(
          icon: '📈',
          title: 'Progress & Streaks',
          subtitle: 'Your journey at a glance — 7 day streak',
          accent: Color(0xFF8DBFAA),
        ),
      ],
    );
  }
}

class _HubTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color accent;

  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.055),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 14,
              bottom: 14,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 24, 16, 16),
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ArriveTheme.text,
                            height: 1.15,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: ArriveTheme.textMuted,
                            height: 1.35,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '→',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: ArriveTheme.textMuted.withOpacity(0.8),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HubWideTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color accent;

  const _HubWideTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.055),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 14,
              bottom: 14,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ArriveTheme.text,
                            height: 1.15,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: ArriveTheme.textMuted,
                            height: 1.3,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '→',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: ArriveTheme.textMuted.withOpacity(0.8),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HubStreakCard extends StatelessWidget {
  const _HubStreakCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.055),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: ArriveTheme.textSoft,
                    fontWeight: FontWeight.w300,
                  ),
                  children: [
                    TextSpan(
                      text: '7',
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
            const StreakDots(dotSize: 24),
          ],
        ),
      ),
    );
  }
}