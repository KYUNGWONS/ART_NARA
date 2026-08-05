import 'package:flutter/material.dart';

import '../constants/art_tokens.dart';
import '../utils/image_url.dart';
import '../models/artwork_detail.dart';
import '../services/artwork_like_api_service.dart';
import 'art_home_feed_screen.dart' show formatPrice;
import 'artwork_detail_screen.dart';

/// 관심 작품 목록 (마이페이지 > 관심 작품)
class LikedArtworksScreen extends StatefulWidget {
  const LikedArtworksScreen({super.key});

  @override
  State<LikedArtworksScreen> createState() => _LikedArtworksScreenState();
}

class _LikedArtworksScreenState extends State<LikedArtworksScreen> {
  List<ArtworkDetail> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await ArtworkLikeApiService.listLiked();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  /// 하트를 눌러 관심 해제. 목록에서 먼저 빼고(낙관적) 서버 응답으로 확정한다.
  /// 팔린 작품은 피드에서 하트를 다시 누를 수 없으므로 여기서 되돌릴 수 있어야 한다.
  Future<void> _unlike(ArtworkDetail artwork) async {
    final index = _items.indexWhere((item) => item.id == artwork.id);
    if (index < 0) return;
    setState(() => _items = List.of(_items)..removeAt(index));

    final liked = await ArtworkLikeApiService.toggle(artwork.id);
    if (!mounted) return;
    if (liked == null || liked) {
      // 실패했거나 서버가 여전히 '관심'이면 되돌려 놓는다.
      _insertBack(artwork, index);
      _showSnack('관심 해제에 실패했어요');
      return;
    }
    _showSnack('관심 작품에서 뺐어요', onUndo: () => _restore(artwork, index));
  }

  Future<void> _restore(ArtworkDetail artwork, int index) async {
    final liked = await ArtworkLikeApiService.toggle(artwork.id);
    if (!mounted) return;
    if (liked == true) {
      _insertBack(artwork, index);
    } else {
      _showSnack('다시 담지 못했어요');
    }
  }

  void _insertBack(ArtworkDetail artwork, int index) {
    setState(() => _items = List.of(_items)
      ..insert(index.clamp(0, _items.length), artwork));
  }

  void _showSnack(String message, {VoidCallback? onUndo}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      action: onUndo == null
          ? null
          : SnackBarAction(label: '되돌리기', onPressed: onUndo),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArtColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: ArtColors.bgCanvas,
        elevation: 0,
        foregroundColor: ArtColors.textPrimary,
        title: const Text('관심 작품',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ArtColors.brandPrimary,
            )),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: ArtColors.brandPrimary))
          : _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border,
                      size: 64, color: ArtColors.borderSoft),
                  const SizedBox(height: ArtSpacing.md),
                  Text('아직 관심 작품이 없어요',
                      style: ArtText.body
                          .copyWith(color: ArtColors.textSecondary)),
                  const SizedBox(height: ArtSpacing.xs),
                  const Text('마음에 드는 작품의 하트를 눌러보세요',
                      style: ArtText.caption),
                ],
              ),
            )
          : RefreshIndicator(
              color: ArtColors.brandPrimary,
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: ArtSpacing.xs),
                itemCount: _items.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: ArtColors.borderSoft),
                itemBuilder: (context, index) => _tile(_items[index]),
              ),
            ),
    );
  }

  Widget _tile(ArtworkDetail artwork) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: ArtSpacing.lg, vertical: ArtSpacing.xs),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: ArtColors.bgSubtle,
          borderRadius: BorderRadius.circular(ArtRadius.sm),
        ),
        child: artwork.imageUrl.isEmpty
            ? const Icon(Icons.image_outlined,
                color: ArtColors.textSecondary, size: 22)
            : ClipRRect(
                borderRadius: BorderRadius.circular(ArtRadius.sm),
                child: Image.network(resolveImageUrl(artwork.imageUrl), fit: BoxFit.cover),
              ),
      ),
      title: Text(artwork.title,
          style: ArtText.body.copyWith(fontWeight: FontWeight.w700)),
      subtitle: Text(
        // 관심 작품이 그새 팔렸을 수 있으니 목록에서 바로 알려준다.
        '${artwork.artistName} · ₩${formatPrice(artwork.auction ? (artwork.currentBid ?? artwork.price) : artwork.price)}'
        '${artwork.sold ? ' · 판매 완료' : ''}',
        style: ArtText.caption,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.favorite,
            size: 20, color: ArtColors.brandPrimary),
        tooltip: '관심 해제',
        onPressed: () => _unlike(artwork),
      ),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute<void>(
            builder: (_) => ArtworkDetailScreen(artworkId: artwork.id),
          ))
          .then((_) => _load()),
    );
  }
}
