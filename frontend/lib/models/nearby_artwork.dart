class NearbyArtwork {
  const NearbyArtwork({
    required this.id,
    required this.title,
    required this.artistName,
    required this.price,
    required this.auction,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.distanceKm,
  });

  final int id;
  final String title;
  final String artistName;
  final int price;
  final bool auction;
  final double latitude;
  final double longitude;
  final String address;
  final double distanceKm;

  factory NearbyArtwork.fromJson(Map<String, dynamic> json) {
    return NearbyArtwork(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      auction: json['auction'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      address: json['address'] as String? ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
    );
  }
}
