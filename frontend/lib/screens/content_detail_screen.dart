import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/tour_detail.dart';
import '../models/tour_spot.dart';
import '../services/tour_api_service.dart';

/// 지역 콘텐츠 상세 화면.
///
/// 지역 콘텐츠 그리드 카드(`_TourSpotCard`)를 탭하면 진입한다.
/// [spot]의 contentId/contentTypeId로 상세정보(공통/소개/이미지)를 조회해 표시.
class ContentDetailScreen extends StatefulWidget {
  final TourSpot spot;

  const ContentDetailScreen({super.key, required this.spot});

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  late final Future<TourDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = TourApiService.fetchDetail(
      contentId: widget.spot.contentId,
      contentTypeId: widget.spot.contentTypeId,
      fallbackTitle: widget.spot.title,
      fallbackImage: widget.spot.firstImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: FutureBuilder<TourDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _LoadingView(spot: widget.spot);
          }
          final detail =
              snapshot.data ??
              TourDetail(
                contentId: widget.spot.contentId,
                contentTypeId: widget.spot.contentTypeId,
                title: widget.spot.title,
                imageUrls: [
                  if ((widget.spot.firstImage ?? '').isNotEmpty)
                    widget.spot.firstImage!,
                ],
              );
          return _DetailView(detail: detail);
        },
      ),
    );
  }
}

// ─── 로딩 중 뷰 (대표 이미지 + 제목 + 스피너로 빈 화면 방지) ───
class _LoadingView extends StatelessWidget {
  final TourSpot spot;

  const _LoadingView({required this.spot});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: (spot.firstImage ?? '').isNotEmpty
              ? Image.network(
                  spot.firstImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(color: AppColors.offWhite),
                )
              : Container(color: AppColors.offWhite),
        ),
        Positioned.fill(
          child: Container(color: AppColors.black.withValues(alpha: 0.35)),
        ),
        const Center(
          child: CircularProgressIndicator(
            color: AppColors.white,
            strokeWidth: 3,
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: _CircleIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── 상세 본문 ───
class _DetailView extends StatelessWidget {
  final TourDetail detail;

  const _DetailView({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 이미지 슬라이드 + 오버레이 버튼
                _ImageSlider(imageUrls: detail.imageUrls),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        detail.title,
                        style: GoogleFonts.gowunDodum(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      // 주소
                      if ((detail.addr1 ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: 16,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                detail.addr1!,
                                style: GoogleFonts.gowunDodum(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      // 타입 배지 + (축제) 기간
                      Row(
                        children: [
                          _TypeBadge(
                            label: contentTypeLabel(detail.contentTypeId),
                          ),
                          if ((detail.period ?? '').isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                '기간: ${detail.period}',
                                style: GoogleFonts.gowunDodum(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkGrey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      // 타입별 핵심 정보
                      if (detail.infoItems.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ...detail.infoItems.map(_buildInfoRow),
                      ],
                      // 설명
                      if ((detail.overview ?? '').isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Divider(height: 1, color: AppColors.lightGrey),
                        const SizedBox(height: 16),
                        Text(
                          detail.overview!,
                          style: GoogleFonts.gowunDodum(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.darkGrey,
                            height: 1.6,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // 하단 고정: 콘텐츠 생성하기 버튼 (동작 없음)
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: _CreateContentButton(
              onTap: () {
                // TODO: 콘텐츠 생성 기능 연동 (현재는 동작 없음)
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(TourDetailInfo info) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              info.label,
              style: GoogleFonts.gowunDodum(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              info.value,
              style: GoogleFonts.gowunDodum(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 이미지 슬라이드 (좌우 스와이프 + 인디케이터) ───
class _ImageSlider extends StatefulWidget {
  final List<String> imageUrls;

  const _ImageSlider({required this.imageUrls});

  @override
  State<_ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<_ImageSlider> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static Widget _placeholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.12),
      child: const Center(
        child: Icon(Icons.photo_rounded, size: 48, color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          // 이미지 페이지뷰
          Positioned.fill(
            child: urls.isEmpty
                ? _placeholder()
                : PageView.builder(
                    controller: _controller,
                    itemCount: urls.length,
                    onPageChanged: (i) => setState(() => _current = i),
                    itemBuilder: (context, index) {
                      return Image.network(
                        urls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder(),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          // 상단 오버레이 버튼 (뒤로 / 좋아요 / 공유)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  _CircleIconButton(
                    icon: Icons.favorite_border_rounded,
                    onTap: () {}, // 시각용 (동작 없음)
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    icon: Icons.share_rounded,
                    onTap: () {}, // 시각용 (동작 없음)
                  ),
                ],
              ),
            ),
          ),
          // 하단 인디케이터 점
          if (urls.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (i) {
                  final selected = i == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: selected ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── 타입 배지 ───
class _TypeBadge extends StatelessWidget {
  final String label;

  const _TypeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.gowunDodum(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─── 원형 아이콘 버튼 (반투명 배경) ───
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: AppColors.white),
      ),
    );
  }
}

// ─── 콘텐츠 생성하기 버튼 (그라데이션, 동작 없음) ───
class _CreateContentButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateContentButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.purple],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          '콘텐츠 생성하기',
          style: GoogleFonts.gowunDodum(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
