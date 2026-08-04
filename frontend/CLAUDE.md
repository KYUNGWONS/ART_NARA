# CLAUDE.md

이 파일은 Claude Code(claude.ai/code)가 이 저장소에서 작업할 때 참고할 가이드를 제공합니다.

## 프로젝트 개요

DUST-ART(아트나라)는 미대생 미술품 거래 플랫폼 Flutter 앱입니다(다국어 KO/EN/JA/ZH, iOS/Android). 디자인 토큰은 `lib/constants/dust_tokens.dart`(DustColors/DustText/DustSpacing/DustRadius) — **새 화면은 하드코딩 대신 이 토큰 사용**.

## 자주 쓰는 명령어

```bash
# 의존성 설치
flutter pub get

# 연결된 디바이스 / 실행 중인 시뮬레이터에서 앱 실행
flutter run

# 정적 분석 (analysis_options.yaml → package:flutter_lints 사용)
flutter analyze

# 모든 테스트 실행
flutter test

# 단일 테스트 파일만 실행
flutter test test/widget_test.dart
```

## 아키텍처

### 진입점과 앱 셸

- [lib/main.dart](lib/main.dart)는 `runApp` **이전에** Kakao SDK(`KakaoSdk.init`)와 카카오맵 SDK(`KakaoMapSdk.instance.initialize` — 같은 네이티브 앱 키)를 초기화합니다. 지도 초기화 결과는 전역 `isKakaoMapInitialized` 플래그로 노출되므로, 지도 화면은 SDK가 준비되었다고 가정하지 말고 이 플래그를 분기 조건으로 사용해야 합니다. x86 에뮬레이터에서는 카카오맵 네이티브가 없어 항상 false(목록 폴백)입니다.
- 루트 위젯은 `MaterialApp`을 `ChangeNotifierProvider<LocaleProvider>`로 감싸고, `DustColors.brandPrimary` 시드 컬러와 `GoogleFonts.notoSansKrTextTheme()`을 적용합니다. 색·간격은 `dust_tokens.dart` 토큰을 사용하세요(레거시 `app_colors.dart`는 점진 대체 중).
- 초기 라우트는 `SplashOnboardingScreen`(DUST-ART 스플래시/온보딩) → `LoginScreen`(카카오/구글) → 신규회원이면 `RoleSelectionScreen`(작가/컬렉터) → `ProfileSetupScreen` → `MainScreen`(하단 탭: 홈/판매/지도/제작의뢰/채팅) 순서입니다. 역할 enum `UserRole.koreanStudent`=작가, `UserRole.foreigner`=컬렉터로 백엔드 userType(KOREAN_STUDENT/FOREIGN_TOURIST)과 매핑됩니다.

### `lib/` 계층 구조

- `constants/` — 디자인 토큰(`app_colors`, `app_text_styles`), `app_strings.dart`의 i18n 문자열 맵, 정적 참조 데이터(`country_data.dart`), API 베이스 URL 헬퍼.
- `providers/` — `provider`로 소비되는 `ChangeNotifier`들. 현재는 활성 `AppLanguage`를 보관하고 `tr(Map<AppLanguage,String>)` 조회를 제공하는 `LocaleProvider`만 존재합니다.
- `models/` — 백엔드 응답 봉투인 `{code, message, data}` 형태를 그대로 따르는 `fromJson` 생성자를 가진 단순 Dart DTO들 (`LoginResponse`, `UserProfileResponse` 참고).
- `services/` — REST/OAuth 클라이언트. 모든 HTTP 호출은 화면에서 직접 호출하지 않고 반드시 이 클래스들을 거쳐야 합니다.
- `screens/` — 라우트 단위의 풀 페이지 위젯들. `MainScreen`은 바텀 내비게이션 상태(`_currentTab`)와 선택된 커뮤니티 카테고리를 보유합니다.
- `widgets/` — 공통 UI 구성 요소(현재는 비어 있거나 채워나가는 중).
- `data/` — 백엔드 엔드포인트가 준비되기 전 사용하는 인메모리 목업 데이터(예: `mock_community_data.dart`).

### API와 인증 규칙

