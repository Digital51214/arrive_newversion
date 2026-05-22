import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../../new_bottom_bar/bottom_nav_bar.dart';
import '../../new_service_screens/daily_propmt_service.dart';
import '../../new_service_screens/journal_add_service.dart';
import '../../new_service_screens/session_manager.dart';

import '../constants.dart';
import 'screen_saved.dart';

class WriteScreen extends StatefulWidget {
  /// Optional: pre-fill the body text (e.g. coming from Quick Thought / Arrive)
  final String? initialBody;

  const WriteScreen({super.key, this.initialBody});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  late final TextEditingController _bodyController;
  final _emojiController = TextEditingController(text: '😊');

  bool _promptMode = true;
  bool _isSaving = false;

  String? _todayPrompt;
  bool _isPromptLoading = true;

  int _wordCount = 0;

  final List<XFile> _photos = [];
  final ImagePicker _picker = ImagePicker();

  late AnimationController _blinkController;
  late Animation<double> _blinkAnim;

  final String _fallbackPrompt =
      'What is one thing you\'re carrying today that you haven\'t said out loud yet?';

  final List<Map<String, dynamic>> _tags = [
    {'label': '😌 Calm', 'sel': false},
    {'label': '💭 Reflective', 'sel': false},
    {'label': '😟 Anxious', 'sel': false},
    {'label': '💪 Hopeful', 'sel': false},
    {'label': '😔 Sad', 'sel': false},
    {'label': '🔥 Motivated', 'sel': false},
    {'label': '😊 Happy', 'sel': false},
  ];

  @override
  void initState() {
    super.initState();

    // Pre-fill body if coming from Quick Thought
    _bodyController = TextEditingController(
      text: widget.initialBody ?? '',
    );

    // If pre-filled, switch to free-write mode and position cursor at end
    if (widget.initialBody != null && widget.initialBody!.isNotEmpty) {
      _promptMode = false;
      _bodyController.selection = TextSelection.fromPosition(
        TextPosition(offset: _bodyController.text.length),
      );
      _wordCount = _bodyController.text
          .trim()
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .length;
    }

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _blinkAnim = Tween<double>(
      begin: 1.0,
      end: 0.25,
    ).animate(_blinkController);

    _bodyController.addListener(() {
      final words = _bodyController.text
          .trim()
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .length;

      if (words != _wordCount) {
        setState(() => _wordCount = words);
      }
    });

    _fetchTodayPrompt();
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _fetchTodayPrompt() async {
    try {
      print('========== WRITE SCREEN FETCH PROMPT START ==========');

      final prompt = await DailyPromptService.fetchTodayPrompt();

      if (!mounted) return;

      setState(() {
        _todayPrompt = prompt;
        _isPromptLoading = false;
      });

      print('TODAY PROMPT FROM API: $_todayPrompt');
      print('========== WRITE SCREEN FETCH PROMPT END ==========');
    } catch (e) {
      print('WRITE SCREEN PROMPT ERROR: $e');

      if (!mounted) return;

      setState(() {
        _todayPrompt = null;
        _isPromptLoading = false;
      });
    }
  }

  String _todayDate() {
    final days = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday',
    ];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final now = DateTime.now();
    return '${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}';
  }

