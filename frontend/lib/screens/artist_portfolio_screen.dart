import 'package:flutter/material.dart';

import '../constants/dust_tokens.dart';
import '../utils/image_url.dart';
import '../utils/artist_inquiry.dart';
import '../models/artist_profile.dart';
import '../services/artist_api_service.dart';
import 'artwork_detail_screen.dart';

/// 작가 포트폴리오 — Figma 41:850 디자인.
class ArtistPortfolioScreen extends StatefulWidget {
  const ArtistPortfolioScreen({super.key, required this.artistName});

  final String artistName;

  @override
  State<ArtistPortfolioScreen> createState() => _ArtistPortfolioScreenState();
}

class _ArtistPortfolioScreenState extends State<ArtistPortfolioScreen> {
  final _api = const ArtistApiService();
  late Future<ArtistProfile> _profileFuture;
  int _tab = 1; // 디자인 기본 탭: 포트폴리오

  @override
  void initState() {
    super.initState();
    _profileFuture = _api.fetchPortfolio(widget.artistName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DustColors.bgCanvas,
      body: FutureBuilder<ArtistProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(color: DustColors.brandPrimary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('작가 정보를 불러오지 못했어요',
                      style: DustText.caption),
                  const SizedBox(height: DustSpacing.sm),
                  OutlinedButton(
                    onPressed: () => setState(() => _profileFuture =
                        _api.fetchPortfolio(widget.artistName)),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }
          final profile = snapshot.data!;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _CoverHeader(profile: profile),
              _StatsRow(profile: profile),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    DustSpacing.lg, DustSpacing.md, DustSpacing.lg, 0),
                child: Text(
                  profile.introduction,
                  style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: DustColors.textSecondary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    DustSpacing.lg, DustSpacing.md, DustSpacing.lg, 0),
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => openArtistInquiry(context, profile.name),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DustColors.brandPrimary,
                      side: const BorderSide(color: DustColors.brandPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DustRadius.full),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const Text('작가에게 문의하기'),
                  ),
                ),
              ),
              const SizedBox(height: DustSpacing.md),
              _Tabs(
                current: _tab,
                reviewCount: profile.reviewCount,
                onChanged: (index) => setState(() => _tab = index),
              ),
              const SizedBox(height: DustSpacing.md),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: DustSpacing.md),
                child: _buildTabContent(profile),
              ),
              const SizedBox(height: DustSpacing.lg),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabContent(ArtistProfile profile) {
    switch (_tab) {
      case 0:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DustSpacing.md),
          decoration: BoxDecoration(
            color: DustColors.bgSurface,
            borderRadius: BorderRadius.circular(DustRadius.md),
            border: Border.all(color: DustColors.borderSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${profile.name} 작가',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: DustColors.textPrimary)),
              const SizedBox(height: DustSpacing.xs),
              Text(profile.introduction,
                  style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: DustColors.textPrimary)),
              const SizedBox(height: DustSpacing.xs),
              if (profile.location != null && profile.location!.isNotEmpty)
                Text('활동 지역 · ${profile.location}',
                    style: const TextStyle(
                        fontSize: 12, color: DustColors.textSecondary)),
            ],
          ),
        );
      case 1:
        if (profile.artworks.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(DustSpacing.lg),
            child: Center(
                child: Text('등록된 작품이 없습니다', style: DustText.caption)),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: profile.artworks.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: DustSpacing.xs,
            mainAxisSpacing: DustSpacing.xs,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            final artwork = profile.artworks[index];
            return GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ArtworkDetailScreen(artworkId: artwork.id),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DustRadius.sm),
                child: artwork.imageUrl.isEmpty
                    ? Container(
                        color: DustColors.bgSubtle,
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            artwork.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 11,
                                color: DustColors.textSecondary),
                          ),
                        ),
                      )
                    : Image.network(
                        resolveImageUrl(artwork.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Container(color: DustColors.bgSubtle),
                      ),
              ),
            );
          },
        );
      default:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DustSpacing.lg),
          decoration: BoxDecoration(
            color: DustColors.bgSurface,
            borderRadius: BorderRadius.circular(DustRadius.md),
            border: Border.all(color: DustColors.borderSoft),
          ),
          child: Column(
            children: [
              if (profile.rating != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 20, color: DustColors.brandPrimary),
                    const SizedBox(width: 4),
                    Text('${profile.rating}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: DustColors.textPrimary)),
                    Text('  ·  리뷰 ${profile.reviewCount ?? 0}개',
                        style: const TextStyle(
                            fontSize: 13, color: DustColors.textSecondary)),
                  ],
                ),
              const SizedBox(height: DustSpacing.xs),
              const Text('구매자 리뷰는 준비 중입니다',
                  style: TextStyle(
                      fontSize: 12, color: DustColors.textSecondary)),
            ],
          ),
        );
    }
  }
}

/// 상단 커버 + 프로필 (디자인: 다크 커버 위 원형 아바타, 이름, 위치)
class _CoverHeader extends StatelessWidget {
  const _CoverHeader({required this.profile});

  final ArtistProfile profile;

  @override
  Widget build(BuildContext context) {
    final cover = profile.artworks
        .where((artwork) => artwork.imageUrl.isNotEmpty)
        .map((artwork) => artwork.imageUrl)
        .toList();
    return Stack(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: cover.isEmpty
              ? Container(color: DustColors.brandDeep)
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(resolveImageUrl(cover.first), fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Container(color: DustColors.brandDeep)),
                    Container(color: Colors.black.withValues(alpha: 0.35)),
                  ],
                ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.chevron_left,
                      size: 28, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined,
                      size: 22, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: DustSpacing.lg,
          bottom: DustSpacing.lg,
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DustColors.bgSubtle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.person_outline,
                    size: 36, color: DustColors.textSecondary),
              ),
              const SizedBox(width: DustSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: Colors.white70),
                      const SizedBox(width: 2),
                      Text(profile.location ?? '',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 통계 3분할 (작품 | 판매 | 평점)
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});

  final ArtistProfile profile;

  @override
  Widget build(BuildContext context) {
    Widget stat(String value, String label) {
      return Expanded(
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: DustColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: DustColors.textSecondary)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: DustSpacing.md),
      decoration: const BoxDecoration(
        color: DustColors.bgSurface,
        border:
            Border(bottom: BorderSide(color: DustColors.borderSoft)),
      ),
      child: Row(
        children: [
          stat('${profile.artworkCount}', '작품'),
          Container(width: 1, height: 30, color: DustColors.borderSoft),
          stat('${profile.salesCount}', '판매'),
          Container(width: 1, height: 30, color: DustColors.borderSoft),
          // 리뷰 도메인이 없어 평점이 없으면 '-' 로 둔다.
          stat(profile.rating?.toString() ?? '-', '평점'),
        ],
      ),
    );
  }
}

/// 탭 (소개 | 포트폴리오 | 리뷰 (n)) — 활성 탭에 teal 밑줄
class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.current,
    required this.reviewCount,
    required this.onChanged,
  });

  final int current;
  /// 리뷰 도메인이 없으면 null — 탭 라벨에서 개수를 숨긴다.
  final int? reviewCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = [
      '소개',
      '포트폴리오',
      reviewCount == null ? '리뷰' : '리뷰 ($reviewCount)',
    ];
    return Row(
      children: List.generate(labels.length, (index) {
        final active = index == current;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w400,
                      color: active
                          ? DustColors.textPrimary
                          : DustColors.textSecondary,
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  color: active
                      ? DustColors.brandPrimary
                      : Colors.transparent,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
