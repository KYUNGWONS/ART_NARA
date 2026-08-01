/// 알림 (GET /api/notifications 응답 항목)
class AppNotification {
  final int id;

  /// COMMISSION_CREATED / COMMISSION_OFFER / AUCTION_CLOSED / ORDER_COMPLETED
  final String type;
  final String title;
  final String message;
  final int? targetId;
  final bool read;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.targetId,
    this.read = false,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    return AppNotification(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      targetId: json['targetId'] as int?,
      read: json['read'] as bool? ?? false,
      createdAt: createdAt is String ? DateTime.tryParse(createdAt) : null,
    );
  }
}
