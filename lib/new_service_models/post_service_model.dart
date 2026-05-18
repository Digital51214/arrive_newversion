import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../new_community/theme/arrive_colors.dart';


class PostComposerModal {
  static void show(
      BuildContext context, {
        required Function({
        required String content,
        required String type,
        required bool isAnonymous,
        }) onSubmit,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PostComposerSheet(onSubmit: onSubmit),
    );
  }
}

class _PostComposerSheet extends StatefulWidget {
  final Function({
  required String content,
  required String type,
  required bool isAnonymous,
  }) onSubmit;

  const _PostComposerSheet({
    required this.onSubmit,
  });

  @override
  State<_PostComposerSheet> createState() => _PostComposerSheetState();
}

class _PostComposerSheetState extends State<_PostComposerSheet> {
  final TextEditingController _controller = TextEditingController();

  String _selectedType = 'thought';
  bool _isAnonymous = false;

  final List<Map<String, String>> _types = [
    {'label': '💭 Thought', 'value': 'thought'},
    {'label': '🤝 Support', 'value': 'support'},
    {'label': '✨ Win', 'value': 'win'},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitPost() {
    final content = _controller.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first')),
      );
      return;
    }

    print('COMPOSER SUBMIT CLICKED');
    print('CONTENT: $content');
    print('TYPE: $_selectedType');
    print('IS ANONYMOUS: $_isAnonymous');

    Navigator.pop(context);

    widget.onSubmit(
      content: content,
      type: _selectedType,
      isAnonymous: _isAnonymous,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            decoration: BoxDecoration(
              color: ArriveColors.bg.withOpacity(0.96),
              border: Border(
                top: BorderSide(color: ArriveColors.glassBorder),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ArriveColors.textMuted.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  'Share something',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: ArriveColors.text,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Write freely. You can post anonymously too.',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: ArriveColors.textSoft,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: _controller,
                  maxLines: 5,
                  minLines: 4,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: ArriveColors.text,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What’s on your mind?',
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: ArriveColors.textMuted,
                    ),
                    filled: true,
                    fillColor: ArriveColors.glass,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: ArriveColors.glassBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: ArriveColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: ArriveColors.green),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _types.map((item) {
                    final isSelected = _selectedType == item['value'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = item['value']!;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ArriveColors.green.withOpacity(0.15)
                              : ArriveColors.glass,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? ArriveColors.green
                                : ArriveColors.glassBorder,
                          ),
                        ),
                        child: Text(
                          item['label']!,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? ArriveColors.green
                                : ArriveColors.textMuted,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isAnonymous = !_isAnonymous;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ArriveColors.glass,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ArriveColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isAnonymous
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 22,
                          color: _isAnonymous
                              ? ArriveColors.green
                              : ArriveColors.textMuted,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Post anonymously',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ArriveColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _submitPost,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: ArriveColors.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Post',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111111),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}