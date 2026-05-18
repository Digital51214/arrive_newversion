import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../new_service_screens/session_manager.dart';
import '../../new_service_screens/sign_up_service.dart';
import '../theme/app_theme.dart';
import 'walkthrough_screen.dart';

class PostpartumScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String gender;

  const PostpartumScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.gender,
  });

  @override
  State<PostpartumScreen> createState() => _PostpartumScreenState();
}

class _PostpartumScreenState extends State<PostpartumScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathe;
  late Animation<double> _scaleAnim;

  int? _selectedOption;
  bool? _postpartumEnabled;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathe, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  void _selectOption(int idx, bool enabled) {
    if (_isLoading) return;

    setState(() {
      _selectedOption = idx;
      _postpartumEnabled = enabled;
    });
  }

  Future<void> _continue() async {
    if (_postpartumEnabled == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      print('POSTPARTUM SIGNUP API CALL STARTED');
      print('POSTPARTUM MODE: ${_postpartumEnabled! ? 1 : 0}');

      final result = await SignupService.registerUser(
        firstName: widget.firstName,
        lastName: widget.lastName,
        email: widget.email,
        gender: widget.gender,
        password: widget.password,
        postpartumMode: _postpartumEnabled! ? 1 : 0,
      );

      final user = result['user'];

      print('POSTPARTUM SIGNUP SUCCESS');
      print('SIGNUP USER DATA: $user');

      await SessionManager.saveUserSession(user);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        _slide(WalkthroughScreen(postpartumEnabled: _postpartumEnabled!)),
      );
    } catch (e) {
      print('POSTPARTUM SIGNUP ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
      print('POSTPARTUM SIGNUP API CALL ENDED');
    }
  }

  @override
  Widget build(BuildContext context) {
    final features = [
      'A private community feed — share, read, and connect with other moms',
      'Anonymous posting — say what you really feel without anyone knowing it\'s you',
      'Prompts and AI responses tailored to the postpartum experience',
      'A saved posts tab — bookmark the posts that felt like someone read your mind',
    ];

    final options = [
      {
        'emoji': '🌸',
        'label': 'Yes — turn on Postpartum Mode',
        'sub': 'I\'m pregnant, a new mom, or navigating postpartum right now',
        'enabled': true,
        'color': const Color(0xA6D4A0B8),
      },
      {
        'emoji': '🌿',
        'label': 'Not right now',
        'sub': 'I can always turn it on later in settings',
        'enabled': false,
        'color': const Color(0xA68DBFAA),
      },
      {
        'emoji': '🤍',
        'label': 'Prefer not to say',
        'sub': 'No problem — I\'ll keep it off for now',
        'enabled': false,
        'color': const Color(0x40FFFFFF),
      },
    ];

    final bool isReady = _selectedOption != null;

    return Scaffold(
      backgroundColor: ArriveTheme.bg,
      body: OrbBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    '← Back',
                    style: ArriveTheme.dmSans.copyWith(
                      fontSize: 13,
                      color: ArriveTheme.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                AnimatedBuilder(
                  animation: _scaleAnim,
                  builder: (_, child) => Transform.scale(
                    scale: _scaleAnim.value,
                    child: child,
                  ),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ArriveTheme.pink.withOpacity(0.22),
                          ArriveTheme.pink.withOpacity(0.08),
                        ],
                      ),
                      border: Border.all(
                        color: ArriveTheme.pink.withOpacity(0.38),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ArriveTheme.pink.withOpacity(0.18),
                          blurRadius: 32,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🌸', style: TextStyle(fontSize: 32)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                RichText(
                  text: TextSpan(
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      color: ArriveTheme.text,
                      height: 1.25,
                    ),
                    children: [
                      const TextSpan(text: 'Are you a new or\n'),
                      TextSpan(
                        text: 'expecting mom?',
                        style: TextStyle(
                          color: ArriveTheme.pink,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'ARRIVE has a dedicated space built specifically for the postpartum journey. It\'s private, safe, and completely optional — but if it fits, it\'s here for you.',
                  style: ArriveTheme.dmSans.copyWith(
                    fontSize: 14,
                    color: ArriveTheme.textSoft,
                    fontWeight: FontWeight.w300,
                    height: 1.72,
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ArriveTheme.glass,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ArriveTheme.pink.withOpacity(0.28),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🌸 POSTPARTUM MODE INCLUDES',
                        style: ArriveTheme.dmSans.copyWith(
                          fontSize: 10,
                          letterSpacing: 1.0,
                          color: ArriveTheme.pink,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...features.map(
                            (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(top: 6, right: 10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ArriveTheme.pink.withOpacity(0.7),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  f,
                                  style: ArriveTheme.dmSans.copyWith(
                                    fontSize: 13,
                                    color: ArriveTheme.textSoft,
                                    height: 1.5,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                ...List.generate(options.length, (i) {
                  final opt = options[i];
                  final isSelected = _selectedOption == i;
                  final col = opt['color'] as Color;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _selectOption(i, opt['enabled'] as bool),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ArriveTheme.glassHover
                              : ArriveTheme.glass,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? col : ArriveTheme.glassBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              opt['emoji'] as String,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt['label'] as String,
                                    style: ArriveTheme.dmSans.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: ArriveTheme.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    opt['sub'] as String,
                                    style: ArriveTheme.dmSans.copyWith(
                                      fontSize: 12,
                                      color: ArriveTheme.textMuted,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? col : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? col
                                      : ArriveTheme.glassBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Center(
                                child: Text(
                                  '✓',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                              )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 8),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: isReady ? 1 : 0.45,
                  child: IgnorePointer(
                    ignoring: !isReady || _isLoading,
                    child: GestureDetector(
                      onTap: _continue,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xD9D4A0B8),
                              Color(0xBFB894C8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: ArriveTheme.pink.withOpacity(0.28),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _isLoading ? 'Creating account...' : 'Continue →',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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