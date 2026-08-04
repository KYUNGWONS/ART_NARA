import 'package:flutter/material.dart';

import '../constants/dust_tokens.dart';
import '../models/home_feed.dart';
import '../services/artwork_api_service.dart';
import '../utils/image_url.dart';
import '../widgets/auction_countdown.dart';
import '../widgets/sold_overlay.dart';
import 'art_home_feed_screen.dart' show formatPrice;
import 'artwork_detail_screen.dart';

/// 홈 피드 '더보기' — 전체 작품을 페이지 단위(무한 스크롤)로 본다.
///
/// GET /api/artworks?page=&size=&category= 를 사용한다. 홈 피드는 섹션당 20건으로
/// 잘려 내려오므로, 전체 목록은 이 화면이 담당한다.
class ArtworkListScreen extends StatefulWidget {
  const ArtworkListScreen({super.key, required this.title, this.category});

  final String title;

  /// null 또는 '추천' 이면 전체.
  final String? category;

  @override
  State<ArtworkListScreen> createState() => _ArtworkListScreenState();
}

class _ArtworkListScreenState extends State<ArtworkListScreen> {
  static const _pageSize = 20;

  final _api = const ArtworkApiService();
  final _scrollController = ScrollController();
  final List<Artwork> _items = [];

  int _nextPage = 0;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      // 바닥 400px 전에 미리 다음 페이지를 청한다.
      if (_scrollController.position.extentAfter < 400) _loadMore();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      final page = await _api.fetchPage(
        page: _nextPage,
        size: _pageSize,
        category: widget.category,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(page.items);
        _hasMore = !page.last;
        _nextPage++;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('작품 목록을 불러오지 못했어요')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DustColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: DustColors.bgCanvas,
        elevation: 0,
        foregroundColor: DustColors.textPrimary,
        title: Text(widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: DustColors.brandPrimary,
            )),
        centerTitle: true,
      ),
      body: _items.isEmpty && !_loading
          ? const Center(child: Text('작품이 없습니다', style: DustText.caption))
          : GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(DustSpacing.md),
              // 로딩 인디케이터 자리 1칸
              itemCount: _items.length + (_hasMore ? 1 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: DustSpacing.sm,
                mainAxisSpacing: DustSpacing.sm,
                mainAxisExtent: 258,
              ),
              itemBuilder: (context, index) {
                if (index >= _items.length) {
                  return const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: DustColors.brandPrimary),
                    ),
                  );
                }
                return _Card(artwork: _items[index]);
              },
            ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.artwork});

  final Artwork artwork;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ArtworkDetailScreen(artworkId: artwork.id),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: DustColors.bgSurface,
          borderRadius: BorderRadius.circular(DustRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: DustColors.bgSubtle,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(DustRadius.md)),
                  ),
                  child: artwork.imageUrl.isEmpty
                      ? const Icon(Icons.image_outlined,
                          color: DustColors.textSecondary)
                      : ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(DustRadius.md)),
                          child: Image.network(
                              resolveImageUrl(artwork.imageUrl),
                              fit: BoxFit.cover),
                        ),
                ),
                if (artwork.sold)
                  const Positioned.fill(
                    child: SoldOverlay(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(DustRadius.md)),
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
                  Text(artwork.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: DustColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text(artwork.artistName,
                      style: const TextStyle(
                          fontSize: 13, color: DustColors.textSecondary)),
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
                    AuctionCountdown(
                      artwork.remainingTime,
                      prefix: '남은 시간 ',
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
