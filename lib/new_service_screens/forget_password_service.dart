import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgotPasswordService {
  static const String _sendOtpUrl =
      'https://api.arrivejournal.com/public/api/send_otp';

  static const String _resetPasswordUrl =
      'https://api.arrivejournal.com/public/api/reset_password';

  // ── Send OTP ──────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> sendOtp({
    required String email,
  }) async {
    print('========== SEND OTP API START ==========');
    print('EMAIL : $email');
    print('URL   : $_sendOtpUrl');

    try {
      final body = {
        "email": email.trim(),
      };

      print('REQUEST BODY : $body');

      final response = await http.post(
        Uri.parse(_sendOtpUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      print('STATUS CODE    : ${response.statusCode}');
      print('RESPONSE BODY  : ${response.body}');

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final bool isSuccess =
            decoded['status']?.toString().toLowerCase() == 'success';

        print('IS SUCCESS : $isSuccess');
        print('MESSAGE    : ${decoded['message']}');
        print('OTP        : ${decoded['otp']}');
        print('========== SEND OTP API END ==========');

        return {
          "success": isSuccess,
          "message": decoded['message']?.toString() ?? 'OTP sent.',
          "otp": decoded['otp']?.toString() ?? '',
        };
      }

      print('SEND OTP FAILED — STATUS : ${response.statusCode}');
      print('========== SEND OTP API END ==========');

      return {
        "success": false,
        "message": decoded['message']?.toString() ?? 'Failed to send OTP.',
        "otp": '',
      };
    } catch (e) {
      print('SEND OTP API ERROR : $e');
      print('========== SEND OTP API END ==========');

      return {
        "success": false,
        "message": e.toString(),
        "otp": '',
      };
    }
  }

  // ── Reset Password ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    print('========== RESET PASSWORD API START ==========');
    print('EMAIL : $email');
    print('OTP   : $otp');
    print('URL   : $_resetPasswordUrl');

    try {
      final body = {
        "email": email.trim(),
        "otp": otp.trim(),
        "password": password,
        "password_confirmation": passwordConfirmation,
      };

      print('REQUEST BODY : $body');

      final response = await http.post(
        Uri.parse(_resetPasswordUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      print('STATUS CODE    : ${response.statusCode}');
      print('RESPONSE BODY  : ${response.body}');

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final bool isSuccess =
            decoded['status']?.toString().toLowerCase() == 'success';

        print('IS SUCCESS : $isSuccess');
        print('MESSAGE    : ${decoded['message']}');
        print('========== RESET PASSWORD API END ==========');

        return {
          "success": isSuccess,
          "message": decoded['message']?.toString() ?? 'Password reset.',
        };
      }

      print('RESET PASSWORD FAILED — STATUS : ${response.statusCode}');
      print('========== RESET PASSWORD API END ==========');

      return {
        "success": false,
        "message":
        decoded['message']?.toString() ?? 'Failed to reset password.',
      };
    } catch (e) {
      print('RESET PASSWORD API ERROR : $e');
      print('========== RESET PASSWORD API END ==========');

      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
}