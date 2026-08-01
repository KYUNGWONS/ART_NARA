/// 참여 중인 채팅방 목록 아이템 (GET /api/chat/rooms/my 응답 항목)
///
/// 백엔드 ChatRoomResponse 가 상대 프로필과 마지막 메시지를 함께 내려주므로
/// 목록 화면은 방마다 추가 조회 없이 그릴 수 있다.
class ChatRoomItem {
  final String chatRoomId;
  final String? opponentProfileImageUrl;
  final String opponentNickname;

  /// 백엔드 userType 원문(KOREAN_STUDENT / FOREIGN_TOURIST)
  final String? opponentUserType;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  /// WAITING / ACTIVE / CLOSED
  final String? status;

  /// 내가 읽지 않은 메시지 수
  final int unreadCount;

  const ChatRoomItem({
    required this.chatRoomId,
    this.opponentProfileImageUrl,
    required this.opponentNickname,
    this.opponentUserType,
    this.lastMessage,
    this.lastMessageAt,
    this.status,
    this.unreadCount = 0,
  });

  /// 역할 배지 문구. 상대가 아직 없으면 null.
  String? get opponentRoleLabel {
    if (opponentUserType == null) return null;
    return opponentUserType!.toUpperCase().startsWith('FOREIGN') ? '컬렉터' : '작가';
  }

  factory ChatRoomItem.fromJson(Map<String, dynamic> json) {
    final lastAt = json['lastMessageAt'];
    return ChatRoomItem(
      chatRoomId: (json['roomId'] ?? json['chatRoomId'])?.toString() ?? '',
      opponentProfileImageUrl: json['opponentProfileImageUrl'] as String?,
      opponentNickname: json['opponentNickname'] as String? ?? '대화 상대 대기 중',
      opponentUserType: json['opponentUserType'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: lastAt is String ? DateTime.tryParse(lastAt) : null,
      status: json['status'] as String?,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}
