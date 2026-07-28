/// 작성자 유형 (한국인 대학생 / 방문 외국인)
enum CommunityAuthorRole { koreanStudent, foreigner }

/// 여행 커뮤니티 게시물 모델 (자유 게시판)
/// 추후 백엔드 API 응답으로 교체
class CommunityPost {
  final String id;
  final String author;
  final CommunityAuthorRole authorRole;
  final String category;
  final String title;
  final String content;
  final String? imageUrl;
  final int likes;
  final int comments;

  /// 표시용 (예: "방금 전", "2시간 전", "어제")
  final String createdAt;

  const CommunityPost({
    required this.id,
    required this.author,
    required this.authorRole,
    required this.category,
    required this.title,
    required this.content,
    this.imageUrl,
    this.likes = 0,
    this.comments = 0,
    this.createdAt = '방금 전',
  });
}
