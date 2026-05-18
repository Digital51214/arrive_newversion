import 'dart:convert';
import 'package:http/http.dart' as http;

class DailyPromptService {
  static const String _baseUrl =
      'https://api.arrivejournal.com/public/api/daily-prompt';

  /// Fetch today's daily prompt from API
  /// Returns prompt string, or null if failed
  static Future<String?> fetchTodayPrompt() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        if (json['success'] == true) {
          final prompt = json['data']?['prompt']?.toString();
          return prompt?.isNotEmpty == true ? prompt : null;
        }
      }

      return null;
    } catch (e) {
      print('DAILY PROMPT SERVICE ERROR: $e');
      return null;
    }
  }
}