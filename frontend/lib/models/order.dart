class Order {
  const Order({
    required this.orderId,
    required this.artworkId,
    required this.artworkTitle,
    required this.artistName,
    required this.price,
    required this.deliveryFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.receiverName,
    required this.deliveryAddress,
    required this.status,
    required this.certificateNo,
    required this.orderedDate,
  });

  final int orderId;
  final int artworkId;
  final String artworkTitle;
  final String artistName;
  final int price;
  final int deliveryFee;
  final int totalAmount;
  final String paymentMethod;
  final String receiverName;
  final String deliveryAddress;
  final String status;
  final String certificateNo;
  final String orderedDate;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] as int? ?? 0,
      artworkId: json['artworkId'] as int? ?? 0,
      artworkTitle: json['artworkTitle'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      deliveryFee: json['deliveryFee'] as int? ?? 0,
      totalAmount: json['totalAmount'] as int? ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? '',
      receiverName: json['receiverName'] as String? ?? '',
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      status: json['status'] as String? ?? '',
      certificateNo: json['certificateNo'] as String? ?? '',
      orderedDate: json['orderedDate'] as String? ?? '',
    );
  }
}
