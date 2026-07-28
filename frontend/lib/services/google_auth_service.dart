import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google 로그인 서비스
/// TODO: 백엔드 연동 시 serverClientId 설정 및 idToken 전달
class GoogleAuthService {
  static const String _iosClientId =
      '1023791519522-f5ueiutbvdpbt00s2ie4fhafkgarksor.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = Platform.isIOS
      ? GoogleSignIn(scopes: ['email', 'profile'], clientId: _iosClientId)
      : GoogleSignIn(scopes: ['email', 'profile']);

  /// Google 로그인 수행
  /// 성공 시 [GoogleAuthResult] 반환 (profileImageUrl, nickname, idToken)
  static Future<GoogleAuthResult?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        debugPrint('[Google] 로그인 취소됨');
        return null;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final profileImageUrl = account.photoUrl;
      final nickname = account.displayName ?? account.email;

      debugPrint('[Google] 로그인 성공: $nickname');
      return GoogleAuthResult(
        idToken: idToken,
        profileImageUrl: profileImageUrl,
        nickname: nickname,
        email: account.email,
      );
    } catch (e, stack) {
      debugPrint('[Google] 로그인 실패: $e');
      debugPrint('[Google] stackTrace: $stack');
      return null;
    }
  }

  /// Google 로그아웃
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('[Google] 로그아웃 성공');
    } catch (e) {
      debugPrint('[Google] 로그아웃 실패: $e');
    }
  }
}

class GoogleAuthResult {
  final String? idToken;
  final String? profileImageUrl;
  final String nickname;
  final String? email;

  const GoogleAuthResult({
    this.idToken,
    this.profileImageUrl,
    required this.nickname,
    this.email,
  });
}
