import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_strings.dart';
import '../constants/dust_tokens.dart';
import '../providers/locale_provider.dart';
import '../services/auth_api_service.dart';
import '../services/google_auth_service.dart';
import '../services/kakao_auth_service.dart';
import '../services/notification_api_service.dart';
import 'chat_list_screen.dart';
import 'art_home_feed_screen.dart';
import 'commission_screen.dart';
import 'splash_onboarding_screen.dart';
import 'map_screen.dart';
import 'my_profile_screen.dart';
import 'notification_screen.dart';
import 'sell_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentTab = 0; // 홈이 기본 선택 (디자인 bottom-navigation 순서)
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _unreadNotifications = 0;
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
    _loadUnread();
  }

  /// 헤더 벨·하단 알림 탭의 배지에 쓰는 안읽음 수.
  Future<void> _loadUnread() async {
    final result = await NotificationApiService.list();
    if (!mounted) return;
    setState(() => _unreadNotifications = result.unread);
  }

  void _selectTab(int index) {
    setState(() => _currentTab = index);
    _loadUnread();
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
                color: DustColors.bgSurface,
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
                      color: DustColors.borderSoft,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 타이틀
                  Text(
                    localeProvider.tr(AppStrings.settings),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: DustColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: DustColors.borderSoft),
                  // 로그아웃 버튼
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: DustColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        size: 20,
                        color: DustColors.danger,
                      ),
                    ),
                    title: Text(
                      localeProvider.tr(AppStrings.logout),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DustColors.danger,
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DustColors.textPrimary,
                ),
              ),
              content: Text(
                localeProvider.tr(AppStrings.logoutConfirm),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: DustColors.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    localeProvider.tr(AppStrings.cancel),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: DustColors.textSecondary,
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: DustColors.danger,
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

    // 초기 화면(스플래시)으로 이동, 모든 스택 제거
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SplashOnboardingScreen(),
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
          key: _scaffoldKey,
          backgroundColor: DustColors.bgCanvas,
          drawer: _buildDrawer(),
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

  // ─── 좌측 서랍 (디자인 header-row 의 메뉴 버튼) ───
  // 디자인 하단 내비에는 채팅 탭이 없어, 작품 문의(채팅)와 설정을 여기로 옮겼다.
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: DustColors.bgSurface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(DustSpacing.lg, DustSpacing.lg,
                  DustSpacing.lg, DustSpacing.sm),
              child: Text('ART NARA',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: DustColors.brandPrimary,
                  )),
            ),
            const Divider(height: 1, color: DustColors.borderSoft),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded,
                  color: DustColors.brandPrimary),
              title: const Text('작품 문의', style: DustText.body),
              subtitle: const Text('작가와 나눈 대화', style: DustText.caption),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      backgroundColor: DustColors.bgCanvas,
                      appBar: AppBar(
                        backgroundColor: DustColors.bgCanvas,
                        elevation: 0,
                        foregroundColor: DustColors.textPrimary,
                        title: const Text('작품 문의',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: DustColors.brandPrimary,
                            )),
                        centerTitle: true,
                      ),
                      body: const SafeArea(child: ChatListScreen()),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined,
                  color: DustColors.brandPrimary),
              title: const Text('설정', style: DustText.body),
              onTap: () {
                Navigator.of(context).pop();
                _showSettingsSheet();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── 상단 내비게이션 바 (디자인 header-row: 메뉴 · 타이틀 · 벨) ───
  static const _tabTitles = ['둘러보기', '작품 판매 등록', '지도', '제작 의뢰 신청', '알림', '마이페이지'];

  Widget _buildTopBar(LocaleProvider locale) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: DustSpacing.md, vertical: DustSpacing.sm),
      color: DustColors.bgCanvas,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 좌측: 메뉴 버튼 (디자인 header-row > menu-button) — 채팅·설정 서랍
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              borderRadius: BorderRadius.circular(DustRadius.full),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.menu_rounded,
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
          // 우측: 알림 벨 (디자인 header-right-icons > notification-button)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectTab(4),
              borderRadius: BorderRadius.circular(DustRadius.full),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      size: 24,
                      color: DustColors.textPrimary,
                    ),
                    // 안읽은 알림이 있으면 점 배지
                    if (_unreadNotifications > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: DustColors.brandPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 중앙 메인 콘텐츠 (디자인 탭 순서: 홈 · 판매 · 지도 · 제작의뢰 · 알림 · 마이페이지) ───
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
      case 4: // 알림
        return NotificationScreen(
          onOpenTab: _selectTab,
          onUnreadChanged: (count) {
            if (mounted) setState(() => _unreadNotifications = count);
          },
        );
      case 5: // 마이페이지
        return const MyProfileScreen(embedded: true);
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
      AppStrings.navNotifications,
      AppStrings.navMyPage,
    ];
    final icons = [
      Icons.home_rounded,
      Icons.sell_outlined,
      Icons.map_outlined,
      Icons.description_outlined,
      Icons.notifications_none_rounded,
      Icons.person_outline_rounded,
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icons[_currentTab], size: 48, color: DustColors.borderSoft),
          const SizedBox(height: 16),
          Text(
            locale.tr(labels[_currentTab]),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: DustColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DustColors.borderSoft,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 하단 내비게이션 바 (디자인 bottom-navigation: 홈 · 판매 · 지도 · 제작의뢰 · 알림 · 마이페이지) ───
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
        icon: Icons.notifications_none_rounded,
        activeIcon: Icons.notifications_rounded,
        label: AppStrings.navNotifications,
      ),
      _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: AppStrings.navMyPage,
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
                  onTap: () => _selectTab(index),
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
