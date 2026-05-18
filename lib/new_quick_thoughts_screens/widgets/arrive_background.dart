import 'dart:ui';
import 'package:flutter/material.dart';
import '../../new_bottom_bar/bottom_nav_bar.dart';
import '../theme/arrive_colors.dart';

class ArriveBackground extends StatelessWidget {
  final Widget child;

  const ArriveBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SimpleBottomBar(currentIndex: 2),
      backgroundColor: ArriveColors.pageBg,
      body: Center(
        child: Container(
          width: 390,
          color: ArriveColors.bg,
          child: Stack(
            children: [
              const _BlurOrb(
                size: 300,
                top: -80,
                left: -70,
                color: Color.fromRGBO(184, 168, 216, 0.22),
              ),
              const _BlurOrb(
                size: 260,
                bottom: 100,
                right: -60,
                color: Color.fromRGBO(120, 165, 220, 0.20),
              ),
              const _BlurOrb(
                size: 200,
                top: 320,
                left: 18,
                color: Color.fromRGBO(212, 160, 184, 0.16),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  final double size;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final Color color;

  const _BlurOrb({
    required this.size,
    required this.color,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
