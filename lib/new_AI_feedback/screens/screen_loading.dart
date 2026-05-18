import 'package:flutter/material.dart';
import '../../new_bottom_bar/bottom_nav_bar.dart';
import '../../new_service_screens/Ai_feedback_service.dart';
import '../constants.dart';

import 'screen_results.dart';

class LoadingScreen extends StatefulWidget {
  final int userId;
  final int journalId;
  final String title;
  final String body;
  final List<String> tags;
  final String mode;
  final String modeIcon;

  const LoadingScreen({
    super.key,
    required this.userId,
    required this.journalId,
    required this.title,
    required this.body,
    required this.tags,
    required this.mode,
    required this.modeIcon,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _breatheController;
  late Animation<double> _spinAnim;
  late Animation<double> _breatheAnim;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _spinAnim = Tween<double>(begin: 0, end: 1).animate(_spinController);

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _breatheAnim = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(_breatheController);

    _callAiFeedbackApi();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  Future<void> _callAiFeedbackApi() async {
    try {
      print('========== LOADING SCREEN API CALL ==========');
      print('User ID: ${widget.userId}');
      print('Journal ID: ${widget.journalId}');
      print('Selected Mode: ${widget.mode}');
      print('API Mode Value: ${widget.mode.toLowerCase()}');

      final response = await AiFeedbackService.getAiFeedback(
        userId: widget.userId,
        journalId: widget.journalId,
        mode: widget.mode,
      );

      print('AI Feedback Success');
      print('AI Feedback ID: ${response['ai_feedback_id']}');
      print('AI Feedback Mode: ${response['mode']}');
      print('AI Feedback Mood: ${response['mood']}');

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            userId: widget.userId,
            journalId: widget.journalId,
            mode: widget.mode,
            modeIcon: widget.modeIcon,
            feedback: response,
            title: widget.title,
            body: widget.body,
            tags: widget.tags,
          ),
        ),
      );
    } catch (e) {
      print('AI Feedback Failed From LoadingScreen');
      print('Error: $e');

      if (mounted) {
        _goToResultsWithError();
      }
    }
  }

  void _goToResultsWithError() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          userId: widget.userId,
          journalId: widget.journalId,
          mode: widget.mode,
          modeIcon: widget.modeIcon,
          feedback: null,
          title: widget.title,
          body: widget.body,
          tags: widget.tags,
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
            child: _orbWidget(280, kLavender.withOpacity(0.2)),
          ),
          Positioned(
            bottom: 120,
            right: -50,
            child: _orbWidget(240, kBlue.withOpacity(0.22)),
          ),
          SafeArea(
            child: Column(
              children: [
                ArriveHeader(onBack: () => Navigator.of(context).pop()),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                RotationTransition(
                                  turns: _spinAnim,
                                  child: Container(
                                    width: 108,
                                    height: 108,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: kLavender.withOpacity(0.15),
                                        width: 1,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        width: 4,
                                        height: 4,
                                        margin: const EdgeInsets.only(top: 0),
                                        decoration: BoxDecoration(
                                          color: kLavender.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ScaleTransition(
                                  scale: _breatheAnim,
                                  child: Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: kGlass,
                                      border: Border.all(
                                        color: kLavender.withOpacity(0.4),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: kLavender.withOpacity(0.2),
                                          blurRadius: 40,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.modeIcon,
                                        style: const TextStyle(fontSize: 34),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Reading your entry…',
                            style: cormorant(size: 26),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your words are being heard. This takes just a moment.',
                            textAlign: TextAlign.center,
                            style: dmSans(size: 13, color: kTextSoft)
                                .copyWith(height: 1.6),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: kLavender.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: kLavender.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '✦ ${widget.mode} Mode',
                              style: dmSans(
                                size: 11,
                                weight: FontWeight.w500,
                                color: kLavender,
                              ).copyWith(letterSpacing: 0.8),
                            ),
                          ),
                        ],
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