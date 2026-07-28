class HomeFeed {
  const HomeFeed({
    required this.curationTitle,
    required this.curationDescription,
    required this.recommended,
    required this.auctions,
    required this.artists,
  });

  final String curationTitle;
  final String curationDescription;
  final List<Artwork> recommended;
  final List<Artwork> auctions;
  final List<Artist> artists;

  factory HomeFeed.fromJson(Map<String, dynamic> json) {
    return HomeFeed(
      curationTitle: json['curationTitle'] as String? ?? '',
      curationDescription: json['curationDescription'] as String? ?? '',
      recommended: _parseList(json['recommended']),
      auctions: _parseList(json['auctions']),
      artists: _parseArtists(json['artists']),
    );
  }

  static List<Artwork> _parseList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(Artwork.fromJson)
        .toList();
  }

  static List<Artist> _parseArtists(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(Artist.fromJson)
        .toList();
  }
}

class Artwork {
  const Artwork({
    required this.id,
    required this.title,
    required this.artistName,
    required this.price,
    required this.imageUrl,
    required this.liked,
    required this.auction,
    this.currentBid,
    this.remainingTime,
  });

  final int id;
  final String title;
  final String artistName;
  final int price;
  final String imageUrl;
  final bool liked;
  final bool auction;
  final int? currentBid;
  final String? remainingTime;

  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      liked: json['liked'] as bool? ?? false,
      auction: json['auction'] as bool? ?? false,
      currentBid: json['currentBid'] as int?,
      remainingTime: json['remainingTime'] as String?,
    );
  }
}

class Artist {
  const Artist({required this.name, required this.introduction});

  final String name;
  final String introduction;

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['name'] as String? ?? '',
      introduction: json['introduction'] as String? ?? '',
    );
  }
}
