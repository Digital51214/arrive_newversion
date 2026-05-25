import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:google_fonts/google_fonts.dart';

import '../new_onboarding_screens/theme/app_theme.dart';

// ─── COLORS ───────────────────────────────────────────────────────────────────
const kBg = Color(0xFF111620);
const kGreen = Color(0xFF7DDE8A);
const kPink = Color(0xFFD4A0B8);
const kBlue = Color(0xFF90B8E0);
const kGold = Color(0xFFD4B896);
const kSage = Color(0xFF8DBFAA);
const kLavender = Color(0xFFB8A8D8);
const kText = Color(0xEBF0EBE4); // rgba(240,235,228,0.92)
const kTextSoft = Color(0x94F0EBE4); // 0.58
const kTextMuted = Color(0x52F0EBE4); // 0.32

// ─── GLASS CARD ───────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final Color? topLineColor;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.topLineColor,
    this.padding,
    this.onTap,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? 20;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(br),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.07),
              Colors.white.withOpacity(0.04),
            ],
          ),
          boxShadow: shadows ??
              [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(br),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                  padding: padding ?? const EdgeInsets.all(18),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── ARRIVE LOGO ──────────────────────────────────────────────────────────────
class ArriveLogo extends StatelessWidget {
  final double size;
  final Color color;

  const ArriveLogo({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/only logo.png',
      width: 25,
      height: 25,
      fit: BoxFit.cover,
    );
  }
}

// class _ArriveLogoPainter extends CustomPainter {
//   final Color color;
//   const _ArriveLogoPainter({required this.color});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = size.width * 0.07
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = StrokeJoin.round;
//
//     final w = size.width;
//     final h = size.height;
//
//     final path1 = Path();
//     path1.moveTo(w * 0.5, h * 0.035);
//     path1.cubicTo(w * 0.33, h * 0.035, w * 0.2, h * 0.148, w * 0.2, h * 0.287);
//     path1.cubicTo(w * 0.2, h * 0.374, w * 0.26, h * 0.452, w * 0.35, h * 0.496);
//     path1.lineTo(w * 0.5, h * 0.565);
//     path1.lineTo(w * 0.65, h * 0.496);
//     path1.cubicTo(w * 0.74, h * 0.452, w * 0.8, h * 0.374, w * 0.8, h * 0.287);
//     path1.cubicTo(w * 0.8, h * 0.148, w * 0.67, h * 0.035, w * 0.5, h * 0.035);
//     canvas.drawPath(path1, paint);
//
//     final path2 = Path();
//     path2.moveTo(w * 0.2, h * 0.496);
//     path2.cubicTo(w * 0.08, h * 0.496, w * 0.01, h * 0.565, w * 0.01, h * 0.644);
//     path2.cubicTo(w * 0.01, h * 0.739, w * 0.09, h * 0.8, w * 0.2, h * 0.8);
//     path2.cubicTo(w * 0.3, h * 0.8, w * 0.39, h * 0.739, w * 0.41, h * 0.661);
//     path2.lineTo(w * 0.5, h * 0.565);
//     path2.lineTo(w * 0.59, h * 0.661);
//     path2.cubicTo(w * 0.61, h * 0.739, w * 0.7, h * 0.8, w * 0.8, h * 0.8);
//     path2.cubicTo(w * 0.91, h * 0.8, w * 0.99, h * 0.739, w * 0.99, h * 0.644);
//     path2.cubicTo(w * 0.99, h * 0.565, w * 0.92, h * 0.496, w * 0.8, h * 0.496);
//     path2.cubicTo(w * 0.7, h * 0.496, w * 0.61, h * 0.557, w * 0.59, h * 0.635);
//     path2.lineTo(w * 0.5, h * 0.73);
//     path2.lineTo(w * 0.41, h * 0.635);
//     path2.cubicTo(w * 0.39, h * 0.557, w * 0.3, h * 0.496, w * 0.2, h * 0.496);
//     canvas.drawPath(path2, paint);
//
//     final path3 = Path();
//     path3.moveTo(w * 0.35, h * 0.8);
//     path3.cubicTo(w * 0.28, h * 0.852, w * 0.28, h * 0.939, w * 0.38, h * 0.965);
//     path3.lineTo(w * 0.5, h * 0.983);
//     path3.lineTo(w * 0.62, h * 0.965);
//     path3.cubicTo(w * 0.72, h * 0.939, w * 0.72, h * 0.852, w * 0.65, h * 0.8);
//     canvas.drawPath(path3, paint);
//   }
//
//   @override
//   bool shouldRepaint(_ArriveLogoPainter old) => old.color != color;
// }

// ─── FLOATING ORB PAINTER ─────────────────────────────────────────────────────
class OrbsBackground extends StatefulWidget {
  const OrbsBackground({super.key});

  @override
  State<OrbsBackground> createState() => _OrbsBackgroundState();
}

class _OrbsBackgroundState extends State<OrbsBackground>
    with TickerProviderStateMixin {
  late AnimationController _c1, _c2, _c3;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(vsync: this, duration: const Duration(seconds: 9))
      ..repeat(reverse: true);
    _c2 = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
    _c3 = AnimationController(vsync: this, duration: const Duration(seconds: 14))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_c1, _c2, _c3]),
      builder: (_, __) => CustomPaint(
        painter: _OrbsPainter(
          t1: _c1.value,
          t2: _c2.value,
          t3: _c3.value,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _OrbsPainter extends CustomPainter {
  final double t1, t2, t3;
  const _OrbsPainter({required this.t1, required this.t2, required this.t3});

  Offset _drift(double t, double ax, double ay) {
    final dx = 12 * (t - 0.5);
    final dy = -15 * (t - 0.5);
    return Offset(ax + dx, ay + dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    void orb(Offset center, double radius, Color color, double opacity) {
      final paint = Paint()
        ..shader = RadialGradient(colors: [
          color.withOpacity(opacity),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    final o1 = _drift(t1, -30, -40);
    orb(o1, 140, const Color(0xFF7DDE8A), 0.15);
    final o2 = _drift(1 - t2, size.width + 25, size.height - 60);
    orb(o2, 120, const Color(0xFF78A5DC), 0.13);
    final o3 = _drift(t3, size.width * 0.15, size.height * 0.4);
    orb(o3, 90, const Color(0xFFD4B896), 0.09);
  }

  @override
  bool shouldRepaint(_OrbsPainter old) => true;
}

// ─── STATUS BAR ───────────────────────────────────────────────────────────────
class ArriveStatusBar extends StatelessWidget {
  const ArriveStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kTextSoft,
            ),
          ),
          Text(
            '●●● WiFi 🔋',
            style: TextStyle(fontSize: 12, color: kTextSoft),
          ),
        ],
      ),
    );
  }
}

