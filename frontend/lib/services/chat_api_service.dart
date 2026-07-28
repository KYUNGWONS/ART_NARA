import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/chat_room_item.dart';
import 'auth_api_service.dart';

/// 채팅방 목록 등 채팅 관련 백엔드 API
class ChatApiService {
  /// GET /api/chat/rooms/my?userId={id}
  /// 참여 중인 채팅방 목록 조회. 백엔드는 userId 쿼리 파라미터를 요구한다.
  /// (userId는 GET /api/users/me 호출 시 [AuthApiService.userId]에 캐시된다.)
  ///
  /// TODO(서버 연동): 서버 미연결 시 mock 반환 로직 제거하고, 실패 시 빈 리스트 또는 에러 처리만 하도록 수정
  /// TODO(백엔드 보강): ChatRoomResponse에 상대방 프로필·마지막 메시지 필드가 없어
  /// 목록 UI가 비게 된다. 백엔드에서 partner 정보/lastMessage를 포함하도록 확장 필요.
  static Future<List<ChatRoomItem>> getChatRooms() async {
    final userId = AuthApiService.userId;
    if (userId == null) {
      debugPrint('[ChatAPI] GET /api/chat/rooms/my 스킵: userId 없음 (먼저 getMe 필요) → mock 사용');
      return _mockChatRoomsForOffline();
    }
    try {
      final uri = Uri.parse('$apiBaseUrl/api/chat/rooms/my?userId=$userId');
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

  /// 서버 미연결 시 채팅방 목록 화면 테스트용 mock 응답
  /// TODO(서버 연동): 실제 서버 연동 후 이 메서드 삭제
  static List<ChatRoomItem> _mockChatRoomsForOffline() {
    debugPrint('[ChatAPI] 서버 미연결 - mock 채팅방 목록 사용');
    return [
      ChatRoomItem(
        chatRoomId: 'room_001',
        partnerProfileImageUrl:
            'https://k.kakaocdn.net/dn/cpObSK/dJMcabirNp2/6k8AYPwXmaMXKlGBRmWja0/img_640x640.jpg',
        partnerNickname: '재혁이',
        partnerAge: 28,
        partnerNationality: '한국',
        partnerPlanningScore: 40,
        partnerActivityScore: -40,
        partnerInterests: ['travel', 'food', 'culture'],
        lastMessage: '내일 오후 2시에 만나요! 장소 정했어요.',
        lastMessageAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      ChatRoomItem(
        chatRoomId: 'room_002',
        partnerProfileImageUrl: null,
        partnerNickname: '하늘이',
        partnerAge: 24,
        partnerNationality: '한국',
        partnerPlanningScore: 40,
        partnerActivityScore: -40,
        partnerInterests: ['travel', 'food'],
        lastMessage: '네, 그 코스 좋아요. 다음 주 토요일 가능하세요?',
        lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatRoomItem(
        chatRoomId: 'room_003',
        partnerProfileImageUrl: null,
        partnerNickname: '준혁',
        partnerAge: 26,
        partnerNationality: '한국',
        partnerPlanningScore: 0,
        partnerActivityScore: -10,
        partnerInterests: ['cafe', 'food', 'activity'],
        lastMessage: '사진 보내드렸어요. 여기 분위기 좋아요 ☕',
        lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ChatRoomItem(
        chatRoomId: 'room_004',
        partnerProfileImageUrl: null,
        partnerNickname: 'Andy',
        partnerAge: 23,
        partnerNationality: '한국',
        partnerPlanningScore: -40,
        partnerActivityScore: -50,
        partnerInterests: ['cafe', 'food', 'unique'],
        lastMessage: '감사합니다! 다음에 또 연락드릴게요.',
        lastMessageAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
