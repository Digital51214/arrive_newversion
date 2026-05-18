import 'dart:convert';
import 'package:http/http.dart' as http;

class AllCommunityPostRepliesService {
  static const String _url =
      'https://api.arrivejournal.com/public/api/community/posts/replies';

  static Future<Map<String, dynamic>> fetchReplies({
    required int userId,
    required int postId,
  }) async {
    print('========== FETCH POST REPLIES SERVICE START ==========');
    print('API URL : $_url');
    print('USER ID : $userId');
    print('POST ID : $postId');

    try {
      final body = {
        'user_id': userId,
        'post_id': postId,
      };

      print('REQUEST BODY : $body');

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('REPLIES STATUS CODE : ${response.statusCode}');
      print('REPLIES RAW BODY    : ${response.body}');

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid replies response format');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          decoded['message']?.toString() ?? 'Unable to fetch replies',
        );
      }

      if (decoded['success'] != true) {
        throw Exception(
          decoded['message']?.toString() ?? 'Replies not found',
        );
      }

      final data = decoded['data'];

      print('REPLIES FETCH SUCCESS');
      print('REPLIES COUNT : ${data is List ? data.length : 0}');
      print('========== FETCH POST REPLIES SERVICE END ==========');

      return decoded;
    } catch (e) {
      print('FETCH POST REPLIES SERVICE ERROR: $e');
      print('========== FETCH POST REPLIES SERVICE FAILED ==========');

      throw Exception(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}