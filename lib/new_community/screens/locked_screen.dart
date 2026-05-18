import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/arrive_colors.dart';

class LockedScreen extends StatelessWidget {
  final VoidCallback onActivate;
  final VoidCallback onActivateSpeakFreely;
  final bool canActivatePostpartum;
  final VoidCallback onBlockedPostpartumTap;

  const LockedScreen({
    super.key,
    required this.onActivate,
    required this.onActivateSpeakFreely,
    required this.canActivatePostpartum,
    required this.onBlockedPostpartumTap,
  });

  @override
  Widget build(BuildContext context) {
    final postpartumOpacity = canActivatePostpartum ? 1.0 : 0.45;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 50),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: ArriveColors.glass,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: ArriveColors.glassBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'A safe space,\njust for you',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: ArriveColors.text,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Choose the space that feels right for you today.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: ArriveColors.textSoft,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Postpartum Mode Activation Button
                  Opacity(
                    opacity: postpartumOpacity,
                    child: GestureDetector(
                      onTap: canActivatePostpartum
                          ? onActivate
                          : onBlockedPostpartumTap,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: ArriveColors.primaryBtn,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: canActivatePostpartum
                              ? [
                            BoxShadow(
                              color: ArriveColors.pink.withOpacity(0.28),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ]
                              : [],
                        ),
                        child: Text(
                          'Activate Postpartum Mode',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  // Speak Freely Mode Activation Button
                  GestureDetector(
                    onTap: onActivateSpeakFreely,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        gradient: ArriveColors.speakFreelyBtn,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: ArriveColors.speakBlue.withOpacity(0.28),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Activate Speak Freely Mode',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Additional Info Text
                  Text(
                    '🔒 Name only · Anonymous option · Always private',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: ArriveColors.textMuted,
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