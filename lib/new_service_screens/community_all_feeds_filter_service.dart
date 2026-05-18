import 'dart:convert';
import 'package:http/http.dart' as http;

class CommunityAllFeedsFilterService {
  static const String _baseUrl =
      'https://api.arrivejournal.com/public/api/community/posts';

  static Future<Map<String, dynamic>> fetchPosts({
    required Map<String, dynamic> body,
  }) async {
    print('========== COMMUNITY POSTS API CALL ==========');
    print('URL  : $_baseUrl');
    print('BODY : $body');

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('STATUS CODE : ${response.statusCode}');
      print('RAW RESPONSE: ${response.body}');
      print('==============================================');

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception('Invalid API response format');
      }

      throw Exception(
        decoded is Map<String, dynamic>
            ? decoded['message']?.toString() ?? 'Something went wrong'
            : 'Something went wrong',
      );
    } catch (e) {
      print('COMMUNITY POSTS API ERROR: $e');
      rethrow;
    }
  }
}