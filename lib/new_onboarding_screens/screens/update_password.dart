import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../new_bottom_bar/bottom_nav_bar.dart';
import '../../new_service_screens/session_manager.dart';
import '../../new_service_screens/update_password_service.dart';
import '../theme/app_theme.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _currentPassword = TextEditingController();
  final _newPassword     = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _isLoading      = false;
  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;

  // ─── Validation ───────────────────────────────────────────────────────────
  String? _validate() {
    final current = _currentPassword.text.trim();
    final newPass = _newPassword.text.trim();
    final confirm = _confirmPassword.text.trim();

    if (current.isEmpty) return 'Please enter your current password.';
    if (newPass.isEmpty) return 'Please enter a new password.';
    if (newPass.length < 8) return 'New password must be at least 8 characters.';
    if (confirm.isEmpty) return 'Please confirm your new password.';
    if (newPass != confirm) return 'Passwords do not match.';
    if (current == newPass) return 'New password must be different from current.';

    return null;
  }

  // ─── Handle Update ────────────────────────────────────────────────────────
  Future<void> _handleUpdatePassword() async {
    final error = _validate();
    if (error != null) {
      _showSnackbar(error, isError: true);
      return;
    }

    final userId = await SessionManager.getUserId();

    if (userId == 0) {
      _showSnackbar('Session not found. Please login again.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    print('CALLING PASSWORD UPDATE API...');

    final result = await PasswordService.updatePassword(
      userId: userId,
      oldPassword: _currentPassword.text.trim(),
      newPassword: _newPassword.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      print('PASSWORD UPDATED SUCCESSFULLY');
      _currentPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      _showSnackbar(result['message']);
    } else {
      print('PASSWORD UPDATE FAILED: ${result['message']}');
      _showSnackbar(result['message'], isError: true);
    }
  }

  // ─── Snackbar ─────────────────────────────────────────────────────────────
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ keyboard aane par screen resize hoti hai
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: const SimpleBottomBar(currentIndex: 4),
      backgroundColor: ArriveTheme.bg,
      body: OrbBackground(
        child: SafeArea(
          child: SingleChildScrollView( // ✅ Spacer hata ke scroll add kiya
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _back(context),

                const SizedBox(height: 40),

                Text(
                  'Update\npassword',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    color: ArriveTheme.text,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Choose a new password to keep your account secure.',
                  style: ArriveTheme.dmSans.copyWith(
                    fontSize: 13,
                    color: ArriveTheme.textSoft,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 32),

                _field(
                  'Current Password',
                  'Enter current password',
                  controller: _currentPassword,
                  obscure: _obscureCurrent,
                  onToggle: () => setState(
                        () => _obscureCurrent = !_obscureCurrent,
                  ),
                ),

                const SizedBox(height: 14),

                _field(
                  'New Password',
                  'Enter new password',
                  controller: _newPassword,
                  obscure: _obscureNew,
                  onToggle: () => setState(
                        () => _obscureNew = !_obscureNew,
                  ),
                ),

                const SizedBox(height: 14),

                _field(
                  'Confirm Password',
                  'Re-enter new password',
                  controller: _confirmPassword,
                  obscure: _obscureConfirm,
                  onToggle: () => setState(
                        () => _obscureConfirm = !_obscureConfirm,
                  ),
                ),

                const SizedBox(height: 40), // ✅ Spacer ki jagah fixed height

                _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: ArriveTheme.green,
                    strokeWidth: 2,
                  ),
                )
                    : PrimaryButton(
                  label: 'Update Password →',
                  onTap: _handleUpdatePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Field with eye toggle ────────────────────────────────────────────────
  Widget _field(
      String label,
      String hint, {
        TextEditingController? controller,
        bool obscure = false,
        VoidCallback? onToggle,
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
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: onToggle != null
                ? GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: ArriveTheme.textMuted,
              ),
            )
                : null,
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
                color: ArriveTheme.green.withOpacity(0.45),
                width: 1.5,
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