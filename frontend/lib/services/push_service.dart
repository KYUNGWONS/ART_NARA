import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../utils/notification_navigation.dart';
import 'api_headers.dart';

/// 푸시 알림 등록.
///
/// Firebase 설정(google-services.json)이 없는 빌드에서는 초기화가 실패하는데,
/// 그때는 **조용히 꺼진 상태로 둔다** — 앱 내 알림 탭은 그대로 동작한다.
/// (카카오맵을 x86 에뮬레이터에서 건너뛰는 것과 같은 방식.)
class PushService {
  static bool _available = false;
  static String? _token;

  static bool get isAvailable => _available;

  /// 로그인 직후 호출한다. 등록 토큰을 서버에 올려야 그 계정으로 푸시가 간다.
  static Future<void> registerDevice() async {
    try {
      if (!_available) {
        await Firebase.initializeApp();
        _available = true;
      }
      final messaging = FirebaseMessaging.instance;
      // Android 13+ 와 iOS 는 사용자 허용이 필요하다. 거부해도 앱은 그대로 쓴다.
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[Push] 알림 권한 거부됨 — 등록을 건너뜁니다');
        return;
      }
      final token = await messaging.getToken();
      if (token == null) return;
      _token = token;
      await _sendToServer(token);

      // 토큰은 재설치·복원 때 바뀐다. 갱신되면 서버 것도 바꿔준다.
      messaging.onTokenRefresh.listen((refreshed) {
        _token = refreshed;
        _sendToServer(refreshed);
      });

      _listenForTaps(messaging);
    } catch (error) {
      _available = false;
      debugPrint('[Push] 초기화 실패 — 푸시 없이 진행합니다: $error');
    }
  }

  /// 알림함에서 푸시를 눌렀을 때 해당 화면으로 보낸다.
  ///
  /// 앱이 죽어 있었으면 [getInitialMessage], 백그라운드였으면 [onMessageOpenedApp] 로 들어온다.
  /// 서버가 실어 보내는 data{type,targetId} 를 앱 내 알림 목록과 **같은 규칙**으로 해석한다.
  static bool _tapListenerAttached = false;

  static void _listenForTaps(FirebaseMessaging messaging) {
    if (_tapListenerAttached) return; // 재로그인 때 중복 구독되지 않게
    _tapListenerAttached = true;

    messaging.getInitialMessage().then((message) {
      if (message != null) _openFrom(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen(_openFrom);
  }

  static void _openFrom(RemoteMessage message) {
    final type = message.data['type'];
    if (type == null || type.isEmpty) return;
    final context = appNavigatorKey.currentContext;
    if (context == null) {
      debugPrint('[Push] 화면이 준비되지 않아 이동을 건너뜁니다 (type: $type)');
      return;
    }
    debugPrint('[Push] 알림 탭 → 이동 (type: $type)');
    openNotificationTarget(
      context,
      type: type,
      targetId: int.tryParse(message.data['targetId'] ?? ''),
    );
  }

  /// 로그아웃 시 이 기기로 더 이상 푸시가 가지 않게 한다.
  static Future<void> unregisterDevice() async {
    final token = _token;
    if (token == null) return;
    try {
      await http.delete(
        Uri.parse('$apiBaseUrl/api/devices'),
        headers: authJsonHeaders(),
        body: jsonEncode({'token': token}),
      );
    } catch (error) {
      debugPrint('[Push] 기기 해제 실패: $error');
    }
    _token = null;
  }

  static Future<void> _sendToServer(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/devices'),
        headers: authJsonHeaders(),
        body: jsonEncode({
          'token': token,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'IOS' : 'ANDROID',
        }),
      );
      debugPrint('[Push] 기기 등록 ${response.statusCode}');
    } catch (error) {
      debugPrint('[Push] 기기 등록 실패: $error');
    }
  }
}
