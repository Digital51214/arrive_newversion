import 'dart:math' as math;
import 'dart:ui';
import 'package:arrive_newversion/new_service_screens/quick_thoughts_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/arrive_colors.dart';
import '../widgets/arrive_background.dart';
import '../widgets/arrive_header.dart';

import 'arrive_response_screen.dart';

class ArriveLoadingScreen extends StatefulWidget {
  final String thought;
  final String mode;

  const ArriveLoadingScreen({
    super.key,
    required this.thought,
    required this.mode,
  });

  @override
  State<ArriveLoadingScreen> createState() => _ArriveLoadingScreenState();
}

class _ArriveLoadingScreenState extends State<ArriveLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  String _statusText = 'Taking your words in…';

  final List<String> _loadingMessages = [
    'Taking your words in…',
    'Listening carefully…',
    'Finding the right words…',
    'Almost there…',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _cycleMessages();
    _callApi();
  }

  void _cycleMessages() {
    int index = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return false;
      index = (index + 1) % _loadingMessages.length;
      setState(() {
        _statusText = _loadingMessages[index];
      });
      return true;
    });
  }

  Future<void> _callApi() async {
    try {
      final response = await QuickThoughtService.sendQuickThought(
        thought: widget.thought,
        mode: widget.mode,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ArriveResponseScreen(
            thought: widget.thought,
            mode: widget.mode,
            response: response,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ArriveResponseScreen(
            thought: widget.thought,
            mode: widget.mode,
            response: QuickThoughtResponse(
              paragraph:
              'Something went wrong while reaching out. Please check your connection and try again.',
              q1: 'What are you feeling right now?',
              q2: 'What do you need most in this moment?',
              q3: 'What small step could help you feel better?',
            ),
          ),
        ),
      );
    }
  }

  String get _modeIcon {
    switch (widget.mode) {
      case 'Friend':
        return '🤝';
      case 'Coach':
        return '⚡';
      default:
        return '🧘';
    }
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
                                  child: Center(
                                    child: Text(
                                      _modeIcon,
                                      style: const TextStyle(fontSize: 32),
                                    ),
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
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          _statusText,
                          key: ValueKey(_statusText),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            height: 1.6,
                            fontWeight: FontWeight.w300,
                            color: ArriveColors.textSoft,
                          ),
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
                          '✦ ${widget.mode} Mode',
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