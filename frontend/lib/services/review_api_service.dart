import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/review.dart';
import 'api_headers.dart';

/// 리뷰 API. 조회는 공개, 작성은 로그인 + 구매 이력이 있어야 한다.
class ReviewApiService {
  /// GET /api/artists/{name}/reviews
  static Future<ReviewList> listByArtist(String artistName) async {
    try {
      final uri = Uri.parse(
          '$apiBaseUrl/api/artists/${Uri.encodeComponent(artistName)}/reviews');
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        debugPrint('[ReviewAPI] 목록 조회 실패: ${response.statusCode}');
        return const ReviewList();
      }
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      return data == null ? const ReviewList() : ReviewList.fromJson(data);
    } catch (e) {
      debugPrint('[ReviewAPI] 목록 조회 요청 실패: $e');
      return const ReviewList();
    }
  }

  /// POST /api/artworks/{id}/reviews — 성공하면 null, 실패하면 사용자에게 보여줄 메시지.
  static Future<String?> create({
    required int artworkId,
    required int rating,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/artworks/$artworkId/reviews'),
        headers: authJsonHeaders(),
        body: jsonEncode({'rating': rating, 'content': content}),
      );
      if (response.statusCode == 200) return null;
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return body['message'] as String? ?? '리뷰 등록에 실패했어요 (${response.statusCode})';
    } catch (e) {
      debugPrint('[ReviewAPI] 작성 요청 실패: $e');
      return '리뷰 등록 중 오류가 발생했어요';
    }
  }
}
