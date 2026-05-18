import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/arrive_colors.dart';
import '../widgets/arrive_background.dart';
import '../widgets/arrive_header.dart';
import 'arrive_response_screen.dart';

class ArriveLoadingScreen extends StatefulWidget {
  const ArriveLoadingScreen({super.key});

  @override
  State<ArriveLoadingScreen> createState() => _ArriveLoadingScreenState();
}

class _ArriveLoadingScreenState extends State<ArriveLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ArriveResponseScreen(),
        ),
      );
    });
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ArriveBackground(
      child: SafeArea(
        child: Column(
          children: [
            const ArriveHeader(),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _controller.value * 2 * math.pi,
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color.fromRGBO(184, 168, 216, 0.15),
                                    width: 1,
                                  ),
                                ),
                                child: CustomPaint(painter: _RingPainter()),
                              ),
                            ),
                            ClipOval(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ArriveColors.glass,
                                    border: Border.all(
                                      color: const Color.fromRGBO(184, 168, 216, 0.35),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromRGBO(184, 168, 216, 0.18),
                                        blurRadius: 40,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text('🧘', style: TextStyle(fontSize: 32)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Hearing you…',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                          color: ArriveColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Taking your words in. This will only take a moment.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          height: 1.6,
                          fontWeight: FontWeight.w300,
                          color: ArriveColors.textSoft,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(184, 168, 216, 0.10),
                          border: Border.all(
                            color: const Color.fromRGBO(184, 168, 216, 0.30),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '✦ Therapist Mode',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w500,
                            color: ArriveColors.lavender,
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
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color.fromRGBO(184, 168, 216, 0.7);

    canvas.drawArc(rect.deflate(0.5), -1.2, 1.4, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
