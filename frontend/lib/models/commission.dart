class Commission {
  const Commission({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.categories = const [],
    required this.budget,
    required this.status,
    required this.notifiedArtistCount,
    required this.offers,
    required this.referenceImageUrl,
    this.desiredDate,
    this.lowestOffer,
  });

  final int id;
  final String title;
  final String description;
  /// 대표 카테고리(첫 선택). 구버전 응답 호환용.
  final String category;

  /// 선택한 선호 카테고리 전체. 없으면 category 하나로 채운다.
  final List<String> categories;
  final int budget;
  final String? desiredDate;
  final String status;
  final int notifiedArtistCount;
  final int? lowestOffer;
  final String referenceImageUrl;
  final List<CommissionOffer> offers;

  factory Commission.fromJson(Map<String, dynamic> json) {
    final offers = json['offers'] is List
        ? (json['offers'] as List)
            .whereType<Map<String, dynamic>>()
            .map(CommissionOffer.fromJson)
            .toList()
        : const <CommissionOffer>[];
    return Commission(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      categories: json['categories'] is List
          ? (json['categories'] as List).whereType<String>().toList()
          : [if ((json['category'] as String? ?? '').isNotEmpty) json['category'] as String],
      budget: json['budget'] as int? ?? 0,
      desiredDate: json['desiredDate'] as String?,
      status: json['status'] as String? ?? '',
      notifiedArtistCount: json['notifiedArtistCount'] as int? ?? 0,
      lowestOffer: json['lowestOffer'] as int?,
      referenceImageUrl: json['referenceImageUrl'] as String? ?? '',
      offers: offers,
    );
  }
}

class CommissionOffer {
  const CommissionOffer({
    required this.artistName,
    required this.amount,
    required this.message,
    required this.offerTime,
  });

  final String artistName;
  final int amount;
  final String message;
  final String offerTime;

  factory CommissionOffer.fromJson(Map<String, dynamic> json) {
    return CommissionOffer(
      artistName: json['artistName'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      offerTime: json['offerTime'] as String? ?? '',
    );
  }
}
