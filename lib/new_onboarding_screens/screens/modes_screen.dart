import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'first_entry_screen.dart';

class ModesScreen extends StatefulWidget {
  const ModesScreen({super.key});

  @override
  State<ModesScreen> createState() => _ModesScreenState();
}

class _ModesScreenState extends State<ModesScreen> {
  String _activeMode = 'Friend';

  final Map<String, _ModeData> _modes = {
    'Friend': const _ModeData(
      icon: '🤝',
      label: 'Friend',
      sublabel: 'Warm · Honest · Real',
      color: Color(0xFFD4B896),
      borderColor: Color(0x66D4B896),
      bgColor: Color(0x1FD4B896),
      traits: [
        'No judgment',
        'Says the real thing',
        'Feels like a text from a friend',
      ],
      body:
      'Hey — I hear you. And I want you to know that "further along" is a story you\'re telling yourself, not a fact. You\'re not behind. You\'re exactly where you are, and that\'s enough right now. Stop measuring your life against something that doesn\'t even exist.',
    ),
    'Therapist': const _ModeData(
      icon: '🧘',
      label: 'Therapist',
      sublabel: 'Reflective · Grounding · Insightful',
      color: Color(0xFFB8A8D8),
      borderColor: Color(0x66B8A8D8),
      bgColor: Color(0x1FB8A8D8),
      traits: [
        'Helps you see patterns',
        'Asks the deeper question',
        'Grounding and calm',
      ],
      body:
      'What you\'re describing sounds like a pattern worth noticing — the feeling that you should be somewhere other than where you are. Can you sit with the question: who decided what "further along" looks like for you? Often that voice belongs to someone else entirely.',
    ),
    'Coach': const _ModeData(
      icon: '⚡',
      label: 'Coach',
      sublabel: 'Direct · Energizing · Forward',
      color: Color(0xFF90B8E0),
      borderColor: Color(0x6690B8E0),
      bgColor: Color(0x1F90B8E0),
      traits: [
        'Action-focused',
        'Cuts through the noise',
        'Pushes you forward',
      ],
      body:
      'That self-criticism isn\'t motivating you — it\'s slowing you down. Here\'s what I need you to do: name one thing you\'ve actually accomplished this week. Just one. Growth doesn\'t always look like a straight line, but it\'s happening. Start there.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final mode = _modes[_activeMode]!;

    return Scaffold(
      backgroundColor: ArriveTheme.bg,
      body: OrbBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✦ BEFORE YOU START',
                        style: ArriveTheme.dmSans.copyWith(
                          fontSize: 10,
                          letterSpacing: 1.8,
                          color: ArriveTheme.lavender,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Three ways to\nbe heard.',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 31,
                          fontWeight: FontWeight.w300,
                          color: ArriveTheme.text,
                          height: 1.18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap each one to see how the same thought sounds through a different lens. You choose every time — nothing is locked in.',
                        style: ArriveTheme.dmSans.copyWith(
                          fontSize: 13,
                          color: ArriveTheme.textSoft,
                          fontWeight: FontWeight.w300,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    decoration: BoxDecoration(
                      color: ArriveTheme.glass,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ArriveTheme.glassBorder, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR THOUGHT',
                          style: ArriveTheme.dmSans.copyWith(
                            fontSize: 10,
                            letterSpacing: 1.1,
                            color: ArriveTheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '"I\'ve been so hard on myself lately. I keep thinking I should be further along by now."',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: ArriveTheme.textSoft,
                            height: 1.55,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: _modes.keys.map((key) {
                      final m = _modes[key]!;
                      final isActive = _activeMode == key;

                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: key == 'Coach' ? 0 : 10),
                          child: GestureDetector(
                            onTap: () => setState(() => _activeMode = key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: ArriveTheme.glass,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isActive ? m.borderColor : ArriveTheme.glassBorder,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    m.icon,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    m.label,
                                    style: ArriveTheme.dmSans.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isActive ? m.color : ArriveTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                    decoration: BoxDecoration(
                      color: ArriveTheme.glass,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: mode.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: mode.bgColor,
                                border: Border.all(color: mode.borderColor, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  mode.icon,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${mode.label} Mode',
                                    style: ArriveTheme.dmSans.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: mode.color,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    mode.sublabel,
                                    style: ArriveTheme.dmSans.copyWith(
                                      fontSize: 10,
                                      color: ArriveTheme.textMuted,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: RichText(
                            key: ValueKey(_activeMode),
                            text: TextSpan(
                              style: ArriveTheme.dmSans.copyWith(
                                fontSize: 14,
                                color: ArriveTheme.textSoft,
                                height: 1.75,
                                fontWeight: FontWeight.w300,
                              ),
                              children: _styledBody(mode),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: mode.traits
                              .map(
                                (t) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: ArriveTheme.glassBorder,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                t,
                                style: ArriveTheme.dmSans.copyWith(
                                  fontSize: 10,
                                  color: ArriveTheme.textMuted,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      _slide(const FirstEntryScreen()),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xD9B8A8D8),
                            Color(0xBF90B8E0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: ArriveTheme.lavender.withOpacity(0.30),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Got it — let\'s go →',
                          style: ArriveTheme.dmSans.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'You can change modes any time. Nothing is permanent.',
                      textAlign: TextAlign.center,
                      style: ArriveTheme.dmSans.copyWith(
                        fontSize: 11,
                        color: ArriveTheme.textMuted,
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

  List<InlineSpan> _styledBody(_ModeData mode) {
    if (_activeMode == 'Friend') {
      return [
        const TextSpan(
          text:
          'Hey — I hear you. And I want you to know that ',
        ),
        TextSpan(
          text: '"further along"',
          style: ArriveTheme.dmSans.copyWith(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: ArriveTheme.text,
          ),
        ),
        const TextSpan(
          text:
          ' is a story you\'re telling yourself, not a fact. You\'re not behind. You\'re exactly where you are, and that\'s enough right now. Stop measuring your life against something that doesn\'t even exist.',
        ),
      ];
    }

    if (_activeMode == 'Therapist') {
      return [
        const TextSpan(
          text:
          'What you\'re describing sounds like a pattern worth noticing — the feeling that you ',
        ),
        TextSpan(
          text: 'should',
          style: ArriveTheme.dmSans.copyWith(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: ArriveTheme.text,
          ),
        ),
        const TextSpan(
          text:
          ' be somewhere other than where you are. Can you sit with the question: who decided what "further along" looks like for you? Often that voice belongs to someone else entirely.',
        ),
      ];
    }

    return [
      const TextSpan(
        text:
        'That self-criticism isn\'t motivating you — it\'s slowing you down. Here\'s what I need you to do: name one thing you\'ve actually accomplished this week. Just one. Growth doesn\'t always look like a straight line, but it\'s happening. Start there.',
      ),
    ];
  }
}

class _ModeData {
  final String icon;
  final String label;
  final String sublabel;
  final String body;
  final Color color;
  final Color borderColor;
  final Color bgColor;
  final List<String> traits;

  const _ModeData({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.borderColor,
    required this.bgColor,
    required this.traits,
    required this.body,
  });
}

PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, anim, __, child) => SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
    child: child,
  ),
  transitionDuration: const Duration(milliseconds: 380),
);