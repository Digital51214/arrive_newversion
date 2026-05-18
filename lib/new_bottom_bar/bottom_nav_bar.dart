import 'package:arrive_newversion/new_home_screens/concept_b.dart';
import 'package:flutter/material.dart';

import '../new_AI_feedback/screens/screen_write.dart';
import '../new_community/screens/community_main_screen.dart';
import '../new_onboarding_screens/screens/profile_screen.dart';
import '../new_quick_thoughts_screens/screens/arrive_compose_screen.dart';

class SimpleBottomBar extends StatelessWidget {
  final int currentIndex;

  const SimpleBottomBar({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget screen;

    switch (index) {
      case 0:
        screen = const ConceptBScreen();
        break;

      case 1:
        screen = const WriteScreen();
        break;

      case 2:
        screen = const ArriveComposeScreen();
        break;

      case 3:
        screen = const CommunityMainScreen();
        break;

      case 4:
        screen = const ProfileScreen();
        break;

      default:
        screen = const ConceptBScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF252D42),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 45),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(context, 0, "🏠", "Home"),
          _item(context, 1, "📖", "Journal"),

          /// CENTER CLICKABLE ITEM
          _arriveItem(context, 2),

          _item(context, 3, "🌸", "Community"),
          _item(context, 4, "🤵🏼", "Profile"),
        ],
      ),
    );
  }

  Widget _item(
      BuildContext context,
      int index,
      String icon,
      String label,
      ) {
    final bool isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _navigate(context, index),
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: isSelected ? 1.0 : 0.35,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 20),
              ),

              const SizedBox(height: 4),

              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF7DDE8A)
                      : const Color(0xFFA6F0EBE4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _arriveItem(BuildContext context, int index) {
    final bool isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _navigate(context, index),
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: isSelected ? 1.0 : 0.55,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ArriveLogoWidget(),

              SizedBox(height: 7),

              Text(
                'Arrive',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8DBFAA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArriveLogoWidget extends StatelessWidget {
  const _ArriveLogoWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 22),
      painter: _ArriveLogoPainter(),
    );
  }
}

class _ArriveLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7DDE8A)
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}