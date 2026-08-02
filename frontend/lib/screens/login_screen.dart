import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_strings.dart';
import '../constants/dust_tokens.dart';
import '../widgets/artnara_wordmark.dart';
import '../providers/locale_provider.dart';
import '../services/auth_api_service.dart';
import '../services/google_auth_service.dart';
import '../services/kakao_auth_service.dart';
import 'main_screen.dart';
import 'profile_setup_screen.dart';
import 'role_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isKakaoLoading = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleKakaoLogin() async {
    if (_isKakaoLoading) return;

    setState(() => _isKakaoLoading = true);

    final locale = context.read<LocaleProvider>();
    final accessToken = await KakaoAuthService.login();

    if (!mounted) return;

    if (accessToken == null) {
      debugPrint('[Login] 카카오 OAuth 실패 (accessToken 없음)');
      setState(() => _isKakaoLoading = false);
      _showLoginError(locale);
      return;
    }

    debugPrint('[Login] 카카오 OAuth accessToken 획득 (${accessToken.length}자) → /auth/login 요청');
    final loginResponse = await AuthApiService.login('KAKAO', accessToken);

    if (!mounted) return;
    setState(() => _isKakaoLoading = false);

    if (loginResponse == null ||
        loginResponse.code != 'SUCCESS' ||
        loginResponse.data == null) {
      _showLoginError(locale);
      return;
    }

    final data = loginResponse.data!;
    if (!data.isNewUser && !data.profileCompleted) {
      _showLoginError(locale);
      return;
    }

    final userInfo = await KakaoAuthService.getUserInfo();
    if (!mounted) return;
    final profileImageUrl =
        userInfo?.kakaoAccount?.profile?.profileImageUrl ??
        userInfo?.kakaoAccount?.profile?.thumbnailImageUrl;
    final nickname = userInfo?.kakaoAccount?.profile?.nickname;
    // 회원가입(POST /api/users) body에 사용할 이메일 캡처
    AuthApiService.userEmail = userInfo?.kakaoAccount?.email;

    _navigateAfterLogin(
      isNewUser: data.isNewUser,
      profileCompleted: data.profileCompleted,
      userType: data.userType,
      profileImageUrl: profileImageUrl,
      nickname: nickname,
    );
  }

  Future<void> _handleGoogleLogin() async {
    if (_isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);
    debugPrint('[Google] 로그인 시작');

    final locale = context.read<LocaleProvider>();
    final result = await GoogleAuthService.signIn();

    if (!mounted) return;

    if (result == null) {
      setState(() => _isGoogleLoading = false);
      _showLoginError(locale);
      return;
    }

    final idToken = result.idToken;
    if (idToken == null || idToken.isEmpty) {
      debugPrint('[Login] 구글 OAuth 실패 (idToken 없음)');
      setState(() => _isGoogleLoading = false);
      _showLoginError(locale);
      return;
    }

    debugPrint('[Login] 구글 OAuth idToken 획득 (${idToken.length}자) → /auth/login 요청');
    final loginResponse = await AuthApiService.login('GOOGLE', idToken);

    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (loginResponse == null ||
        loginResponse.code != 'SUCCESS' ||
        loginResponse.data == null) {
      _showLoginError(locale);
      return;
    }

    final data = loginResponse.data!;
    if (!data.isNewUser && !data.profileCompleted) {
      _showLoginError(locale);
      return;
    }

    // 회원가입(POST /api/users) body에 사용할 이메일 캡처
    AuthApiService.userEmail = result.email;

    _navigateAfterLogin(
      isNewUser: data.isNewUser,
      profileCompleted: data.profileCompleted,
      userType: data.userType,
      profileImageUrl: result.profileImageUrl,
      nickname: result.nickname,
    );
  }

  void _showLoginError(LocaleProvider locale) {
    debugPrint('[Login] 로그인 실패 → 에러 표시 (원인은 위 [AuthAPI] 로그 확인)');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          locale.tr(AppStrings.loginError),
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: DustColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _navigateAfterLogin({
    required bool isNewUser,
    required bool profileCompleted,
    String? userType,
    String? profileImageUrl,
    String? nickname,
  }) {
    if (isNewUser) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              RoleSelectionScreen(
                kakaoProfileImageUrl: profileImageUrl,
                kakaoNickname: nickname,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.3, 0.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }
    if (!profileCompleted) {
      final role = userRoleFromApi(userType);
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ProfileSetupScreen(
                role: role,
                kakaoProfileImageUrl: profileImageUrl,
                kakaoNickname: nickname,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.3, 0.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }
    // 기존 사용자(프로필 완료) → 메인으로
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.3, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: child,
            ),
          );
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
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: DustColors.bgCanvas,
            child: SafeArea(
              child: Column(
                children: [
                  // 상단 뒤로가기
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, top: 8),
                      child: TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 16,
                          color: DustColors.textSecondary,
                        ),
                        label: Text(
                          locale.tr(AppStrings.back),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: DustColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  // 로고 + 타이틀
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // ART NARA 워드마크
                          const ArtNaraWordmark(fontSize: 34),
                          const SizedBox(height: 12),
                          const Text(
                            '당신의 예술, 새로운 가치를 만나다',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: DustColors.brandPrimary,
                            ),
                          ),
                          const SizedBox(height: DustSpacing.lg * 2),
                          // 타이틀
                          Text(
                            locale.tr(AppStrings.loginTitle),
                            style: DustText.section.copyWith(fontSize: 19),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  // 카카오 로그인 버튼
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: (_isKakaoLoading || _isGoogleLoading)
                                  ? null
                                  : _handleKakaoLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFEE500),
                                foregroundColor: const Color(0xFF191919),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                disabledBackgroundColor: const Color(
                                  0xFFFEE500,
                                ).withValues(alpha: 0.6),
                              ),
                              child: _isKakaoLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Color(0xFF191919),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // 카카오 말풍선 아이콘
                                        Image.network(
                                          'https://developers.kakao.com/assets/img/about/logos/kakaolink/kakaolink_btn_small.png',
                                          width: 20,
                                          height: 20,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.chat_bubble,
                                                  size: 20,
                                                  color: Color(0xFF191919),
                                                );
                                              },
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          locale.tr(AppStrings.loginWithKakao),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF191919),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Google 로그인 버튼
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: OutlinedButton(
                              onPressed: (_isKakaoLoading || _isGoogleLoading)
                                  ? null
                                  : _handleGoogleLogin,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: DustColors.textPrimary,
                                side: const BorderSide(
                                  color: DustColors.borderSoft,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isGoogleLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: DustColors.textSecondary,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          'https://www.google.com/favicon.ico',
                                          width: 20,
                                          height: 20,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.g_mobiledata_rounded,
                                                  size: 24,
                                                  color: DustColors.textSecondary,
                                                );
                                              },
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          locale.tr(AppStrings.loginWithGoogle),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: DustColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
