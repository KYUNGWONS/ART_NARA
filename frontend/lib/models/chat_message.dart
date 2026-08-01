/// 채팅 메시지 (백엔드 ChatMessageResponse 대응)
class ChatMessage {
  final int? id;
  final String text;
  final bool isMe;
  final DateTime sentAt;

  /// TEXT / IMAGE / APPOINTMENT
  final String messageType;

  ChatMessage({
    this.id,
    required this.text,
    required this.isMe,
    DateTime? sentAt,
    this.messageType = 'TEXT',
  }) : sentAt = sentAt ?? DateTime.now();

  /// [myUserId] 기준으로 내 메시지인지 판별한다.
  factory ChatMessage.fromJson(Map<String, dynamic> json, int? myUserId) {
    final senderId = json['senderId'] as int?;
    final createdAt = json['createdAt'];
    return ChatMessage(
      id: json['id'] as int?,
      text: json['content'] as String? ?? '',
      isMe: myUserId != null && senderId == myUserId,
      sentAt: createdAt is String ? DateTime.tryParse(createdAt) : null,
      messageType: json['messageType'] as String? ?? 'TEXT',
    );
  }
}
