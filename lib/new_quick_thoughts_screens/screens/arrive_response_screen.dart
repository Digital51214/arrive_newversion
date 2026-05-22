import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../new_AI_feedback/screens/screen_write.dart';
import '../../new_service_screens/quick_thoughts_service.dart';
import '../theme/arrive_colors.dart';
import '../widgets/arrive_background.dart';
import '../widgets/arrive_header.dart';

import 'arrive_compose_screen.dart';


class ArriveResponseScreen extends StatefulWidget {
  final String thought;
  final String mode;
  final QuickThoughtResponse response;

  const ArriveResponseScreen({
    super.key,
    required this.thought,
    required this.mode,
    required this.response,
  });

  @override
  State<ArriveResponseScreen> createState() => _ArriveResponseScreenState();
}

class _ArriveResponseScreenState extends State<ArriveResponseScreen> {
  final Map<int, bool> _expandedQuestions = {};

  // Hard-coded question labels — exactly like original design
  static const List<String> _questionLabels = [
    'What feels heaviest about this?',
    'What do you need most right now?',
    'What would being kinder look like?',
  ];

  String get _modeIcon {
    switch (widget.mode) {
      case 'Friend':
        return '🤝';
      case 'Coach':
        return '⚡';
      default:
        return '🧘';
    }
  }

  void _switchMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArriveComposeScreen(
          preservedThought: widget.thought,
          preservedMode: widget.mode,
        ),
      ),
    );
  }

  void _newThought() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ArriveComposeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Answers from API response — already available, no extra call needed
    final answers = [
      widget.response.q1,
      widget.response.q2,
      widget.response.q3,
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
                    // Header + user thought bubble
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
                                child: Center(
                                  child: Text(
                                    _modeIcon,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.mode,
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
                                  '"${widget.thought}"',
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

                    // Main response paragraph
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
                              widget.response.paragraph,
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

                    // Follow-up label
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

                    // Expandable follow-up questions with inline answers
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: List.generate(_questionLabels.length, (index) {
                          final question = _questionLabels[index];
                          final answer = answers[index];
                          final isExpanded = _expandedQuestions[index] ?? false;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _expandedQuestions[index] = !isExpanded;
                                });
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: isExpanded
                                          ? const Color.fromRGBO(184, 168, 216, 0.10)
                                          : ArriveColors.glass,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isExpanded
                                            ? const Color.fromRGBO(184, 168, 216, 0.40)
                                            : ArriveColors.glassBorder,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Question row (always visible)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 13,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  question,
                                                  style: GoogleFonts.dmSans(
                                                    fontSize: 13,
                                                    height: 1.4,
                                                    color: isExpanded
                                                        ? ArriveColors.lavender
                                                        : ArriveColors.textSoft,
                                                    fontWeight: isExpanded
                                                        ? FontWeight.w500
                                                        : FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              AnimatedRotation(
                                                turns: isExpanded ? 0.25 : 0,
                                                duration: const Duration(milliseconds: 300),
                                                child: Text(
                                                  '→',
                                                  style: GoogleFonts.dmSans(
                                                    fontSize: 14,
                                                    color: isExpanded
                                                        ? ArriveColors.lavender
                                                        : ArriveColors.textMuted,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Answer — expands below the question
                                        AnimatedCrossFade(
                                          duration: const Duration(milliseconds: 300),
                                          crossFadeState: isExpanded
                                              ? CrossFadeState.showFirst
                                              : CrossFadeState.showSecond,
                                          firstChild: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                                child: Container(
                                                  height: 1,
                                                  color: const Color.fromRGBO(184, 168, 216, 0.20),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                                                child: Text(
                                                  answer,
                                                  style: GoogleFonts.dmSans(
                                                    fontSize: 13,
                                                    height: 1.75,
                                                    fontWeight: FontWeight.w300,
                                                    color: ArriveColors.textSoft,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          secondChild: const SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              text: '📖 Save to Journal',
                              isPrimary: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WriteScreen(
                                      initialBody: widget.thought,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ActionButton(
                              text: '🔄 Switch Mode',
                              isPrimary: false,
                              onTap: _switchMode,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: _NewThoughtButton(onTap: _newThought),
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
  final VoidCallback? onTap;

  const _ActionButton({
    required this.text,
    required this.isPrimary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
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
      ),
    );
  }
}

class _NewThoughtButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NewThoughtButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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