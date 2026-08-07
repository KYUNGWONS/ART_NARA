import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/login_response.dart';
import '../screens/naver_login_screen.dart';
import 'auth_api_service.dart';

/// 네이버 로그인.
///
/// 네이버 SDK(`flutter_naver_login`)는 동의 결과를 커스텀탭 → `intent://` 로 돌려주는데,
/// 그 전달이 막히는 환경이 있어(에뮬레이터 실측: 코드는 발급되는데 앱으로 안 넘어옴)
/// **앱 자체 WebView 로 동의를 받고 인가 코드만 서버에 넘기는 방식**으로 바꿨다.
///
/// 토큰 교환·신원 확인은 서버가 한다 — 클라이언트 시크릿이 앱에 들어가지 않는다.
class NaverAuthService {
  /// 동의 화면을 띄우고 로그인까지 끝낸다. 실패·취소면 null.
  static Future<LoginResponse?> signIn(BuildContext context) async {
    final state = _randomState();
    final config = await _fetchConfig(state);
    if (config == null) {
      debugPrint('[Naver] 서버에 네이버 로그인 설정이 없습니다 (NAVER_CLIENT_ID/SECRET)');
      return null;
    }

    if (!context.mounted) return null;
    final result = await Navigator.of(context).push<NaverLoginResultData>(
      MaterialPageRoute<NaverLoginResultData>(
        builder: (_) => NaverLoginScreen(
          authorizeUrl: config.authorizeUrl,
          redirectUri: config.redirectUri,
          state: state,
        ),
      ),
    );
    if (result == null || !result.isSuccess) {
      debugPrint('[Naver] 로그인 종료: ${result?.message ?? '취소'}');
      return null;
    }
    return AuthApiService.loginWithNaverCode(result.code!, state);
  }

  /// 로그아웃 시 별도로 끊을 세션이 없다(WebView 쿠키는 앱 종료와 함께 사라진다).
  static Future<void> signOut() async {}

  static Future<({String authorizeUrl, String redirectUri})?> _fetchConfig(
      String state) async {
    try {
      final response = await http.get(
          Uri.parse('$apiBaseUrl/auth/naver/config?state=$state'));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(utf8.decode(response.bodyBytes))['data']
          as Map<String, dynamic>?;
      if (data == null || data['enabled'] != true) return null;
      return (
        authorizeUrl: data['authorizeUrl'] as String,
        redirectUri: data['redirectUri'] as String,
      );
    } catch (error) {
      debugPrint('[Naver] 설정 조회 실패: $error');
      return null;
    }
  }

  /// 요청 위조 방지용 난수. 콜백에서 같은 값인지 대조한다.
  static String _randomState() {
    final random = Random.secure();
    return List.generate(24, (_) => random.nextInt(16).toRadixString(16)).join();
  }
}
