import 'dart:convert';
import 'package:http/http.dart' as http;

class CommunityPostService {
  static const String _baseUrl =
      'https://api.arrivejournal.com/public/api/community/posts/create';

  static String _mapCommunityType(String mode) {
    switch (mode.trim().toLowerCase()) {
      case 'speak freely mode':
        return 'free_speak';
      case 'postpartum mode':
      default:
        return 'postpartum';
    }
  }

  static bool _parseBool(dynamic value) {
    if (value == true) return true;
    if (value == false) return false;

    final text = value?.toString().toLowerCase().trim();
    return text == '1' || text == 'true' || text == 'yes';
  }

  static Future<Map<String, dynamic>> createPost({
    required int userId,
    required String content,
    required String type,
    required bool isAnonymous,
    required String mode,
  }) async {
    try {
      final String finalPostType =
      isAnonymous ? 'anonymous' : type.trim();

      final body = {
        'user_id': userId,
        'content': content.trim(),
        'community_type': _mapCommunityType(mode),
        'post_type': finalPostType,
        'is_anonymous': isAnonymous,
      };

      print('========== CREATE COMMUNITY POST ==========');
      print('URL: $_baseUrl');
      print('BODY: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid server response');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final postData = decoded['data'] as Map<String, dynamic>? ?? {};

        final String apiPostType =
            postData['post_type']?.toString().trim().toLowerCase() ??
                finalPostType;

        final bool finalIsAnonymous = isAnonymous ||
            apiPostType == 'anonymous' ||
            _parseBool(postData['is_anonymous']);

        return {
          'success': decoded['success'] == true,
          'message': decoded['message']?.toString() ??
              'Post created successfully.',
          'data': {
            'id': postData['id'],
            'content': postData['content'] ?? content.trim(),
            'community_type': postData['community_type'] ?? _mapCommunityType(mode),
            'post_type': apiPostType,
            'is_anonymous': finalIsAnonymous,
            'hug_count': postData['hug_count'] ?? 0,
            'feel_count': postData['feel_count'] ?? 0,
            'reply_count': postData['reply_count'] ?? 0,
            'user_hugged': postData['user_hugged'] ?? false,
            'user_felt': postData['user_felt'] ?? false,
            'user_saved': postData['user_saved'] ?? false,
            'created_at': postData['created_at'],
            'author_name': finalIsAnonymous
                ? 'Anonymous'
                : postData['author_name']?.toString() ?? 'User',
          }
        };
      }

      throw Exception(decoded['message'] ?? 'Post creation failed');
    } catch (e) {
      print('CREATE POST ERROR: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}