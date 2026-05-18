import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordService {
  static const String _baseUrl = 'https://api.arrivejournal.com/public/api';

  static Future<Map<String, dynamic>> updatePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    print('PASSWORD UPDATE REQUEST —');
    print('USER ID: $userId');
    print('OLD PASSWORD: $oldPassword');
    print('NEW PASSWORD: $newPassword');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/update/password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      print('RESPONSE STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 200) {
        print('PASSWORD UPDATE SUCCESS: ${data['message']}');
        return {
          'success': true,
          'message': data['message'] ?? 'Password updated successfully!',
        };
      } else {
        print('PASSWORD UPDATE FAILED: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Something went wrong.',
        };
      }
    } catch (e) {
      print('PASSWORD UPDATE ERROR: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
}