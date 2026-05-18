
import 'package:arrive_newversion/new_home_screens/concept_b.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../new_AI_feedback/constants.dart';
import '../../new_bottom_bar/bottom_nav_bar.dart';
import '../../new_home_screens/concept_a.dart';
import '../theme/app_theme.dart';

class FirstEntryScreen extends StatefulWidget {
  const FirstEntryScreen({super.key});

  @override
  State<FirstEntryScreen> createState() => _FirstEntryScreenState();
}

class _FirstEntryScreenState extends State<FirstEntryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbController;
  late final AnimationController _dotController;

  late final Animation<double> _orbScale;
  late final Animation<double> _outerGlow;
  late final Animation<double> _dotOpacity;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _orbScale = Tween<double>(begin: 0.92, end: 1.05).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOut),
    );

    _outerGlow = Tween<double>(begin: 14, end: 28).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOut),
    );

    _dotOpacity = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _dotController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _orbController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArriveTheme.bg,
      body: OrbBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                AnimatedBuilder(
                  animation: _orbController,
                  builder: (_, __) {
                    return Transform.scale(
                      scale: _orbScale.value,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ArriveTheme.green.withOpacity(0.08),
                          boxShadow: [
                            BoxShadow(
                              color: ArriveTheme.green.withOpacity(0.16),
                              blurRadius: _outerGlow.value,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ArriveTheme.green.withOpacity(0.10),
                              border: Border.all(
                                color: ArriveTheme.green.withOpacity(0.28),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '✏️',
                                style: TextStyle(fontSize: 34),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: ArriveTheme.text,
                      height: 1.28,
                    ),
                    children: [
                      const TextSpan(text: 'You\'re all set,\n'),
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

                const SizedBox(height: 12),

                Text(
                  'Your space is ready. No pressure — but there\'s a prompt waiting if you want to start right now.',
                  textAlign: TextAlign.center,
                  style: ArriveTheme.dmSans.copyWith(
                    fontSize: 14,
                    color: ArriveTheme.textSoft,
                    fontWeight: FontWeight.w300,
                    height: 1.75,
                  ),
                ),

                const SizedBox(height: 30),

                _promptCard(),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConceptBScreen())
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xE07DDE8A),
                          Color(0xC78DBFAA),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: ArriveTheme.green.withOpacity(0.28),
                          blurRadius: 24,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Write My First Entry →',
                        style: ArriveTheme.dmSans.copyWith(
                          color: const Color(0xFF111111),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      _slide(const ConceptAScreen()),
                    );
                  },
                  child: Text(
                    'I\'ll do it later',
                    style: ArriveTheme.dmSans.copyWith(
                      fontSize: 13,
                      color: ArriveTheme.textMuted,
                      decoration: TextDecoration.underline,
                      decorationColor: ArriveTheme.textMuted,
                    ),
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _promptCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ArriveTheme.glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ArriveTheme.green.withOpacity(0.30),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 24,
            right: 24,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    ArriveTheme.green.withOpacity(0.60),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _dotController,
                      builder: (_, __) {
                        return Opacity(
                          opacity: _dotOpacity.value,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ArriveTheme.green,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'TODAY\'S PROMPT',
                      style: ArriveTheme.dmSans.copyWith(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: ArriveTheme.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '"What is one thing you\'re carrying today that you haven\'t said out loud yet?"',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    color: ArriveTheme.text,
                    height: 1.5,
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