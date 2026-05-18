import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/arrive_colors.dart';
import '../widgets/arrive_background.dart';
import '../widgets/arrive_header.dart';
import 'arrive_compose_screen.dart';

class ArriveResponseScreen extends StatelessWidget {
  const ArriveResponseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final followups = [
      'What feels heaviest about this?',
      'What do you need most right now?',
      'What would being kinder look like?',
    ];

    return ArriveBackground(
      child: SafeArea(
        child: Column(
          children: [
            const ArriveHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ArriveColors.glass,
                                  border: Border.all(
                                    color: const Color.fromRGBO(184, 168, 216, 0.35),
                                  ),
                                ),
                                child: const Center(
                                  child: Text('🧘', style: TextStyle(fontSize: 18)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Therapist',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: ArriveColors.lavender,
                                      ),
                                    ),
                                    Text(
                                      'Heard your thought',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        color: ArriveColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: ArriveColors.glass,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: ArriveColors.glassBorder,
                                  ),
                                ),
                                child: Text(
                                  '"Today was harder than I expected because I kept pretending I was okay when I really wasn\'t…"',
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 15,
                                    height: 1.5,
                                    fontStyle: FontStyle.italic,
                                    color: ArriveColors.textSoft,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                            decoration: BoxDecoration(
                              color: ArriveColors.glass,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: ArriveColors.glassBorder),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.2),
                                  blurRadius: 32,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Text(
                              'That sounds exhausting, especially when part of your energy is going into holding yourself together for everyone else. Sometimes the hardest part is not just the day itself, but feeling like you have to carry it quietly. You do not have to make perfect sense of it right away; even noticing that you were not really okay is already something honest and important. Maybe the gentlest next step is asking what part of today hurt the most.',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                height: 1.85,
                                fontWeight: FontWeight.w300,
                                color: ArriveColors.textSoft,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
                      child: Text(
                        'Keep going if you want…',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w500,
                          color: ArriveColors.textMuted,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: followups
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 13,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ArriveColors.glass,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: ArriveColors.glassBorder,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 13,
                                                height: 1.4,
                                                color: ArriveColors.textSoft,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '→',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 14,
                                              color: ArriveColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: const [
                          Expanded(
                            child: _ActionButton(
                              text: '📖 Save to Journal',
                              isPrimary: true,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _ActionButton(
                              text: '🔄 Switch Mode',
                              isPrimary: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: _NewThoughtButton(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final bool isPrimary;

  const _ActionButton({required this.text, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPrimary
                  ? const Color.fromRGBO(125, 222, 138, 0.35)
                  : ArriveColors.glassBorder,
            ),
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [
                      Color.fromRGBO(125, 222, 138, 0.20),
                      Color.fromRGBO(141, 191, 170, 0.15),
                    ],
                  )
                : null,
            color: isPrimary ? null : ArriveColors.glass,
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isPrimary ? ArriveColors.green : ArriveColors.textSoft,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NewThoughtButton extends StatelessWidget {
  const _NewThoughtButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ArriveComposeScreen(),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: ArriveColors.glass,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ArriveColors.glassBorder),
            ),
            child: Center(
              child: Text(
                '+ New Thought',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ArriveColors.textSoft,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
