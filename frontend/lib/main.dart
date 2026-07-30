import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'constants/dust_tokens.dart';
import 'providers/locale_provider.dart';
import 'screens/splash_onboarding_screen.dart';

/// 네이버 지도 SDK 초기화 상태 (앱 전역)
bool isNaverMapInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화
  const kakaoAppKey = String.fromEnvironment('KAKAO_NATIVE_APP_KEY');
  if (kakaoAppKey.isNotEmpty) {
    KakaoSdk.init(nativeAppKey: kakaoAppKey);
  }

  // 네이버 지도 SDK 초기화
  try {
    const naverClientId = String.fromEnvironment('NAVER_MAP_CLIENT_ID');
    if (naverClientId.isEmpty) {
      throw StateError('NAVER_MAP_CLIENT_ID is not configured');
    }
    await FlutterNaverMap().init(clientId: naverClientId);
    isNaverMapInitialized = true;
    debugPrint('네이버 지도 SDK 초기화 성공');
  } catch (e) {
    debugPrint('네이버 지도 SDK 초기화 실패: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const ArtNaraApp());
}

class ArtNaraApp extends StatelessWidget {
  const ArtNaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: MaterialApp(
        title: 'ArtNara',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // DUST-ART 디자인 토큰 기준 (Figma Foundations 25:210)
          colorScheme: ColorScheme.fromSeed(
            seedColor: DustColors.brandPrimary,
            primary: DustColors.brandPrimary,
            secondary: DustColors.brandDeep,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.white,
          textTheme: GoogleFonts.notoSansKrTextTheme(),
        ),
        home: const SplashOnboardingScreen(),
      ),
    );
  }
}
