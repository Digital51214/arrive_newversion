import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/arrive_colors.dart';
import '../widgets/arrive_background.dart';
import '../widgets/arrive_header.dart';
import '../widgets/mode_chip.dart';
import 'arrive_loading_screen.dart';

class ArriveComposeScreen extends StatefulWidget {
  /// Optional: when coming from "Switch Mode", preserve the existing thought text
  final String? preservedThought;

  /// Optional: when coming from "Switch Mode", pre-select current mode
  final String? preservedMode;

  const ArriveComposeScreen({
    super.key,
    this.preservedThought,
    this.preservedMode,
  });

  @override
  State<ArriveComposeScreen> createState() => _ArriveComposeScreenState();
}

class _ArriveComposeScreenState extends State<ArriveComposeScreen> {
  late final TextEditingController controller;
  String? selectedMode;

  /// True when this screen was opened via "Switch Mode" (has preserved content)
  bool get isSwitchModeFlow => widget.preservedThought != null;

  final starters = const [
    "I've been carrying something I haven't said out loud yet…",
    'Today was harder than I expected because…',
    "I'm proud of myself for something small today…",
    'Something I keep avoiding thinking about is…',
    'Right now I just need someone to tell me…',
  ];

  int get wordCount => controller.text.trim().isEmpty
      ? 0
      : controller.text.trim().split(RegExp(r'\s+')).length;

  bool get isReady => controller.text.trim().isNotEmpty && selectedMode != null;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.preservedThought ?? '');
    // Pre-select mode only if switching — user should pick a *different* mode
    // We don't pre-select so they're forced to actively choose
    selectedMode = null;

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _goToLoadingScreen() {
    if (!isReady) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArriveLoadingScreen(
          thought: controller.text.trim(),
          mode: selectedMode!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ArriveColors.lavender,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                isSwitchModeFlow ? 'Switch Mode' : 'Quick Thought',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w500,
                                  textStyle: const TextStyle(
                                    color: ArriveColors.lavender,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isSwitchModeFlow
                                ? "Same thought,\ndifferent lens"
                                : "What's on\nyour mind?",
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 28,
                              height: 1.25,
                              fontWeight: FontWeight.w300,
                              color: ArriveColors.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isSwitchModeFlow
                                ? 'Your thought is kept. Pick a new mode and send again.'
                                : 'No entry needed. Just say it — pick how you want to be heard.',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              height: 1.6,
                              fontWeight: FontWeight.w300,
                              color: ArriveColors.textSoft,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          ModeChip(
                            icon: '🤝',
                            title: 'Friend',
                            accent: const Color.fromRGBO(212, 184, 150, 0.7),
                            selected: selectedMode == 'Friend',
                            onTap: () {
                              setState(() {
                                selectedMode = 'Friend';
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          ModeChip(
                            icon: '🧘',
                            title: 'Therapist',
                            accent: const Color.fromRGBO(184, 168, 216, 0.7),
                            selected: selectedMode == 'Therapist',
                            onTap: () {
                              setState(() {
                                selectedMode = 'Therapist';
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          ModeChip(
                            icon: '⚡',
                            title: 'Coach',
                            accent: const Color.fromRGBO(144, 184, 224, 0.7),
                            selected: selectedMode == 'Coach',
                            onTap: () {
                              setState(() {
                                selectedMode = 'Coach';
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: ArriveColors.glass,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: ArriveColors.glassBorder),
                            ),
                            child: TextField(
                              controller: controller,
                              maxLines: null,
                              minLines: 8,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                height: 1.8,
                                fontWeight: FontWeight.w300,
                                color: ArriveColors.text,
                              ),
                              cursorColor: ArriveColors.lavender,
                              decoration: InputDecoration(
                                hintText: "Just say what's on your mind…",
                                hintStyle: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: ArriveColors.textMuted,
                                  fontWeight: FontWeight.w300,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$wordCount ${wordCount == 1 ? 'word' : 'words'}',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: ArriveColors.textMuted,
                            ),
                          ),
                          Text(
                            'No title. No saving. Just you.',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: ArriveColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: isReady ? _goToLoadingScreen : null,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        child: Opacity(
                          opacity: isReady ? 1 : 0.4,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromRGBO(184, 168, 216, 0.85),
                                  Color.fromRGBO(144, 184, 224, 0.75),
                                ],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(184, 168, 216, 0.28),
                                  blurRadius: 20,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Send →',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (controller.text.trim().isNotEmpty && selectedMode == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Center(
                          child: Text(
                            'Pick a mode above to continue',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: ArriveColors.textMuted,
                            ),
                          ),
                        ),
                      ),

                    // Only show starter prompts for fresh compose (not switch mode flow)
                    if (!isSwitchModeFlow) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
                        child: Text(
                          'Not sure where to start?',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w500,
                            color: ArriveColors.textMuted,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: starters
                              .map(
                                (text) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () {
                                  controller.text = text;
                                  controller.selection =
                                      TextSelection.fromPosition(
                                        TextPosition(
                                            offset: controller.text.length),
                                      );
                                  setState(() {});
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 16, sigmaY: 16),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 13,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ArriveColors.glass,
                                        borderRadius:
                                        BorderRadius.circular(14),
                                        border: Border.all(
                                          color: ArriveColors.glassBorder,
                                        ),
                                      ),
                                      child: Text(
                                        '"$text"',
                                        style:
                                        GoogleFonts.cormorantGaramond(
                                          fontSize: 15,
                                          height: 1.4,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w400,
                                          color: ArriveColors.textSoft,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                              .toList(),
                        ),
                      ),
                    ],
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