import 'package:arrive_newversion/new_onboarding_screens/screens/login_screen.dart';
import 'package:arrive_newversion/new_onboarding_screens/screens/update_password.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../new_bottom_bar/bottom_nav_bar.dart';
import '../../new_service_screens/delete_account_service.dart';
import '../../new_service_screens/session_manager.dart';

import '../theme/app_theme.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _firstName = 'Kezia';
  String _email     = 'you@email.com';
  String _emoji     = '🌸';
  bool _isDeleting  = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ─── Load user from session ───────────────────────────────────────────────
  Future<void> _loadUserData() async {
    final firstName = await SessionManager.getFirstName();
    final email     = await SessionManager.getEmail();
    final emoji     = await SessionManager.getEmoji();

    if (!mounted) return;

    setState(() {
      _firstName = firstName.isEmpty ? 'Kezia' : firstName;
      _email     = email.isEmpty ? 'you@email.com' : email;
      _emoji     = emoji;
    });
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> _handleLogout() async {
    try {
      await SessionManager.clearSession();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      _showSnackbar('Logout failed. Please try again.', isError: true);
    }
  }

  // ─── Delete Account ───────────────────────────────────────────────────────
  Future<void> _handleDeleteAccount() async {
    final userId = await SessionManager.getUserId();

    if (userId == 0) {
      _showSnackbar('Session not found. Please login again.', isError: true);
      return;
    }

    setState(() => _isDeleting = true);

    final result = await AccountService.deleteAccount(userId: userId);

    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (result['success'] == true) {
      await SessionManager.clearSession();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
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

  // ─── Dialogs ──────────────────────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _themeDialog(
        context: context,
        icon: Icons.logout_rounded,
        iconColor: ArriveTheme.green,
        title: 'Logout?',
        message: 'Are you sure you want to sign out from your account?',
        cancelText: 'Cancel',
        actionText: 'Logout',
        actionColor: ArriveTheme.green,
        onAction: () {
          Navigator.pop(context);
          _handleLogout();
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _themeDialog(
        context: context,
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.redAccent,
        title: 'Delete Account?',
        message: 'This action is permanent and cannot be undone.',
        cancelText: 'Cancel',
        actionText: _isDeleting ? 'Deleting...' : 'Delete',
        actionColor: Colors.redAccent,
        onAction: () {
          Navigator.pop(context);
          _handleDeleteAccount();
        },
      ),
    );
  }

  Widget _themeDialog({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String cancelText,
    required String actionText,
    required Color actionColor,
    required VoidCallback onAction,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: ArriveTheme.bg.withOpacity(0.95),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ArriveTheme.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: ArriveTheme.dmSans.copyWith(
                fontSize: 17,
                color: ArriveTheme.text,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ArriveTheme.dmSans.copyWith(
                fontSize: 12,
                color: ArriveTheme.textMuted,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: ArriveTheme.glass,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: ArriveTheme.glassBorder),
                      ),
                      child: Center(
                        child: Text(
                          cancelText,
                          style: ArriveTheme.dmSans.copyWith(
                            fontSize: 13,
                            color: ArriveTheme.textSoft,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: actionColor,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: _isDeleting
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          actionText,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
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
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: danger ? Colors.red.withOpacity(0.08) : ArriveTheme.glass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: danger
                ? Colors.red.withOpacity(0.3)
                : ArriveTheme.glassBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: danger ? Colors.redAccent : ArriveTheme.green,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ArriveTheme.dmSans.copyWith(
                      fontSize: 14,
                      color: danger ? Colors.redAccent : ArriveTheme.text,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: ArriveTheme.dmSans.copyWith(
                      fontSize: 11,
                      color: ArriveTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SimpleBottomBar(currentIndex: 4),
      backgroundColor: ArriveTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _back(context),

              const SizedBox(height: 30),

              Text(
                'Your Profile',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 32,
                  color: ArriveTheme.text,
                ),
              ),

              const SizedBox(height: 20),

              // ── Emoji Avatar ──
              Center(
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ArriveTheme.green.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: ArriveTheme.glass,
                    child: Text(
                      _emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── First Name ──
              Center(
                child: Text(
                  _firstName,
                  style: ArriveTheme.dmSans.copyWith(
                    fontSize: 18,
                    color: ArriveTheme.text,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Center(
                child: Text(
                  _email,
                  style: ArriveTheme.dmSans.copyWith(
                    fontSize: 13,
                    color: ArriveTheme.textMuted,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _profileTile(
                icon: Icons.person,
                title: 'Edit Profile',
                subtitle: 'Update your info',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                  _loadUserData();
                },
              ),

              const SizedBox(height: 12),

              _profileTile(
                icon: Icons.lock,
                title: 'Update Password',
                subtitle: 'Change password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UpdatePasswordScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _profileTile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out',
                onTap: () => _showLogoutDialog(context),
                danger: true,
              ),

              const SizedBox(height: 12),

              _profileTile(
                icon: Icons.delete,
                title: 'Delete Account',
                subtitle: 'Permanent action',
                onTap: () => _showDeleteDialog(context),
                danger: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}