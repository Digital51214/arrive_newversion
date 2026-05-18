import 'package:arrive_newversion/new_onboarding_screens/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../new_home_screens/concept_b.dart';
import '../../new_service_screens/login_service.dart';
import '../../new_service_screens/session_manager.dart';
import '../theme/app_theme.dart';
import 'forget_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_email.text.trim().isEmpty || _password.text.trim().isEmpty) {
      print('LOGIN VALIDATION FAILED: Empty fields');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('LOGIN API CALL STARTED');

      final result = await LoginService.loginUser(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      print('LOGIN API SUCCESS');
      print('LOGIN RESULT: $result');

      final user = result['user'];

      await SessionManager.saveUserSession(user);

      print('USER SESSION SAVED');
      print('NAVIGATING TO MAIN SCREEN AND CLEARING BACK STACK');

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const ConceptBScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      print('LOGIN ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

                Text(
                  'Welcome\nback',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    color: ArriveTheme.text,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Log in to continue your journey.',
                  style: ArriveTheme.dmSans.copyWith(
                    fontSize: 13,
                    color: ArriveTheme.textSoft,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 32),

                _field(
                  'Email',
                  'you@email.com',
                  controller: _email,
                  type: TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                _field(
                  'Password',
                  'Enter your password',
                  controller: _password,
                  obscure: !_passwordVisible,
                  isPassword: true,
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: _isLoading
                                ? null
                                : (val) {
                              setState(() {
                                _rememberMe = val ?? false;
                              });
                            },
                            activeColor: ArriveTheme.green,
                            side: BorderSide(
                              color: ArriveTheme.glassBorder,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          'Remember me',
                          style: ArriveTheme.dmSans.copyWith(
                            fontSize: 12,
                            color: ArriveTheme.textSoft,
                          ),
                        ),
                      ],
                    ),

                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SendOtpScreen(),
                        ),
                      ),
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: ArriveTheme.green,
                          decoration: TextDecoration.underline,
                          decorationColor: ArriveTheme.green,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                PrimaryButton(
                  label: _isLoading ? 'Logging in...' : 'Login →',
                  onTap: _isLoading ? () {} : _handleLogin,
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
        bool isPassword = false,
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
          enabled: !_isLoading,
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
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _passwordVisible
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: ArriveTheme.textMuted,
                size: 20,
              ),
              onPressed: _isLoading
                  ? null
                  : () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            )
                : null,
            filled: true,
            fillColor: ArriveTheme.glass,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: ArriveTheme.glassBorder.withOpacity(0.6),
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
}