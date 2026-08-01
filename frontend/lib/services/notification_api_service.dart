import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/app_notification.dart';
import 'auth_api_service.dart';

/// 알림 API. 대상은 JWT 신원에서 결정되므로 userId 를 넘기지 않는다.
class NotificationApiService {
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (AuthApiService.accessToken != null &&
            AuthApiService.accessToken!.isNotEmpty)
          'Authorization': 'Bearer ${AuthApiService.accessToken}',
      };

  /// GET /api/notifications → (목록, 안읽음 수)
  static Future<({List<AppNotification> items, int unread})> list() async {
    try {
      final uri = Uri.parse('$apiBaseUrl/api/notifications');
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode != 200) {
        debugPrint('[NotificationAPI] 목록 조회 실패: ${response.statusCode}');
        return (items: <AppNotification>[], unread: 0);
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>?;
      if (data == null) return (items: <AppNotification>[], unread: 0);
      final items = (data['notifications'] as List<dynamic>? ?? [])
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      final unread = (data['unreadCount'] as num?)?.toInt() ?? 0;
      debugPrint('[NotificationAPI] 목록 조회 성공: ${items.length}개 (안읽음 $unread)');
      return (items: items, unread: unread);
    } catch (e) {
      debugPrint('[NotificationAPI] 목록 조회 요청 실패: $e');
      return (items: <AppNotification>[], unread: 0);
    }
  }

  /// PATCH /api/notifications/{id}/read
  static Future<bool> markAsRead(int id) async {
    return _patch('$apiBaseUrl/api/notifications/$id/read');
  }

  /// PATCH /api/notifications/read-all
  static Future<bool> markAllAsRead() async {
    return _patch('$apiBaseUrl/api/notifications/read-all');
  }

  static Future<bool> _patch(String url) async {
    try {
      final response = await http.patch(Uri.parse(url), headers: _headers);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[NotificationAPI] $url 요청 실패: $e');
      return false;
    }
  }
}
