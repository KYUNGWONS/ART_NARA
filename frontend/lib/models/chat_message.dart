/// 채팅 메시지 모델
/// TODO: 백엔드 API 연동 시 서버 스키마에 맞게 확장
class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime sentAt;

  ChatMessage({required this.text, required this.isMe, DateTime? sentAt})
    : sentAt = sentAt ?? DateTime.now();
}
