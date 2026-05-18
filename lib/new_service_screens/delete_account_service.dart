import 'dart:convert';
import 'package:http/http.dart' as http;

class AccountService {
  static const String _baseUrl = 'https://api.arrivejournal.com/public/api';

  static Future<Map<String, dynamic>> deleteAccount({
    required int userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/delete/account'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Account deleted successfully!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Something went wrong.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
}