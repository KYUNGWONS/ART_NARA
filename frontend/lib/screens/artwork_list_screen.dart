import 'package:flutter/material.dart';

import '../constants/dust_tokens.dart';
import '../models/home_feed.dart';
import 'art_home_feed_screen.dart' show formatPrice;
import 'artwork_detail_screen.dart';

/// 홈 피드 섹션의 '더보기' — 해당 섹션 작품을 한 화면에 모아 본다.
class ArtworkListScreen extends StatelessWidget {
  const ArtworkListScreen({super.key, required this.title, required this.items});

  final String title;
  final List<Artwork> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DustColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: DustColors.bgCanvas,
        elevation: 0,
        foregroundColor: DustColors.textPrimary,
        title: Text(title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: DustColors.brandPrimary,
            )),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? const Center(child: Text('작품이 없습니다', style: DustText.caption))
          : GridView.builder(
              padding: const EdgeInsets.all(DustSpacing.md),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: DustSpacing.sm,
                mainAxisSpacing: DustSpacing.sm,
                mainAxisExtent: 258,
              ),
              itemBuilder: (context, index) => _Card(artwork: items[index]),
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
                      child: Image.network(artwork.imageUrl, fit: BoxFit.cover),
                    ),
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
                    Text('남은 시간 ${artwork.remainingTime}',
                        style: const TextStyle(
                            fontSize: 11, color: DustColors.brandPrimary)),
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
