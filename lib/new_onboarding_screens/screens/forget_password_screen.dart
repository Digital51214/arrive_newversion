import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../new_service_screens/forget_password_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN 1 — Send OTP
// ─────────────────────────────────────────────────────────────────────────────
class SendOtpScreen extends StatefulWidget {
  const SendOtpScreen({super.key});

  @override
  State<SendOtpScreen> createState() => _SendOtpScreenState();
}

class _SendOtpScreenState extends State<SendOtpScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();

    print('========== SEND OTP TAPPED ==========');
    print('EMAIL : $email');

    if (email.isEmpty) {
      _showSnack('Please enter your email address.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showSnack('Please enter a valid email address.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('CALLING SEND OTP API...');

      final result = await ForgotPasswordService.sendOtp(email: email);

      print('SEND OTP RESULT : $result');

      if (!mounted) return;

      if (result['success'] == true) {
        final otpFromApi = result['otp']?.toString() ?? '';

        print('OTP SENT SUCCESSFULLY');
        print('OTP FROM API : $otpFromApi');

        if (otpFromApi.isEmpty) {
          _showSnack('OTP not received from server. Please try again.');
          return;
        }

        _showSnack(result['message'] ?? 'OTP sent to your email.');

        Navigator.push(
          context,
          _slide(
            EnterOtpScreen(
              email: email,
              otpFromApi: otpFromApi,
            ),
          ),
        );
      } else {
        print('SEND OTP FAILED : ${result['message']}');
        _showSnack(result['message'] ?? 'Failed to send OTP. Try again.');
      }
    } catch (e) {
      print('SEND OTP ERROR: $e');

      if (!mounted) return;

      _showSnack(
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArriveTheme.bg,
      body: OrbBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                _title(
                  'Forgot\npassword?',
                  "Enter your email and we'll send you a verification code.",
                ),

                const SizedBox(height: 32),

                _field(
                  'Email',
                  'you@email.com',
                  controller: _emailController,
                  type: TextInputType.emailAddress,
                ),

                const Spacer(),

                _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: ArriveTheme.green,
                  ),
                )
                    : PrimaryButton(
                  label: 'Send OTP →',
                  onTap: _handleSendOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN 2 — Enter OTP
// ─────────────────────────────────────────────────────────────────────────────
class EnterOtpScreen extends StatefulWidget {
  final String email;
  final String otpFromApi;

  const EnterOtpScreen({
    super.key,
    required this.email,
    required this.otpFromApi,
  });

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final _otpController = TextEditingController();

  bool _isVerifying = false;
  bool _isResending = false;
  bool _otpExpired = false;

  late String _currentOtp;

  @override
  void initState() {
    super.initState();

    _currentOtp = widget.otpFromApi;

    print('========== ENTER OTP SCREEN INIT ==========');
    print('EMAIL       : ${widget.email}');
    print('CURRENT OTP : $_currentOtp');
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    if (_isVerifying) return;

    final otp = _otpController.text.trim();

    print('========== VERIFY OTP TAPPED ==========');
    print('EMAIL       : ${widget.email}');
    print('ENTERED OTP : $otp');
    print('CURRENT OTP : $_currentOtp');
    print('OTP EXPIRED : $_otpExpired');

    if (_otpExpired) {
      _showSnack('OTP expired. Please resend OTP.');
      return;
    }

    if (_currentOtp.isEmpty) {
      _showSnack('OTP expired. Please resend OTP.');
      return;
    }

    if (otp.isEmpty) {
      _showSnack('Please enter the OTP code.');
      return;
    }

    if (otp.length != 4) {
      _showSnack('Please enter 4 digit OTP code.');
      return;
    }

    setState(() => _isVerifying = true);

    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    if (otp != _currentOtp) {
      print('OTP INCORRECT');

      setState(() => _isVerifying = false);

      _showSnack('Your OTP is incorrect');
      return;
    }

    print('OTP CORRECT — NAVIGATING TO CHANGE PASSWORD SCREEN');

    setState(() => _isVerifying = false);

    await Navigator.push(
      context,
      _slide(
        ChangePasswordScreen(
          email: widget.email,
          otp: otp,
        ),
      ),
    );

    if (!mounted) return;

    print('RETURNED FROM CHANGE PASSWORD SCREEN — OTP EXPIRED');

    setState(() {
      _otpExpired = true;
      _currentOtp = '';
      _otpController.clear();
    });

    _showSnack('OTP expired. Please resend OTP.');
  }

  Future<void> _handleResendOtp() async {
    if (_isResending) return;

    print('========== RESEND OTP TAPPED ==========');
    print('EMAIL : ${widget.email}');

    setState(() => _isResending = true);

    try {
      final result = await ForgotPasswordService.sendOtp(
        email: widget.email,
      );

      print('RESEND OTP RESULT : $result');

      if (!mounted) return;

      if (result['success'] == true) {
        final newOtp = result['otp']?.toString() ?? '';

        if (newOtp.isEmpty) {
          _showSnack('New OTP not received. Please try again.');
          return;
        }

        print('OTP RESENT SUCCESSFULLY');
        print('NEW OTP : $newOtp');

        setState(() {
          _currentOtp = newOtp;
          _otpExpired = false;
          _otpController.clear();
        });

        _showSnack('New OTP sent to ${widget.email}');
      } else {
        print('RESEND OTP FAILED : ${result['message']}');
        _showSnack(result['message'] ?? 'Failed to resend OTP.');
      }
    } catch (e) {
      print('RESEND OTP ERROR: $e');

      if (!mounted) return;

      _showSnack(
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArriveTheme.bg,
      body: OrbBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(
                  'Enter\nOTP',
                  'We sent a verification code to ${widget.email}',
                ),

                const SizedBox(height: 32),

                _field(
                  'OTP Code',
                  'Enter 4 digit code',
                  controller: _otpController,
                  type: TextInputType.number,
                  maxLength: 4,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),

                if (_otpExpired) ...[
                  const SizedBox(height: 10),
                  Text(
                    'OTP expired. Please resend OTP.',
                    style: ArriveTheme.dmSans.copyWith(
                      fontSize: 12,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                Center(
                  child: _isResending
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ArriveTheme.green,
                    ),
                  )
                      : GestureDetector(
                    onTap: _handleResendOtp,
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: ArriveTheme.green,
                        decoration: TextDecoration.underline,
                        decorationColor: ArriveTheme.green,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                _isVerifying
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: ArriveTheme.green,
                  ),
                )
                    : PrimaryButton(
                  label: 'Verify OTP →',
                  onTap: _handleVerifyOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN 3 — Change Password
// ─────────────────────────────────────────────────────────────────────────────
class ChangePasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ChangePasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    print('========== CHANGE PASSWORD TAPPED ==========');
    print('EMAIL : ${widget.email}');
    print('OTP   : ${widget.otp}');

    if (password.isEmpty) {
      _showSnack('Please enter a new password.');
      return;
    }

    if (password.length < 6) {
      _showSnack('Password must be at least 6 characters.');
      return;
    }

    if (confirmPassword.isEmpty) {
      _showSnack('Please confirm your password.');
      return;
    }

    if (password != confirmPassword) {
      _showSnack('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('CALLING RESET PASSWORD API...');

      final result = await ForgotPasswordService.resetPassword(
        email: widget.email,
        otp: widget.otp,
        password: password,
        passwordConfirmation: confirmPassword,
      );

      print('RESET PASSWORD RESULT : $result');

      if (!mounted) return;

      if (result['success'] == true) {
        print('PASSWORD RESET SUCCESSFUL — NAVIGATING TO LOGIN SCREEN');

        _showSnack(result['message'] ?? 'Password changed successfully!');

        await Future.delayed(const Duration(milliseconds: 800));

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      } else {
        print('RESET PASSWORD FAILED : ${result['message']}');

        _showSnack(result['message'] ?? 'Failed to reset password. Try again.');
      }
    } catch (e) {
      print('RESET PASSWORD ERROR: $e');

      if (!mounted) return;

      _showSnack(
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArriveTheme.bg,
      body: OrbBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(
                  'Change\npassword',
                  'Create a new secure password for your account.',
                ),

                const SizedBox(height: 32),

                _field(
                  'New Password',
                  'Enter new password',
                  controller: _passwordController,
                  obscure: true,
                ),

                const SizedBox(height: 14),

                _field(
                  'Confirm Password',
                  'Re-enter password',
                  controller: _confirmPasswordController,
                  obscure: true,
                ),

                const Spacer(),

                _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: ArriveTheme.green,
                  ),
                )
                    : PrimaryButton(
                  label: 'Change Password →',
                  onTap: _handleChangePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Helpers
// ─────────────────────────────────────────────────────────────────────────────
Widget _title(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: GoogleFonts.cormorantGaramond(
          fontSize: 36,
          fontWeight: FontWeight.w300,
          color: ArriveTheme.text,
          height: 1.15,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: ArriveTheme.dmSans.copyWith(
          fontSize: 13,
          color: ArriveTheme.textSoft,
          fontWeight: FontWeight.w300,
        ),
      ),
    ],
  );
}

Widget _field(
    String label,
    String hint, {
      TextEditingController? controller,
      bool obscure = false,
      TextInputType type = TextInputType.text,
      int? maxLength,
      List<TextInputFormatter>? inputFormatters,
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
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        textAlign: label == 'OTP Code' ? TextAlign.center : TextAlign.start,
        style: ArriveTheme.dmSans.copyWith(
          fontSize: 15,
          color: ArriveTheme.text,
          fontWeight: FontWeight.w300,
        ),
        cursorColor: ArriveTheme.green,
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          hintStyle: ArriveTheme.dmSans.copyWith(
            color: ArriveTheme.textMuted,
            fontWeight: FontWeight.w300,
          ),
          filled: true,
          fillColor: ArriveTheme.glass,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(
              color: ArriveTheme.glassBorder,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(
              color: ArriveTheme.glassBorder,
              width: 1,
            ),
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

PageRouteBuilder _slide(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 380),
  );
}