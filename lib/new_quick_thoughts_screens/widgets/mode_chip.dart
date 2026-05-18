import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/arrive_colors.dart';

class ModeChip extends StatelessWidget {
  final String icon;
  final String title;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const ModeChip({
    super.key,
    required this.icon,
    required this.title,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withOpacity(0.07) : ArriveColors.glass,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? accent : ArriveColors.glassBorder,
                ),
              ),
              child: Column(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: selected ? ArriveColors.text : ArriveColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedOpacity(
                    opacity: selected ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
