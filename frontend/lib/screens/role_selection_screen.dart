import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/locale_provider.dart';
import 'profile_setup_screen.dart';

enum UserRole { koreanStudent, foreigner }

class RoleSelectionScreen extends StatefulWidget {
  final String? kakaoProfileImageUrl;
  final String? kakaoNickname;

  const RoleSelectionScreen({
    super.key,
    this.kakaoProfileImageUrl,
    this.kakaoNickname,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, locale, _) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF0F5FF),
                  Color(0xFFFFF5F2),
                ],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // 상단 바
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, top: 8),
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 16,
                            color: AppColors.grey,
                          ),
                          label: Text(
                            locale.tr(AppStrings.back),
                            style: GoogleFonts.gowunDodum(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    // 타이틀
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            locale.tr(AppStrings.roleTitle),
                            style: GoogleFonts.gowunDodum(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            locale.tr(AppStrings.roleSubtitle),
                            style: GoogleFonts.gowunDodum(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 역할 선택: 이미지 두 개 중간 배치, 선택 시 해당 프로필 입력으로 이동
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildRoleImage(
                              imagePath:
                                  'assets/images/role_korean_student.png',
                              label: locale.tr(AppStrings.roleKoreanStudent),
                              role: UserRole.koreanStudent,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildRoleImage(
                              imagePath:
                                  'assets/images/role_foreign_traveler.png',
                              label: locale.tr(AppStrings.roleForeigner),
                              role: UserRole.foreigner,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleImage({
    required String imagePath,
    required String label,
    required UserRole role,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProfileSetupScreen(
                  role: role,
                  kakaoProfileImageUrl: widget.kakaoProfileImageUrl,
                  kakaoNickname: widget.kakaoNickname,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.3, 0.0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.gowunDodum(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// API userType 문자열을 UserRole로 변환
UserRole userRoleFromApi(String? userType) {
  if (userType == null || userType.isEmpty) return UserRole.koreanStudent;
  final t = userType.toLowerCase();
  // 'foreign', 'foreigner', 'foreign_tourist'(백엔드 enum) 모두 외국인으로 처리
  if (t.startsWith('foreign')) return UserRole.foreigner;
  return UserRole.koreanStudent;
}
