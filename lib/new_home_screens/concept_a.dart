
import 'package:arrive_newversion/new_home_screens/shared.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../new_bottom_bar/bottom_nav_bar.dart';
import '../new_onboarding_screens/theme/app_theme.dart';
import 'concept_b.dart';
import 'concept_c.dart';

class ConceptAScreen extends StatelessWidget {
  const ConceptAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFF111620),
      body: Stack(
        children: [
          OrbBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _header(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _greeting(),
                          _bigJournalCard(),
                          const SizedBox(height: 12),
                          _toolGrid(),
                          const SizedBox(height: 12),
                          _streakMini(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                    builder: (_) => const ConceptBScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
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
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.055),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    '🔔',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ArriveTheme.green,
                      border: Border.all(
                        color: const Color(0xFF111620),
                        width: 1.5,
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

  Widget _greeting() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GOOD MORNING',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              letterSpacing: 1.0,
              color: ArriveTheme.textMuted.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: ArriveTheme.text,
                height: 1.2,
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
          const SizedBox(height: 5),
          Text(
            'This is your space to arrive — fully and honestly.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: ArriveTheme.textSoft.withOpacity(0.9),
              fontWeight: FontWeight.w300,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigJournalCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _glassCard(
        radius: 20,
        padding: const EdgeInsets.all(22),
        topLineColor: ArriveTheme.green.withOpacity(0.40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _blinkDot(ArriveTheme.green),
                const SizedBox(width: 6),
                Text(
                  "TODAY'S PROMPT",
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                    color: ArriveTheme.green,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '"What are you carrying today that you\'d like to set down?"',
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
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
          ],
        ),
      ),
    );
  }

  Widget _toolGrid() {
    final tools = [
      {
        'icon': '🪞',
        'name': 'AI Feedback',
        'desc': 'Reflect on your entry with Friend, Therapist or Coach.',
        'badge': 'OPTIONAL',
        'line': const Color(0x59D4B896),
        'accent': const Color(0xFFD4B896),
      },
      {
        'icon': '😌',
        'name': 'Mood Check-in',
        'desc': 'Quick check. How are you feeling right now?',
        'badge': 'DAILY',
        'line': const Color(0x59D4A0B8),
        'accent': const Color(0xFFD4A0B8),
      },
      {
        'icon': '📈',
        'name': 'Progress',
        'desc': 'Your streaks, mood trends, and journal history.',
        'badge': '7 DAY STREAK',
        'line': const Color(0x598DBFAA),
        'accent': const Color(0xFF8DBFAA),
      },
      {
        'icon': '🌸',
        'name': 'Community',
        'desc': 'Postpartum Mode — share, support, and save.',
        'badge': 'PRIVATE',
        'line': const Color(0x59D296AF),
        'accent': const Color(0xFFD4A0B8),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        itemCount: tools.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (_, i) {
          final t = tools[i];
          return _glassCard(
            radius: 18,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            topLineColor: (t['line'] as Color).withOpacity(0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t['icon'] as String,
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(height: 10),
                Text(
                  t['name'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ArriveTheme.text,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 3),
                Expanded(
                  child: Text(
                    t['desc'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: ArriveTheme.textMuted,
                      height: 1.4,
                      fontWeight: FontWeight.w300,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: t['line'] as Color),
                  ),
                  child: Text(
                    t['badge'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      letterSpacing: 0.8,
                      color: t['accent'] as Color,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(
                  6,
                      (_) => Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: _streakDot(active: true, now: false),
                  ),
                ),
                _streakDot(active: true, now: true),
              ],
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
              offset: const Offset(0, 6),
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
          )
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

  Widget _blinkDot(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0.2),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (_, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}