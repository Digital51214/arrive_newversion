import 'dart:convert';
import 'package:http/http.dart' as http;

class CommunityPostReplyService {
  static const String _baseUrl =
      'https://api.arrivejournal.com/public/api/community/posts/replies/create';

  static Future<Map<String, dynamic>> createReply({
    required int userId,
    required int postId,
    required String content,
    required bool isAnonymous,
  }) async {
    print('========== CREATE REPLY SERVICE START ==========');
    print('API URL      : $_baseUrl');
    print('USER ID      : $userId');
    print('POST ID      : $postId');
    print('CONTENT      : $content');
    print('IS ANONYMOUS : $isAnonymous');

    try {
      final body = {
        'user_id': userId,
        'post_id': postId,
        'content': content,
        'is_anonymous': isAnonymous,
      };

      print('REQUEST BODY : $body');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('REPLY STATUS CODE : ${response.statusCode}');
      print('REPLY RAW BODY    : ${response.body}');

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid reply response format');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          decoded['message']?.toString() ?? 'Unable to add reply',
        );
      }

      if (decoded['success'] != true) {
        throw Exception(
          decoded['message']?.toString() ?? 'Reply not added',
        );
      }

      print('REPLY ADDED SUCCESSFULLY');
      print('REPLY DATA : ${decoded['data']}');
      print('========== CREATE REPLY SERVICE END ==========');

      return decoded;
    } catch (e) {
      print('CREATE REPLY SERVICE ERROR: $e');
      print('========== CREATE REPLY SERVICE FAILED ==========');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}