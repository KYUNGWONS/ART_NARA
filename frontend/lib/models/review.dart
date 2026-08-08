import '../utils/server_time.dart';

/// 작품 리뷰 (GET /api/artists/{name}/reviews 응답 항목)
class Review {
  final int id;
  final int artworkId;
  final String artworkTitle;
  final String authorNickname;
  final int rating;
  final String content;
  final DateTime? createdAt;

  const Review({
    required this.id,
    required this.artworkId,
    required this.artworkTitle,
    required this.authorNickname,
    required this.rating,
    required this.content,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    return Review(
      id: json['id'] as int? ?? 0,
      artworkId: json['artworkId'] as int? ?? 0,
      artworkTitle: json['artworkTitle'] as String? ?? '',
      authorNickname: json['authorNickname'] as String? ?? '',
      rating: json['rating'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      createdAt: parseServerTime(createdAt),
    );
  }
}

/// 작가 리뷰 목록 응답
class ReviewList {
  final List<Review> reviews;
  final int totalCount;
  final double? averageRating;

  const ReviewList({
    this.reviews = const [],
    this.totalCount = 0,
    this.averageRating,
  });

  factory ReviewList.fromJson(Map<String, dynamic> json) {
    return ReviewList(
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
    );
  }
}
