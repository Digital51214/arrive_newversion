import 'package:flutter/material.dart';
import '../../new_bottom_bar/bottom_nav_bar.dart';
import '../constants.dart';
import 'screen_loading.dart';

class ModeScreen extends StatefulWidget {
  final int userId;
  final int journalId;
  final String title;
  final String body;
  final List<String> tags;

  const ModeScreen({
    super.key,
    required this.userId,
    required this.journalId,
    required this.title,
    required this.body,
    required this.tags,
  });

  @override
  State<ModeScreen> createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedMode;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<Map<String, dynamic>> _modes = [
    {
      'id': 'Friend',
      'icon': '🤝',
      'name': 'Friend',
      'color': Color(0xFFD4B896),
      'colorOp': Color(0xB3D4B896),
      'desc':
      'Warm, honest, and real. Talks to you the way a close friend would — without judgment, with love.',
      'traits': ['Empathetic', 'Conversational', 'Warm'],
    },
    {
      'id': 'Therapist',
      'icon': '🧘',
      'name': 'Therapist',
      'color': Color(0xFFB8A8D8),
      'colorOp': Color(0xB3B8A8D8),
      'desc':
      'Reflective and grounding. Helps you see patterns, name what you feel, and find clarity within.',
      'traits': ['Reflective', 'Clinical warmth', 'Insightful'],
    },
    {
      'id': 'Coach',
      'icon': '⚡',
      'name': 'Coach',
      'color': Color(0xFF90B8E0),
      'colorOp': Color(0xB390B8E0),
      'desc':
      'Direct and energizing. Focuses on what you can do next — action, growth, and forward momentum.',
      'traits': ['Action-oriented', 'Motivating', 'Direct'],
    },
  ];

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();

    print('ModeScreen User ID: ${widget.userId}');
    print('ModeScreen Journal ID: ${widget.journalId}');
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _goToLoadingScreen() {
    if (_selectedMode == null) return;

    final modeData = _modes.firstWhere((m) => m['id'] == _selectedMode);

    print('Selected Mode: $_selectedMode');
    print('Selected Mode API Value: ${_selectedMode!.toLowerCase()}');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoadingScreen(
          userId: widget.userId,
          journalId: widget.journalId,
          title: widget.title,
          body: widget.body,
          tags: widget.tags,
          mode: _selectedMode!,
          modeIcon: modeData['icon'] as String,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SimpleBottomBar(currentIndex: 1),
      backgroundColor: kBg,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: _orbWidget(280, kGreen.withOpacity(0.22)),
          ),
          Positioned(
            bottom: 120,
            right: -50,
            child: _orbWidget(240, kBlue.withOpacity(0.28)),
          ),
          SafeArea(
            child: Column(
              children: [
                ArriveHeader(onBack: () => Navigator.of(context).pop()),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.fromLTRB(22, 26, 22, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  eyebrow('✦ AI Feedback', kLavender),
                                  const SizedBox(height: 8),
                                  Text(
                                    'How would you like\nto be heard?',
                                    style: cormorant(size: 28),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Choose one. Your entry will be read through that lens.',
                                    style: dmSans(
                                      size: 13,
                                      color: kTextSoft,
                                      weight: FontWeight.w300,
                                    ).copyWith(height: 1.6),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: _modes.map((mode) {
                                  final isSelected =
                                      _selectedMode == mode['id'];
                                  final modeColor = mode['color'] as Color;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedMode = mode['id'] as String;
                                        });

                                        print(
                                            'Mode Card Selected: $_selectedMode');
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                        const Duration(milliseconds: 220),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.07)
                                              : kGlass,
                                          borderRadius:
                                          BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isSelected
                                                ? modeColor
                                                : kGlassBorder,
                                            width: 1,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                height: 1,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.transparent,
                                                      mode['colorOp'] as Color,
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                  const BorderRadius
                                                      .vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        mode['icon'] as String,
                                                        style: const TextStyle(
                                                          fontSize: 26,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        mode['name'] as String,
                                                        style:
                                                        cormorant(size: 22),
                                                      ),
                                                      const Spacer(),
                                                      if (isSelected)
                                                        Container(
                                                          padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                            horizontal: 9,
                                                            vertical: 3,
                                                          ),
                                                          decoration:
                                                          BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                20),
                                                            border: Border.all(
                                                              color: modeColor,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'Selected',
                                                            style: dmSans(
                                                              size: 9,
                                                              weight: FontWeight
                                                                  .w500,
                                                              color: modeColor,
                                                            ).copyWith(
                                                              letterSpacing:
                                                              1.0,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    mode['desc'] as String,
                                                    style: dmSans(
                                                      size: 13,
                                                      color: kTextSoft,
                                                      weight: FontWeight.w300,
                                                    ).copyWith(height: 1.5),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Wrap(
                                                    spacing: 6,
                                                    runSpacing: 6,
                                                    children:
                                                    (mode['traits']
                                                    as List<String>)
                                                        .map((t) {
                                                      return Container(
                                                        padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                          horizontal: 9,
                                                          vertical: 3,
                                                        ),
                                                        decoration:
                                                        BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(20),
                                                          border: Border.all(
                                                            color: kGlassBorder,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          t,
                                                          style: dmSans(
                                                            size: 10,
                                                            color: kTextMuted,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.fromLTRB(20, 18, 20, 0),
                              child: AnimatedOpacity(
                                opacity: _selectedMode != null ? 1.0 : 0.4,
                                duration: const Duration(milliseconds: 200),
                                child: GestureDetector(
                                  onTap: _selectedMode == null
                                      ? null
                                      : _goToLoadingScreen,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          kLavender.withOpacity(0.85),
                                          kBlue.withOpacity(0.75),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: kLavender.withOpacity(0.28),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'Get My Feedback →',
                                      textAlign: TextAlign.center,
                                      style: dmSans(
                                        size: 15,
                                        weight: FontWeight.w500,
                                        color: kText,
                                      ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orbWidget(double size, Color color) {
    return IgnorePointer(
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
    );
  }
}