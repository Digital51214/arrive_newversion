import 'dart:convert';
import 'package:http/http.dart' as http;

class JournalListService {
  static const String _url =
      'https://api.arrivejournal.com/public/api/get_user_journal';

  static Future<Map<String, dynamic>> getUserJournals({
    required int userId,
  }) async {
    try {
      print('GET USER JOURNALS API STARTED');
      print('USER ID: $userId');

      final body = {
        "user_id": userId,
      };

      print('REQUEST BODY: $body');

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      print('API STATUS CODE: ${response.statusCode}');
      print('API RESPONSE BODY: ${response.body}');

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": decoded["success"] == true,
          "journals": decoded["journals"] ?? [],
          "message": decoded["message"] ?? "",
        };
      }

      return {
        "success": false,
        "journals": [],
        "message": decoded["message"] ?? "Failed to get journals",
      };
    } catch (e) {
      print('GET USER JOURNALS API ERROR: $e');

      return {
        "success": false,
        "journals": [],
        "message": e.toString(),
      };
    }
  }
}