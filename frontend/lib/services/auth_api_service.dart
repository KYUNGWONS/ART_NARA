import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/login_response.dart';

/// 인증 관련 백엔드 API (로그인, 로그아웃)
class AuthApiService {
  /// 로그인 후 발급받은 JWT (로그아웃·인증 API 호출 시 사용)
  static String? accessToken;
  static String? refreshToken;

  /// OAuth 로그인 시 캡처한 사용자 이메일 (회원가입 POST /api/users body에 사용)
  static String? userEmail;

  /// 내 프로필 조회(GET /api/users/me) 시 채워지는 내 userId.
  /// 백엔드 채팅 등 userId 쿼리 파라미터가 필요한 API에서 사용한다.
  static int? userId;

  /// POST /auth/login
  /// OAuth accessToken(kakao 또는 google idToken)과 provider를 body로 전달하여 JWT 발급.
  /// [provider] "KAKAO" | "GOOGLE"
  ///
  /// 성공(200 + code SUCCESS + 유효 토큰) 시 [accessToken]/[refreshToken]을 저장하고
  /// [LoginResponse]를 반환한다. 그 외(비-200, 파싱 실패, 400/401, 네트워크 예외)에는
  /// null을 반환하며, 호출부(login_screen)가 이를 로그인 실패로 처리한다.
  static Future<LoginResponse?> login(
    String provider,
    String oauthAccessToken,
  ) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/auth/login');
      final headers = <String, String>{'Content-Type': 'application/json'};
      final body = jsonEncode(<String, String>{
        'provider': provider,
        'accessToken': oauthAccessToken,
      });
      final response = await http.post(uri, headers: headers, body: body);

      debugPrint(
        '[AuthAPI] POST /auth/login 응답 statusCode: ${response.statusCode}',
      );
      if (response.body.isNotEmpty) {
        debugPrint('[AuthAPI] POST /auth/login 응답 body: ${response.body}');
      }

      if (response.statusCode != 200) {
        // 400=지원하지 않는 제공자/이메일 없음, 401=OAuth 토큰 검증 실패
        debugPrint('[AuthAPI] 로그인 실패: HTTP ${response.statusCode}');
        debugPrint('[AuthAPI] POST /auth/login 응답 헤더: ${response.headers}');
        return null;
      }

      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      if (map == null) {
        debugPrint('[AuthAPI] 로그인 응답 파싱 실패');
        return null;
      }

      final loginResponse = LoginResponse.fromJson(map);
      final data = loginResponse.data;
      if (loginResponse.code == 'SUCCESS' &&
          data != null &&
          data.accessToken.isNotEmpty) {
        accessToken = data.accessToken;
        refreshToken = data.refreshToken;
        debugPrint('[AuthAPI] 로그인 성공 (isNewUser: ${data.isNewUser})');
        return loginResponse;
      }

      debugPrint('[AuthAPI] 로그인 실패: code=${loginResponse.code}');
      return null;
    } catch (e) {
      debugPrint('[AuthAPI] 로그인 요청 실패: $e');
      return null;
    }
  }

  /// 토큰 초기화 (로그아웃 시 호출)
  static void clearTokens() {
    accessToken = null;
    refreshToken = null;
    userEmail = null;
    userId = null;
  }

  /// POST /auth/logout
  /// Request body: {"refreshToken": "string"}. Authorization 헤더에 accessToken 포함.
  static Future<bool> logout({String? accessToken}) async {
    final token = accessToken ?? AuthApiService.accessToken;
    final refresh = AuthApiService.refreshToken ?? '';
    try {
      final uri = Uri.parse('$apiBaseUrl/auth/logout');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      final body = jsonEncode(<String, String>{'refreshToken': refresh});
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        debugPrint('[AuthAPI] 로그아웃 성공');
        clearTokens();
        return true;
      }
      debugPrint('[AuthAPI] 로그아웃 실패: ${response.statusCode}');
      clearTokens();
      return false;
    } catch (e) {
      debugPrint('[AuthAPI] 로그아웃 요청 실패: $e');
      clearTokens();
      return false;
    }
  }
}
