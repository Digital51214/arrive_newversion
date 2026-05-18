import 'dart:convert';
import 'package:http/http.dart' as http;

class JournalAddService {
  static const String _baseUrl =
      'https://api.arrivejournal.com/public/api/save_detailed_entry';

  static Future<Map<String, dynamic>> saveDetailedEntry({
    required int userId,
    required String dayName,
    required String content,
    required String difficulties,
    required List<String> tags,
    required List<String> imagesBase64,
  }) async {
    try {
      print('========== SAVE JOURNAL API START ==========');
      print('User ID: $userId');
      print('Day Name: $dayName');
      print('Content: $content');
      print('Difficulties Emoji: $difficulties');
      print('Tags: $tags');
      print('Images Count: ${imagesBase64.length}');

      final body = {
        "user_id": userId,
        "day_name": dayName,
        "content": content,
        "difficulties": difficulties,
        "tags": tags,
        "images_base64": imagesBase64,
      };

      print('REQUEST BODY JSON: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      print('API STATUS CODE: ${response.statusCode}');
      print('API RESPONSE BODY: ${response.body}');

      final decoded = jsonDecode(response.body);

      print('DECODED RESPONSE: $decoded');
      print('========== SAVE JOURNAL API END ==========');

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded["status"] == "success") {
        return {
          "success": true,
          "data": decoded,
          "message": decoded["message"] ?? "Journal saved successfully",
          "journal_id": decoded["journal_id"] ?? 0,
        };
      }

      return {
        "success": false,
        "message": decoded["message"] ?? "Something went wrong",
        "data": decoded,
      };
    } catch (e) {
      print('SAVE JOURNAL API ERROR: $e');

      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
}