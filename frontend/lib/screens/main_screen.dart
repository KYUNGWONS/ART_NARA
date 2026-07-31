import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/dust_tokens.dart';
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
import 'commission_screen.dart';
import 'landing_screen.dart';
import 'map_screen.dart';
import 'my_profile_screen.dart';
import 'sell_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentTab = 0; // 홈이 기본 선택 (디자인 1:437 탭 순서)
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
          backgroundColor: DustColors.bgCanvas,
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

  // ─── 상단 내비게이션 바 (디자인 1:437: 메뉴 · 둘러보기 · 벨) ───
  static const _tabTitles = ['둘러보기', '판매', '지도', '제작 의뢰', '채팅'];

  Widget _buildTopBar(LocaleProvider locale) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: DustSpacing.md, vertical: DustSpacing.sm),
      color: DustColors.bgCanvas,
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
              borderRadius: BorderRadius.circular(DustRadius.full),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 24,
                  color: DustColors.textPrimary,
                ),
              ),
            ),
          ),
          // 중앙: 현재 탭 타이틀
          Text(
            _tabTitles[_currentTab],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: DustColors.brandPrimary,
            ),
          ),
          // 우측: 설정 아이콘
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showSettingsSheet(),
              borderRadius: BorderRadius.circular(DustRadius.full),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.settings_outlined,
                  size: 24,
                  color: DustColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 중앙 메인 콘텐츠 (디자인 탭 순서: 홈 · 판매 · 지도 · 제작의뢰 · 채팅) ───
  Widget _buildBody(LocaleProvider locale) {
    switch (_currentTab) {
      case 0: // 홈 (둘러보기)
        return const ArtHomeFeedScreen();
      case 1: // 판매 등록
        return const SellScreen();
      case 2: // 지도
        return const MapScreen();
      case 3: // 제작 의뢰 (역경매)
        return const CommissionScreen();
      case 4: // 채팅 (참여 중인 채팅방 목록)
        return const ChatListScreen();
      default:
        return _buildPlaceholder(locale);
    }
  }

  Widget _buildPlaceholder(LocaleProvider locale) {
    final labels = [
      AppStrings.navHome,
      AppStrings.navSell,
      AppStrings.navMap,
      AppStrings.navCommission,
      AppStrings.navChat,
    ];
    final icons = [
      Icons.home_rounded,
      Icons.sell_outlined,
      Icons.map_outlined,
      Icons.description_outlined,
      Icons.chat_bubble_outline_rounded,
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

  // ─── 하단 내비게이션 바 (디자인 1:437: 홈 · 판매 · 지도 · 제작의뢰 · 채팅) ───
  Widget _buildBottomNav(LocaleProvider locale) {
    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: AppStrings.navHome,
      ),
      _NavItem(
        icon: Icons.sell_outlined,
        activeIcon: Icons.sell,
        label: AppStrings.navSell,
      ),
      _NavItem(
        icon: Icons.map_outlined,
        activeIcon: Icons.map_rounded,
        label: AppStrings.navMap,
      ),
      _NavItem(
        icon: Icons.description_outlined,
        activeIcon: Icons.description,
        label: AppStrings.navCommission,
      ),
      _NavItem(
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        label: AppStrings.navChat,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: DustColors.bgCanvas,
        border: Border(top: BorderSide(color: DustColors.borderSoft)),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 아이콘
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 24,
                          color: isSelected
                              ? DustColors.brandPrimary
                              : DustColors.textSecondary,
                        ),
                        const SizedBox(height: 4),
                        // 라벨
                        Text(
                          locale.tr(item.label),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? DustColors.brandPrimary
                                : DustColors.textSecondary,
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
