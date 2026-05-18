import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class CommunityFilterFeedsService {
  static const String _baseUrl =
      'https://api.arrivejournal.com/public/api/community/filtered';

  static Future<Map<String, dynamic>> fetchFilteredPosts({
    required int userId,
    required String communityType,
    required String postType,
    int perPage = 12,
    int page = 1,
  }) async {
    final body = <String, dynamic>{
      'user_id': userId,
      'community_type': communityType,
      'post_type': postType,
      'per_page': perPage,
      'page': page,
    };

    print('========== COMMUNITY FILTER FEEDS SERVICE ==========');
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
        print('FILTER POSTS SUCCESS');
        return decodedJson;
      }

      final message =
          decodedJson['message']?.toString() ?? 'Failed to load filtered posts';

      print('FILTER POSTS FAILED: $message');
      throw Exception(message);
    } on TimeoutException {
      print('FILTER POSTS ERROR: Request timed out');
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      print('FILTER POSTS ERROR: Invalid JSON');
      throw Exception('Invalid server response');
    } catch (e) {
      print('FILTER POSTS ERROR: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchAnonymousPosts({
    required int userId,
    required String communityType,
    int perPage = 12,
    int page = 1,
  }) async {
    final body = <String, dynamic>{
      'user_id': userId,
      'community_type': communityType,
      'post_type': 'anonymous',
      'per_page': perPage,
      'page': page,
    };

    print('========== COMMUNITY ANONYMOUS POSTS SERVICE ==========');
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
        print('ANONYMOUS POSTS SUCCESS');
        return decodedJson;
      }

      final message =
          decodedJson['message']?.toString() ?? 'Failed to load anonymous posts';

      print('ANONYMOUS POSTS FAILED: $message');
      throw Exception(message);
    } on TimeoutException {
      print('ANONYMOUS POSTS ERROR: Request timed out');
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      print('ANONYMOUS POSTS ERROR: Invalid JSON');
      throw Exception('Invalid server response');
    } catch (e) {
      print('ANONYMOUS POSTS ERROR: $e');
      rethrow;
    }
  }
}