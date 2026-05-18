import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  static const String _url =
      'https://api.arrivejournal.com/public/api/arrive_login';

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    print('LOGIN API CALL STARTED');
    print('Email: ${email.trim()}');

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'password': password.trim(),
      }),
    );

    print('LOGIN STATUS CODE: ${response.statusCode}');
    print('LOGIN RESPONSE BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data['status'] == 'success') {
        print('LOGIN SUCCESS');
        return data;
      }
    }

    print('LOGIN FAILED');
    throw Exception(data['message'] ?? 'Login failed');
  }
}