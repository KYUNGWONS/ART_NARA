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
    this.sellerConfirmed = false,
    this.buyerConfirmed = false,
    this.paid = false,
    this.cancelled = false,
    this.viewerIsSeller = false,
    this.buyerName = '',
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

  /// 직거래 진행 상태. 배송이 없어 만나서 주고받은 뒤 양쪽이 확인해야 결제가 열린다.
  final bool sellerConfirmed;
  final bool buyerConfirmed;
  final bool paid;
  final bool cancelled;

  /// 이 주문을 보는 사람이 판매자인지. 버튼 문구가 '전달했어요'/'받았어요' 로 갈린다.
  final bool viewerIsSeller;
  final String buyerName;

  /// 내가 눌러야 할 확인이 남아 있는지.
  bool get needsMyConfirmation =>
      !paid && !cancelled && !(viewerIsSeller ? sellerConfirmed : buyerConfirmed);

  /// 양쪽 확인이 끝나 결제만 남았는지(구매자에게만 의미 있다).
  bool get readyToPay =>
      !paid && !cancelled && sellerConfirmed && buyerConfirmed;

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
      sellerConfirmed: json['sellerConfirmed'] as bool? ?? false,
      buyerConfirmed: json['buyerConfirmed'] as bool? ?? false,
      paid: json['paid'] as bool? ?? false,
      cancelled: json['cancelled'] as bool? ?? false,
      viewerIsSeller: json['viewerIsSeller'] as bool? ?? false,
      buyerName: json['buyerName'] as String? ?? '',
    );
  }
}
