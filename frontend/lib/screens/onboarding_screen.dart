import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/locale_provider.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingVisual> _visuals = [
    OnboardingVisual(
      emoji: '🤝',
      bgEmoji: '✨',
      gradientColors: [Color(0xFF4A7FFF), Color(0xFF7BA4FF)],
      imageAsset: 'assets/images/onboarding_student.png',
    ),
    OnboardingVisual(
      emoji: '✨',
      bgEmoji: '👋',
      gradientColors: [Color(0xFF4A7FFF), Color(0xFF7BA4FF)],
      imageAsset: 'assets/images/onboarding_friends.png',
    ),
    OnboardingVisual(
      emoji: '💬',
      bgEmoji: '🚀',
      gradientColors: [Color(0xFF4A7FFF), Color(0xFF7BA4FF)],
      imageAsset: 'assets/images/onboarding_chat.png',
    ),
  ];

  // 각 페이지별 번역 키 매핑
  static final List<
    ({Map<AppLanguage, String> title, Map<AppLanguage, String> desc})
  >
  _pageStrings = [
    (title: AppStrings.onboarding1Title, desc: AppStrings.onboarding1Desc),
    (title: AppStrings.onboarding2Title, desc: AppStrings.onboarding2Desc),
    (title: AppStrings.onboarding3Title, desc: AppStrings.onboarding3Desc),
  ];

  void _onNextPressed() {
    if (_currentPage < _visuals.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // 로그인 화면으로 이동
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.0, 0.05),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _onSkipPressed() {
    _pageController.animateToPage(
      _visuals.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, locale, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(color: Color(0xFFFAFBFD)),
            child: SafeArea(
              child: Column(
                children: [
                  // 상단 바: 뒤로가기 + 건너뛰기
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 8, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 16,
                            color: AppColors.grey,
                          ),
                          label: Text(
                            locale.tr(AppStrings.back),
                            style: GoogleFonts.gowunDodum(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: _currentPage < _visuals.length - 1
                              ? 1.0
                              : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: TextButton(
                            onPressed: _currentPage < _visuals.length - 1
                                ? _onSkipPressed
                                : null,
                            child: Text(
                              locale.tr(AppStrings.skip),
                              style: GoogleFonts.gowunDodum(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 페이지 뷰
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _visuals.length,
                      itemBuilder: (context, index) {
                        return _buildPage(
                          visual: _visuals[index],
                          title: locale.tr(_pageStrings[index].title),
                          description: locale.tr(_pageStrings[index].desc),
                        );
                      },
                    ),
                  ),
                  // 페이지 인디케이터
                  Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: _visuals.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor:
                            _visuals[_currentPage].gradientColors.first,
                        dotColor: AppColors.lightGrey,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 4,
                        spacing: 6,
                      ),
                    ),
                  ),
                  // 하단 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ElevatedButton(
                          onPressed: _onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentPage == 1
                                ? AppColors.primary
                                : _visuals[_currentPage].gradientColors.first,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _currentPage == _visuals.length - 1
                                  ? locale.tr(AppStrings.getStarted)
                                  : locale.tr(AppStrings.next),
                              key: ValueKey<String>(
                                '${locale.currentLanguage}_$_currentPage',
                              ),
                              style: GoogleFonts.jua(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage({
    required OnboardingVisual visual,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          // 이모지 카드 (친근한 느낌으로 키움)
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                right: 8,
                top: 8,
                child: Text(
                  visual.bgEmoji,
                  style: const TextStyle(fontSize: 44),
                ),
              ),
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: visual.gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(42),
                  boxShadow: [
                    BoxShadow(
                      color: visual.gradientColors.first.withValues(alpha: 0.3),
                      blurRadius: 36,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(42),
                  child: Center(
                    child: visual.imageAsset != null
                        ? Image.asset(
                            visual.imageAsset!,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          )
                        : Text(
                            visual.emoji,
                            style: const TextStyle(fontSize: 72),
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // 제목 (Jua - 친근한 톤)
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.jua(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          // 설명 (Gowun Dodum - 부드럽게)
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.gowunDodum(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.darkGrey,
              height: 1.75,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class OnboardingVisual {
  final String emoji;
  final String bgEmoji;
  final List<Color> gradientColors;
  final String? imageAsset;

  const OnboardingVisual({
    required this.emoji,
    required this.bgEmoji,
    required this.gradientColors,
    this.imageAsset,
  });
}
