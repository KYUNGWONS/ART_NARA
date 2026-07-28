import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/content_draft.dart';
import 'auth_api_service.dart';

/// 사용자가 생성한 콘텐츠를 백엔드에 등록하는 API.
class ContentApiService {
  /// POST /api/contents
  /// 콘텐츠 생성 플로우에서 누적한 [ContentDraft]를 등록한다.
  ///
  /// TODO(서버 연동): 서버 미연결 시 mock 성공(true) 반환 로직 제거하고,
  /// 실패 시 false만 반환하도록 수정.
  static Future<bool> submitContent(ContentDraft draft) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/api/contents');
      final token = AuthApiService.accessToken;
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      final body = jsonEncode(draft.toJson());
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[ContentAPI] 콘텐츠 등록 성공');
        return true;
      }
      debugPrint('[ContentAPI] 콘텐츠 등록 실패: ${response.statusCode}');
      return _mockSubmitForOffline();
    } catch (e) {
      debugPrint('[ContentAPI] 콘텐츠 등록 요청 실패 (서버 미연결 시 mock 응답 사용): $e');
      return _mockSubmitForOffline();
    }
  }

  /// 서버 미연결 시 등록 플로우 테스트용 mock 성공 응답.
  /// TODO(서버 연동): 실제 서버 연동 후 이 메서드 삭제.
  static bool _mockSubmitForOffline() {
    debugPrint('[ContentAPI] 서버 미연결 - mock 등록 성공 응답 사용');
    return true;
  }
}
