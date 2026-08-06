class Order {
  const Order({
    required this.orderId,
    required this.artworkId,
    required this.artworkTitle,
    required this.artistName,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.certificateNo,
    required this.orderedDate,
    required this.refunded,
  });

  final int orderId;
  final int artworkId;
  final String artworkTitle;
  final String artistName;
  final int amount;
  final String paymentMethod;
  final String status;
  final String certificateNo;
  final String orderedDate;

  /// 환불된 주문인지. 구버전 응답에는 없어 false 로 읽는다.
  final bool refunded;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] as int? ?? 0,
      artworkId: json['artworkId'] as int? ?? 0,
      artworkTitle: json['artworkTitle'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? '',
      status: json['status'] as String? ?? '',
      certificateNo: json['certificateNo'] as String? ?? '',
      orderedDate: json['orderedDate'] as String? ?? '',
      refunded: json['refunded'] as bool? ?? false,
    );
  }
}
