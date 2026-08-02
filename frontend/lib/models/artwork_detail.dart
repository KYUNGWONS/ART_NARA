class ArtworkDetail {
  const ArtworkDetail({
    required this.id,
    required this.title,
    required this.artistName,
    required this.artistIntroduction,
    required this.description,
    required this.imageUrl,
    required this.medium,
    required this.size,
    required this.year,
    required this.price,
    required this.auction,
    required this.minBidIncrement,
    required this.certified,
    required this.bidHistory,
    required this.auctionClosed,
    this.winnerName,
    this.wonByViewer = false,
    this.currentBid,
    this.remainingTime,
  });

  final int id;
  final String title;
  final String artistName;
  final String artistIntroduction;
  final String description;
  final String imageUrl;
  final String medium;
  final String size;
  final int year;
  final int price;
  final bool auction;
  final int? currentBid;
  final int minBidIncrement;
  final String? remainingTime;
  final bool auctionClosed;
  final String? winnerName;

  /// 서버가 판단한 '내가 낙찰자인지' — 클라이언트에서 이름을 비교하지 않는다.
  final bool wonByViewer;
  final bool certified;
  final List<ArtworkBid> bidHistory;

  factory ArtworkDetail.fromJson(Map<String, dynamic> json) {
    final bids = json['bidHistory'] is List
        ? (json['bidHistory'] as List)
            .whereType<Map<String, dynamic>>()
            .map(ArtworkBid.fromJson)
            .toList()
        : const <ArtworkBid>[];
    return ArtworkDetail(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      artistIntroduction: json['artistIntroduction'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      medium: json['medium'] as String? ?? '',
      size: json['size'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      price: json['price'] as int? ?? 0,
      auction: json['auction'] as bool? ?? false,
      currentBid: json['currentBid'] as int?,
      minBidIncrement: json['minBidIncrement'] as int? ?? 0,
      remainingTime: json['remainingTime'] as String?,
      auctionClosed: json['auctionClosed'] as bool? ?? false,
      winnerName: json['winnerName'] as String?,
      wonByViewer: json['wonByViewer'] as bool? ?? false,
      certified: json['certified'] as bool? ?? false,
      bidHistory: bids,
    );
  }
}

class ArtworkBid {
  const ArtworkBid({
    required this.bidderName,
    required this.amount,
    required this.bidTime,
  });

  final String bidderName;
  final int amount;
  final String bidTime;

  factory ArtworkBid.fromJson(Map<String, dynamic> json) {
    return ArtworkBid(
      bidderName: json['bidderName'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      bidTime: json['bidTime'] as String? ?? '',
    );
  }
}
