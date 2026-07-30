class Sale {
  const Sale({
    required this.id,
    required this.title,
    required this.description,
    required this.medium,
    required this.size,
    required this.buyNowPrice,
    required this.auctionEnabled,
    required this.status,
    this.year,
    this.auctionStartPrice,
    this.auctionEndDate,
  });

  final int id;
  final String title;
  final String description;
  final String medium;
  final String size;
  final int? year;
  final int buyNowPrice;
  final bool auctionEnabled;
  final int? auctionStartPrice;
  final String? auctionEndDate;
  final String status;

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      medium: json['medium'] as String? ?? '',
      size: json['size'] as String? ?? '',
      year: json['year'] as int?,
      buyNowPrice: json['buyNowPrice'] as int? ?? 0,
      auctionEnabled: json['auctionEnabled'] as bool? ?? false,
      auctionStartPrice: json['auctionStartPrice'] as int?,
      auctionEndDate: json['auctionEndDate'] as String?,
      status: json['status'] as String? ?? '',
    );
  }
}
