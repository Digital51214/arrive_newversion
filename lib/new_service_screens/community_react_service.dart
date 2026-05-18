import 'dart:convert';
import 'package:http/http.dart' as http;

class CommunityReactService {
  static const String _url =
      'https://api.arrivejournal.com/public/api/community/posts/react';

  static Future<Map<String, dynamic>> reactToPost({
    required int userId,
    required int postId,
    required String type, // hug or feel
  }) async {
    if (type != 'hug' && type != 'feel') {
      throw Exception('type must be "hug" or "feel"');
    }

    final body = {
      'user_id': userId,
      'post_id': postId,
      'type': type,
    };

    try {
      print('========== COMMUNITY REACT API START ==========');
      print('URL  : $_url');
      print('BODY : $body');

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE    : ${response.body}');
      print('========== COMMUNITY REACT API END ==========');

      if (response.body.trim().isEmpty) {
        throw Exception('Empty response from server');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid response from server');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          decoded['message']?.toString() ?? 'Unable to react on post',
        );
      }

      if (decoded['success'] != true) {
        throw Exception(
          decoded['message']?.toString() ?? 'Unable to react on post',
        );
      }

      // API kabhi data ke andar result bhejti hai, kabhi direct top-level.
      final rawData = decoded['data'];

      final Map<String, dynamic> data =
      rawData is Map<String, dynamic> ? rawData : decoded;

      return {
        'success': true,
        'message': decoded['message'],
        'reacted': _parseBool(data['reacted']),
        'type': data['type']?.toString() ?? type,
        'hug_count': _parseInt(data['hug_count']),
        'feel_count': _parseInt(data['feel_count']),
      };
    } catch (e) {
      print('COMMUNITY REACT ERROR: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _parseBool(dynamic value) {
    if (value == true) return true;
    if (value == false) return false;

    final s = value?.toString().toLowerCase().trim();
    return s == '1' || s == 'true' || s == 'yes';
  }
}