# CLAUDE.md

이 파일은 Claude Code(claude.ai/code)가 이 저장소에서 작업할 때 참고할 가이드를 제공합니다.

## 프로젝트 개요

DUST-ART(아트나라)는 미대생 미술품 거래 플랫폼 Flutter 앱입니다(다국어 KO/EN/JA/ZH, iOS/Android). 디자인 토큰은 `lib/constants/dust_tokens.dart`(DustColors/DustText/DustSpacing/DustRadius) — **새 화면은 하드코딩 대신 이 토큰 사용**. [server/](server/) 디렉터리에는 실제 채팅 백엔드가 준비되기 전까지 임시로 사용하는 작은 Node.js WebSocket 헬퍼가 들어 있습니다.

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

로컬 채팅 테스트 서버 (Node.js, 실제 채팅 백엔드 준비 전까지 사용):

```bash
cd server
npm install
npm start            # ws://localhost:8080, 들어오는 메시지를 모든 클라이언트에 브로드캐스트
```

## 아키텍처

### 진입점과 앱 셸

- [lib/main.dart](lib/main.dart)는 `runApp` **이전에** Kakao SDK(`KakaoSdk.init`)와 Naver Map SDK(`FlutterNaverMap().init`)를 초기화합니다. Naver 초기화 결과는 전역 `isNaverMapInitialized` 플래그로 노출되므로, 지도 화면은 SDK가 준비되었다고 가정하지 말고 이 플래그를 분기 조건으로 사용해야 합니다.
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

- `ChatScreen`은 [lib/screens/chat_screen.dart](lib/screens/chat_screen.dart) 상단에 선언된 `kWebSocketUrl`로 연결합니다. 현재는 [server/index.js](server/index.js)의 로컬 브로드캐스트 서버를 가리키며, 백엔드 전환은 한 줄 수정으로 가능합니다. 개발 서버가 보낸 메시지를 송신자에게 그대로 되돌려주기 때문에, `ChatScreen`은 `_lastSentText` / `_sentEchoThreshold`로 중복을 제거합니다 — 수신 경로를 리팩터링할 때 이 로직을 유지하세요.

### 네이티브 SDK 키

- Kakao 네이티브 앱 키와 Naver Map 클라이언트 ID는 현재 [lib/main.dart](lib/main.dart)에 하드코딩되어 있습니다. 상수가 아니라 설정 값으로 취급하세요. SDK 설정을 변경해야 한다면 키를 여기저기 흩어두지 말고 `main.dart`에서 직접 수정합니다.

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
