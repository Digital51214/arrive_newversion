import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'walkthrough_screen.dart';
import 'dart:math' as math;
class SplashScreen2 extends StatefulWidget {
  const SplashScreen2({super.key});

  @override
  State<SplashScreen2> createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathe;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3500))
      ..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _breathe, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _breathe.dispose();
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Logo orb
                AnimatedBuilder(
                  animation: _scaleAnim,
                  builder: (_, child) => Transform.scale(
                    scale: _scaleAnim.value,
                    child: child,
                  ),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ArriveTheme.green.withOpacity(0.12),
                      border: Border.all(
                          color: ArriveTheme.green.withOpacity(0.3), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: ArriveTheme.green.withOpacity(0.18),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.035),
                      child: Container(
                        width: 100,
                        height: 100,
                        child: CustomPaint(
                          painter: _ArriveSvgPainter(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Wordmark
                Text(
                  'Arrive',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 52,
                    fontWeight: FontWeight.w300,
                    color: ArriveTheme.text,
                    letterSpacing: 4,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Where Healing Begins',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    color: ArriveTheme.textSoft,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'A private space to write, reflect, and be heard — by yourself and by an AI that meets you exactly where you are.',
                  textAlign: TextAlign.center,
                  style: ArriveTheme.dmSans.copyWith(
                    fontSize: 15,
                    color: ArriveTheme.textSoft,
                    fontWeight: FontWeight.w300,
                    height: 1.75,
                  ),
                ),
                const Spacer(),
                // Buttons
                PrimaryButton(
                  label: 'Create Your Account →',
                  onTap: () => Navigator.push(context,
                      _slide(const SignupScreen())),
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'I already have an account',
                  onTap: () => Navigator.push(context,
                      _slide(const LoginScreen())),
                ),
                const SizedBox(height: 20),
                Text(
                  'Your entries are private and encrypted.\nARRIVE never sells your data.',
                  textAlign: TextAlign.center,
                  style: ArriveTheme.dmSans.copyWith(
                    fontSize: 11,
                    color: ArriveTheme.textMuted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
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

// Custom painter for the ARRIVE logo SVG
class _ArriveSvgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7DDE8A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final scaleX = size.width / 130;
    final scaleY = size.height / 130;

    // 👇 SVG ko chhota karne ke liye extra scale
    const shrink = 0.6; // 👈 is value ko adjust karo (0.5 - 0.8 best)

    final dx = size.width * (1 - shrink) / 2;
    final dy = size.height * (1 - shrink) / 2;
    canvas.save();
    canvas.translate(dx, dy); // center maintain
    canvas.scale(scaleX * shrink, scaleY * shrink);

    // Top leaf shape
    final path1 = Path()
      ..moveTo(50, 4)
      ..cubicTo(33, 4, 20, 17, 20, 33)
      ..cubicTo(20, 43, 26, 52, 35, 57)
      ..lineTo(50, 65)
      ..lineTo(65, 57)
      ..cubicTo(74, 52, 80, 43, 80, 33)
      ..cubicTo(80, 17, 67, 4, 50, 4);
    canvas.drawPath(path1, paint);

    // Middle branching shape
    final path2 = Path()
      ..moveTo(20, 57)
      ..cubicTo(8, 57, 1, 65, 1, 74)
      ..cubicTo(1, 85, 9, 92, 20, 92)
      ..cubicTo(30, 92, 39, 85, 41, 76)
      ..lineTo(50, 65)
      ..lineTo(59, 76)
      ..cubicTo(61, 85, 70, 92, 80, 92)
      ..cubicTo(91, 92, 99, 85, 99, 74)
      ..cubicTo(99, 65, 92, 57, 80, 57)
      ..cubicTo(70, 57, 61, 64, 59, 73)
      ..lineTo(50, 84)
      ..lineTo(41, 73)
      ..cubicTo(39, 64, 30, 57, 20, 57);
    canvas.drawPath(path2, paint);

    // Bottom root
    final path3 = Path()
      ..moveTo(35, 92)
      ..cubicTo(28, 98, 28, 108, 38, 111)
      ..lineTo(50, 113)
      ..lineTo(62, 111)
      ..cubicTo(72, 108, 72, 98, 65, 92);
    canvas.drawPath(path3, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_) => false;
}