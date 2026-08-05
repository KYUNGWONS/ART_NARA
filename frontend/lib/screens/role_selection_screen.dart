import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../constants/art_tokens.dart';
import '../providers/locale_provider.dart';
import 'profile_setup_screen.dart';

/// 회원 역할.
/// 백엔드 userType enum(KOREAN_STUDENT/FOREIGN_TOURIST)과 결합되어 있어 이름은 유지한다:
/// koreanStudent = 작가, foreigner = 컬렉터.
enum UserRole { koreanStudent, foreigner }

/// 역할 선택 — 작가 / 컬렉터
class RoleSelectionScreen extends StatelessWidget {
  final String? kakaoProfileImageUrl;
  final String? kakaoNickname;

  const RoleSelectionScreen({
    super.key,
    this.kakaoProfileImageUrl,
    this.kakaoNickname,
  });

  void _select(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileSetupScreen(
          role: role,
          kakaoProfileImageUrl: kakaoProfileImageUrl,
          kakaoNickname: kakaoNickname,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, locale, _) {
        return Scaffold(
          backgroundColor: ArtColors.bgCanvas,
          body: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.chevron_left,
                        size: 28, color: ArtColors.textPrimary),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: ArtSpacing.lg * 1.5),
                  child: Column(
                    children: [
                      Text(
                        locale.tr(AppStrings.roleTitle),
                        textAlign: TextAlign.center,
                        style: ArtText.section
                            .copyWith(color: ArtColors.brandPrimary),
                      ),
                      const SizedBox(height: ArtSpacing.xs),
                      Text(
                        locale.tr(AppStrings.roleSubtitle),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13,
                            color: ArtColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ArtSpacing.lg * 1.5),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: ArtSpacing.lg),
                  child: Column(
                    children: [
                      _RoleCard(
                        icon: Icons.palette_outlined,
                        title: locale.tr(AppStrings.roleKoreanStudent),
                        description:
                            locale.tr(AppStrings.roleKoreanStudentDesc),
                        onTap: () =>
                            _select(context, UserRole.koreanStudent),
                      ),
                      const SizedBox(height: ArtSpacing.md),
                      _RoleCard(
                        icon: Icons.collections_outlined,
                        title: locale.tr(AppStrings.roleForeigner),
                        description: locale.tr(AppStrings.roleForeignerDesc),
                        onTap: () => _select(context, UserRole.foreigner),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ArtSpacing.lg),
        decoration: BoxDecoration(
          color: ArtColors.bgSurface,
          borderRadius: BorderRadius.circular(ArtRadius.md),
          border: Border.all(color: ArtColors.borderSoft),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ArtColors.bgInfo,
                borderRadius: BorderRadius.circular(ArtRadius.md),
              ),
              child:
                  Icon(icon, size: 28, color: ArtColors.brandPrimary),
            ),
            const SizedBox(width: ArtSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: ArtColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: ArtColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: ArtColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// API userType 문자열을 UserRole로 변환
UserRole userRoleFromApi(String? userType) {
  if (userType == null || userType.isEmpty) return UserRole.koreanStudent;
  final t = userType.toLowerCase();
  // 'foreign*'(백엔드 enum FOREIGN_TOURIST)은 컬렉터로 처리
  if (t.startsWith('foreign')) return UserRole.foreigner;
  return UserRole.koreanStudent;
}
