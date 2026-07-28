import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../data/mock_community_data.dart';
import '../models/community_post.dart';

/// 선택 카테고리 기준 필터된 게시물 (공용)
List<CommunityPost> filteredCommunityPosts(String categoryId) {
  if (categoryId == categoryAll) return mockCommunityPosts;
  return mockCommunityPosts.where((p) => p.category == categoryId).toList();
}

/// 홈 화면용: 고정 높이, 세로 카테고리, 스크롤 없음, 더보기로 전체 화면 이동
class CommunityBoardPreview extends StatelessWidget {
  final String selectedCategoryId;
  final ValueChanged<String> onCategoryChanged;
  static const double fixedHeight = 360;

  const CommunityBoardPreview({
    super.key,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final posts = filteredCommunityPosts(selectedCategoryId);
    final displayPosts = posts.take(2).toList(); // 고정 2개만 표시, 스크롤 없음

    return SizedBox(
      height: fixedHeight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 세로 카테고리
              _VerticalCategoryList(
                selectedCategoryId: selectedCategoryId,
                onCategoryChanged: onCategoryChanged,
              ),
              // 오른쪽: 우측 상단 더보기 + 게시물 미리보기(고정)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 더보기 버튼 (우측 상단)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => CommunityBoardFullScreen(
                                  initialCategoryId: selectedCategoryId,
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            '더보기',
                            style: GoogleFonts.gowunDodum(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: displayPosts.isEmpty
                          ? Center(
                              child: Text(
                                '해당 카테고리에 게시물이 없어요',
                                style: GoogleFonts.gowunDodum(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.grey,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(
                                top: 4,
                                left: 12,
                                right: 12,
                                bottom: 8,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (
                                    int i = 0;
                                    i < displayPosts.length;
                                    i++
                                  ) ...[
                                    if (i > 0) const SizedBox(height: 10),
                                    _CompactPostTile(post: displayPosts[i]),
                                  ],
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 세로 배치 카테고리 리스트
class _VerticalCategoryList extends StatelessWidget {
  final String selectedCategoryId;
  final ValueChanged<String> onCategoryChanged;

  const _VerticalCategoryList({
    required this.selectedCategoryId,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      color: AppColors.offWhite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final cat in communityCategories) ...[
            GestureDetector(
              onTap: () => onCategoryChanged(cat['id']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selectedCategoryId == cat['id']
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: Border(
                    left: BorderSide(
                      color: selectedCategoryId == cat['id']
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    cat['label']!,
                    style: GoogleFonts.gowunDodum(
                      fontSize: 12,
                      fontWeight: selectedCategoryId == cat['id']
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selectedCategoryId == cat['id']
                          ? AppColors.primary
                          : AppColors.darkGrey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 미리보기용 짧은 게시물 타일 (카드보다 작게)
class _CompactPostTile extends StatelessWidget {
  final CommunityPost post;

  const _CompactPostTile({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.gowunDodum(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.gowunDodum(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  post.author,
                  style: GoogleFonts.gowunDodum(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  post.createdAt,
                  style: GoogleFonts.gowunDodum(
                    fontSize: 11,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 더보기 시 열리는 전체 게시판 화면 (한 화면 안에서 스크롤로 전체 목록)
class CommunityBoardFullScreen extends StatefulWidget {
  final String initialCategoryId;

  const CommunityBoardFullScreen({
    super.key,
    this.initialCategoryId = categoryAll,
  });

  @override
  State<CommunityBoardFullScreen> createState() =>
      _CommunityBoardFullScreenState();
}

class _CommunityBoardFullScreenState extends State<CommunityBoardFullScreen> {
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final posts = filteredCommunityPosts(_selectedCategoryId);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(
          '자유 게시판',
          style: GoogleFonts.gowunDodum(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _VerticalCategoryList(
            selectedCategoryId: _selectedCategoryId,
            onCategoryChanged: (id) => setState(() => _selectedCategoryId = id),
          ),
          Expanded(
            child: posts.isEmpty
                ? Center(
                    child: Text(
                      '해당 카테고리에 게시물이 없어요',
                      style: GoogleFonts.gowunDodum(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                    itemCount: posts.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CommunityPostCard(post: posts[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 카테고리 ID → 한글 라벨
String _categoryLabel(String id) {
  switch (id) {
    case 'question':
      return '질문';
    case 'review':
      return '후기';
    case 'meetup':
      return '만남';
    case 'info':
      return '정보';
    default:
      return '전체';
  }
}

/// 게시물 카드 (자유 게시판 스타일: 작성자 유형·카테고리·작성일)
class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;

  const CommunityPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final isKorean = post.authorRole == CommunityAuthorRole.koreanStudent;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (post.imageUrl != null) _buildImage(post.imageUrl!),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 카테고리 태그 + 작성자 유형 + 작성일
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _categoryLabel(post.category),
                        style: GoogleFonts.gowunDodum(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isKorean ? '한국인 대학생' : '외국인',
                      style: GoogleFonts.gowunDodum(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      post.createdAt,
                      style: GoogleFonts.gowunDodum(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  post.title,
                  style: GoogleFonts.gowunDodum(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.gowunDodum(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGrey,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      post.author,
                      style: GoogleFonts.gowunDodum(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 18,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likes}',
                      style: GoogleFonts.gowunDodum(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.comments}',
                      style: GoogleFonts.gowunDodum(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildImage(String imageUrl) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.lightGrey,
          child: const Icon(Icons.image_not_supported_outlined, size: 48),
        ),
      ),
    );
  }
}

/// 여행 커뮤니티 피드 화면 (단독 탭용, 현재 미사용)
/// - Header: 브랜드 메시지
/// - Category Bar: 가로 스크롤 칩
/// - Post Feed: 카드 리스트 (사진 강조)
/// - FAB: 글쓰기 (동작 추후 연결)
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedCategoryId = categoryAll;

  List<CommunityPost> get _filteredPosts {
    if (_selectedCategoryId == categoryAll) return mockCommunityPosts;
    return mockCommunityPosts
        .where((p) => p.category == _selectedCategoryId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCategoryBar(),
            Expanded(child: _buildPostFeed()),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// 가로 스크롤 카테고리 칩
  Widget _buildCategoryBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      color: AppColors.white,
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          itemCount: communityCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final cat = communityCategories[index];
            final id = cat['id']!;
            final label = cat['label']!;
            final isSelected = _selectedCategoryId == id;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryId = id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.offWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.lightGrey,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: GoogleFonts.gowunDodum(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.darkGrey,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 게시물 피드 (카드 리스트, 사진 강조)
  Widget _buildPostFeed() {
    final posts = _filteredPosts;
    if (posts.isEmpty) {
      return Center(
        child: Text(
          '해당 카테고리에 게시물이 없어요',
          style: GoogleFonts.gowunDodum(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return CommunityPostCard(post: posts[index]);
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        // TODO: 글쓰기 페이지로 이동
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      child: const Icon(Icons.edit_rounded, size: 26),
    );
  }
}
