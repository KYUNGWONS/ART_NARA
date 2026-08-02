import 'package:flutter/material.dart';

import '../constants/dust_tokens.dart';
import '../services/auth_api_service.dart';
import '../widgets/artnara_wordmark.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'role_selection_screen.dart';

/// Figma 스플래시/온보딩(node 1:309) 기준 좌표계. 이 값에 맞춰 화면 크기에 비례 배치한다.
const _designWidth = 390.0;
const _designHeight = 844.0;

class _OnboardingPage {
  const _OnboardingPage({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

/// 1페이지는 디자인 그대로 워드마크 + 태그라인. 2~4페이지는 서비스 소개.
const _pages = [
  _OnboardingPage(title: '', subtitle: '당신의 예술, 새로운 가치를 만나다'),
  _OnboardingPage(
    title: '집 주변의 작품을 만나요',
    subtitle: '지도로 가까운 작가의 작품을\n직접 보고 소장할 수 있어요',
  ),
  _OnboardingPage(
    title: '경매와 제작 의뢰까지',
    subtitle: '입찰로 합리적으로 소장하고,\n원하는 작품은 직접 의뢰하세요',
  ),
  _OnboardingPage(
    title: '정품 인증과 디지털 소유권',
    subtitle: 'QR 정품 인증과 소유권 자동 이전으로\n믿을 수 있는 거래를 약속합니다',
  ),
];

class SplashOnboardingScreen extends StatefulWidget {
  const SplashOnboardingScreen({super.key});

  @override
  State<SplashOnboardingScreen> createState() => _SplashOnboardingScreenState();
}

class _SplashOnboardingScreenState extends State<SplashOnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  /// 저장된 refresh token 이 있으면 온보딩을 건너뛰고 바로 진입한다.
  Future<void> _tryAutoLogin() async {
    final profileCompleted = await AuthApiService.tryAutoLogin();
    if (!mounted || profileCompleted == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => profileCompleted
            ? const MainScreen()
            : const RoleSelectionScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _start() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DustColors.bgCanvas,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sw = constraints.maxWidth / _designWidth;
          final sh = constraints.maxHeight / _designHeight;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 수채 배경 (Figma image 2)
              Image.asset(
                'assets/images/dust_splash_bg.jpg',
                fit: BoxFit.cover,
              ),

              // 페이지 콘텐츠
              PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => index == 0
                    ? _WordmarkPage(sw: sw, sh: sh)
                    : _MessagePage(page: _pages[index], sh: sh),
              ),

              // 캐러셀 도트 (디자인: y=700.5, 10x10, 간격 22)
              Positioned(
                top: 700.5 * sh,
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_pages.length, (index) {
                      final selected = index == _currentPage;
                      return Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? DustColors.brandPrimary
                              : DustColors.brandPrimary.withValues(alpha: 0.25),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // 시작하기 CTA (디자인: x=30, y=734.5, 330x53, pill)
              Positioned(
                top: 734.5 * sh,
                left: 30 * sw,
                right: 30 * sw,
                child: SizedBox(
                  height: 53,
                  child: FilledButton(
                    onPressed: _start,
                    style: FilledButton.styleFrom(
                      backgroundColor: DustColors.brandPrimary,
                      foregroundColor: DustColors.textOnBrand,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DustRadius.full),
                      ),
                    ),
                    child: const Text(
                      '시작하기',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 1페이지 — ART NARA 워드마크 + 태그라인 (Figma 좌표 그대로)
class _WordmarkPage extends StatelessWidget {
  const _WordmarkPage({required this.sw, required this.sh});

  final double sw;
  final double sh;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 워드마크 (디자인 image 11 자리 — 브랜드명이 ART NARA 라 텍스트로 그린다)
        Positioned(
          top: 336 * sh,
          left: 0,
          right: 0,
          child: Center(child: ArtNaraWordmark(fontSize: 40 * sw)),
        ),
        // 태그라인 (디자인: y=386)
        Positioned(
          top: 386 * sh,
          left: 0,
          right: 0,
          child: const Center(
            child: Text(
              '당신의 예술, 새로운 가치를 만나다',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: DustColors.brandPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 2~4페이지 — 서비스 소개 문구
class _MessagePage extends StatelessWidget {
  const _MessagePage({required this.page, required this.sh});

  final _OnboardingPage page;
  final double sh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(40, 300 * sh, 40, 0),
      child: Column(
        children: [
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: DustText.section.copyWith(color: DustColors.brandPrimary),
          ),
          const SizedBox(height: DustSpacing.md),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: DustText.body.copyWith(
              height: 1.6,
              color: DustColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
