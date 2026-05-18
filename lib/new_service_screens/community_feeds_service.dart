import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class CommunityFeedsService {
  static const String _baseUrl =
      'https://api.arrivejournal.com/public/api';

  // ─── Fetch Posts ────────────────────────────────────────────────────────────
  // Body: user_id, community_type, per_page, page, (optional) type, is_anonymous
  static Future<Map<String, dynamic>> fetchPosts({
    required Map<String, dynamic> body,
  }) async {
    final token = await SessionManager.getToken();

    print('========== FETCH POSTS REQUEST ==========');
    print('URL: $_baseUrl/community/posts');
    print('BODY: $body');

    final response = await http.post(
      Uri.parse('$_baseUrl/community/posts'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('STATUS: ${response.statusCode}');
    print('RESPONSE: ${response.body}');

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && decoded['success'] == true) {
      return decoded;
    }

    throw Exception(
      decoded['message']?.toString() ?? 'Failed to fetch posts',
    );
  }

  // ─── Create Post ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createPost({
    required int userId,
    required String content,
    required String type,
    required bool isAnonymous,
    required String mode,
  }) async {
    final token = await SessionManager.getToken();

    final communityType =
    mode == 'speak freely mode' ? 'free_speak' : 'postpartum';

    final body = {
      'user_id': userId,
      'content': content,
      'type': type,
      'is_anonymous': isAnonymous,
      'community_type': communityType,
    };

    print('========== CREATE POST REQUEST ==========');
    print('URL: $_baseUrl/community/create-post');
    print('BODY: $body');

    final response = await http.post(
      Uri.parse('$_baseUrl/community/create-post'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('STATUS: ${response.statusCode}');
    print('RESPONSE: ${response.body}');

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return decoded;
    }

    throw Exception(
      decoded['message']?.toString() ?? 'Failed to create post',
    );
  }

  // ─── Toggle Hug ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> toggleHug({
    required int userId,
    required int postId,
  }) async {
    final token = await SessionManager.getToken();

    final body = {
      'user_id': userId,
      'post_id': postId,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/community/toggle-hug'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) return decoded;

    throw Exception(
      decoded['message']?.toString() ?? 'Failed to toggle hug',
    );
  }

  // ─── Toggle Save ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> toggleSave({
    required int userId,
    required int postId,
  }) async {
    final token = await SessionManager.getToken();

    final body = {
      'user_id': userId,
      'post_id': postId,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/community/toggle-save'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) return decoded;

    throw Exception(
      decoded['message']?.toString() ?? 'Failed to toggle save',
    );
  }
}