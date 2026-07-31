class ArtistProfile {
  const ArtistProfile({
    required this.name,
    required this.introduction,
    required this.location,
    required this.artworkCount,
    required this.salesCount,
    required this.rating,
    required this.reviewCount,
    required this.artworks,
  });

  final String name;
  final String introduction;
  final String location;
  final int artworkCount;
  final int salesCount;
  final double rating;
  final int reviewCount;
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
      location: json['location'] as String? ?? '',
      artworkCount: json['artworkCount'] as int? ?? 0,
      salesCount: json['salesCount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
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
