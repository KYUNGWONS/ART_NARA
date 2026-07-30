import 'package:flutter/material.dart';

import 'login_screen.dart';

// DUST-ART 디자인 팔레트 (Figma 스플래시/온보딩 화면 기준)
const kDustCream = Color(0xFFF6F1E8);
const kDustNavy = Color(0xFF25333B);
const kDustGrey = Color(0xFF8A857B);

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

const _pages = [
  _OnboardingPage(
    title: '당신의 방,\n새로운 갤러리가 되다',
    subtitle: '미대생의 진짜 작품을\n합리적인 가격에 만나보세요',
    icon: Icons.wallpaper_outlined,
  ),
  _OnboardingPage(
    title: '경매와 제작 의뢰까지',
    subtitle: '구매, 경매 입찰, 원하는 작품 의뢰까지\n원하는 방식으로 작품을 만나세요',
    icon: Icons.gavel_outlined,
  ),
  _OnboardingPage(
    title: '정품 인증과\n디지털 소유권',
    subtitle: 'QR 정품 인증과 소유권 자동 이전으로\n믿을 수 있는 거래를 약속합니다',
    icon: Icons.verified_outlined,
  ),
];

/// 앱 첫 진입 스플래시 / 온보딩 화면 (DUST-ART 디자인)
class SplashOnboardingScreen extends StatefulWidget {
  const SplashOnboardingScreen({super.key});

  @override
  State<SplashOnboardingScreen> createState() => _SplashOnboardingScreenState();
}

class _SplashOnboardingScreenState extends State<SplashOnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

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
      backgroundColor: kDustCream,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            // 워드마크
            const Text(
              'DUST-ART',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w600,
                letterSpacing: 8,
                color: kDustNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '창고 속 예술을 거실로',
              style: TextStyle(fontSize: 12, color: kDustGrey, letterSpacing: 2),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _PageContent(page: _pages[index]),
              ),
            ),
            // 페이지 인디케이터
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final selected = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: selected ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: selected ? kDustNavy : kDustNavy.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            // 시작하기
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _start,
                  style: FilledButton.styleFrom(
                    backgroundColor: kDustNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    '시작하기',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 수채 워시 느낌의 비주얼 영역
          Container(
            width: 180,
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  kDustNavy.withValues(alpha: 0.08),
                  kDustCream,
                ],
              ),
            ),
            child: Icon(page.icon, size: 64, color: kDustNavy),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.4,
              color: kDustNavy,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, height: 1.6, color: kDustGrey),
          ),
        ],
      ),
    );
  }
}
