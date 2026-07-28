import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/tour_spot.dart';
import '../providers/locale_provider.dart';
import '../screens/content_detail_screen.dart';
import '../services/tour_api_service.dart';
import 'staggered_entrance.dart';

/// 홈 화면 "다가오는 축제" 섹션.
///
/// 한국관광공사 행사정보조회(`searchFestival2`)로 진행/예정 축제를 조회해
/// 가로 스크롤 사진 카드로 보여준다. 카드 탭 시 상세 화면으로 이동한다.
class UpcomingFestivals extends StatefulWidget {
  const UpcomingFestivals({super.key});

  @override
  State<UpcomingFestivals> createState() => _UpcomingFestivalsState();
}

class _UpcomingFestivalsState extends State<UpcomingFestivals> {
  static const double _cardWidth = 220;
  static const double _cardHeight = 170;

  late final Future<List<TourSpot>> _festivalsFuture =
      TourApiService.searchFestivals();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    return FutureBuilder<List<TourSpot>>(
      future: _festivalsFuture,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final festivals = snapshot.data ?? const <TourSpot>[];
        // 로딩도 아니고 결과도 없으면 섹션 자체를 숨긴다.
        if (!loading && festivals.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                locale.tr(AppStrings.upcomingFestivalsTitle),
                style: GoogleFonts.gowunDodum(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: _cardHeight,
              child: loading
                  ? _buildLoading()
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: festivals.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => StaggeredEntrance(
                        index: index,
                        child: _FestivalCard(
                          festival: festivals[index],
                          width: _cardWidth,
                          height: _cardHeight,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: 2,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, _) => Container(
        width: _cardWidth,
        height: _cardHeight,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

/// 축제 한 건을 표시하는 사진 카드 (탭 시 상세 화면 이동).
class _FestivalCard extends StatelessWidget {
  const _FestivalCard({
    required this.festival,
    required this.width,
    required this.height,
  });

  final TourSpot festival;
  final double width;
  final double height;

  /// "YYYYMMDD" → "M.D"
  static String? _fmt(String? ymd) {
    final s = (ymd ?? '').trim();
    if (s.length != 8) return null;
    return '${int.parse(s.substring(4, 6))}.${int.parse(s.substring(6, 8))}';
  }

  String? get _period {
    final start = _fmt(festival.eventStartDate);
    final end = _fmt(festival.eventEndDate);
    if (start == null && end == null) return null;
    if (start != null && end != null && start != end) return '$start ~ $end';
    return start ?? end;
  }

  @override
  Widget build(BuildContext context) {
    final period = _period;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ContentDetailScreen(spot: festival),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (festival.firstImage != null)
                Image.network(
                  festival.firstImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholder(),
                )
              else
                _placeholder(),
              // 텍스트 가독성을 위한 하단 그라데이션 오버레이
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                    stops: [0.45, 1.0],
                  ),
                ),
              ),
              // 기간 배지 (좌상단)
              if (period != null)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      period,
                      style: GoogleFonts.gowunDodum(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      festival.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.gowunDodum(
                        color: AppColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (festival.addr1.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              festival.addr1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.gowunDodum(
                                color: AppColors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.lightGrey,
      child: const Center(
        child: Icon(
          Icons.celebration_outlined,
          color: AppColors.grey,
          size: 36,
        ),
      ),
    );
  }
}
