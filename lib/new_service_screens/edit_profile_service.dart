import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  static const String _baseUrl = 'https://api.arrivejournal.com/public/api';

  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String name,
    required String emoji,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/update_profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'name': name,
          'emoji': emoji,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Profile updated successfully!',
          'user': data['user'],
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