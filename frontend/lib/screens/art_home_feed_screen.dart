import 'package:flutter/material.dart';

import '../constants/dust_tokens.dart';
import '../utils/artist_inquiry.dart';
import 'artwork_list_screen.dart';
import '../models/home_feed.dart';
import '../services/artwork_like_api_service.dart';
import '../services/home_feed_api_service.dart';
import 'artist_portfolio_screen.dart';
import 'artwork_detail_screen.dart';

/// 카테고리 필터 칩 (Figma 홈 피드 1:437).
/// TODO(서버 연동): 작품에 카테고리 필드가 생기면 실제 필터링으로 교체.
const _categories = ['추천', '회화', '조각', '디지털', '사진', '일러스트'];

class ArtHomeFeedScreen extends StatefulWidget {
  const ArtHomeFeedScreen({super.key});

  @override
  State<ArtHomeFeedScreen> createState() => _ArtHomeFeedScreenState();
}

class _ArtHomeFeedScreenState extends State<ArtHomeFeedScreen> {
  final _searchController = TextEditingController();
  final _api = const HomeFeedApiService();
  late Future<HomeFeed> _feedFuture;
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _feedFuture = _api.fetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openMore(String title, List<Artwork> items) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
          builder: (_) => ArtworkListScreen(title: title, items: items),
        ))
        .then((_) => _search());
  }

  Future<void> _toggleLike(Artwork artwork) async {
    final liked = await ArtworkLikeApiService.toggle(artwork.id);
    if (!mounted) return;
    if (liked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('관심 작품은 로그인 후 이용할 수 있어요')),
      );
      return;
    }
    _search(); // 서버 상태로 목록 갱신
  }

  void _search() {
    setState(() {
      _feedFuture = _api.fetch(
        query: _searchController.text,
        category: _categories[_selectedCategory],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeFeed>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: DustColors.brandPrimary),
          );
        }
        if (snapshot.hasError) {
          return _ErrorView(onRetry: _search);
        }

        final feed = snapshot.data!;
        return RefreshIndicator(
          color: DustColors.brandPrimary,
          onRefresh: () async => _search(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                DustSpacing.md, DustSpacing.md, DustSpacing.md, 32),
            children: [
              _SearchRow(
                controller: _searchController,
                onSubmitted: (_) => _search(),
              ),
              const SizedBox(height: DustSpacing.lg),
              _CategoryTabs(
                selected: _selectedCategory,
                onSelected: (index) {
                  _selectedCategory = index;
                  _search();
                },
              ),
              const SizedBox(height: DustSpacing.lg),
              _SectionHeader(
                title: '추천 작품',
                onMore: () => _openMore('추천 작품', feed.recommended),
              ),
              const SizedBox(height: DustSpacing.sm),
              _ArtworkGrid(items: feed.recommended, onToggleLike: _toggleLike),
              const SizedBox(height: DustSpacing.lg),
              _SectionHeader(
                title: '마감 임박 경매',
                onMore: () => _openMore('마감 임박 경매', feed.auctions),
              ),
              const SizedBox(height: DustSpacing.sm),
              _ArtworkGrid(items: feed.auctions, onToggleLike: _toggleLike),
              const SizedBox(height: DustSpacing.lg),
              _ArtistSection(artists: feed.artists),
            ],
          ),
        );
      },
    );
  }
}

/// 검색 바 + 필터 버튼 (디자인: pill 검색창 34.7 높이 + 우측 정사각 버튼)
class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                  fontSize: 14, color: DustColors.textPrimary),
              decoration: InputDecoration(
                hintText: '작품, 작가, 태그 검색',
                hintStyle: const TextStyle(
                    fontSize: 14, color: DustColors.textSecondary),
                prefixIcon: const Icon(Icons.search,
                    size: 20, color: DustColors.textSecondary),
                filled: true,
                fillColor: DustColors.bgSurface,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DustRadius.full),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: DustSpacing.xs),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: DustColors.bgSurface,
            borderRadius: BorderRadius.circular(DustRadius.sm),
          ),
          child: const Icon(Icons.tune,
              size: 20, color: DustColors.textPrimary),
        ),
      ],
    );
  }
}

