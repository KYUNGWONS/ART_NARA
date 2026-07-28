import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KakaoAuthService {
  /// 카카오 로그인 수행
  /// 카카오톡 앱이 설치되어 있으면 카카오톡으로, 아니면 카카오 계정(웹)으로 로그인
  /// 성공 시 액세스 토큰을 반환
  static Future<String?> login() async {
    try {
      OAuthToken token;

      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (e) {
          debugPrint('카카오톡 로그인 실패, 카카오 계정 로그인 시도: $e');
          // 카카오톡 로그인 실패 시 카카오 계정으로 로그인 시도
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        // 카카오톡 미설치 시 카카오 계정으로 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      debugPrint('카카오 로그인 성공: accessToken=${token.accessToken}');
      return token.accessToken;
    } catch (e) {
      debugPrint('카카오 로그인 실패: $e');
      return null;
    }
  }

  /// 카카오 로그아웃
  static Future<bool> logout() async {
    try {
      await UserApi.instance.logout();
      debugPrint('카카오 로그아웃 성공');
      return true;
    } catch (e) {
      debugPrint('카카오 로그아웃 실패: $e');
      return false;
    }
  }

  /// 현재 로그인된 사용자 정보 가져오기
  static Future<User?> getUserInfo() async {
    try {
      final user = await UserApi.instance.me();
      debugPrint('사용자 정보: ${user.kakaoAccount?.profile?.nickname}');
      return user;
    } catch (e) {
      debugPrint('사용자 정보 요청 실패: $e');
      return null;
    }
  }
}
