import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/arrive_colors.dart';

class ArriveHeader extends StatelessWidget {
  const ArriveHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Container(
          decoration: BoxDecoration(

            border: Border(
              bottom: BorderSide(color: ArriveColors.glassBorder),
            ),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(

                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                decoration: BoxDecoration(

                  border: Border(
                    bottom: BorderSide(color: ArriveColors.glassBorder),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const _ArriveLogo(),
                        const SizedBox(width: 9),
                        Text(
                          'Arrive',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.8,
                            color: ArriveColors.text,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ArriveColors.glass,
                        border: Border.all(color: ArriveColors.glassBorder),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Text('🔔', style: TextStyle(fontSize: 15)),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ArriveColors.green,
                                border: Border.all(
                                  color: ArriveColors.bg,
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArriveLogo extends StatelessWidget {
  const _ArriveLogo();

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

class _ArriveLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ArriveColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final w = size.width;
    final h = size.height;

    final p1 = Path()
      ..moveTo(w * 0.5, h * 0.04)
      ..cubicTo(w * 0.33, h * 0.04, w * 0.2, h * 0.18, w * 0.2, h * 0.33)
      ..cubicTo(w * 0.2, h * 0.43, w * 0.26, h * 0.52, w * 0.35, h * 0.57)
      ..lineTo(w * 0.5, h * 0.65)
      ..lineTo(w * 0.65, h * 0.57)
      ..cubicTo(w * 0.74, h * 0.52, w * 0.8, h * 0.43, w * 0.8, h * 0.33)
      ..cubicTo(w * 0.8, h * 0.18, w * 0.67, h * 0.04, w * 0.5, h * 0.04);

    final p2 = Path()
      ..moveTo(w * 0.2, h * 0.57)
      ..cubicTo(w * 0.08, h * 0.57, w * 0.01, h * 0.65, w * 0.01, h * 0.74)
      ..cubicTo(w * 0.01, h * 0.85, w * 0.09, h * 0.92, w * 0.2, h * 0.92)
      ..cubicTo(w * 0.30, h * 0.92, w * 0.39, h * 0.85, w * 0.41, h * 0.76)
      ..lineTo(w * 0.5, h * 0.65)
      ..lineTo(w * 0.59, h * 0.76)
      ..cubicTo(w * 0.61, h * 0.85, w * 0.70, h * 0.92, w * 0.8, h * 0.92)
      ..cubicTo(w * 0.91, h * 0.92, w * 0.99, h * 0.85, w * 0.99, h * 0.74)
      ..cubicTo(w * 0.99, h * 0.65, w * 0.92, h * 0.57, w * 0.8, h * 0.57)
      ..cubicTo(w * 0.70, h * 0.57, w * 0.61, h * 0.64, w * 0.59, h * 0.73)
      ..lineTo(w * 0.5, h * 0.84)
      ..lineTo(w * 0.41, h * 0.73)
      ..cubicTo(w * 0.39, h * 0.64, w * 0.30, h * 0.57, w * 0.2, h * 0.57);

    final p3 = Path()
      ..moveTo(w * 0.35, h * 0.92)
      ..cubicTo(w * 0.28, h * 0.98, w * 0.28, h * 1.08, w * 0.38, h * 1.11)
      ..lineTo(w * 0.5, h * 1.13)
      ..lineTo(w * 0.62, h * 1.11)
      ..cubicTo(w * 0.72, h * 1.08, w * 0.72, h * 0.98, w * 0.65, h * 0.92);

    canvas.drawPath(p1, paint);
    canvas.drawPath(p2, paint);
    canvas.drawPath(p3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
