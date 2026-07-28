import 'user_location.dart';

/// 참여 중인 채팅방 목록 아이템 (GET /chat/rooms 응답 항목)
class ChatRoomItem {
  final String chatRoomId;
  final String? partnerProfileImageUrl;
  final String partnerNickname;
  final int? partnerAge;
  final String? partnerNationality;
  final int partnerPlanningScore;
  final int partnerActivityScore;
  final List<String> partnerInterests;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const ChatRoomItem({
    required this.chatRoomId,
    this.partnerProfileImageUrl,
    required this.partnerNickname,
    this.partnerAge,
    this.partnerNationality,
    this.partnerPlanningScore = 0,
    this.partnerActivityScore = 0,
    this.partnerInterests = const [],
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ChatRoomItem.fromJson(Map<String, dynamic> json) {
    final lastAt = json['lastMessageAt'];
    // 백엔드 ChatRoomResponse는 'roomId'(정수), 구 프론트 목업은 'chatRoomId'(문자열).
    final rawRoomId = json['chatRoomId'] ?? json['roomId'];
    return ChatRoomItem(
      chatRoomId: rawRoomId?.toString() ?? '',
      partnerProfileImageUrl: json['partnerProfileImageUrl'] as String?,
      partnerNickname: json['partnerNickname'] as String? ?? '',
      partnerAge: json['partnerAge'] as int?,
      partnerNationality: json['partnerNationality'] as String?,
      partnerPlanningScore: json['partnerPlanningScore'] as int? ?? 0,
      partnerActivityScore: json['partnerActivityScore'] as int? ?? 0,
      partnerInterests:
          (json['partnerInterests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: lastAt != null
          ? (lastAt is String ? DateTime.tryParse(lastAt) : null)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': chatRoomId,
      'partnerProfileImageUrl': partnerProfileImageUrl,
      'partnerNickname': partnerNickname,
      'partnerAge': partnerAge,
      'partnerNationality': partnerNationality,
      'partnerPlanningScore': partnerPlanningScore,
      'partnerActivityScore': partnerActivityScore,
      'partnerInterests': partnerInterests,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
    };
  }

  /// 채팅 상세 화면 진입용 UserLocation 변환 (주소/좌표는 빈 값)
  UserLocation toUserLocation() {
    return UserLocation(
      userId: chatRoomId,
      nickname: partnerNickname,
      age: partnerAge,
      address: '',
      lat: 0,
      lng: 0,
      profileImageUrl: partnerProfileImageUrl,
      role: '',
      introduction: partnerNationality != null ? '$partnerNationality' : null,
      interests: partnerInterests,
      planningScore: partnerPlanningScore,
      activityScore: partnerActivityScore,
    );
  }
}
