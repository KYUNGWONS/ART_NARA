import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/login_response.dart';
import 'token_storage.dart';

/// 인증 관련 백엔드 API (로그인, 로그아웃)
class AuthApiService {
  /// 로그인 후 발급받은 JWT (로그아웃·인증 API 호출 시 사용)
  static String? accessToken;
  static String? refreshToken;

  /// OAuth 로그인 시 캡처한 사용자 이메일 (회원가입 POST /api/users body에 사용)
  static String? userEmail;

  /// 내 userId. 로그인 시 JWT 의 sub 에서 채우고, 프로필 조회 시 응답 값으로 갱신한다.
  /// 채팅 메시지 전송(senderId) 등 본인 식별이 필요한 곳에서 사용한다.
  static int? userId;

  /// JWT 페이로드의 sub(사용자 id)를 꺼낸다. 서명 검증은 서버 몫이라 여기선 디코딩만 한다.
  static int? _userIdFromJwt(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length < 2) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      return int.tryParse('${payload['sub']}');
    } catch (e) {
      debugPrint('[AuthAPI] JWT sub 파싱 실패: $e');
      return null;
    }
  }

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
        userId = _userIdFromJwt(data.accessToken);
        // 앱 재시작 자동 로그인용. 실패해도 로그인 자체는 성공으로 둔다.
        await TokenStorage.save(data.accessToken, data.refreshToken);
        debugPrint('[AuthAPI] 로그인 성공 (isNewUser: ${data.isNewUser}, userId: $userId)');
        return loginResponse;
      }

      debugPrint('[AuthAPI] 로그인 실패: code=${loginResponse.code}');
      return null;
    } catch (e) {
      debugPrint('[AuthAPI] 로그인 요청 실패: $e');
      return null;
    }
  }

  /// 저장된 refresh token 으로 자동 로그인을 시도한다.
  ///
  /// 성공 시 새 토큰 쌍을 메모리·보안 저장소에 반영하고
  /// (profileCompleted) 를 반환한다. 실패(만료·위조·네트워크)면 null.
  static Future<bool?> tryAutoLogin() async {
    final saved = await TokenStorage.readRefreshToken();
    if (saved == null || saved.isEmpty) return null;
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': saved}),
      );
      if (response.statusCode != 200) {
        debugPrint('[AuthAPI] 자동 로그인 실패: ${response.statusCode} → 저장 토큰 폐기');
        await TokenStorage.clear();
        return null;
      }
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final data = map['data'] as Map<String, dynamic>?;
      final newAccess = data?['accessToken'] as String?;
      final newRefresh = data?['refreshToken'] as String?;
      if (newAccess == null || newRefresh == null) return null;

      accessToken = newAccess;
      refreshToken = newRefresh;
      userId = _userIdFromJwt(newAccess);
      await TokenStorage.save(newAccess, newRefresh);
      debugPrint('[AuthAPI] 자동 로그인 성공 (userId: $userId)');
      return data?['profileCompleted'] as bool? ?? false;
    } catch (e) {
      debugPrint('[AuthAPI] 자동 로그인 요청 실패: $e');
      return null; // 네트워크 오류는 토큰을 지우지 않는다(다음 실행에서 재시도)
    }
  }

  /// 토큰 초기화 (로그아웃 시 호출)
  static Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
    userEmail = null;
    userId = null;
    await TokenStorage.clear();
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
        await clearTokens();
        return true;
      }
      debugPrint('[AuthAPI] 로그아웃 실패: ${response.statusCode}');
      await clearTokens();
      return false;
    } catch (e) {
      debugPrint('[AuthAPI] 로그아웃 요청 실패: $e');
      await clearTokens();
      return false;
    }
  }
}
