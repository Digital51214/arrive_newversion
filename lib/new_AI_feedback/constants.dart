import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colors ──
const Color kBg = Color(0xFF252D42);
const Color kBgDark = Color(0xFF232A3D);
const Color kGreen = Color(0xFF7DDE8A);
const Color kLavender = Color(0xFFB8A8D8);
const Color kBlue = Color(0xFF90B8E0);
const Color kPink = Color(0xFFD4A0B8);
const Color kGold = Color(0xFFD4B896);
const Color kSage = Color(0xFF8DBFAA);

const Color kText = Color(0xFFFFFAF5);
const Color kTextSoft = Color(0xD9F0EBE4);
const Color kTextMuted = Color(0xA6F0EBE4);

const Color kGlass = Color(0x1EFFFFFF);
const Color kGlassHover = Color(0x2EFFFFFF);
const Color kGlassBorder = Color(0x38FFFFFF);

// ── Text Styles ──
TextStyle cormorant({
  double size = 20,
  FontWeight weight = FontWeight.w300,
  Color color = kText,
  FontStyle style = FontStyle.normal,
}) =>
    GoogleFonts.cormorantGaramond(
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontStyle: style,
    );

TextStyle dmSans({
  double size = 14,
  FontWeight weight = FontWeight.w300,
  Color color = kText,
}) =>
    GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );

// ── Decoration helpers ──
BoxDecoration glassBox({
  double radius = 20,
  Color borderColor = kGlassBorder,
  Color bgColor = kGlass,
}) =>
    BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1),
    );

// ── Eyebrow label ──
Widget eyebrow(String text, Color color, {bool dot = false}) {
  return Row(
    children: [
      if (dot)
        Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      Text(
        text.toUpperCase(),
        style: dmSans(size: 10, weight: FontWeight.w500, color: color)
            .copyWith(letterSpacing: 1.2),
      ),
    ],
  );
}

// ── Glass card wrapper ──
Widget glassCard({
  required Widget child,
  EdgeInsets padding = const EdgeInsets.all(18),
  double radius = 20,
  Color? topLineColor,
}) {
  return Container(
    decoration: glassBox(radius: radius),
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
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  topLineColor,
                  Colors.transparent,
                ]),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(radius)),
              ),
            ),
          ),
        Padding(padding: padding, child: child),
      ],
    ),
  );
}

// ── Gradient button ──
Widget gradientButton({
  required String label,
  required VoidCallback onTap,
  List<Color> colors = const [Color(0xD97DDE8A), Color(0xB28DBFAA)],
  Color textColor = const Color(0xFF111111),
  double radius = 14,
  Widget? prefix,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefix != null) ...[prefix, const SizedBox(width: 9)],
          Text(label,
              style: dmSans(size: 15, weight: FontWeight.w600, color: textColor)),
        ],
      ),
    ),
  );
}

// ── Bottom nav ──
class ArriveBottomNav extends StatelessWidget {
  const ArriveBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBg.withOpacity(0.9),
        border: Border(top: BorderSide(color: kGlassBorder, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 16),
      child: Row(
        children: [
          _navItem('🏠', 'Home', false),
          _navItem('📖', 'Journal', true),
          _navItemArrive(),
          _navItem('🌸', 'Community', false),
          _navItem('👤', 'Me', false),
        ],
      ),
    );
  }

  Widget _navItem(String icon, String label, bool active) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label,
              style: dmSans(
                  size: 10,
                  weight: FontWeight.w500,
                  color: active ? kGreen : kTextMuted)),
        ],
      ),
    );
  }

  Widget _navItemArrive() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(painter: _ArriveLogo(), size: const Size(20, 22)),
          const SizedBox(height: 4),
          Text('Arrive',
              style: dmSans(size: 10, weight: FontWeight.w500, color: kSage)),
        ],
      ),
    );
  }
}

class _ArriveLogo extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final sx = size.width / 100;
    final sy = size.height / 115;

    final top = Path()
      ..moveTo(50 * sx, 4 * sy)
      ..cubicTo(33 * sx, 4 * sy, 20 * sx, 17 * sy, 20 * sx, 33 * sy)
      ..cubicTo(20 * sx, 43 * sy, 26 * sx, 52 * sy, 35 * sx, 57 * sy)
      ..lineTo(50 * sx, 65 * sy)
      ..lineTo(65 * sx, 57 * sy)
      ..cubicTo(74 * sx, 52 * sy, 80 * sx, 43 * sy, 80 * sx, 33 * sy)
      ..cubicTo(80 * sx, 17 * sy, 67 * sx, 4 * sy, 50 * sx, 4 * sy);
    canvas.drawPath(top, paint);

    final mid = Path()
      ..moveTo(20 * sx, 57 * sy)
      ..cubicTo(8 * sx, 57 * sy, 1 * sx, 65 * sy, 1 * sx, 74 * sy)
      ..cubicTo(1 * sx, 85 * sy, 9 * sx, 92 * sy, 20 * sx, 92 * sy)
      ..cubicTo(30 * sx, 92 * sy, 39 * sx, 85 * sy, 41 * sx, 76 * sy)
      ..lineTo(50 * sx, 65 * sy)
      ..lineTo(59 * sx, 76 * sy)
      ..cubicTo(61 * sx, 85 * sy, 70 * sx, 92 * sy, 80 * sx, 92 * sy)
      ..cubicTo(91 * sx, 92 * sy, 99 * sx, 85 * sy, 99 * sx, 74 * sy)
      ..cubicTo(99 * sx, 65 * sy, 92 * sx, 57 * sy, 80 * sx, 57 * sy)
      ..cubicTo(70 * sx, 57 * sy, 61 * sx, 64 * sy, 59 * sx, 73 * sy)
      ..lineTo(50 * sx, 84 * sy)
      ..lineTo(41 * sx, 73 * sy)
      ..cubicTo(39 * sx, 64 * sy, 30 * sx, 57 * sy, 20 * sx, 57 * sy);
    canvas.drawPath(mid, paint);

    final bot = Path()
      ..moveTo(35 * sx, 92 * sy)
      ..cubicTo(28 * sx, 98 * sy, 28 * sx, 108 * sy, 38 * sx, 111 * sy)
      ..lineTo(50 * sx, 113 * sy)
      ..lineTo(62 * sx, 111 * sy)
      ..cubicTo(72 * sx, 108 * sy, 72 * sx, 98 * sy, 65 * sx, 92 * sy);
    canvas.drawPath(bot, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── App Header ──
class ArriveHeader extends StatelessWidget {
  final VoidCallback? onBack;
  const ArriveHeader({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: kBg.withOpacity(0.7),
        border: Border(bottom: BorderSide(color: kGlassBorder, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            CustomPaint(painter: _ArriveLogo(), size: const Size(22, 24)),
            const SizedBox(width: 9),
            Text('Arrive', style: cormorant(size: 21)),
          ]),
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: glassBox(radius: 10),
                child: Text('← Journal',
                    style: dmSans(size: 13, color: kTextSoft)),
              ),
            ),
        ],
      ),
    );
  }
}
