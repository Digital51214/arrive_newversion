import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../new_bottom_bar/bottom_nav_bar.dart';
import '../../new_service_screens/session_manager.dart';
import '../theme/arrive_colors.dart';
import 'locked_screen.dart';
import 'feed_screen.dart';
import 'my_posts_screen.dart';
import 'saved_screen.dart';

enum CommunityMode {
  postpartum,
  speakFreely,
}

class CommunityMainScreen extends StatefulWidget {
  const CommunityMainScreen({super.key});

  @override
  State<CommunityMainScreen> createState() => _CommunityMainScreenState();
}

class _CommunityMainScreenState extends State<CommunityMainScreen>
    with TickerProviderStateMixin {
  bool _unlocked = false;
  int _tab = 0;

  String _gender = '';
  CommunityMode _mode = CommunityMode.speakFreely;

  late AnimationController _orb1Ctrl;
  late AnimationController _orb2Ctrl;
  late AnimationController _orb3Ctrl;
  late AnimationController _blinkCtrl;

  bool get _isFemale => _gender.toLowerCase() == 'female';

  String get _selectedModeForApi {
    return _mode == CommunityMode.speakFreely
        ? 'speak freely mode'
        : 'postpartum mode';
  }

  String get _communityTypeForMyPosts {
    return _mode == CommunityMode.speakFreely ? 'free_speak' : 'postpartum';
  }

  Color get _modeColor {
    return _mode == CommunityMode.speakFreely
        ? ArriveColors.speakBlue
        : ArriveColors.pink;
  }

  String get _modeText {
    return _mode == CommunityMode.speakFreely
        ? 'Speak Freely Mode'
        : 'Postpartum Mode';
  }

  @override
  void initState() {
    super.initState();

    _orb1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);

    _orb2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11),
    )..repeat(reverse: true);

    _orb3Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 13),
    )..repeat(reverse: true);

    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _loadGender();
  }

  Future<void> _loadGender() async {
    final user = await SessionManager.getUser();
    final gender = user?['gender']?.toString().trim().toLowerCase() ?? '';

    if (!mounted) return;

    setState(() {
      _gender = gender;

      if (_isFemale) {
        _unlocked = false;
        _mode = CommunityMode.postpartum;
      } else {
        _unlocked = true;
        _mode = CommunityMode.speakFreely;
      }
    });
  }

  @override
  void dispose() {
    _orb1Ctrl.dispose();
    _orb2Ctrl.dispose();
    _orb3Ctrl.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  void _showPostpartumBlockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'This mode is only for female users.',
          style: GoogleFonts.dmSans(fontSize: 13, color: ArriveColors.text),
        ),
        backgroundColor: ArriveColors.glass,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _activatePostpartumMode() {
    if (!_isFemale) {
      _showPostpartumBlockedMessage();
      return;
    }
    setState(() {
      _unlocked = true;
      _mode = CommunityMode.postpartum;
      _tab = 0;
    });
  }

  void _activateSpeakFreelyMode() {
    setState(() {
      _unlocked = true;
      _mode = CommunityMode.speakFreely;
      _tab = 0;
    });
  }

  Widget _buildTabContent() {
    switch (_tab) {
      case 0:
        return FeedScreen(
          key: ValueKey('feed-$_mode'),
          selectedMode: _selectedModeForApi,
        );
      case 1:
        return MyPostsScreen(
          key: ValueKey('myposts-$_mode'),
          communityType: _communityTypeForMyPosts,
        );
      default:
        return const SavedScreen(key: ValueKey('saved'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ resizeToAvoidBottomInset false — keyboard overflow nahi hoga
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: const SimpleBottomBar(currentIndex: 3),
      backgroundColor: ArriveColors.bg,
      body: Stack(
        children: [
          // ── Ambient orbs ──
          _AmbientOrb(
            ctrl: _orb1Ctrl,
            color: _mode == CommunityMode.speakFreely
                ? ArriveColors.speakBlue.withOpacity(0.38)
                : const Color(0x61D296B8),
            size: 280,
            top: -80,
            left: -60,
          ),
          _AmbientOrb(
            ctrl: _orb2Ctrl,
            color: const Color(0x5278A5DC),
            size: 240,
            bottom: 120,
            right: -50,
            reverse: true,
          ),
          _AmbientOrb(
            ctrl: _orb3Ctrl,
            color: const Color(0x388DBFAA),
            size: 160,
            topFraction: 0.5,
            leftFraction: 0.25,
          ),

          // ── Main content ──
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                if (_unlocked) _buildTabNav(),

                // ✅ KEY FIX:
                // - Unlocked: FeedScreen/MyPostsScreen/SavedScreen directly in Expanded
                //   (ye screens khud scroll karti hain — wrapper nahi chahiye)
                // - Locked: SingleChildScrollView theek hai kyunki LockedScreen static content hai
                Expanded(
                  child: _unlocked
                      ? _buildTabContent()
                      : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: LockedScreen(
                      canActivatePostpartum: _isFemale,
                      onBlockedPostpartumTap:
                      _showPostpartumBlockedMessage,
                      onActivate: _activatePostpartumMode,
                      onActivateSpeakFreely: _activateSpeakFreelyMode,
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

  Widget _buildHeader() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: ArriveColors.headerBg,
            border: Border(
              bottom: BorderSide(color: ArriveColors.glassBorder),
            ),
          ),
          child: Row(
            children: [
              Row(
                children: [
                  _ArriveLogo(),
                  const SizedBox(width: 9),
                  Text(
                    'Arrive',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 21,
                      fontWeight: FontWeight.w300,
                      color: ArriveColors.text,
                      letterSpacing: 0.05 * 21,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _modeColor.withOpacity(0.1),
                  border: Border.all(color: _modeColor.withOpacity(0.25)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _blinkCtrl,
                      builder: (_, __) => Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _modeColor
                              .withOpacity(0.2 + 0.8 * _blinkCtrl.value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _modeText,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                        color: _modeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabNav() {
    final tabs = _mode == CommunityMode.speakFreely
        ? ['Feeds', 'My Posts', 'Saved 🔖']
        : ['Community', 'My Posts', 'Saved 🔖'];

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x80111620),
            border: Border(
              bottom: BorderSide(color: ArriveColors.glassBorder),
            ),
          ),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final active = i == _tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: active ? _modeColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      tabs[i],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        color: active ? _modeColor : ArriveColors.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Ambient Orb ─────────────────────────────────────────────────────────────
class _AmbientOrb extends StatelessWidget {
  final AnimationController ctrl;
  final Color color;
  final double size;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double? topFraction;
  final double? leftFraction;
  final bool reverse;

  const _AmbientOrb({
    required this.ctrl,
    required this.color,
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.topFraction,
    this.leftFraction,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = reverse ? 1.0 - ctrl.value : ctrl.value;
        double dx, dy;

        if (t < 0.33) {
          dx = lerpDouble(0, 12, t / 0.33)!;
          dy = lerpDouble(0, -15, t / 0.33)!;
        } else if (t < 0.66) {
          dx = lerpDouble(12, -8, (t - 0.33) / 0.33)!;
          dy = lerpDouble(-15, 10, (t - 0.33) / 0.33)!;
        } else {
          dx = lerpDouble(-8, 0, (t - 0.66) / 0.34)!;
          dy = lerpDouble(10, 0, (t - 0.66) / 0.34)!;
        }

        final orb = Transform.translate(
          offset: Offset(dx, dy),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color, Colors.transparent],
              ),
            ),
          ),
        );

        if (topFraction != null || leftFraction != null) {
          final screenSize = MediaQuery.of(context).size;
          return Positioned(
            top: topFraction != null ? screenSize.height * topFraction! : null,
            left:
            leftFraction != null ? screenSize.width * leftFraction! : null,
            child: IgnorePointer(child: orb),
          );
        }

        return Positioned(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
          child: IgnorePointer(child: orb),
        );
      },
    );
  }
}

// ─── Arrive Logo ─────────────────────────────────────────────────────────────
class _ArriveLogo extends StatelessWidget {
  final double size;
  const _ArriveLogo({this.size = 26});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 28 / 26),
      painter: _ArriveLogoPainter(),
    );
  }
}

class _ArriveLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = ArriveColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.065
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final sx = w / 100;
    final sy = h / 115;

    final path1 = Path();
    path1.moveTo(50 * sx, 4 * sy);
    path1.cubicTo(33 * sx, 4 * sy, 20 * sx, 17 * sy, 20 * sx, 33 * sy);
    path1.cubicTo(20 * sx, 43 * sy, 26 * sx, 52 * sy, 35 * sx, 57 * sy);
    path1.lineTo(50 * sx, 65 * sy);
    path1.lineTo(65 * sx, 57 * sy);
    path1.cubicTo(74 * sx, 52 * sy, 80 * sx, 43 * sy, 80 * sx, 33 * sy);
    path1.cubicTo(80 * sx, 17 * sy, 67 * sx, 4 * sy, 50 * sx, 4 * sy);
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(20 * sx, 57 * sy);
    path2.cubicTo(8 * sx, 57 * sy, 1 * sx, 65 * sy, 1 * sx, 74 * sy);
    path2.cubicTo(1 * sx, 85 * sy, 9 * sx, 92 * sy, 20 * sx, 92 * sy);
    path2.cubicTo(30 * sx, 92 * sy, 39 * sx, 85 * sy, 41 * sx, 76 * sy);
    path2.lineTo(50 * sx, 65 * sy);
    path2.lineTo(59 * sx, 76 * sy);
    path2.cubicTo(61 * sx, 85 * sy, 70 * sx, 92 * sy, 80 * sx, 92 * sy);
    path2.cubicTo(91 * sx, 92 * sy, 99 * sx, 85 * sy, 99 * sx, 74 * sy);
    path2.cubicTo(99 * sx, 65 * sy, 92 * sx, 57 * sy, 80 * sx, 57 * sy);
    path2.cubicTo(70 * sx, 57 * sy, 61 * sx, 64 * sy, 59 * sx, 73 * sy);
    path2.lineTo(50 * sx, 84 * sy);
    path2.lineTo(41 * sx, 73 * sy);
    path2.cubicTo(39 * sx, 64 * sy, 30 * sx, 57 * sy, 20 * sx, 57 * sy);
    canvas.drawPath(path2, paint);

    final path3 = Path();
    path3.moveTo(35 * sx, 92 * sy);
    path3.cubicTo(28 * sx, 98 * sy, 28 * sx, 108 * sy, 38 * sx, 111 * sy);
    path3.lineTo(50 * sx, 113 * sy);
    path3.lineTo(62 * sx, 111 * sy);
    path3.cubicTo(72 * sx, 108 * sy, 72 * sx, 98 * sy, 65 * sx, 92 * sy);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}