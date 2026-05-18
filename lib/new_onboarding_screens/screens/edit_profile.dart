import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../new_bottom_bar/bottom_nav_bar.dart';
import '../../new_service_screens/edit_profile_service.dart';
import '../../new_service_screens/session_manager.dart';

import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _fname = TextEditingController();
  final _email = TextEditingController();

  String _selectedEmoji = '🌸';
  bool _isLoading = false;
  int? _userId;

  final List<String> _emojis = [
    '🌸', '🌷', '🌿', '🩵', '✨', '💫',
    '🌙', '☀️', '🦋', '🤍', '💙', '🌼',
    '🍃', '🌺', '🪷', '⭐', '🕊️', '🌻',
    '😊', '🙂', '😌', '🥰', '💭', '🫶',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ─── Load user from session ───────────────────────────────────────────────
  Future<void> _loadUserData() async {
    final user = await SessionManager.getUser();

    final firstName = user?['first_name']?.toString().trim() ?? '';
    final email    = user?['email']?.toString().trim() ?? '';
    final emoji    = user?['emoji']?.toString().trim() ?? '';
    final userId   = user?['id'];

    if (!mounted) return;

    setState(() {
      _fname.text = firstName;
      _email.text = email;
      if (emoji.isNotEmpty) _selectedEmoji = emoji;
      _userId = userId is int ? userId : int.tryParse(userId.toString());
    });
  }

  // ─── Emoji picker bottom sheet ────────────────────────────────────────────
  void _showEmojiPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
          decoration: BoxDecoration(
            color: ArriveTheme.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(color: ArriveTheme.glassBorder, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 46, height: 4,
                decoration: BoxDecoration(
                  color: ArriveTheme.textMuted.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 22),

              Text(
                'Choose your emoji',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                  color: ArriveTheme.text,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                'Pick one that feels like you today.',
                style: ArriveTheme.dmSans.copyWith(
                  fontSize: 13,
                  color: ArriveTheme.textSoft,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 20),

              GridView.builder(
                shrinkWrap: true,
                itemCount: _emojis.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final emoji = _emojis[index];
                  final isSelected = emoji == _selectedEmoji;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedEmoji = emoji);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ArriveTheme.green.withOpacity(0.18)
                            : ArriveTheme.glass,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? ArriveTheme.green.withOpacity(0.55)
                              : ArriveTheme.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 25)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Save changes — API call via ProfileService ───────────────────────────
  Future<void> _handleUpdateProfile() async {
    final name = _fname.text.trim();

    if (name.isEmpty) {
      _showSnackbar('Please enter your name', isError: true);
      return;
    }
    if (_userId == null) {
      _showSnackbar('Session not found. Please login again.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await ProfileService.updateProfile(
      userId: _userId!,
      name: name,
      emoji: _selectedEmoji,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Session update karo
      await SessionManager.updateUser(result['user']);
      _showSnackbar(result['message']);
    } else {
      _showSnackbar(result['message'], isError: true);
    }
  }

  // ─── Snackbar helper ──────────────────────────────────────────────────────
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: ArriveTheme.dmSans.copyWith(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
        backgroundColor: isError
            ? Colors.redAccent.withOpacity(0.85)
            : ArriveTheme.green.withOpacity(0.85),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _fname.dispose();
    _email.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SimpleBottomBar(currentIndex: 4),
      backgroundColor: ArriveTheme.bg,
      body: OrbBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _back(context),
                const SizedBox(height: 32),

                Text(
                  'Edit\nprofile',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    color: ArriveTheme.text,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Update your profile details and keep things fresh.',
                  style: ArriveTheme.dmSans.copyWith(
                    fontSize: 13,
                    color: ArriveTheme.textSoft,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 30),

                // ── Emoji Avatar ──
                Center(
                  child: GestureDetector(
                    onTap: _showEmojiPickerSheet,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ArriveTheme.green.withOpacity(0.45),
                              width: 1.4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: ArriveTheme.glass,
                            child: Text(
                              _selectedEmoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 2, bottom: 4,
                          child: Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: ArriveTheme.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: ArriveTheme.bg, width: 2),
                            ),
                            child: const Icon(
                              Icons.emoji_emotions_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                _field('Name', 'Kezia', controller: _fname),
                const SizedBox(height: 14),
                _field('Email', 'you@email.com',
                    controller: _email,
                    type: TextInputType.emailAddress),
                const SizedBox(height: 34),

                // ── Save Button ──
                _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: ArriveTheme.green,
                    strokeWidth: 2,
                  ),
                )
                    : PrimaryButton(
                  label: 'Save Changes →',
                  onTap: _handleUpdateProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
      String label,
      String hint, {
        TextEditingController? controller,
        bool obscure = false,
        TextInputType type = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: ArriveTheme.dmSans.copyWith(
            fontSize: 11,
            letterSpacing: 1.1,
            color: ArriveTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: type,
          style: ArriveTheme.dmSans.copyWith(
            fontSize: 15,
            color: ArriveTheme.text,
            fontWeight: FontWeight.w300,
          ),
          cursorColor: ArriveTheme.green,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ArriveTheme.dmSans.copyWith(
              color: ArriveTheme.textMuted,
              fontWeight: FontWeight.w300,
            ),
            filled: true,
            fillColor: ArriveTheme.glass,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: ArriveTheme.glassBorder, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: ArriveTheme.glassBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: ArriveTheme.green.withOpacity(0.45), width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _back(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Text(
        '← Back',
        style: ArriveTheme.dmSans.copyWith(
          fontSize: 13,
          color: ArriveTheme.textMuted,
        ),
      ),
    );
  }
}