- REST 베이스 URL은 [lib/constants/api_config.dart](lib/constants/api_config.dart)에서 런타임에 결정됩니다. Android 에뮬레이터에서는 `http://10.0.2.2:8080`, 그 외에는 `http://localhost:8080`을 사용합니다. 서비스 코드에서 베이스 URL을 직접 하드코딩하지 말고 `apiBaseUrl`을 읽으세요.
- `AuthApiService`([lib/services/auth_api_service.dart](lib/services/auth_api_service.dart))는 JWT 쌍(`accessToken` / `refreshToken`)을 `static` 필드로 보관합니다. 다른 서비스(`UserApiService`, `ChatApiService` 등)는 `AuthApiService.accessToken`을 직접 읽어 `Authorization: Bearer …` 헤더를 자체적으로 추가합니다. 공용 HTTP 클라이언트나 인터셉터가 없으므로, **새로운 서비스를 추가할 때마다 이 규칙을 직접 적용**해야 합니다.
- 로그인 흐름: `KakaoAuthService` / `GoogleAuthService`로 OAuth `accessToken`(Kakao) 또는 `idToken`(Google)을 얻은 뒤, `POST /auth/login`에 `{provider, accessToken}` 바디로 교환하여 앱 자체의 JWT 쌍을 발급받습니다. `provider` 값은 문자열 `"KAKAO"` 또는 `"GOOGLE"`입니다.
- **오프라인 mock 폴백 패턴 (중요):** 현재 백엔드를 호출하는 모든 서비스 메서드는 요청이 실패하거나 성공이 아닌 응답 봉투가 돌아오면 하드코딩된 mock 응답을 반환하도록 되어 있어, 서버 없이도 UI 흐름이 계속 동작합니다. 각 헬퍼에는 `TODO(서버 연동)` 마커가 붙어 있으며, 실제 백엔드가 연결되면 모두 제거해야 합니다. 새로운 서비스 메서드를 추가할 때도 동일한 `try { … } catch { return _mockXForOffline(); }` 형태를 따르고, 같은 TODO를 달아 나중에 쉽게 찾아 제거할 수 있도록 하세요.

### 다국어(i18n)

- 앱은 `AppLanguage { ko, en, ja, zh }`를 통해 4개 언어를 지원합니다. 문자열은 `AppStrings` 위에 `static const Map<AppLanguage, String>` 항목으로 저장되며, 화면에서는 `context.watch<LocaleProvider>().tr(AppStrings.someKey)` 형태로 렌더링합니다. 사용자에게 보여지는 카피를 추가할 때는 리터럴을 인라인하지 말고 4개 로케일을 모두 채워서 `app_strings.dart`에 등록하세요.

### 채팅 / WebSocket

- `ChatScreen`([lib/screens/chat_screen.dart](lib/screens/chat_screen.dart))은 백엔드 STOMP 서버에 붙습니다. 접속 주소는 `apiBaseUrl`의 http→ws 치환(`chatWebSocketUrl`)이라 별도 설정이 없습니다.
  - 이전 대화: `GET /api/chat/rooms/{roomId}/messages` (본인이 참여한 방만, 아니면 403)
  - 실시간 수신: 구독 `/topic/chat/{roomId}` / 전송: `/app/chat/send` `{roomId, senderId, content, messageType}`
  - **보낸 메시지를 로컬에 먼저 추가하지 마세요.** 서버가 `/topic`으로 되돌려주는 것 하나만 표시합니다(중복 방지).
  - `senderId`는 `AuthApiService.userId`이며 로그인 시 JWT `sub`에서 채워집니다.

### 네이티브 SDK 키

- Kakao 네이티브 앱 키(로그인+지도 겸용)·Google 웹 클라이언트 ID는 `String.fromEnvironment`로 읽습니다. **`--dart-define` 없이 실행하면 로그인·지도가 동작하지 않습니다.**

  ```bash
  flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080 \
    --dart-define=KAKAO_NATIVE_APP_KEY=... \
    --dart-define=GOOGLE_SERVER_CLIENT_ID=...apps.googleusercontent.com
  ```

- 카카오 키는 **네이티브 쪽에도** 필요합니다(커스텀 스킴 `kakao{키}://oauth`). git 미추적 `android/local.properties`의 `kakaoNativeAppKey=`에 넣으면 `app/build.gradle.kts`가 읽어 `manifestPlaceholders`로 주입합니다 — `--dart-define` 값과 반드시 같아야 합니다.
- 리다이렉트 인텐트 필터는 `MainActivity`가 아니라 **`com.kakao.sdk.flutter.AuthCodeCustomTabsActivity`** 에 있어야 로그인 Future가 완료됩니다.

## Trigger Keywords (자동화)

Claude Code에서 다음 키워드를 포함한 메시지를 제출하면 자동으로 테스트 실행 및 커밋/푸시가 진행됩니다:

**트리거 키워드:**

- `commit` (영어)
- `커밋` (한글)

**자동 실행 흐름:**

1. `flutter test` 실행
2. 모든 테스트 패스 → 변경사항 분석하여 적절한 영어 커밋 메시지 자동 생성
3. `git add -A && git commit && git push` 자동 실행
4. 테스트 실패 → 실패 보고 (git 커맨드 실행 안 함)

**사용 예:**

```
"코드 정리했으니 commit 해줘"
"이거 커밋할게"
"commit"
"커밋"
```
