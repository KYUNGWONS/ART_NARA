import 'dart:io' show Platform, Process;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' show KakaoMapSdk;
import 'package:provider/provider.dart';
import 'constants/dust_tokens.dart';
import 'providers/locale_provider.dart';
import 'screens/splash_onboarding_screen.dart';

/// 카카오 지도 SDK 초기화 상태 (앱 전역).
/// 로그인과 같은 네이티브 앱 키를 쓰므로 별도의 지도 키가 필요 없다.
bool isKakaoMapInitialized = false;

/// x86/x86_64 안드로이드(에뮬레이터)인지 — 카카오맵 네이티브 미지원 환경 판별용.
Future<bool> _isX86Android() async {
  if (!Platform.isAndroid) return false;
  try {
    final result = await Process.run('getprop', ['ro.product.cpu.abi']);
    return (result.stdout as String).trim().startsWith('x86');
  } catch (_) {
    return false;
  }
}

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

  // 카카오 지도 SDK 초기화 — 로그인과 동일한 네이티브 앱 키를 재사용한다.
  // (네이버 지도에서 2026-08-05 전환: 키 두 벌 관리를 없애기 위함)
  try {
    if (kakaoAppKey.isEmpty) {
      throw StateError('KAKAO_NATIVE_APP_KEY is not configured');
    }
    if (await _isX86Android()) {
      // 카카오맵 네이티브 라이브러리(libK3fAndroid.so)는 arm 전용이라
      // x86_64 에뮬레이터에서는 dlopen 이 FATAL 로 죽는다(Dart 에서 못 잡음).
      // 초기화를 건너뛰면 지도 탭이 거리순 목록 폴백으로 동작한다.
      throw StateError('x86 에뮬레이터 — 카카오맵 네이티브 미지원');
    }
    await KakaoMapSdk.instance.initialize(kakaoAppKey);
    isKakaoMapInitialized = true;
    debugPrint('카카오 지도 SDK 초기화 성공');
  } catch (e) {
    debugPrint('카카오 지도 SDK 초기화 실패: $e');
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
