import 'dart:ffi' show Abi;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' show KakaoMapSdk;
import 'package:provider/provider.dart';
import 'constants/art_tokens.dart';
import 'providers/locale_provider.dart';
import 'screens/splash_onboarding_screen.dart';

/// 카카오 지도 SDK 초기화 상태 (앱 전역).
/// 로그인과 같은 네이티브 앱 키를 쓰므로 별도의 지도 키가 필요 없다.
bool isKakaoMapInitialized = false;

/// 지도를 못 그리는 이유(목록 폴백 배너에 표시). 초기화 성공 시 null.
String? kakaoMapUnavailableReason;

/// 이 앱 프로세스가 arm 으로 돌고 있는지.
///
/// 카카오맵 네이티브(libK3fAndroid.so)는 arm 전용이라 x86 프로세스에서는 dlopen 이
/// FATAL 로 죽는다(Dart 에서 못 잡는다). 판단 기준은 **기기 속성이 아니라 프로세스 ABI** 다 —
/// arm64 변환을 지원하는 에뮬레이터에 arm64 APK 를 설치하면 x86_64 기기여도 지도가 동작한다.
bool get _isArmProcess =>
    !Platform.isAndroid ||
    Abi.current() == Abi.androidArm64 ||
    Abi.current() == Abi.androidArm;

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
    if (!_isArmProcess) {
      // 초기화를 건너뛰면 지도 탭이 거리순 목록 폴백으로 동작한다.
      kakaoMapUnavailableReason =
          'x86 빌드에서는 카카오맵을 쓸 수 없어 목록으로 보여드려요. arm 기기·arm64 빌드에서는 지도가 표시됩니다.';
      throw StateError('x86 프로세스 — 카카오맵 네이티브 미지원 (${Abi.current()})');
    }
    await KakaoMapSdk.instance.initialize(kakaoAppKey);
    isKakaoMapInitialized = true;
    debugPrint('카카오 지도 SDK 초기화 성공');
  } catch (e) {
    kakaoMapUnavailableReason ??= '지도를 불러오지 못해 목록으로 보여드려요.';
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
          // 디자인 토큰 기준 (Figma "ART NARA Foundations" 25:210 — 파일명이 옛 브랜드명이다)
          colorScheme: ColorScheme.fromSeed(
            seedColor: ArtColors.brandPrimary,
            primary: ArtColors.brandPrimary,
            secondary: ArtColors.brandDeep,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: ArtColors.bgSurface,
          textTheme: GoogleFonts.notoSansKrTextTheme(),
        ),
        home: const SplashOnboardingScreen(),
      ),
    );
  }
}
