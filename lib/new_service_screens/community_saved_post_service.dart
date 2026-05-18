import 'dart:convert';
import 'package:http/http.dart' as http;

class CommunitySavePostService {
  static const String _baseUrl =
      'https://api.arrivejournal.com/public/api/community/posts/save';

  static Future<Map<String, dynamic>> savePost({
    required int userId,
    required int postId,
  }) async {
    final body = <String, dynamic>{
      'user_id': userId,
      'post_id': postId,
    };

    print('========== COMMUNITY SAVE POST API CALL ==========');
    print('URL     : $_baseUrl');
    print('USER ID : $userId');
    print('POST ID : $postId');
    print('BODY    : $body');

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('SAVE STATUS CODE : ${response.statusCode}');
      print('SAVE RAW RESPONSE: ${response.body}');
      print('=================================================');

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decoded is Map<String, dynamic>) {
          print('SAVE API SUCCESS : ${decoded['success']}');
          print('POST SAVED STATE : ${decoded['saved']}');
          print('SAVE MESSAGE     : ${decoded['message']}');

          return decoded;
        }

        throw Exception('Invalid save response format');
      }

      throw Exception(
        decoded is Map<String, dynamic>
            ? decoded['message']?.toString() ?? 'Unable to save post'
            : 'Unable to save post',
      );
    } catch (e) {
      print('COMMUNITY SAVE POST API ERROR: $e');
      rethrow;
    }
  }
}