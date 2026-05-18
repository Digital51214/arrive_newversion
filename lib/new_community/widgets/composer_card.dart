import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../new_service_screens/session_manager.dart';
import '../theme/arrive_colors.dart';


class ComposerCard extends StatelessWidget {
  final VoidCallback onTap;

  const ComposerCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ArriveColors.glassBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 24, offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: ArriveColors.glass,
              child: Stack(
                children: [
                  // Top gradient line
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.transparent,
                          Color(0x66D4A0B8),
                          Color(0x4D90B8E0),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                                  colors: [Color(0x40D4A0B8), Color(0x3390B8E0)],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: ArriveColors.glassBorder),
                              ),
                              child: const Center(child: Text('🌸', style: TextStyle(fontSize: 14))),
                            ),
                            const SizedBox(width: 11),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Dynamically load the first name from the session
                                FutureBuilder<String>(
                                  future: SessionManager.getFirstName(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator(); // Show loading while fetching
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        'Error: ${snapshot.error}',
                                        style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: ArriveColors.text),
                                      );
                                    } else if (snapshot.hasData) {
                                      return Text(
                                        snapshot.data ?? 'User', // Display the first name if available
                                        style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: ArriveColors.text),
                                      );
                                    } else {
                                      return Text(
                                        'User', // Fallback if no data
                                        style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: ArriveColors.text),
                                      );
                                    }
                                  },
                                ),
                                Text(
                                  "What's on your heart today...",
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 15, fontStyle: FontStyle.italic, color: ArriveColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: const [
                            _Chip('💭 Thought'),
                            _Chip('🤝 Need Support'),
                            _Chip('✨ Share a Win'),
                            _Chip('🤍 Anonymous'),
                          ],
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
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: ArriveColors.glass,
            border: Border.all(color: ArriveColors.glassBorder),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: ArriveColors.textMuted),
          ),
        ),
      ),
    );
  }
}