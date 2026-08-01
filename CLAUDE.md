# CLAUDE.md — ART NARA (DUST-ART)

미대생 미술품 거래 플랫폼. 원격: https://github.com/KYUNGWONS/ART_NARA (master에 직접 커밋·푸시).
기능 명세 원천은 레포 루트의 사업계획서 PDF(DUST-ART_...pdf): 3탭(구매/판매/제작의뢰) + 경매, 지도 집 주변 매칭, QR 정품 인증, 디지털 소유권. **블록체인 없음, 배송 없음** (사용자 확정).

## 구조

- `frontend/` — Flutter 앱 (상세 규칙은 frontend/CLAUDE.md). 하단 탭: 홈/판매/지도/제작의뢰/채팅.
- `backend/` — Spring Boot 3, 패키지 `com.example.artnara`, H2(dev)/JPA.

## 디자인 시스템 (DUST-ART)

- Figma "DUST-ART Foundations"(파일 `LghoZTZPejVsF7jndmqJEm`, node `25:210`)에서 추출한 토큰을 `frontend/lib/constants/dust_tokens.dart`에 정의해 둠. **새 화면은 하드코딩 대신 이 토큰 사용.**
  - 브랜드: teal `#07524E` / deep `#084742` (네이비 아님)
  - 배경: canvas ivory `#F8F3E8`, surface `#FEFCF7`, subtle `#F0EBE3`
  - 텍스트: primary `#141413`, secondary `#6B665E`, on-brand `#FFFFFF`, 테두리 `#E0DBD1`
  - 타이포: Noto Sans KR — Heading 28 Bold / Section 22 Bold / Body 16 Regular / Caption 12 Regular
  - Spacing 8·12·16·24, Radius 8·14·22·Full
- 워드마크/배경은 Figma에서 내려받은 에셋 사용: `assets/images/dust_wordmark.png`(배경 투명 PNG — `colorBlendMode` 걸면 투명부가 흰색으로 칠해지니 그냥 그릴 것), `dust_splash_bg.jpg`.
- 서비스 내부 텍스트는 ART NARA 혼용 중 — 통일 여부는 사용자 결정 대기.
- 주요 화면 node id: 스플래시/온보딩 `1:309`, 홈 피드 `1:325`·`1:437`, 작품 판매 등록 `1:274`, 제작 의뢰 신청 `23:67`, 작가 포트폴리오 `41:850`, 정품 인증서 `50:1034`·`60:302`.
- **최신 디자인 리비전: 파일 `ZqY7Mo7424n3gMp5kZJ4AZ`("26.07.29 1-6")** — 프레임 8개(작가 포트폴리오 `1:278`, 제작 의뢰 신청 `1:349`, 홈 피드2 `1:443`, 홈 피드1 `1:549`, 작품 판매 등록 `1:654`, 스플래시/온보딩 `1:722`, 정품 인증서1 `1:737`, 정품 인증서2 `1:806`). 이 리비전에서 바뀐 점:
  - **하단 내비가 6탭**(홈·판매·지도·제작의뢰·**알림**·**마이페이지**)이고 채팅 탭이 없다 → 채팅(작품 문의)은 홈 헤더 좌측 햄버거 서랍으로 이동.
  - 헤더는 `메뉴(햄버거) · 화면 제목 · 알림 벨` 한 줄. 화면 제목은 헤더에서만 그린다(본문 중복 금지).
  - 인증서 항목: 작품 제목·작가·**제작 연도·크기·재료**·고유 인증 ID.
  - 판매 등록 스텝은 디자인상 5개(…·배송 정보·등록 완료)지만 **배송이 없으므로 4스텝**(작품 정보·상세 정보·가격 설정·등록 완료)으로 운영.
  - 색은 Foundations 토큰과 사실상 동일(브랜드 teal 미세 차이 `#0A3C36`) — `DustColors` 유지.
