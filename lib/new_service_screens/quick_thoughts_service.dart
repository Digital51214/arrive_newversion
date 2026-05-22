import 'dart:convert';
import 'package:http/http.dart' as http;

class QuickThoughtService {
  static const String _baseUrl = 'https://api.arrivejournal.com/public/api';
  static const String _apiKey = 'your-api-key-here'; // Replace with actual key

  static Future<QuickThoughtResponse> sendQuickThought({
    required String thought,
    required String mode,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/quick-thought'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'thought': thought,
        'mode': mode,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return QuickThoughtResponse.fromJson(data);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}

class QuickThoughtResponse {
  final String paragraph;
  final String q1;
  final String q2;
  final String q3;

  const QuickThoughtResponse({
    required this.paragraph,
    required this.q1,
    required this.q2,
    required this.q3,
  });

  factory QuickThoughtResponse.fromJson(Map<String, dynamic> json) {
    return QuickThoughtResponse(
      paragraph: json['paragraph'] as String? ?? '',
      q1: json['q1'] as String? ?? '',
      q2: json['q2'] as String? ?? '',
      q3: json['q3'] as String? ?? '',
    );
  }

  List<String> get followUpQuestions => [q1, q2, q3];
}