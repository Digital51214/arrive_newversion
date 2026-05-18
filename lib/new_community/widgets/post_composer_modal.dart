import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/arrive_colors.dart';

class PostComposerModal {
  static Future<void> show(
      BuildContext context, {
        required Future<void> Function({
        required String content,
        required String type,
        required bool isAnonymous,
        }) onSubmit,
      }) async {
    final TextEditingController contentController = TextEditingController();

    String selectedType = 'thought';
    bool isAnonymous = false;
    bool isSubmitting = false;

    Future<void> submitPost({
      required BuildContext sheetContext,
      required void Function(void Function()) setSheetState,
    }) async {
      if (isSubmitting) {
        print('COMPOSER SUBMIT SKIPPED: Already submitting');
        return;
      }

      final String content = contentController.text.trim();

      if (content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please write something first'),
          ),
        );
        return;
      }

      final String finalType = isAnonymous ? 'anonymous' : selectedType;

      print('========== COMPOSER SUBMIT START ==========');
      print('CONTENT       : $content');
      print('SELECTED TYPE : $selectedType');
      print('IS ANONYMOUS  : $isAnonymous');
      print('FINAL TYPE    : $finalType');
      print('==========================================');

      setSheetState(() {
        isSubmitting = true;
      });

      try {
        await onSubmit(
          content: content,
          type: finalType,
          isAnonymous: isAnonymous,
        );

        if (Navigator.of(sheetContext).canPop()) {
          Navigator.of(sheetContext).pop();
        }

        print('COMPOSER SUBMIT SUCCESS');
      } catch (e) {
        print('COMPOSER SUBMIT ERROR: $e');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().replaceAll('Exception: ', ''),
              ),
            ),
          );
        }
      } finally {
        try {
          setSheetState(() {
            isSubmitting = false;
          });
        } catch (e) {
          print('COMPOSER SET STATE AFTER CLOSE SKIPPED: $e');
        }
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            // ── FIX 1: keyboard open hone par overflow na ho ──
            final double bottomInset =
                MediaQuery.of(sheetContext).viewInsets.bottom;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 14,
                  right: 14,
                  bottom: bottomInset + 14,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 22,
                      sigmaY: 22,
                    ),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2422).withOpacity(0.96),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: ArriveColors.glassBorder,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.38),
                            blurRadius: 32,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: AbsorbPointer(
                        absorbing: isSubmitting,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: isSubmitting ? 0.72 : 1,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 44,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: ArriveColors.glassBorder,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          ArriveColors.pink.withOpacity(0.35),
                                          ArriveColors.pink.withOpacity(0.08),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(
                                        color: ArriveColors.pink.withOpacity(0.35),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '🌿',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 11),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Share with community',
                                          style: GoogleFonts.cormorantGaramond(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w400,
                                            color: ArriveColors.text,
                                            height: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Write something honest, soft, or supportive.',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w300,
                                            color: ArriveColors.textMuted,
                                            height: 1.45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: isSubmitting
                                        ? null
                                        : () {
                                      print('COMPOSER CLOSE TAPPED');

                                      if (Navigator.of(sheetContext)
                                          .canPop()) {
                                        Navigator.of(sheetContext).pop();
                                      }
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.18),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: ArriveColors.glassBorder,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: ArriveColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: ArriveColors.glassBorder,
                                  ),
                                ),
                                child: TextField(
                                  controller: contentController,
                                  minLines: 5,
                                  maxLines: 8,
                                  cursorColor: ArriveColors.pink,
                                  textInputAction: TextInputAction.newline,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13.5,
                                    color: ArriveColors.text,
                                    height: 1.55,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'What would you like to share?',
                                    hintStyle: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: ArriveColors.textMuted,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              Text(
                                'Choose post type',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: ArriveColors.textSoft,
                                  letterSpacing: 0.4,
                                ),
                              ),

                              const SizedBox(height: 9),

                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 180),
                                opacity: isAnonymous ? 0.35 : 1.0,
                                child: IgnorePointer(
                                  ignoring: isAnonymous,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _typeButton(
                                          label: '💭 Thought',
                                          value: 'thought',
                                          selectedType: selectedType,
                                          isDisabled: isAnonymous,
                                          onTap: () {
                                            setSheetState(() {
                                              selectedType = 'thought';
                                            });

                                            print(
                                              'COMPOSER TYPE SELECTED: thought',
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _typeButton(
                                          label: '🤝 Support',
                                          value: 'need_support',
                                          selectedType: selectedType,
                                          isDisabled: isAnonymous,
                                          onTap: () {
                                            setSheetState(() {
                                              selectedType = 'need_support';
                                            });

                                            print(
                                              'COMPOSER TYPE SELECTED: need_support',
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _typeButton(
                                          label: '✨ Win',
                                          value: 'share_win',
                                          selectedType: selectedType,
                                          isDisabled: isAnonymous,
                                          onTap: () {
                                            setSheetState(() {
                                              selectedType = 'share_win';
                                            });

                                            print(
                                              'COMPOSER TYPE SELECTED: share_win',
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              if (isAnonymous) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Anonymous mode is on. This post will be saved under Anonymous.',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w300,
                                    color: ArriveColors.textMuted,
                                    height: 1.4,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 14),

                              GestureDetector(
                                onTap: isSubmitting
                                    ? null
                                    : () {
                                  setSheetState(() {
                                    isAnonymous = !isAnonymous;

                                    if (isAnonymous) {
                                      selectedType = 'anonymous';
                                    } else {
                                      selectedType = 'thought';
                                    }
                                  });

                                  print(
                                    'COMPOSER ANONYMOUS TOGGLED: $isAnonymous',
                                  );
                                  print(
                                    'COMPOSER TYPE NOW: $selectedType',
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAnonymous
                                        ? ArriveColors.pink.withOpacity(0.12)
                                        : Colors.black.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isAnonymous
                                          ? ArriveColors.pink.withOpacity(0.5)
                                          : ArriveColors.glassBorder,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                        const Duration(milliseconds: 200),
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isAnonymous
                                              ? ArriveColors.pink.withOpacity(0.9)
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isAnonymous
                                                ? ArriveColors.pink
                                                : ArriveColors.textMuted
                                                .withOpacity(0.45),
                                          ),
                                        ),
                                        child: isAnonymous
                                            ? const Icon(
                                          Icons.check_rounded,
                                          size: 15,
                                          color: Colors.white,
                                        )
                                            : null,
                                      ),

                                      const SizedBox(width: 10),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Post anonymously',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: ArriveColors.text,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              isAnonymous
                                                  ? 'Your name will stay hidden and this will appear under Anonymous.'
                                                  : 'Your name will be visible on this post.',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w300,
                                                color: ArriveColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Text(
                                        isAnonymous ? '🤍' : '🌷',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: isSubmitting
                                          ? null
                                          : () {
                                        print('COMPOSER CANCEL TAPPED');

                                        if (Navigator.of(sheetContext)
                                            .canPop()) {
                                          Navigator.of(sheetContext).pop();
                                        }
                                      },
                                      child: Container(
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.16),
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: ArriveColors.glassBorder,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: ArriveColors.textMuted,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      onTap: isSubmitting
                                          ? null
                                          : () => submitPost(
                                        sheetContext: sheetContext,
                                        setSheetState: setSheetState,
                                      ),
                                      child: Container(
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              ArriveColors.pink.withOpacity(0.95),
                                              ArriveColors.pink.withOpacity(0.68),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: ArriveColors.pink
                                                .withOpacity(0.65),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: ArriveColors.pink
                                                  .withOpacity(0.22),
                                              blurRadius: 18,
                                              offset: const Offset(0, 7),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: isSubmitting
                                              ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const SizedBox(
                                                width: 17,
                                                height: 17,
                                                child:
                                                CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Posting...',
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 13.5,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          )
                                              : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.send_rounded,
                                                size: 17,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 7),
                                              Text(
                                                isAnonymous
                                                    ? 'Post Anonymously'
                                                    : 'Share Post',
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 13.5,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 300), () {
        try {
          contentController.dispose();
          print('COMPOSER CONTROLLER DISPOSED SAFELY');
        } catch (e) {
          print('COMPOSER CONTROLLER DISPOSE ERROR SKIPPED: $e');
        }
      });

      print('COMPOSER SHEET CLOSED');
    });
  }

  static Widget _typeButton({
    required String label,
    required String value,
    required String selectedType,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    final bool isSelected = selectedType == value && !isDisabled;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ArriveColors.pink.withOpacity(0.14)
              : Colors.black.withOpacity(0.16),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? ArriveColors.pink.withOpacity(0.55)
                : ArriveColors.glassBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isDisabled
                  ? ArriveColors.textMuted.withOpacity(0.75)
                  : isSelected
                  ? ArriveColors.pink
                  : ArriveColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}