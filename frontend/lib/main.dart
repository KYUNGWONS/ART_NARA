import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'constants/dust_tokens.dart';
import 'providers/locale_provider.dart';
import 'screens/splash_onboarding_screen.dart';

/// 네이버 지도 SDK 초기화 상태 (앱 전역)
bool isNaverMapInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화.
  // 이 키는 android/local.properties 의 kakaoNativeAppKey(커스텀 스킴용)와 **같은 값**이어야 한다.
  const kakaoAppKey = String.fromEnvironment('KAKAO_NATIVE_APP_KEY');
  if (kakaoAppKey.isNotEmpty) {
    KakaoSdk.init(nativeAppKey: kakaoAppKey);
  } else {
    debugPrint('[Kakao] KAKAO_NATIVE_APP_KEY 미설정 — 카카오 로그인이 동작하지 않습니다. '
        '--dart-define=KAKAO_NATIVE_APP_KEY=... 로 네이티브 앱 키를 넘겨주세요.');
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
        title: 'ART NARA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // 디자인 토큰 기준 (Figma "DUST-ART Foundations" 25:210 — 파일명이 옛 브랜드명이다)
          colorScheme: ColorScheme.fromSeed(
            seedColor: DustColors.brandPrimary,
            primary: DustColors.brandPrimary,
            secondary: DustColors.brandDeep,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: DustColors.bgSurface,
          textTheme: GoogleFonts.notoSansKrTextTheme(),
        ),
        home: const SplashOnboardingScreen(),
      ),
    );
  }
}
