import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/home_feed.dart';
import '../services/home_feed_api_service.dart';
import 'artwork_detail_screen.dart';

class ArtHomeFeedScreen extends StatefulWidget {
  const ArtHomeFeedScreen({super.key});

  @override
  State<ArtHomeFeedScreen> createState() => _ArtHomeFeedScreenState();
}

class _ArtHomeFeedScreenState extends State<ArtHomeFeedScreen> {
  final _searchController = TextEditingController();
  final _api = const HomeFeedApiService();
  late Future<HomeFeed> _feedFuture;

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

  void _search() {
    setState(() {
      _feedFuture = _api.fetch(query: _searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeFeed>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorView(onRetry: _search);
        }

        final feed = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => setState(() => _feedFuture = _api.fetch()),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            children: [
              _SearchField(controller: _searchController, onSubmitted: (_) => _search()),
              const SizedBox(height: 16),
              const _ImagePlaceholder(height: 280),
              const SizedBox(height: 16),
              _CurationCard(feed: feed),
              const SizedBox(height: 16),
              _ArtworkSection(title: '추천 작품', items: feed.recommended),
              const SizedBox(height: 24),
              _ArtworkSection(title: '마감 임박 경매', items: feed.auctions),
              const SizedBox(height: 24),
              _ArtistSection(artists: feed.artists),
            ],
          ),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: '작품, 작가를 검색해보세요',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        isDense: true,
      ),
    );
  }
}

class _CurationCard extends StatelessWidget {
  const _CurationCard({required this.feed});

  final HomeFeed feed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('오늘의 큐레이션', style: TextStyle(fontSize: 11)),
          const SizedBox(height: 12),
          Text(feed.curationTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(feed.curationDescription, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          FilledButton(onPressed: () {}, child: const Text('작품 보러 가기')),
        ],
      ),
    );
  }
}

class _ArtworkSection extends StatelessWidget {
  const _ArtworkSection({required this.title, required this.items});

  final String title;
  final List<Artwork> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 306,
          ),
          itemBuilder: (context, index) => _ArtworkCard(artwork: items[index]),
        ),
      ],
    );
  }
}

class _ArtworkCard extends StatelessWidget {
  const _ArtworkCard({required this.artwork});

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
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ImagePlaceholder(height: 160),
          const SizedBox(height: 12),
          Text(artwork.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          Text(artwork.artistName, style: const TextStyle(fontSize: 11)),
          const Spacer(),
          Text(artwork.auction ? '현재가 ₩${artwork.currentBid ?? artwork.price}' : '정가 ₩${artwork.price}'),
          if (artwork.remainingTime != null) ...[
            const SizedBox(height: 4),
            Text('남은 시간 ${artwork.remainingTime}', style: const TextStyle(fontSize: 11)),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {},
              icon: Icon(artwork.liked ? Icons.favorite : Icons.favorite_border, size: 18),
              color: artwork.liked ? AppColors.accent : AppColors.darkGrey,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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
        const Text('주목할 작가', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...artists.map(
          (artist) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 13),
            leading: const CircleAvatar(backgroundColor: Color(0xFFD1D5DB)),
            title: Text(artist.name),
            subtitle: Text(artist.introduction),
            trailing: OutlinedButton(onPressed: () {}, child: const Text('팔로우')),
          ),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text('Image', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
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
          const Text('홈 피드를 불러오지 못했어요'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
