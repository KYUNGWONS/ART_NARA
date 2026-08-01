import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import 'auth_api_service.dart';

/// 관심 작품(하트) 토글. POST /api/artworks/{id}/like
class ArtworkLikeApiService {
  /// 토글 후 상태를 반환한다. 실패하면 null.
  static Future<bool?> toggle(int artworkId) async {
    final token = AuthApiService.accessToken;
    if (token == null || token.isEmpty) {
      debugPrint('[ArtworkLike] 토큰 없음 — 로그인 필요');
      return null;
    }
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/artworks/$artworkId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) {
        debugPrint('[ArtworkLike] 토글 실패: ${response.statusCode}');
        return null;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['data'] as bool?;
    } catch (e) {
      debugPrint('[ArtworkLike] 토글 요청 실패: $e');
      return null;
    }
  }
}