// ─── APP HEADER ───────────────────────────────────────────────────────────────
class ArriveHeader extends StatelessWidget {
  const ArriveHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ArriveLogo(size: 24, color: kGreen),
              const SizedBox(width: 9),
               Text(
                'Arrive',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                  color: ArriveTheme.text,
                  letterSpacing: 1,
                )
              ),
            ],
          ),
          _NotifBell(),
        ],
      ),
    );
  }
}

class _NotifBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 17,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text('🔔', style: TextStyle(fontSize: 15)),
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: kGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBg, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── GREETING ─────────────────────────────────────────────────────────────────
class ArriveGreeting extends StatelessWidget {
  final bool showSub;
  final String userName;

  const ArriveGreeting({
    super.key,
    this.showSub = true,
    this.userName = 'Kezia',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good morning',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.0,
              color: kTextMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
              style: GoogleFonts.cormorantGaramond(
                fontSize: 35,
                fontWeight: FontWeight.w300,
                color: ArriveTheme.text,
                height: 1.2,
              ),
              children: [
                const TextSpan(text: 'Welcome back, '),
                TextSpan(
                  text: '$userName.',
                  style: TextStyle(
                    color: kGreen,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          if (showSub) ...[
            const SizedBox(height: 5),
            Text(
              'This is your space to arrive — fully and honestly.',
              style: TextStyle(
                fontSize: 13,
                color: kTextSoft,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
// ─── BOTTOM NAV ───────────────────────────────────────────────────────────────
class ArriveBottomNav extends StatelessWidget {
  const ArriveBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xD90D1117),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: '🏠', label: 'Home', active: true),
              _NavItem(icon: '📖', label: 'Journal'),
              _NavItemLogo(),
              _NavItem(icon: '🌸', label: 'Community'),
              _NavItem(icon: '👤', label: 'Me'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;

  const _NavItem({required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: active ? 1.0 : 0.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
              color: active ? kGreen : kTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ArriveLogo(size: 20, color: kSage),

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
    );
  }
}

// ─── STREAK DOTS ──────────────────────────────────────────────────────────────
class StreakDots extends StatelessWidget {
  final int total;
  final int completed;
  final double dotSize;

  const StreakDots({
    super.key,
    this.total = 7,
    this.completed = 7,
    this.dotSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isToday = i == total - 1;
        final isDone = i < completed;
        return Container(
          margin: EdgeInsets.only(right: i < total - 1 ? 5 : 0),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday
                ? kGreen.withOpacity(0.35)
                : isDone
                    ? kGreen.withOpacity(0.2)
                    : Colors.white.withOpacity(0.055),
            border: Border.all(
              color: isToday
                  ? kGreen
                  : isDone
                      ? kGreen.withOpacity(0.4)
                      : Colors.white.withOpacity(0.1),
            ),
            boxShadow: isToday
                ? [
                    BoxShadow(
                      color: kGreen.withOpacity(0.3),
                      blurRadius: 8,
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              isToday ? '✦' : isDone ? '✓' : '',
              style: TextStyle(
                fontSize: dotSize * 0.42,
                color: isToday || isDone ? kGreen : kTextMuted,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── BLINKING DOT ─────────────────────────────────────────────────────────────
class BlinkDot extends StatefulWidget {
  final Color color;
  const BlinkDot({super.key, required this.color});

  @override
  State<BlinkDot> createState() => _BlinkDotState();
}

class _BlinkDotState extends State<BlinkDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _a = Tween<double>(begin: 1.0, end: 0.2).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
      ),
    );
  }
}

// ─── FAB ──────────────────────────────────────────────────────────────────────
class ArriveFab extends StatelessWidget {
  const ArriveFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 74,
      right: 20,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xE57DDE8A),
                Color(0xCC64C873),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: kGreen.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(child: Text('✏️', style: TextStyle(fontSize: 20))),
        ),
      ),
    );
  }
}
