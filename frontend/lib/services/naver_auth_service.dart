import 'package:flutter/foundation.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';

/// 네이버 로그인 서비스.
///
/// 앱은 액세스 토큰만 받아오고, **신원 확인은 서버가 한다**
/// (`POST /auth/login` → 서버가 네이버 프로필 API 로 검증 — 카카오와 같은 방식).
/// 프로필 값은 회원가입 화면 기본값을 채우는 용도로만 쓴다.
///
/// 클라이언트 ID·시크릿은 매니페스트 메타데이터로 들어가며,
/// git 미추적 `android/local.properties` 의 naverClientId/naverClientSecret 에서 주입된다.
class NaverAuthService {
  /// 성공하면 [NaverAuthResult], 사용자가 취소하거나 실패하면 null.
  static Future<NaverAuthResult?> signIn() async {
    try {
      final result = await FlutterNaverLogin.logIn();
      if (result.status != NaverLoginStatus.loggedIn) {
        debugPrint('[Naver] 로그인 종료: ${result.status} ${result.errorMessage ?? ''}');
        return null;
      }
      final token = result.accessToken?.accessToken;
      if (token == null || token.isEmpty) {
        debugPrint('[Naver] 액세스 토큰이 비어 있어 로그인할 수 없습니다');
        return null;
      }
      final account = result.account;
      debugPrint('[Naver] 로그인 성공: ${account?.nickname ?? account?.name ?? ''}');
      return NaverAuthResult(
        accessToken: token,
        nickname: account?.nickname ?? account?.name,
        profileImageUrl: account?.profileImage,
      );
    } catch (error) {
      debugPrint('[Naver] 로그인 실패: $error');
      return null;
    }
  }

  /// 앱 로그아웃 시 네이버 세션도 끊는다(다음 로그인에서 계정 선택이 다시 뜬다).
  static Future<void> signOut() async {
    try {
      await FlutterNaverLogin.logOutAndDeleteToken();
    } catch (error) {
      debugPrint('[Naver] 로그아웃 실패: $error');
    }
  }
}

class NaverAuthResult {
  const NaverAuthResult({
    required this.accessToken,
    this.nickname,
    this.profileImageUrl,
  });

  final String accessToken;
  final String? nickname;
  final String? profileImageUrl;
}
