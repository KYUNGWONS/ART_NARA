import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../data/mock_ambassador_data.dart';
import '../models/ambassador.dart';
import '../providers/locale_provider.dart';
import '../screens/ambassador_detail_screen.dart';

/// 홈 화면 "1기 앰배서더" 쇼케이스 섹션.
///
/// 작은 라벨 + 굵은 제목 아래로 앰배서더 원형 프로필을 가로로 보여준다.
/// 프로필을 탭하면 [AmbassadorDetailScreen]으로 이동한다.
/// 현재는 [mockAmbassadors]로 채워지며, 추후 서버 연동 예정.
class AmbassadorShowcase extends StatelessWidget {
  const AmbassadorShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            locale.tr(AppStrings.ambassadorLabel),
            style: GoogleFonts.gowunDodum(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            locale.tr(AppStrings.ambassadorTitle),
            style: GoogleFonts.gowunDodum(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final ambassador in mockAmbassadors)
              Expanded(child: _AmbassadorAvatar(ambassador: ambassador)),
          ],
        ),
      ],
    );
  }
}

/// 그라데이션 링 테두리를 두른 원형 프로필 + 이름.
class _AmbassadorAvatar extends StatelessWidget {
  const _AmbassadorAvatar({required this.ambassador});

  final Ambassador ambassador;

  static const double _size = 64;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AmbassadorDetailScreen(ambassador: ambassador),
          ),
        );
      },
      child: Column(
        children: [
          // 인스타그램풍 그라데이션 링
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.purple, AppColors.accent],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
              child: CircleAvatar(
                radius: _size / 2,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: NetworkImage(ambassador.profileImageUrl),
                onBackgroundImageError: (_, _) {},
                child: ambassador.profileImageUrl.isEmpty
                    ? Text(
                        ambassador.name.characters.first,
                        style: GoogleFonts.gowunDodum(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ambassador.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.gowunDodum(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
