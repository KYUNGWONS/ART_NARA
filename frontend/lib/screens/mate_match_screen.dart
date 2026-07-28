import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/user_location.dart';
import 'chat_screen.dart';

/// 관심사·성향 기반 추천 메이트 목록 화면
///
/// TODO(백엔드): GET /api/mates/recommended 등 연동
///   - 요청: 현재 사용자 토큰/ID 기반으로 서버에서 관심사(interests),
///           계획성(planningScore), 활발도(activityScore) 반영한 추천 목록 조회
///   - 응답: List<UserLocation> 형태로 매칭된 메이트 목록 반환
///   - Mock 제거 후 API 호출 결과로 교체
class MateMatchScreen extends StatelessWidget {
  const MateMatchScreen({super.key});

  /// Mock: 관심사·성향 맞는 메이트 목록 (현재는 더미 전체 사용)
  static List<UserLocation> get _mockRecommendedMates {
    return dummyUserLocations;
  }

  @override
  Widget build(BuildContext context) {
    final mates = _mockRecommendedMates;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(
          '나와 맞는 메이트',
          style: GoogleFonts.gowunDodum(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: mates.isEmpty
          ? Center(
              child: Text(
                '추천 메이트가 없어요',
                style: GoogleFonts.gowunDodum(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: mates.length,
              itemBuilder: (context, index) {
                final mate = mates[index];
                return _MateMatchListItem(
                  mate: mate,
                  onTap: () => _onMateTap(context, mate),
                );
              },
            ),
    );
  }

  void _onMateTap(BuildContext context, UserLocation mate) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => ChatScreen(mate: mate)),
    );
  }
}

class _MateMatchListItem extends StatelessWidget {
  final UserLocation mate;
  final VoidCallback onTap;

  const _MateMatchListItem({required this.mate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: mate.profileImageUrl != null
                  ? NetworkImage(mate.profileImageUrl!)
                  : null,
              child: mate.profileImageUrl == null
                  ? Text(
                      mate.nickname.isNotEmpty ? mate.nickname[0] : '?',
                      style: GoogleFonts.gowunDodum(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mate.nickname,
                    style: GoogleFonts.gowunDodum(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mate.introduction ?? '자기소개가 없습니다.',
                    style: GoogleFonts.gowunDodum(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
