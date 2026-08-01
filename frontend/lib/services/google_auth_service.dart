import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google 로그인 서비스.
///
/// 백엔드(`POST /auth/login`)는 **idToken** 을 받아 `oauth.google.client-id`(웹 클라이언트 ID)와
/// aud 를 대조해 검증한다. 따라서 Android 에서는 반드시 **웹 애플리케이션 클라이언트 ID** 를
/// `serverClientId` 로 넘겨야 idToken 이 발급된다(안 넘기면 idToken 이 null → 로그인 실패).
///
/// 빌드 시 주입:
///   --dart-define=GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com   (웹 클라이언트, Android/iOS 공통)
///   --dart-define=GOOGLE_IOS_CLIENT_ID=yyy.apps.googleusercontent.com      (iOS 클라이언트)
class GoogleAuthService {
  /// 웹 애플리케이션 클라이언트 ID — idToken 의 aud 가 되며 백엔드가 이 값으로 검증한다.
  static const String _serverClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  /// iOS 클라이언트 ID (iOS 에서만 필요)
  static const String _iosClientId =
      String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
    clientId: Platform.isIOS && _iosClientId.isNotEmpty ? _iosClientId : null,
    serverClientId: _serverClientId.isNotEmpty ? _serverClientId : null,
  );

  /// Google 로그인 수행
  /// 성공 시 [GoogleAuthResult] 반환 (profileImageUrl, nickname, idToken)
  static Future<GoogleAuthResult?> signIn() async {
    if (_serverClientId.isEmpty) {
      debugPrint('[Google] GOOGLE_SERVER_CLIENT_ID 미설정 — idToken 이 발급되지 않아 '
          '백엔드 로그인에 실패합니다. --dart-define 으로 웹 클라이언트 ID를 넘겨주세요.');
    }
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