/// 카테고리 칩 (활성: teal pill + white, 비활성: surface + line border)
class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final active = index == selected;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active
                    ? DustColors.brandPrimary
                    : DustColors.bgSurface,
                borderRadius: BorderRadius.circular(DustRadius.full),
                border: active
                    ? null
                    : Border.all(color: DustColors.borderSoft),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active
                      ? DustColors.textOnBrand
                      : DustColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 섹션 헤더: 제목 + 더보기 >
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onMore});

  final String title;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DustColors.textPrimary)),
        InkWell(
          onTap: onMore,
          borderRadius: BorderRadius.circular(DustRadius.sm),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                Text('더보기',
                    style: TextStyle(
                        fontSize: 13, color: DustColors.textSecondary)),
                SizedBox(width: 2),
                Icon(Icons.chevron_right,
                    size: 16, color: DustColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ArtworkGrid extends StatelessWidget {
  const _ArtworkGrid({required this.items, required this.onToggleLike});

  final List<Artwork> items;
  final void Function(Artwork artwork) onToggleLike;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: DustSpacing.md),
        child: Text('작품이 없습니다', style: DustText.caption),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: DustSpacing.sm,
        mainAxisSpacing: DustSpacing.sm,
        mainAxisExtent: 258,
      ),
      itemBuilder: (context, index) => _ArtworkCard(
        artwork: items[index],
        onToggleLike: () => onToggleLike(items[index]),
      ),
    );
  }
}

/// 작품 카드 (디자인: paper 카드, 이미지 160 + 하트, 제목/작가/가격)
class _ArtworkCard extends StatelessWidget {
  const _ArtworkCard({required this.artwork, required this.onToggleLike});

  final VoidCallback onToggleLike;

  final Artwork artwork;

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArtworkDetailScreen(artworkId: artwork.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: DustColors.bgSurface,
          borderRadius: BorderRadius.circular(DustRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _ArtworkThumb(imageUrl: artwork.imageUrl, height: 160),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onToggleLike,
                      borderRadius: BorderRadius.circular(DustRadius.full),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          artwork.liked ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: artwork.liked
                              ? DustColors.brandPrimary
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  DustSpacing.md, DustSpacing.xs, DustSpacing.md, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    // 디자인 art-title: 15px w800
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: DustColors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    artwork.artistName,
                    style: const TextStyle(
                        fontSize: 13, color: DustColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₩${formatPrice(artwork.auction ? (artwork.currentBid ?? artwork.price) : artwork.price)}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DustColors.textPrimary),
                  ),
                  if (artwork.remainingTime != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '남은 시간 ${artwork.remainingTime}',
                      style: const TextStyle(
                          fontSize: 11, color: DustColors.brandPrimary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistSection extends StatelessWidget {
  const _ArtistSection({required this.artists});

  final List<Artist> artists;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: '주목할 작가'),
        const SizedBox(height: DustSpacing.xs),
        ...artists.map(
          (artist) => Container(
            margin: const EdgeInsets.only(bottom: DustSpacing.xs),
            decoration: BoxDecoration(
              color: DustColors.bgSurface,
              borderRadius: BorderRadius.circular(DustRadius.md),
            ),
            child: ListTile(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ArtistPortfolioScreen(artistName: artist.name),
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: DustSpacing.md),
              leading: const CircleAvatar(
                  backgroundColor: DustColors.bgSubtle,
                  child: Icon(Icons.person_outline,
                      color: DustColors.textSecondary)),
              title: Text(artist.name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DustColors.textPrimary)),
              subtitle: Text(artist.introduction,
                  style: const TextStyle(
                      fontSize: 12, color: DustColors.textSecondary)),
              trailing: OutlinedButton(
                onPressed: () => openArtistInquiry(context, artist.name),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DustColors.brandPrimary,
                  side: const BorderSide(color: DustColors.brandPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DustRadius.full),
                  ),
                ),
                child: const Text('문의하기'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArtworkThumb extends StatelessWidget {
  const _ArtworkThumb({required this.imageUrl, required this.height});

  final String imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        alignment: Alignment.center,
        color: DustColors.bgSubtle,
        child: const Icon(Icons.image_outlined,
            size: 28, color: DustColors.textSecondary),
      );
    }
    return Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        height: height,
        color: DustColors.bgSubtle,
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined,
            size: 28, color: DustColors.textSecondary),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('홈 피드를 불러오지 못했어요', style: DustText.caption),
          const SizedBox(height: DustSpacing.sm),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: DustColors.brandPrimary,
              side: const BorderSide(color: DustColors.brandPrimary),
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

/// 1234567 → 1,234,567
String formatPrice(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
    buffer.write(text[i]);
  }
  return buffer.toString();
}
