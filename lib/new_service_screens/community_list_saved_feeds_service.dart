import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class CommunityListSavedFeedsService {
  static const String _baseUrl =
      'https://api.arrivejournal.com/public/api/community/saved';

  static Future<Map<String, dynamic>> fetchSavedPosts({
    required int userId,
    int perPage = 10,
    int page = 1,
  }) async {
    final body = <String, dynamic>{
      'user_id': userId,
      'per_page': perPage,
      'page': page,
    };

    print('========== COMMUNITY SAVED FEEDS SERVICE ==========');
    print('URL  : $_baseUrl');
    print('BODY : $body');

    try {
      final response = await http
          .post(
        Uri.parse(_baseUrl),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 15));

      print('STATUS CODE   : ${response.statusCode}');
      print('RESPONSE BODY : ${response.body}');

      final decodedJson = jsonDecode(response.body);

      if (decodedJson is! Map<String, dynamic>) {
        throw Exception('Invalid server response');
      }

      if (response.statusCode == 200 && decodedJson['success'] == true) {
        final data = decodedJson['data'] as Map<String, dynamic>?;

        print('SAVED POSTS SUCCESS');
        print('TOTAL        : ${data?['total']}');
        print('CURRENT PAGE : ${data?['current_page']}');
        print('LAST PAGE    : ${data?['last_page']}');

        return decodedJson;
      }

      final message =
          decodedJson['message']?.toString() ?? 'Failed to load saved posts';

      print('SAVED POSTS FAILED: $message');
      throw Exception(message);
    } on TimeoutException {
      print('SAVED POSTS ERROR: Request timed out');
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      print('SAVED POSTS ERROR: Invalid JSON');
      throw Exception('Invalid server response');
    } catch (e) {
      print('SAVED POSTS ERROR: $e');
      rethrow;
    }
  }
}