- 디자인 반영 현황(2026-07-31): 스플래시·로그인·홈 피드(칩 필터=백엔드 category 연동)·하단 내비(홈/판매/지도/제작의뢰/채팅)·판매 등록(4스텝 위저드) 완료. 전 화면 색상은 DustColors 토큰으로 통일됨. 제작 의뢰(23:67 멀티칩+안내박스)·정품 인증서(50:1034 골드 프레임 카드)도 완료. 작가 포트폴리오(41:850)도 완료(`GET /api/artists/{작가명}` + artist_portfolio_screen, 홈 피드 작가 리스트·작품 상세 작가 카드에서 진입). **디자인 6화면 전부 반영 완료.** 렌더 이미지는 Figma REST `/v1/images`로 받는다(MCP는 호출 제한 있음).
- 코드베이스는 Knot/UniTrip(여행 매칭 앱)에서 가져와 리네임한 것. 프론트 화면 잔재는 2026-07-31 정리 완료(랜딩/여행 온보딩/브랜드 화면 삭제, 역할=작가·컬렉터, 프로필 설정 아트나라화, 마이페이지 여행 필드 제거). 백엔드 여행 도메인도 2026-07-31 정리: booking/festival/magazine/notification/wishlist/brand 삭제 완료. 2026-08-01 지도 탭을 아트나라 전용(작품 마커 + /api/artworks/nearby)으로 재편하면서 content·recommendation·map 도메인, 프론트 여행 화면·서비스(tour_api, content_api, mate_match 등)도 삭제 완료. 2026-08-02 여행 잔재 정리 마무리: User 의 travelStyle·languages·district·matchingEnabled 및 TravelStyle/District 엔티티 삭제, 시드(test.sql)를 작가/컬렉터·장르·작품 문의 대화로 교체, 채팅 목록·상세를 실제 API + DUST-ART 로 재작성(프론트의 임시 Node WebSocket 서버 `frontend/server/` 삭제). 2026-08-02 2차: VerificationType 을 UNIVERSITY 만 남기고, 프론트의 참조 없는 여행 트리(커뮤니티 게시판·약속 달력·메이트 스토리·관광공사 모델·여행 콘텐츠 옵션)와 미사용 i18n 문자열 138개를 삭제. **여행 잔재 정리 완료.**

## 작업 규칙 (사용자 요구)

- 기능 하나마다 **frontend / backend 커밋을 분리**해서 만들고 origin/master로 푸시. 커밋 메시지는 `feat(backend): ...` / `feat(frontend): ...` 형식.
- 커밋 전 검증: 프론트 `flutter test`(flutter는 `C:\Users\worms\dev\flutter\bin\flutter.bat`), 백엔드 `./gradlew test`(JDK 17 — Java 21 API 금지).
- **새 화면 디자인이 필요하면 Figma "Manyfast Wireframe to Figma (커뮤니티)" 파일에 먼저 그린 뒤 구현할 것.**
- Figma 계정은 **lcm97@jnu.ac.kr**(아트나라 전용). 토큰은 git 미추적 파일 `.claude/settings.local.json`의 `env.FIGMA_DUSTART_TOKEN`에 보관 — **절대 커밋 금지**.
- **디자인 읽기는 Figma REST API로** 한다 (PAT 사용, 검증됨): `curl -H "X-Figma-Token: $TOKEN" https://api.figma.com/v1/files/{fileKey}` / 렌더 이미지는 `/v1/images/{fileKey}?ids=`. PAT는 REST 전용이고 **원격 MCP 엔드포인트는 OAuth(scope mcp:connect)만 받으므로 PAT로는 연결 불가**.
- 디자인 *생성/수정*(Manyfast 파일에 새 화면 그리기)이 필요하면 대화형 터미널에서 `/mcp`로 `figma-dustart` OAuth 인증 필요. 이 인증은 로컬에 저장되며 claude.ai 계정 커넥터와 무관.
- 파일 키: DUST-ART 디자인 `LghoZTZPejVsF7jndmqJEm`, Manyfast 와이어프레임 `PEgRT86N0VTa1bXgTruP4S`.
- **계정 연동형 Figma 커넥터는 다른 프로젝트(Knot) 소속이므로 이 레포에서 사용 금지** — 아트나라 정보가 그 계정에 남으면 안 됨.
- 같은 이유로 아트나라 컨텍스트는 계정 메모리에 저장하지 말고 이 파일(CLAUDE.md)에 기록할 것.