  void _openEmojiPicker() {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: const Color(0xFF2D3650),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: kGlassBorder),
          ),
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              setState(() {
                _emojiController.text = emoji.emoji;
              });
              Navigator.pop(context);
            },
            config: const Config(
              height: 420,
              bottomActionBarConfig: BottomActionBarConfig(enabled: false),
              categoryViewConfig: CategoryViewConfig(
                indicatorColor: kGreen,
                iconColorSelected: kGreen,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<String>> _convertImagesToBase64() async {
    final List<String> base64Images = [];
    for (final photo in _photos) {
      final bytes = await File(photo.path).readAsBytes();
      base64Images.add('data:image/png;base64,${base64Encode(bytes)}');
    }
    print('Converted Images Base64 Count: ${base64Images.length}');
    return base64Images;
  }

  Future<void> _showPhotoOptions() async {
    if (_photos.length >= 4) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PhotoPickerSheet(
        onCamera: () async {
          Navigator.pop(context);
          final img = await _picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          );
          if (img != null && mounted) setState(() => _photos.add(img));
        },
        onGallery: () async {
          Navigator.pop(context);
          final remaining = 4 - _photos.length;
          final imgs = await _picker.pickMultiImage(imageQuality: 85);
          if (imgs.isNotEmpty && mounted) {
            setState(() => _photos.addAll(imgs.take(remaining)));
          }
        },
      ),
    );
  }

  void _removePhoto(int index) => setState(() => _photos.removeAt(index));

  Future<void> _saveEntry() async {
    final body = _bodyController.text.trim();

    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Write something first 💙', style: dmSans(size: 13, color: kText)),
          backgroundColor: kGlass,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = await SessionManager.getUserId();

      print('SESSION USER ID: $userId');

      if (userId == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session expired. Please login again.', style: dmSans(size: 13, color: kText)),
            backgroundColor: kGlass,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      final title = _titleController.text.trim().isEmpty
          ? 'Untitled Entry'
          : _titleController.text.trim();

      final selectedEmoji = _emojiController.text.trim().isEmpty
          ? '😊'
          : _emojiController.text.trim();

      final selectedTags = _tags
          .where((t) => t['sel'] == true)
          .map<String>((t) {
        final label = t['label'] as String;
        return label.replaceAll(RegExp(r'[^\w\s]'), '').trim();
      })
          .where((tag) => tag.isNotEmpty)
          .toList();

      final imagesBase64 = await _convertImagesToBase64();

      print('========== SAVING JOURNAL ENTRY ==========');
      print('User ID From Session: $userId');
      print('Title: $title');
      print('Selected Emoji: $selectedEmoji');
      print('Selected Tags: $selectedTags');
      print('Body: $body');
      print('Images Count: ${imagesBase64.length}');

      final result = await JournalAddService.saveDetailedEntry(
        userId: userId,
        dayName: title,
        content: body,
        difficulties: selectedEmoji,
        tags: selectedTags,
        imagesBase64: imagesBase64,
      );

      print('Final Save Result: $result');

      if (!mounted) return;

      if (result['success'] == true) {
        final int journalId = int.tryParse(
          '${result['journal_id'] ?? result['data']?['journal_id'] ?? 0}',
        ) ??
            0;

        print('Extracted Journal ID: $journalId');

        if (journalId == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Journal ID not found. Please check save API response.',
                style: dmSans(size: 13, color: kText),
              ),
              backgroundColor: kGlass,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? result['data']?['message'] ?? 'Journal saved successfully',
              style: dmSans(size: 13, color: kText),
            ),
            backgroundColor: kGlass,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SavedScreen(
              userId: userId,
              journalId: journalId,
              title: title,
              body: body,
              tags: selectedTags,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to save journal',
              style: dmSans(size: 13, color: kText),
            ),
            backgroundColor: kGlass,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      print('Save Entry Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Please try again.', style: dmSans(size: 13, color: kText)),
          backgroundColor: kGlass,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _promptTextForCard() {
    if (_isPromptLoading) return 'Loading today\'s prompt...';
    final prompt = _todayPrompt?.trim();
    if (prompt != null && prompt.isNotEmpty) return '"$prompt"';
    return '"$_fallbackPrompt"';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SimpleBottomBar(currentIndex: 1),
      backgroundColor: kBg,
      body: Stack(
        children: [
          _orbWidget(top: -60, left: -60, size: 280, color: kGreen.withOpacity(0.22)),
          _orbWidget(bottom: 120, right: -50, size: 240, color: kBlue.withOpacity(0.28)),
          _orbWidget(
            top: MediaQuery.of(context).size.height * 0.45,
            left: 40,
            size: 180,
            color: kPink.withOpacity(0.22),
          ),
          SafeArea(
            child: Column(
              children: [
                const ArriveHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  FadeTransition(
                                    opacity: _blinkAnim,
                                    child: Container(
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        color: kGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'NEW ENTRY',
                                    style: dmSans(
                                      size: 10,
                                      weight: FontWeight.w500,
                                      color: kGreen,
                                    ).copyWith(letterSpacing: 1.2),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(_todayDate(), style: dmSans(size: 12, color: kTextMuted)),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: glassBox(radius: 18),
                                      child: TextField(
                                        controller: _titleController,
                                        maxLength: 80,
                                        style: cormorant(size: 24),
                                        cursorColor: kGreen,
                                        decoration: InputDecoration(
                                          hintText: 'Give this moment a title…',
                                          hintStyle: cormorant(
                                            size: 24,
                                            color: kTextMuted,
                                            style: FontStyle.italic,
                                          ),
                                          border: InputBorder.none,
                                          counterText: '',
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: _openEmojiPicker,
                                        child: Container(
                                          width: 54,
                                          height: 54,
                                          decoration: BoxDecoration(
                                            color: kGlass,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: kGlassBorder),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _emojiController.text.isEmpty ? '😊' : _emojiController.text,
                                              style: const TextStyle(fontSize: 25),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Add Emoji',
                                        style: dmSans(size: 10, weight: FontWeight.w500, color: kTextMuted),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 22),
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, kGlassBorder, Colors.transparent],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                          child: Row(
                            children: [
                              _toggleBtn('✦ Today\'s Prompt', true),
                              const SizedBox(width: 8),
                              _toggleBtn('💭 What\'s on my mind', false),
                            ],
                          ),
                        ),
                        if (_promptMode)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                            child: glassCard(
                              topLineColor: kGreen.withOpacity(0.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '✦ TODAY\'S PROMPT',
                                    style: dmSans(size: 10, weight: FontWeight.w500, color: kGreen)
                                        .copyWith(letterSpacing: 1.0),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _promptTextForCard(),
                                    style: cormorant(size: 17, color: kTextSoft, style: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                          child: Stack(
                            children: [
                              Container(
                                decoration: glassBox(),
                                child: TextField(
                                  controller: _bodyController,
                                  maxLines: null,
                                  minLines: 10,
                                  style: dmSans(size: 14, color: kText).copyWith(height: 1.8),
                                  cursorColor: kGreen,
                                  decoration: InputDecoration(
                                    hintText: _promptMode
                                        ? 'Respond to today\'s prompt… this space is only for you.'
                                        : 'Just say what\'s on your mind… no structure needed.',
                                    hintStyle: dmSans(size: 14, color: kTextMuted)
                                        .copyWith(fontStyle: FontStyle.italic),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(18),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                right: 16,
                                child: Text(
                                  '$_wordCount word${_wordCount != 1 ? 's' : ''}',
                                  style: dmSans(size: 11, color: kTextMuted),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _tags.asMap().entries.map((e) {
                              final idx = e.key;
                              final tag = e.value;
                              final sel = tag['sel'] as bool;
                              return GestureDetector(
                                onTap: () => setState(() => _tags[idx]['sel'] = !sel),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: sel ? kGreen.withOpacity(0.1) : kGlass,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: sel ? kGreen.withOpacity(0.4) : kGlassBorder,
                                    ),
                                  ),
                                  child: Text(
                                    tag['label'] as String,
                                    style: dmSans(
                                      size: 11,
                                      weight: FontWeight.w500,
                                      color: sel ? kGreen : kTextMuted,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        _buildPhotoSection(),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: gradientButton(
                            label: _isSaving ? 'Saving...' : 'Save Entry →',
                            onTap: _isSaving ? () {} : _saveEntry,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.25),
              child: const Center(child: CircularProgressIndicator(color: kGreen)),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📷', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 10),
              Text(
                'ADD PHOTOS',
                style: dmSans(size: 11, weight: FontWeight.w600, color: kTextSoft)
                    .copyWith(letterSpacing: 0.8),
              ),
              const SizedBox(width: 6),
              Text('Optional · up to 4', style: dmSans(size: 11, color: kTextMuted)),
              const Spacer(),
              if (_photos.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _photos.clear()),
                  child: Text(
                    'Clear all',
                    style: dmSans(size: 11, color: kTextMuted).copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: kTextMuted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._photos.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(right: 9),
                  child: _buildPhotoThumb(e.value, e.key),
                )),
                if (_photos.length < 4)
                  GestureDetector(
                    onTap: _showPhotoOptions,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CustomPaint(
                        painter: _DashedBorderPainter(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('+', style: TextStyle(fontSize: 20, color: kTextMuted, fontWeight: FontWeight.w300)),
                            const SizedBox(height: 5),
                            Text('Add', style: dmSans(size: 10, weight: FontWeight.w500, color: kTextMuted).copyWith(letterSpacing: 0.3)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_photos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${_photos.length}/4 photo${_photos.length != 1 ? 's' : ''} added',
                style: dmSans(size: 11, color: kGreen.withOpacity(0.8)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumb(XFile photo, int idx) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kGlassBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(File(photo.path), width: 80, height: 80, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: () => _removePhoto(idx),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2332),
                shape: BoxShape.circle,
                border: Border.all(color: kGlassBorder),
              ),
              child: const Center(
                child: Text('✕', style: TextStyle(fontSize: 10, color: kTextSoft, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggleBtn(String label, bool isPrompt) {
    final active = isPrompt == _promptMode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _promptMode = isPrompt),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: active ? kGreen.withOpacity(0.1) : kGlass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? kGreen.withOpacity(0.4) : kGlassBorder),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: dmSans(size: 12, weight: FontWeight.w500, color: active ? kGreen : kTextMuted),
          ),
        ),
      ),
    );
  }
}

Widget _orbWidget({
  double? top, double? left, double? right, double? bottom,
  required double size, required Color color,
}) {
  return Positioned(
    top: top, left: left, right: right, bottom: bottom,
    child: IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
            stops: const [0.0, 0.7],
          ),
        ),
      ),
    ),
  );
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x38FFFFFF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const radius = 16.0;
    const dashLen = 5.0;
    const gapLen = 4.0;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      const Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics().first;

    double dist = 0;
    while (dist < metrics.length) {
      final end = (dist + dashLen).clamp(0, metrics.length);
      canvas.drawPath(metrics.extractPath(dist, end.toDouble()), paint);
      dist += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _PhotoPickerSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _PhotoPickerSheet({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D3650),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kGlassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36, height: 4,
              decoration: BoxDecoration(color: kGlassBorder, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Add Photo', style: cormorant(size: 22)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text('Choose how you\'d like to add your moment', style: dmSans(size: 13, color: kTextMuted)),
          ),
          Container(height: 1, color: kGlassBorder.withOpacity(0.5)),
          GestureDetector(
            onTap: onCamera,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: kBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBlue.withOpacity(0.3)),
                    ),
                    child: const Center(child: Text('📷', style: TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Take a Photo', style: dmSans(size: 15, weight: FontWeight.w500, color: kText)),
                      Text('Use your camera', style: dmSans(size: 12, color: kTextMuted)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: kTextMuted, size: 20),
                ],
              ),
            ),
          ),
          Container(height: 1, color: kGlassBorder.withOpacity(0.3)),
          GestureDetector(
            onTap: onGallery,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: kBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBlue.withOpacity(0.3)),
                    ),
                    child: const Center(child: Text('🖼️', style: TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Choose from Gallery', style: dmSans(size: 15, weight: FontWeight.w500, color: kText)),
                      Text('Select multiple at once', style: dmSans(size: 12, color: kTextMuted)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: kTextMuted, size: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 45),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: glassBox(radius: 14),
                child: Text(
                  'Cancel',
                  textAlign: TextAlign.center,
                  style: dmSans(size: 14, weight: FontWeight.w500, color: kTextMuted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}