import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupService {
  static const String _baseUrl =
      'https://api.arrivejournal.com/public/api/arrive_register';

  static Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required String password,
    required int postpartumMode,
  }) async {
    final body = {
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email': email.trim().toLowerCase(),
      'gender': gender.trim().toLowerCase(),
      'password': password,
      'password_confirmation': password,
      'postpartum_mode': postpartumMode,
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(data);
    }

    if (data is Map && data['errors'] != null) {
      final errors = data['errors'] as Map;
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        throw Exception(firstError.first.toString());
      }
    }

    throw Exception(data['message'] ?? 'Registration failed');
  }
}