## 백엔드 컨벤션

- 아트나라 도메인은 JPA 전환 완료: 엔티티 Artwork/ArtworkBid/Sale/Commission/CommissionOffer/Ownership/ArtOrder(테이블 `art_orders` — order는 예약어).
- 시드는 `ArtnaraDataInitializer`(CommandLineRunner) — test 프로필은 sql init을 안 돌리므로 시드는 반드시 이 러너에. **작품 id 1~8 순서는 ArtworkService의 위치 mock(LOCATIONS)과 결합되어 있으므로 유지할 것.**
- 서비스 테스트는 `@IntegrationTest`(@SpringBootTest + @Transactional + test 프로필).
- 새 공개 API는 `SecurityConstant.PUBLIC_URLS`에 경로 추가 필요.
- 경매: `Artwork.auctionEndAt` 기준 `AuctionScheduler`가 1분 주기 자동 마감, remainingTime은 동적 계산("D-n"/"HH:mm:ss"). 낙찰자("나")만 낙찰가로 `/api/orders` 결제 가능.
- 주문: 결제수단만 받음(CARD/KAKAO_PAY/NAVER_PAY/TOSS, mock PG). 결제 완료 시 디지털 소유권 + QR 인증서(Certificate 엔티티, `ARTNARA-QR-xxxx`) 자동 발급 — 마이페이지 QR 스캔으로 즉시 조회 가능.
- 채팅: STOMP `/ws`(네이티브 + SockJS 둘 다 등록). 대화 내역은 `GET /api/chat/rooms/{roomId}/messages`(참여자만), 실시간은 `/topic/chat/{roomId}` 구독 + `/app/chat/send`. 목록 `GET /api/chat/rooms/my` 는 상대 프로필·마지막 메시지를 포함하며 대상은 JWT 신원으로 결정된다.
- 이미지: `POST /api/images` multipart → `/images/{파일명}` 정적 서빙, 저장 위치 `app.upload-dir`(기본 uploads/, gitignore됨).
- **에러가 401 로 둔갑하는 함정**: 컨트롤러 예외 → 서블릿이 `/error` 로 ERROR 디스패치 → `JwtAuthenticationFilter`(OncePerRequestFilter 는 ERROR 디스패치를 건너뜀)가 안 돌아 SecurityContext 가 비어 401 빈 응답이 나갔다. `/error` 를 `SecurityConstant.ERROR_URLS` 로 열어 해결(2026-08-01). **401 빈 본문이 보이면 인증이 아니라 서버 예외를 의심할 것.**
- `Sido`(시·도) enum 은 `@JsonCreator`/`@JsonValue` 로 한글 라벨("서울특별시")을 주고받는다. DB 에는 enum 이름(SEOUL)이 저장된다.

## 남은 작업 후보

- 실제 PG SDK 연동 (가맹 계약 필요 — 프로토타입은 mock 유지)

## 로컬 실행 (에뮬레이터)

```bash
# 1) 백엔드
cd backend && ./gradlew bootRun          # http://localhost:8080

# 2) 앱 — 에뮬레이터에서 host 백엔드는 10.0.2.2 로 접근해야 한다
cd frontend && flutter run -d emulator-5554   --dart-define=API_BASE_URL=http://10.0.2.2:8080   --dart-define=KAKAO_NATIVE_APP_KEY=... --dart-define=NAVER_MAP_CLIENT_ID=...
```

