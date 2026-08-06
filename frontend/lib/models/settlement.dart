/// 작가 판매 정산. 금액은 원 단위, 환불 건은 합계에서 빠진다.
class Settlement {
  const Settlement({
    required this.totalSales,
    required this.feeRate,
    required this.feeAmount,
    required this.netAmount,
    required this.thisMonthSales,
    required this.saleCount,
    required this.items,
  });

  final int totalSales;
  final int feeRate;
  final int feeAmount;
  final int netAmount;
  final int thisMonthSales;
  final int saleCount;
  final List<SettlementItem> items;

  factory Settlement.fromJson(Map<String, dynamic> json) => Settlement(
        totalSales: json['totalSales'] as int? ?? 0,
        feeRate: json['feeRate'] as int? ?? 0,
        feeAmount: json['feeAmount'] as int? ?? 0,
        netAmount: json['netAmount'] as int? ?? 0,
        thisMonthSales: json['thisMonthSales'] as int? ?? 0,
        saleCount: json['saleCount'] as int? ?? 0,
        items: (json['items'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(SettlementItem.fromJson)
            .toList(),
      );
}

class SettlementItem {
  const SettlementItem({
    required this.orderId,
    required this.artworkTitle,
    required this.buyerName,
    required this.amount,
    required this.feeAmount,
    required this.netAmount,
    required this.soldDate,
    required this.refunded,
  });

  final int orderId;
  final String artworkTitle;
  final String buyerName;
  final int amount;
  final int feeAmount;
  final int netAmount;
  final String soldDate;
  final bool refunded;

  factory SettlementItem.fromJson(Map<String, dynamic> json) => SettlementItem(
        orderId: json['orderId'] as int? ?? 0,
        artworkTitle: json['artworkTitle'] as String? ?? '',
        buyerName: json['buyerName'] as String? ?? '구매자',
        amount: json['amount'] as int? ?? 0,
        feeAmount: json['feeAmount'] as int? ?? 0,
        netAmount: json['netAmount'] as int? ?? 0,
        soldDate: json['soldDate'] as String? ?? '',
        refunded: json['refunded'] as bool? ?? false,
      );
}
