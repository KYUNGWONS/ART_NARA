class ArtistProfile {
  const ArtistProfile({
    required this.name,
    required this.introduction,
    this.location,
    required this.artworkCount,
    required this.salesCount,
    this.rating,
    this.reviewCount,
    required this.artworks,
  });

  final String name;
  final String introduction;
  /// 작가 프로필의 활동 지역(없으면 null)
  final String? location;
  final int artworkCount;
  final int salesCount;
  /// 리뷰 도메인이 없어 서버가 내려주지 않으면 null
  final double? rating;
  final int? reviewCount;
  final List<ArtistArtwork> artworks;

  factory ArtistProfile.fromJson(Map<String, dynamic> json) {
    final artworks = json['artworks'] is List
        ? (json['artworks'] as List)
            .whereType<Map<String, dynamic>>()
            .map(ArtistArtwork.fromJson)
            .toList()
        : const <ArtistArtwork>[];
    return ArtistProfile(
      name: json['name'] as String? ?? '',
      introduction: json['introduction'] as String? ?? '',
      location: json['location'] as String?,
      artworkCount: json['artworkCount'] as int? ?? 0,
      salesCount: json['salesCount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      artworks: artworks,
    );
  }
}

class ArtistArtwork {
  const ArtistArtwork({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.auction,
  });

  final int id;
  final String title;
  final String imageUrl;
  final int price;
  final bool auction;

  factory ArtistArtwork.fromJson(Map<String, dynamic> json) {
    return ArtistArtwork(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      auction: json['auction'] as bool? ?? false,
    );
  }
}
