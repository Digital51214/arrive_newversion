import 'dart:convert';
import 'package:http/http.dart' as http;

class JournalStreakService {
  static const String _baseUrl =
      'https://api.arrivejournal.com/public/api/journal/streak';

  /// Fetch journal streak count for a user
  /// Returns streak count int, or 0 if failed
  static Future<int> fetchStreak({required int userId}) async {
    print('========== JOURNAL STREAK SERVICE ==========');
    print('URL    : $_baseUrl');
    print('USER ID: $userId');

    try {
      final response = await http
          .post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'user_id': userId}),
      )
          .timeout(const Duration(seconds: 10));

      print('STATUS CODE   : ${response.statusCode}');
      print('RESPONSE BODY : ${response.body}');

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && decoded['success'] == true) {
        final streak = (decoded['streak_count'] as num?)?.toInt() ?? 0;
        print('STREAK COUNT  : $streak');
        print('=============================================');
        return streak;
      }

      print('STREAK FETCH FAILED: ${decoded['message']}');
      print('=============================================');
      return 0;
    } catch (e) {
      print('JOURNAL STREAK SERVICE ERROR: $e');
      print('=============================================');
      return 0;
    }
  }
}