import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArriveTheme {
  // Colors
  static const Color bg = Color(0xFF252D42);
  static const Color bgDark = Color(0xFF1A1F2E);
  static const Color green = Color(0xFF7DDE8A);
  static const Color pink = Color(0xFFD4A0B8);
  static const Color blue = Color(0xFF90B8E0);
  static const Color gold = Color(0xFFD4B896);
  static const Color sage = Color(0xFF8DBFAA);
  static const Color lavender = Color(0xFFB8A8D8);
  static const Color text = Color(0xFFFFFAF5);
  static const Color textSoft = Color(0xD1F0EBE4);
  static const Color textMuted = Color(0x8CF0EBE4);
  static const Color glassBorder = Color(0x2DFFFFFF);
  static const Color glass = Color(0x1AFFFFFF);
  static const Color glassHover = Color(0x29FFFFFF);

  static TextStyle get cormorant => GoogleFonts.cormorantGaramond();
  static TextStyle get dmSans => GoogleFonts.dmSans();

  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: bgDark,
        colorScheme: const ColorScheme.dark(primary: green, surface: bg),
        textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      );
}

class GlassBox extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final double? minHeight;

  const GlassBox({
    super.key,
    required this.child,
    this.borderRadius,
    this.borderColor,
    this.padding,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: minHeight != null ? BoxConstraints(minHeight: minHeight!) : null,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ArriveTheme.glass,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        border: Border.all(color: borderColor ?? ArriveTheme.glassBorder, width: 1),
      ),
      child: child,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final List<Color>? gradientColors;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors ??
                [
                  const Color(0xE07DDE8A),
                  const Color(0xC78DBFAA),
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
            label,
            style: ArriveTheme.dmSans.copyWith(
              color: const Color(0xFF111111),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SecondaryButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: ArriveTheme.glass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ArriveTheme.glassBorder),
        ),
        child: Center(
          child: Text(
            label,
            style: ArriveTheme.dmSans.copyWith(
              color: ArriveTheme.textSoft,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// Animated orbs background
class OrbBackground extends StatefulWidget {
  final Widget child;
  const OrbBackground({super.key, required this.child});

  @override
  State<OrbBackground> createState() => _OrbBackgroundState();
}

class _OrbBackgroundState extends State<OrbBackground>
    with TickerProviderStateMixin {
  late AnimationController _c1, _c2, _c3;
  late Animation<Offset> _a1, _a2, _a3;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat(reverse: true);
    _c2 = AnimationController(vsync: this, duration: const Duration(seconds: 13))
      ..repeat(reverse: true);
    _c3 = AnimationController(vsync: this, duration: const Duration(seconds: 16))
      ..repeat(reverse: true);

    _a1 = Tween<Offset>(begin: Offset.zero, end: const Offset(0.03, -0.04))
        .animate(CurvedAnimation(parent: _c1, curve: Curves.easeInOut));
    _a2 = Tween<Offset>(begin: Offset.zero, end: const Offset(-0.04, 0.03))
        .animate(CurvedAnimation(parent: _c2, curve: Curves.easeInOut));
    _a3 = Tween<Offset>(begin: Offset.zero, end: const Offset(0.02, -0.02))
        .animate(CurvedAnimation(parent: _c3, curve: Curves.easeInOut));
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
    return Stack(
      children: [
        // Orb 1 - top left green
        AnimatedBuilder(
          animation: _a1,
          builder: (_, __) => Positioned(
            top: -100 + (_a1.value.dy * 400),
            left: -80 + (_a1.value.dx * 400),
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ArriveTheme.green.withOpacity(0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        // Orb 2 - bottom right blue
        AnimatedBuilder(
          animation: _a2,
          builder: (_, __) => Positioned(
            bottom: 80 + (_a2.value.dy * 300),
            right: -70 + (_a2.value.dx * 300),
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ArriveTheme.blue.withOpacity(0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        // Orb 3 - lavender mid
        AnimatedBuilder(
          animation: _a3,
          builder: (_, __) => Positioned(
            top: MediaQuery.of(context).size.height * 0.45 + (_a3.value.dy * 220),
            left: 20 + (_a3.value.dx * 220),
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ArriveTheme.lavender.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}
