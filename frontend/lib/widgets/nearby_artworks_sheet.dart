import 'package:flutter/material.dart';

import '../constants/art_tokens.dart';
import '../screens/art_home_feed_screen.dart' show formatPrice;

import '../models/nearby_artwork.dart';
import '../screens/artwork_detail_screen.dart';
import '../services/artwork_api_service.dart';

/// 지도에서 "집 주변 작품" 버튼을 누르면 뜨는 매칭 결과 바텀시트.
void showNearbyArtworksSheet(
  BuildContext context, {
  required double latitude,
  required double longitude,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: ArtColors.bgCanvas,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => _NearbyArtworksSheet(
      latitude: latitude,
      longitude: longitude,
    ),
  );
}

class _NearbyArtworksSheet extends StatelessWidget {
  const _NearbyArtworksSheet({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ArtColors.borderSoft,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 4),
            child: Text('집 주변 작품',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('현재 지도 위치에서 가까운 순으로 보여드려요',
                style: TextStyle(fontSize: 12, color: ArtColors.textSecondary)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<NearbyArtwork>>(
              future: const ArtworkApiService()
                  .fetchNearby(latitude: latitude, longitude: longitude),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('주변 작품을 불러오지 못했어요',
                        style: TextStyle(fontSize: 12)),
                  );
                }
                final artworks = snapshot.data ?? const <NearbyArtwork>[];
                if (artworks.isEmpty) {
                  return const Center(
                    child: Text('주변에 판매 중인 작품이 없습니다',
                        style: TextStyle(fontSize: 12)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  itemCount: artworks.length,
                  itemBuilder: (context, index) =>
                      _NearbyArtworkTile(artwork: artworks[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyArtworkTile extends StatelessWidget {
  const _NearbyArtworkTile({required this.artwork});

  final NearbyArtwork artwork;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ArtworkDetailScreen(artworkId: artwork.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          border: Border.all(color: ArtColors.borderSoft),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ArtColors.bgSurface,
                border: Border.all(color: ArtColors.borderSoft),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.image_outlined,
                  size: 20, color: ArtColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(artwork.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    '${artwork.artistName} · ${artwork.address}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: ArtColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${artwork.auction ? '현재가' : '정가'} ₩${formatPrice(artwork.price)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('${artwork.distanceKm}km',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ArtColors.brandPrimary)),
          ],
        ),
      ),
    );
  }
}
