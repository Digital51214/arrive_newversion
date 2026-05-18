import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'modes_screen.dart';

class WalkthroughScreen extends StatefulWidget {
  final bool postpartumEnabled;
  const WalkthroughScreen({super.key, required this.postpartumEnabled});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  int _step = 0;
  final _pageCtrl = PageController();

  final _slides = const [
    _SlideData(
      accentColor: Color(0xFF7DDE8A),
      num: '01 OF 03',
      title: 'Your journal. Your words. No judgment.',
      body:
      'Write to a daily prompt or just say what\'s on your mind. Add photos, tag your mood. Your entries are private — only you can see them, always.',
    ),
    _SlideData(
      accentColor: Color(0xFFB8A8D8),
      num: '02 OF 03',
      title: 'AI that listens like a person, not a search engine.',
      body:
      'Every response is built around your actual words. You\'ll see this on the next screen — what each mode sounds like in real life.',
    ),
    _SlideData(
      accentColor: Color(0xFFD4A0B8),
      num: '03 OF 03',
      title: 'A community where you\'re never the only one.',
      body:
      'Share thoughts, ask for support, celebrate small wins. Post as yourself or stay anonymous. Postpartum mode available for new moms.',
    ),
  ];

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
      _pageCtrl.animateToPage(
        _step,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.push(context, _slide(const ModesScreen()));
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArriveTheme.bg,
      body: OrbBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final isActive = i == _step;
                    final isDone = i < _step;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3.5),
                      width: isActive ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: isActive
                            ? ArriveTheme.green
                            : isDone
                            ? ArriveTheme.green.withOpacity(0.45)
                            : Colors.white.withOpacity(0.22),
                      ),
                    );
                  }),
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _slides
                      .asMap()
                      .entries
                      .map((e) => _buildSlide(e.key, e.value))
                      .toList(),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          Navigator.push(context, _slide(const ModesScreen())),
                      child: Text(
                        'Skip →',
                        style: ArriveTheme.dmSans.copyWith(
                          fontSize: 13,
                          color: ArriveTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: _next,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xE07DDE8A), Color(0xC78DBFAA)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              _step < 2 ? 'Next →' : 'Continue →',
                              style: ArriveTheme.dmSans.copyWith(
                                color: const Color(0xFF111111),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

  Widget _buildSlide(int idx, _SlideData slide) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: ArriveTheme.glass,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: ArriveTheme.glassBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topIcon(idx),
                const SizedBox(height: 18),
                if (idx == 0) _journalMock(),
                if (idx == 1) _aiMock(),
                if (idx == 2) _communityMock(),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            slide.num,
            style: ArriveTheme.dmSans.copyWith(
              fontSize: 10,
              letterSpacing: 1.4,
              color: ArriveTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            slide.title,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 27,
              fontWeight: FontWeight.w300,
              color: ArriveTheme.text,
              height: 1.22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.body,
            style: ArriveTheme.dmSans.copyWith(
              fontSize: 14,
              color: ArriveTheme.textSoft,
              height: 1.75,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _topIcon(int idx) {
    if (idx == 0) {
      return const Text('✏️', style: TextStyle(fontSize: 42));
    }
    if (idx == 1) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black.withOpacity(0.45),
            width: 1,
          ),
          color: Colors.transparent,
        ),
      );
    }
    return const Text('🌸', style: TextStyle(fontSize: 42));
  }

  Widget _journalMock() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ArriveTheme.green.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ArriveTheme.green.withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✦ Today\'s Prompt',
            style: ArriveTheme.dmSans.copyWith(
              fontSize: 12,
              color: ArriveTheme.green,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '"I\'ve been carrying something I haven\'t said out loud yet. Tonight I\'m going to try to say it here, just to see what it looks like written down..."',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: ArriveTheme.textSoft,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _TagChip(label: '💭 Reflective', isGreen: true),
              _TagChip(label: '😔 Sad', isGreen: true),
              _TagChip(label: '📷 1 photo', isGreen: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _aiMock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'After you write, you can ask for feedback.',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w300,
            color: ArriveTheme.text,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Pick how you want to be heard — as a Friend, a Therapist, or a Coach — and get a personal response that actually fits what you wrote.',
          style: ArriveTheme.dmSans.copyWith(
            fontSize: 13,
            color: ArriveTheme.textSoft,
            height: 1.7,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _communityMock() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ArriveTheme.pink.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ArriveTheme.pink.withOpacity(0.20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🤍 ANONYMOUS MOM',
                style: ArriveTheme.dmSans.copyWith(
                  fontSize: 10,
                  letterSpacing: 1,
                  color: ArriveTheme.pink,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"I love my baby more than anything. I also miss myself deeply. I don\'t think people let you hold both at once. So I\'m saying it here."',
                style: ArriveTheme.dmSans.copyWith(
                  fontSize: 13,
                  color: ArriveTheme.textSoft,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ArriveTheme.sage.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ArriveTheme.sage.withOpacity(0.20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🌿 MAYA T.',
                style: ArriveTheme.dmSans.copyWith(
                  fontSize: 10,
                  letterSpacing: 1,
                  color: ArriveTheme.sage,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"Nobody warns you how beautifully nonlinear this journey actually is."',
                style: ArriveTheme.dmSans.copyWith(
                  fontSize: 13,
                  color: ArriveTheme.textSoft,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        if (widget.postpartumEnabled) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ArriveTheme.pink.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ArriveTheme.pink.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                const Text('🌸', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Postpartum Mode is on for you',
                    style: ArriveTheme.dmSans.copyWith(
                      fontSize: 12,
                      color: ArriveTheme.pink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool isGreen;

  const _TagChip({
    required this.label,
    this.isGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = isGreen ? ArriveTheme.green : ArriveTheme.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.32)),
      ),
      child: Text(
        label,
        style: ArriveTheme.dmSans.copyWith(
          fontSize: 10,
          color: chipColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _SlideData {
  final Color accentColor;
  final String num;
  final String title;
  final String body;

  const _SlideData({
    required this.accentColor,
    required this.num,
    required this.title,
    required this.body,
  });
}

PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, anim, __, child) => SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
    child: child,
  ),
  transitionDuration: const Duration(milliseconds: 380),
);