- 카카오/네이버/구글 키는 `String.fromEnvironment`라 **--dart-define 없이는 로그인·지도가 동작하지 않는다.** 패키지명이 `com.artnara.artnara`로 바뀌었으므로 **Knot용 키는 사용 불가 — 아트나라 전용으로 새로 발급**해야 하고, AndroidManifest 의 `kakao{네이티브키}` scheme 도 함께 교체해야 한다.
- 한글 경로(`문서`) 때문에 두 가지 우회가 필요하다: `android/gradle.properties`의 `android.overridePathCheck=true`(적용됨), 그리고 `flutter run`은 aapt 가 APK 경로를 못 읽어 실패하므로 **`flutter build apk --debug` → APK를 영문 경로로 복사 → `adb install -r`** 로 띄운다.

## OAuth 앱 등록 (카카오 / 구글)

**네이티브 앱이라 도메인·리다이렉트 URI가 아니라 `패키지명 + 인증서 지문`으로 등록한다.** 패키지명은 `com.artnara.artnara`.

디버그 키 지문 (이 PC의 `~/.android/debug.keystore` 기준):
- SHA-1: `95:FC:FF:7C:84:F8:89:BC:BC:9B:09:CA:74:7E:08:1A:F0:E2:0C:E3`
- 카카오 키 해시: `lfz/fIT4iby8mwnKdH4IGvDiDOM=`
- 재발급: `keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android | openssl sha1 -binary | openssl base64`
- **릴리스 빌드는 릴리스 키스토어 지문을 따로 등록해야 한다.**

**카카오**: 앱 생성 → 플랫폼 > Android 에 패키지명·키해시 등록 → 카카오 로그인 ON → 동의항목(닉네임·프로필사진·이메일). *사이트 도메인/Redirect URI 는 웹(JS·REST)용이라 불필요* — 네이티브는 `kakao{네이티브키}://oauth` 커스텀 스킴을 쓴다.

- 현재 dev 앱: **ART_NARA-dev**(앱 ID 1530596), 네이티브 앱 키는 git 미추적 `frontend/android/local.properties` 의 `kakaoNativeAppKey=` 에 보관 — **커밋 금지**. `app/build.gradle.kts` 가 이 값을 읽어 `manifestPlaceholders["kakaoNativeAppKey"]` 로 주입하고, 매니페스트는 `kakao${kakaoNativeAppKey}` 스킴을 쓴다. 앱 실행 시 `--dart-define=KAKAO_NATIVE_APP_KEY=`(KakaoSdk.init 용)도 **같은 값**으로 넘겨야 한다.
- **리다이렉트 인텐트 필터는 `com.kakao.sdk.flutter.AuthCodeCustomTabsActivity` 에 붙여야 한다.** MainActivity 에 붙이면 인텐트는 전달되지만 SDK 의 로그인 Future 가 끝나지 않아 버튼이 무한 로딩된다(실제로 겪음).
- 2026-08-01 에뮬레이터에서 동의 → `/auth/login` 200(JWT) → 역할 선택 → 프로필 설정까지 **정상 동작 확인**.

**구글**: 클라이언트 **2개**가 필요하다.
1. *Android* 클라이언트 — 패키지명 + SHA-1. (앱에서 로그인 창이 뜨게 하는 용도, 코드에 넣지 않음)
2. *웹 애플리케이션* 클라이언트 — 이 ID를 `GOOGLE_SERVER_CLIENT_ID` 로 주입해야 **idToken 이 발급**된다. 백엔드 `oauth.google.client-id` 에도 같은 값을 넣어 aud 를 검증한다. 승인된 리디렉션 URI/자바스크립트 원본은 모바일 전용이면 **비워둬도 된다**.

## 환경 주의사항

- OneDrive 경로라 `build/` 폴더 삭제가 자주 잠김 → 빌드 실패 시 `rm -rf build`(또는 하위 폴더) 후 재시도.
- `flutter analyze`는 비ASCII 경로 때문에 analysis server가 크래시 → 컴파일 검증은 `flutter test`로 대체.
- 레포 루트의 사업계획서 PDF·외주계약서 docx는 의도적으로 git 미추적 상태.
