import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/locale_provider.dart';
import '../services/auth_api_service.dart';
import '../services/google_auth_service.dart';
import '../services/kakao_auth_service.dart';
// TODO: 매거진(Mate Stories) 화면 추후 복구 예정 — 현재는 숨김
// import '../widgets/mate_stories_section.dart';
import 'chat_list_screen.dart';
// TODO: 게시판 화면 추후 복구 예정 — 현재는 준비중
// import 'community_screen.dart';
import 'art_home_feed_screen.dart';
import 'landing_screen.dart';
import 'map_screen.dart';
import 'my_profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentTab = 2; // 홈(가운데)이 기본 선택
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<LocaleProvider>(
          builder: (context, localeProvider, _) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  // 핸들바
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 타이틀
                  Text(
                    localeProvider.tr(AppStrings.settings),
                    style: GoogleFonts.gowunDodum(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppColors.lightGrey),
                  // 로그아웃 버튼
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        size: 20,
                        color: AppColors.accent,
                      ),
                    ),
                    title: Text(
                      localeProvider.tr(AppStrings.logout),
                      style: GoogleFonts.gowunDodum(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // 시트 닫기
                      _showLogoutConfirm();
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutConfirm() {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<LocaleProvider>(
          builder: (context, localeProvider, _) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                localeProvider.tr(AppStrings.logout),
                style: GoogleFonts.gowunDodum(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              content: Text(
                localeProvider.tr(AppStrings.logoutConfirm),
                style: GoogleFonts.gowunDodum(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkGrey,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    localeProvider.tr(AppStrings.cancel),
                    style: GoogleFonts.gowunDodum(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 다이얼로그 닫기
                    _handleLogout();
                  },
                  child: Text(
                    localeProvider.tr(AppStrings.logout),
                    style: GoogleFonts.gowunDodum(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    // 1) 백엔드 로그아웃 (실패해도 클라이언트 로그아웃은 진행)
    await AuthApiService.logout();

    // 2) 카카오/구글 SDK 로그아웃
    await KakaoAuthService.logout();
    await GoogleAuthService.signOut();

    if (!mounted) return;

    // 초기 화면(LandingScreen)으로 이동, 모든 스택 제거
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LandingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, locale, _) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // ─── 상단 헤더 영역 ───
                  _buildTopBar(locale),
                  // ─── 중앙 메인 콘텐츠 ───
                  Expanded(child: _buildBody(locale)),
                ],
              ),
            ),
          ),
          // ─── 하단 내비게이션 바 ───
          bottomNavigationBar: _buildBottomNav(locale),
        );
      },
    );
  }

  // ─── 상단 내비게이션 바 ───
  Widget _buildTopBar(LocaleProvider locale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 좌측: 프로필 아이콘 (내 프로필 조회)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const MyProfileScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightGrey, width: 1),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 22,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ),
          // 중앙: Knot 로고 (초기 화면과 동일)
          Image.asset(
            'assets/images/knot_logo.png',
            height: 36,
            fit: BoxFit.contain,
          ),
          // 우측: 설정 아이콘
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showSettingsSheet(),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightGrey, width: 1),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  size: 22,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 중앙 Hero 콘텐츠 ───
  Widget _buildBody(LocaleProvider locale) {
    switch (_currentTab) {
      case 0: // 맵
        return const MapScreen();
      case 1: // 매거진 (준비중)
        // TODO: 매거진 화면 연동 후 복구 — 현재는 준비중 표시
        return _buildPlaceholder(locale);
      case 2:
        return const ArtHomeFeedScreen();
      case 3: // 채팅 (참여 중인 채팅방 목록)
        return const ChatListScreen();
      default:
        return _buildPlaceholder(locale);
    }
  }

  Widget _buildPlaceholder(LocaleProvider locale) {
    final labels = [
      AppStrings.navMap,
      AppStrings.navMagazine,
      AppStrings.navHome,
      AppStrings.navChat,
      AppStrings.navWish,
    ];
    final icons = [
      Icons.map_outlined,
      Icons.menu_book_outlined,
      Icons.home_rounded,
      Icons.chat_bubble_outline_rounded,
      Icons.favorite_outline_rounded,
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icons[_currentTab], size: 48, color: AppColors.lightGrey),
          const SizedBox(height: 16),
          Text(
            locale.tr(labels[_currentTab]),
            style: GoogleFonts.gowunDodum(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: GoogleFonts.gowunDodum(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.lightGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 하단 내비게이션 바 ───
  Widget _buildBottomNav(LocaleProvider locale) {
    final items = [
      _NavItem(
        icon: Icons.map_outlined,
        activeIcon: Icons.map_rounded,
        label: AppStrings.navMap,
      ),
      _NavItem(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book_rounded,
        label: AppStrings.navMagazine,
      ),
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: AppStrings.navHome,
      ),
      _NavItem(
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        label: AppStrings.navChat,
      ),
      _NavItem(
        icon: Icons.favorite_outline_rounded,
        activeIcon: Icons.favorite_rounded,
        label: AppStrings.navWish,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = _currentTab == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentTab = index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 선택 인디케이터
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: isSelected ? 20 : 0,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // 아이콘
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 24,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.grey,
                        ),
                        const SizedBox(height: 4),
                        // 라벨
                        Text(
                          locale.tr(item.label),
                          style: GoogleFonts.gowunDodum(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final Map<AppLanguage, String> label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
