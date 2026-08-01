import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/chat_message.dart';
import '../models/chat_room_item.dart';
import 'auth_api_service.dart';

/// 채팅방 목록 등 채팅 관련 백엔드 API
class ChatApiService {
  /// GET /api/chat/rooms/my
  /// 참여 중인 채팅방 목록 조회. 대상은 JWT 신원에서 결정되므로 userId 를 넘기지 않는다.
  ///
  /// TODO(서버 연동): 서버 미연결 시 mock 반환 로직 제거하고, 실패 시 빈 리스트 또는 에러 처리만 하도록 수정
  static Future<List<ChatRoomItem>> getChatRooms() async {
    try {
      final uri = Uri.parse('$apiBaseUrl/api/chat/rooms/my');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (AuthApiService.accessToken != null &&
            AuthApiService.accessToken!.isNotEmpty)
          'Authorization': 'Bearer ${AuthApiService.accessToken}',
      };
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) {
        debugPrint('[ChatAPI] GET /api/chat/rooms/my 실패: ${response.statusCode}');
        return _mockChatRoomsForOffline();
      }
      final decoded = jsonDecode(response.body);
      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['data'] != null) {
        list = decoded['data'] as List<dynamic>;
      } else {
        debugPrint('[ChatAPI] GET /api/chat/rooms/my 응답 형식 오류');
        return _mockChatRoomsForOffline();
      }
      final rooms = list
          .map((e) => ChatRoomItem.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('[ChatAPI] GET /api/chat/rooms/my 성공: ${rooms.length}개');
      return rooms;
    } catch (e) {
      debugPrint('[ChatAPI] GET /api/chat/rooms/my 요청 실패 (서버 미연결 시 mock 사용): $e');
      return _mockChatRoomsForOffline();
    }
  }

  /// GET /api/chat/rooms/{roomId}/messages
  /// 채팅 상세 진입 시 이전 대화를 채운다. 실시간 수신은 STOMP(/topic/chat/{roomId}).
  static Future<List<ChatMessage>> getMessages(String roomId) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/api/chat/rooms/$roomId/messages');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (AuthApiService.accessToken != null &&
            AuthApiService.accessToken!.isNotEmpty)
          'Authorization': 'Bearer ${AuthApiService.accessToken}',
      };
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) {
        debugPrint('[ChatAPI] GET messages 실패: ${response.statusCode}');
        return const [];
      }
      final decoded = jsonDecode(response.body);
      final list = decoded is Map ? decoded['data'] as List<dynamic>? : null;
      if (list == null) return const [];
      final myId = AuthApiService.userId;
      final messages = list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>, myId))
          .toList();
      debugPrint('[ChatAPI] GET messages 성공: ${messages.length}개');
      return messages;
    } catch (e) {
      debugPrint('[ChatAPI] GET messages 요청 실패: $e');
      return const [];
    }
  }

  /// POST /api/chat/rooms/direct — 작가 닉네임으로 1:1 문의 방 열기(있으면 기존 방).
  static Future<ChatRoomItem?> openDirectRoom(String opponentNickname) async {
    final token = AuthApiService.accessToken;
    if (token == null || token.isEmpty) {
      debugPrint('[ChatAPI] 문의 방 열기 실패: 로그인 필요');
      return null;
    }
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/chat/rooms/direct'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'opponentNickname': opponentNickname}),
      );
      if (response.statusCode != 200) {
        debugPrint('[ChatAPI] 문의 방 열기 실패: ${response.statusCode}');
        return null;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return ChatRoomItem.fromJson(data);
    } catch (e) {
      debugPrint('[ChatAPI] 문의 방 열기 요청 실패: $e');
      return null;
    }
  }

  /// 서버 미연결 시 채팅방 목록 화면 테스트용 mock 응답
  /// TODO(서버 연동): 실제 서버 연동 후 이 메서드 삭제
  static List<ChatRoomItem> _mockChatRoomsForOffline() {
    debugPrint('[ChatAPI] 서버 미연결 - mock 채팅방 목록 사용');
    return [
      ChatRoomItem(
        chatRoomId: '1',
        opponentNickname: '김예진',
        opponentUserType: 'KOREAN_STUDENT',
        lastMessage: '좋아요! 토요일 오전 11시에 뵐게요.',
        lastMessageAt: DateTime.now().subtract(const Duration(minutes: 12)),
        status: 'ACTIVE',
      ),
      ChatRoomItem(
        chatRoomId: '2',
        opponentNickname: '박소현',
        opponentUserType: 'KOREAN_STUDENT',
        lastMessage: '45.5 x 53.0cm(10호)이고 캔버스에 유채입니다.',
        lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'ACTIVE',
      ),
      ChatRoomItem(
        chatRoomId: '3',
        opponentNickname: 'Lucas',
        opponentUserType: 'FOREIGN_TOURIST',
        lastMessage: '‘고요한 파도’ 시리즈 다른 작업도 있나요?',
        lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'ACTIVE',
      ),
    ];
  }
}
