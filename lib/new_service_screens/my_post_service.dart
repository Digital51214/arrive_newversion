import 'dart:convert';
import 'package:http/http.dart' as http;

class MyPostsService {
  static const String _baseUrl = 'https://api.arrivejournal.com/public/api';

  /// Fetch my posts filtered by community_type
  /// [userId] - logged in user ka id
  /// [communityType] - 'postpartum' ya 'free_speak'
  /// [page] - pagination page number (default 1)
  /// [perPage] - posts per page (default 10)
  static Future<Map<String, dynamic>> getMyPosts({
    required int userId,
    required String communityType,
    int page = 1,
    int perPage = 10,
  }) async {
    print('========== MY POSTS SERVICE START ==========');
    print('USER ID: $userId');
    print('COMMUNITY TYPE: $communityType');
    print('PAGE: $page');
    print('PER PAGE: $perPage');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/community/my-posts'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'per_page': perPage,
          'page': page,
        }),
      );

      print('MY POSTS RESPONSE STATUS: ${response.statusCode}');
      print('MY POSTS RESPONSE BODY: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final Map<String, dynamic> result = jsonDecode(response.body);

      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Failed to fetch posts');
      }

      // ✅ communityType ke hisaab se filter karo
      final List<dynamic> allPosts =
          result['data']?['data'] as List<dynamic>? ?? [];

      final List<dynamic> filteredPosts = allPosts.where((post) {
        final type = post['community_type']?.toString() ?? '';
        return type == communityType;
      }).toList();

      print('TOTAL POSTS FROM API: ${allPosts.length}');
      print(
          'FILTERED POSTS (community_type=$communityType): ${filteredPosts.length}');

      // Stats bhi return karo
      final stats = result['stats'] ?? {};

      print('STATS: $stats');
      print('========== MY POSTS SERVICE END ==========');

      return {
        'success': true,
        'posts': filteredPosts,
        'stats': stats,
        'pagination': {
          'current_page': result['data']?['current_page'] ?? 1,
          'last_page': result['data']?['last_page'] ?? 1,
          'total': result['data']?['total'] ?? 0,
          'next_page_url': result['data']?['next_page_url'],
        },
      };
    } catch (e) {
      print('MY POSTS SERVICE ERROR: $e');
      rethrow;
    }
  }
}