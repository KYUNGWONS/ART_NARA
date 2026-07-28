import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/locale_provider.dart';

/// 홈 화면 "Mate Stories" 섹션.
///
/// 탭 헤더(후기 / KNOT GUIDE / Q&A + 더보기) 아래에 선택된 탭의 피처드
/// 카드(배경 사진 + 별점 + 인용 텍스트)를 보여준다.
///
/// TODO(서버 연동): 현재는 [_slides]의 하드코딩 mock 데이터로만 표시한다.
/// 실제 API 연동 시 mock을 제거하고 응답으로 교체할 것.
class MateStoriesSection extends StatefulWidget {
  const MateStoriesSection({super.key});

  @override
  State<MateStoriesSection> createState() => _MateStoriesSectionState();
}

class _MateStoriesSectionState extends State<MateStoriesSection> {
  static const double _cardHeight = 220;

  /// 탭 정의(id + 라벨 문자열 맵).
  static const List<_StoryTab> _tabs = [
    _StoryTab(id: 'best', label: AppStrings.mateStoriesBestTab),
    _StoryTab(id: 'guide', label: AppStrings.mateStoriesGuideTab),
    _StoryTab(id: 'qna', label: AppStrings.mateStoriesQnaTab),
  ];

  /// 탭 id별 피처드 카드 mock 데이터.
  /// TODO(서버 연동): 실제 API 응답으로 교체.
  static const Map<String, _StorySlide> _slides = {
    'best': _StorySlide(
      rating: 5,
      text: '"Meeting my Korean friends...was the highlight of my trip!"',
      image:
          'https://images.unsplash.com/photo-1538485399081-7191377e8241?w=800',
    ),
    'guide': _StorySlide(
      text: 'How to knot with a local mate',
      image:
          'https://images.unsplash.com/photo-1517154421773-0529f29ea451?w=800',
    ),
    'qna': _StorySlide(
      text: 'Q. What should I prepare before meeting my mate?',
      image:
          'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800',
    ),
  };

  String _selectedTabId = _tabs.first.id;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final slide = _slides[_selectedTabId];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabHeader(locale),
        const SizedBox(height: 14),
        SizedBox(
          height: _cardHeight,
          child: slide == null
              ? const SizedBox.shrink()
              : _StoryCard(slide: slide),
        ),
      ],
    );
  }

  Widget _buildTabHeader(LocaleProvider locale) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < _tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 20),
            _TabLabel(
              text: locale.tr(_tabs[i].label),
              selected: _tabs[i].id == _selectedTabId,
              onTap: () => setState(() => _selectedTabId = _tabs[i].id),
            ),
          ],
        ],
      ),
    );
  }
}

/// 탭 한 개(id + 다국어 라벨 맵).
class _StoryTab {
  const _StoryTab({required this.id, required this.label});

  final String id;
  final Map<AppLanguage, String> label;
}

/// 피처드 카드 한 건(배경 이미지 + 인용 텍스트 + 선택적 별점).
/// TODO(서버 연동): 실제 모델로 교체.
class _StorySlide {
  const _StorySlide({required this.text, required this.image, this.rating});

  final String text;
  final String image;

  /// 1~5 별점. null이면 별점을 표시하지 않는다(가이드/Q&A 탭).
  final int? rating;
}

/// 탭 헤더의 라벨 하나(활성 시 파란색 + 하단 밑줄).
class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.grey;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              text,
              style: GoogleFonts.gowunDodum(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          Container(
            height: 2,
            width: 36,
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

/// 선택된 탭의 피처드 카드(배경 사진 + 그라데이션 + 별점 + 인용 텍스트).
class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.slide});

  final _StorySlide slide;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              slide.image,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(),
            ),
            // 텍스트 가독성을 위한 하단 그라데이션 오버레이
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (slide.rating != null) _StarRow(rating: slide.rating!),
                  const Spacer(),
                  Text(
                    slide.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.gowunDodum(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.lightGrey,
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.grey, size: 40),
      ),
    );
  }
}

/// 별점 5개를 표시하는 행(채워진 별 [rating]개 + 빈 별).
class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 22,
          ),
      ],
    );
  }
}
