import 'package:arrive_newversion/new_onboarding_screens/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../new_service_screens/session_manager.dart';
import '../../new_service_screens/sign_up_service.dart';
import '../theme/app_theme.dart';
import 'postpartum_screen.dart';
import 'walkthrough_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String? _selectedGender;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final _fname = TextEditingController();
  final _lname = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  void _selectGender(String g) {
    if (_isLoading) return;
    setState(() => _selectedGender = g);
  }

  Future<void> _handleContinue() async {
    if (_fname.text.trim().isEmpty ||
        _lname.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.trim().isEmpty ||
        _selectedGender == null) {
      print('SIGNUP VALIDATION FAILED');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (_selectedGender == 'female') {
      print('FEMALE SELECTED: OPEN POSTPARTUM SCREEN');

      Navigator.push(
        context,
        _slide(
          PostpartumScreen(
            firstName: _fname.text,
            lastName: _lname.text,
            email: _email.text,
            password: _password.text,
            gender: _selectedGender!,
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('SIGNUP API CALL STARTED');

      final result = await SignupService.registerUser(
        firstName: _fname.text,
        lastName: _lname.text,
        email: _email.text,
        gender: _selectedGender!,
        password: _password.text,
        postpartumMode: 0,
      );

      final user = result['user'];

      print('SIGNUP SUCCESS');
      print('SIGNUP USER DATA: $user');

      await SessionManager.saveUserSession(user);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        _slide(const WalkthroughScreen(postpartumEnabled: false)),
      );
    } catch (e) {
      print('SIGNUP ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
      print('SIGNUP API CALL ENDED');
    }
  }

  @override
  void dispose() {
    _fname.dispose();
    _lname.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArriveTheme.bg,
      body: OrbBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Create your\naccount',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: ArriveTheme.text,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Takes less than a minute. No credit card needed.',
                      style: ArriveTheme.dmSans.copyWith(
                        fontSize: 13,
                        color: ArriveTheme.textSoft,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              'First Name',
                              'Kezia',
                              controller: _fname,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              'Last Name',
                              'Isaac',
                              controller: _lname,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _field(
                        'Email',
                        'you@email.com',
                        controller: _email,
                        type: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        'Password',
                        'Create a password',
                        controller: _password,
                        obscure: !_isPasswordVisible,
                        isPassword: true,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'I IDENTIFY AS',
                        style: ArriveTheme.dmSans.copyWith(
                          fontSize: 11,
                          letterSpacing: 1.1,
                          color: ArriveTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _genderRow(),
                      const SizedBox(height: 22),
                      PrimaryButton(
                        label: _isLoading ? 'Creating account...' : 'Continue →',
                        onTap: _isLoading ? () {} : _handleContinue,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: ArriveTheme.dmSans.copyWith(
                              fontSize: 11,
                              color: ArriveTheme.textMuted,
                              height: 1.6,
                            ),
                            children: [
                              const TextSpan(
                                text: 'By continuing you agree to our ',
                              ),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: ArriveTheme.textSoft,
                                  decoration: TextDecoration.underline,
                                ),

                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: ArriveTheme.textSoft,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: ArriveTheme.dmSans.copyWith(
                              fontSize: 12,
                              color: ArriveTheme.textMuted,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Log In.",
                              style: TextStyle(
                                color: ArriveTheme.green,
                                decoration: TextDecoration.underline,
                                decorationColor: ArriveTheme.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: ArriveTheme.textMuted,
                size: 20,
              ),
              onPressed: _isLoading
                  ? null
                  : () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            )
                : null,
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: ArriveTheme.glassBorder, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: ArriveTheme.glassBorder, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
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

  Widget _genderRow() {
    final options = [
      {'icon': '♀', 'label': 'Female', 'val': 'female'},
      {'icon': '♂', 'label': 'Male', 'val': 'male'},
      {'icon': '⚧', 'label': 'Non-binary', 'val': 'other'},
      {'icon': '🤍', 'label': 'Prefer not', 'val': 'prefer-not'},
    ];

    return Row(
      children: options.map((o) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: o == options.last ? 0 : 8),
            child: GestureDetector(
              onTap: () => _selectGender(o['val']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  color: _selectedGender == o['val']
                      ? ArriveTheme.green.withOpacity(0.1)
                      : ArriveTheme.glass,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedGender == o['val']
                        ? ArriveTheme.green.withOpacity(0.5)
                        : ArriveTheme.glassBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      o['icon']!,
                      style: TextStyle(
                        fontSize: 18,
                        color: _selectedGender == o['val']
                            ? ArriveTheme.green
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      o['label']!,
                      textAlign: TextAlign.center,
                      style: ArriveTheme.dmSans.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: _selectedGender == o['val']
                            ? ArriveTheme.green
                            : Colors.grey,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
      ),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 380),
  );
}