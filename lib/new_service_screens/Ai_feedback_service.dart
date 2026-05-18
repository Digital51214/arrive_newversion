import 'dart:convert';
import 'package:http/http.dart' as http;

class AiFeedbackService {
  static const String _apiUrl =
      'https://api.arrivejournal.com/public/api/journal_ai_insight';

  static Future<Map<String, dynamic>> getAiFeedback({
    required int userId,
    required int journalId,
    required String mode,
  }) async {
    try {
      final requestBody = {
        "user_id": userId,
        "journal_id": journalId,
        "mode": mode.toLowerCase(),
      };

      print('========== AI FEEDBACK API START ==========');
      print('API URL: $_apiUrl');
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('========== AI FEEDBACK API END ==========');

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        return Map<String, dynamic>.from(decoded);
      } else {
        throw Exception(decoded['message'] ?? 'AI feedback API failed');
      }
    } catch (e) {
      print('AI Feedback Service Error: $e');
      rethrow;
    }
  }
}