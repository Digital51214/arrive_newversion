import 'package:flutter/material.dart';
import '../../new_bottom_bar/bottom_nav_bar.dart';
import '../constants.dart';
import 'screen_mode.dart';

class SavedScreen extends StatefulWidget {
  final int userId;
  final int journalId;
  final String title;
  final String body;
  final List<String> tags;

  const SavedScreen({
    super.key,
    required this.userId,
    required this.journalId,
    required this.title,
    required this.body,
    required this.tags,
  });

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();

    print('SavedScreen User ID: ${widget.userId}');
    print('SavedScreen Journal ID: ${widget.journalId}');
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _previewBody() {
    if (widget.body.length > 200) {
      return '${widget.body.substring(0, 200)}…';
    }
    return widget.body;
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
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: 40,
            child: _orbWidget(180, kPink.withOpacity(0.22)),
          ),
          SafeArea(
            child: Column(
              children: [
                ArriveHeader(onBack: () => Navigator.of(context).pop()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: glassCard(
                                  topLineColor: kGreen.withOpacity(0.5),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '✓',
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: kGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'ENTRY SAVED',
                                        style: dmSans(
                                          size: 10,
                                          weight: FontWeight.w500,
                                          color: kGreen,
                                        ).copyWith(letterSpacing: 1.2),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.title,
                                        style: cormorant(size: 22),
                                      ),
                                      if (widget.tags.isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: widget.tags.map((t) {
                                            return Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: kGreen.withOpacity(0.1),
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                border: Border.all(
                                                  color:
                                                  kGreen.withOpacity(0.35),
                                                ),
                                              ),
                                              child: Text(
                                                t,
                                                style: dmSans(
                                                  size: 10,
                                                  weight: FontWeight.w500,
                                                  color: kGreen,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      Text(
                                        _previewBody(),
                                        style: dmSans(
                                          size: 13,
                                          color: kTextSoft,
                                          weight: FontWeight.w300,
                                        ).copyWith(height: 1.7),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.fromLTRB(20, 14, 20, 0),
                              child: GestureDetector(
                                onTap: () {
                                  print('Get AI Feedback Clicked');
                                  print('Sending User ID: ${widget.userId}');
                                  print(
                                      'Sending Journal ID: ${widget.journalId}');

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ModeScreen(
                                        userId: widget.userId,
                                        journalId: widget.journalId,
                                        title: widget.title,
                                        body: widget.body,
                                        tags: widget.tags,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 15),
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '🪞',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 9),
                                      Text(
                                        'Get AI Feedback',
                                        style: dmSans(
                                          size: 15,
                                          weight: FontWeight.w500,
                                          color: kText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                              child: Text(
                                'Choose how you want to be heard — Friend, Therapist, or Coach',
                                textAlign: TextAlign.center,
                                style: dmSans(
                                  size: 11,
                                  color: kTextMuted,
                                ).copyWith(letterSpacing: 0.4),
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