import 'package:flutter/material.dart';

import '../constants/dust_tokens.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DustColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: DustColors.bgCanvas,
        elevation: 0,
        foregroundColor: DustColors.textPrimary,
        title: const Text('관심 작품',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: DustColors.brandPrimary,
            )),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: DustColors.brandPrimary))
          : _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border,
                      size: 64, color: DustColors.borderSoft),
                  const SizedBox(height: DustSpacing.md),
                  Text('아직 관심 작품이 없어요',
                      style: DustText.body
                          .copyWith(color: DustColors.textSecondary)),
                  const SizedBox(height: DustSpacing.xs),
                  const Text('마음에 드는 작품의 하트를 눌러보세요',
                      style: DustText.caption),
                ],
              ),
            )
          : RefreshIndicator(
              color: DustColors.brandPrimary,
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: DustSpacing.xs),
                itemCount: _items.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: DustColors.borderSoft),
                itemBuilder: (context, index) => _tile(_items[index]),
              ),
            ),
    );
  }

  Widget _tile(ArtworkDetail artwork) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: DustSpacing.lg, vertical: DustSpacing.xs),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: DustColors.bgSubtle,
          borderRadius: BorderRadius.circular(DustRadius.sm),
        ),
        child: artwork.imageUrl.isEmpty
            ? const Icon(Icons.image_outlined,
                color: DustColors.textSecondary, size: 22)
            : ClipRRect(
                borderRadius: BorderRadius.circular(DustRadius.sm),
                child: Image.network(artwork.imageUrl, fit: BoxFit.cover),
              ),
      ),
      title: Text(artwork.title,
          style: DustText.body.copyWith(fontWeight: FontWeight.w700)),
      subtitle: Text(
        '${artwork.artistName} · ₩${formatPrice(artwork.auction ? (artwork.currentBid ?? artwork.price) : artwork.price)}',
        style: DustText.caption,
      ),
      trailing: const Icon(Icons.favorite,
          size: 20, color: DustColors.brandPrimary),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute<void>(
            builder: (_) => ArtworkDetailScreen(artworkId: artwork.id),
          ))
          .then((_) => _load()),
    );
  }
}
