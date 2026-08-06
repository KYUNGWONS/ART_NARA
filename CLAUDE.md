# CLAUDE.md — ART NARA

미대생 미술품 거래 플랫폼. 원격: https://github.com/KYUNGWONS/ART_NARA (master에 직접 커밋·푸시).
기능 명세 원천은 레포 루트의 사업계획서 PDF(ART NARA_...pdf): 3탭(구매/판매/제작의뢰) + 경매, 지도 집 주변 매칭, QR 소유권 인증, 디지털 소유권. **블록체인 없음, 배송 없음** (사용자 확정).

## 역할·품질 기준 (이 프로젝트 ART_NARA 에서만 적용)

> 이 파일은 ART_NARA 레포에서만 로드되므로, 아래 지시는 다른 프로젝트에 영향을 주지 않는다.

- **역할**: 너는 시니어 Flutter 개발자이자 시니어 Spring 개발자이며, 고급 보안 지식(OWASP, 인증/인가, 입력 검증)을 갖춘 고급 앱 개발자로서 작업한다.
- **품질 기준**: 모든 코드 구현은 100점 만점에 **90점 이상** 수준이어야 한다. 커밋 전에 스스로 검토해서 다음을 만족하지 못하면 고치고 나서 커밋한다:
  - 정확성: 테스트(`flutter test`/`./gradlew test`) 통과 + 경계/실패 케이스 처리
  - 보안: 인증·인가 확인(대상은 JWT 신원에서, 남의 리소스 접근 차단), 입력 검증, 비밀키·토큰 하드코딩 금지(local.properties/환경변수), 민감정보 로그 금지
  - 성능/부하: 불필요한 N+1·전체 로드 금지, 목록은 필요한 필드만 내려주기, 무거운 작업은 비동기/스케줄러로, 클라이언트는 불필요한 리빌드·중복 요청 방지 — **가벼우면서 퀄리티 높게**. 트래픽 분산이 필요한 지점(이미지 서빙, 조회 API)은 캐시 헤더·페이징 등 확장 가능한 구조를 우선한다.
  - 가독성: 기존 코드 스타일·토큰(ArtColors 등) 준수, 의도가 드러나는 주석
- **디자인 기준**: 새 화면/와이어프레임은 **Figma 파일 `ZqY7Mo7424n3gMp5kZJ4AZ`("26.07.29 1-6")의 색감·형태를 기준**으로 구성한다. 색은 `art_tokens.dart` 토큰만 사용하고, 새 와이어프레임을 그릴 때도 이 파일의 레이아웃 문법(헤더 한 줄, 6탭 내비, 카드/칩 형태)을 따른다.
- **자율 진행**: 사용자가 멈추라고 하기 전까지 **묻지 말고 알아서 끝까지 진행**한다. 애매한 지점은 합리적으로 판단해 구현하고 멈추지 않는다. 단, **작업이 끝나면 채팅 보고에 "헷갈렸지만 이렇게 판단해서 구현했다" 항목을 반드시 명시**한다(판단 근거 1줄씩). 사용자가 보고를 보고 뒤집으면 그때 수정한다.

## 구조

- `frontend/` — Flutter 앱 (상세 규칙은 frontend/CLAUDE.md). 하단 탭: 홈/판매/지도/제작의뢰/채팅.
- `backend/` — Spring Boot 3, 패키지 `com.example.artnara`, H2(dev)/JPA.

## 디자인 시스템

- Figma Foundations 파일( `LghoZTZPejVsF7jndmqJEm`, node `25:210`)에서 추출한 토큰을 `frontend/lib/constants/art_tokens.dart`에 정의해 둠. **새 화면은 하드코딩 대신 이 토큰 사용.**
  - 브랜드: teal `#07524E` / deep `#084742` (네이비 아님)
  - 배경: canvas ivory `#F8F3E8`, surface `#FEFCF7`, subtle `#F0EBE3`
  - 텍스트: primary `#141413`, secondary `#6B665E`, on-brand `#FFFFFF`, 테두리 `#E0DBD1`
  - 타이포: Noto Sans KR — Heading 28 Bold / Section 22 Bold / Body 16 Regular / Caption 12 Regular
  - Spacing 8·12·16·24, Radius 8·14·22·Full
- 워드마크는 `widgets/artnara_wordmark.dart`(ART·NARA 텍스트 + 오렌지 점)로 그린다. Figma 워드마크 PNG 는 옛 브랜드명이라 삭제했다. 배경은 `assets/images/splash_bg.jpg` 유지.
- 브랜드 표기는 **ART NARA 로 통일**(2026-08-02 확정). **2026-08-06 사용자 지시로 내부 식별자까지 전부 개명**: `dust_tokens.dart`→`art_tokens.dart`, `DustColors/DustText/DustSpacing/DustRadius`→`ArtColors/ArtText/ArtSpacing/ArtRadius`, `dust_splash_bg.jpg`→`splash_bg.jpg`, 인증서 씰 `DA`→`AN`, MCP 서버 `figma-dustart`→`figma`, 토큰 env `FIGMA_DUSTART_TOKEN`→`FIGMA_TOKEN`. **레포에 DUST 문자열은 남아 있지 않다** — 새 코드에도 쓰지 말 것.
- 주요 화면 node id: 스플래시/온보딩 `1:309`, 홈 피드 `1:325`·`1:437`, 작품 판매 등록 `1:274`, 제작 의뢰 신청 `23:67`, 작가 포트폴리오 `41:850`, 소유권 인증서(구 정품 인증서) `50:1034`·`60:302`.
- **최신 디자인 리비전: 파일 `ZqY7Mo7424n3gMp5kZJ4AZ`("26.07.29 1-6")** — 프레임 8개(작가 포트폴리오 `1:278`, 제작 의뢰 신청 `1:349`, 홈 피드2 `1:443`, 홈 피드1 `1:549`, 작품 판매 등록 `1:654`, 스플래시/온보딩 `1:722`, 정품 인증서1 `1:737`, 정품 인증서2 `1:806`). 이 리비전에서 바뀐 점:
  - **하단 내비가 6탭**(홈·판매·지도·제작의뢰·**알림**·**마이페이지**)이고 채팅 탭이 없다 → 채팅(작품 문의)은 홈 헤더 좌측 햄버거 서랍으로 이동.
  - 헤더는 `메뉴(햄버거) · 화면 제목 · 알림 벨` 한 줄. 화면 제목은 헤더에서만 그린다(본문 중복 금지).
  - 인증서 항목: 작품 제목·작가·**제작 연도·크기·재료**·고유 인증 ID.
  - 판매 등록 스텝은 디자인상 5개(…·배송 정보·등록 완료)지만 **배송이 없으므로 4스텝**(작품 정보·상세 정보·가격 설정·등록 완료)으로 운영.
  - 색은 Foundations 토큰과 사실상 동일(브랜드 teal 미세 차이 `#0A3C36`) — `ArtColors` 유지.
- 디자인 반영 현황(2026-07-31): 스플래시·로그인·홈 피드(칩 필터=백엔드 category 연동)·하단 내비(홈/판매/지도/제작의뢰/채팅)·판매 등록(4스텝 위저드) 완료. 전 화면 색상은 ArtColors 토큰으로 통일됨. 제작 의뢰(23:67 멀티칩+안내박스)·정품 인증서(50:1034 골드 프레임 카드)도 완료. 작가 포트폴리오(41:850)도 완료(`GET /api/artists/{작가명}` + artist_portfolio_screen, 홈 피드 작가 리스트·작품 상세 작가 카드에서 진입). **디자인 6화면 전부 반영 완료.** 렌더 이미지는 Figma REST `/v1/images`로 받는다(MCP는 호출 제한 있음).
- 코드베이스는 Knot/UniTrip(여행 매칭 앱)에서 가져와 리네임한 것. 프론트 화면 잔재는 2026-07-31 정리 완료(랜딩/여행 온보딩/브랜드 화면 삭제, 역할=작가·컬렉터, 프로필 설정 아트나라화, 마이페이지 여행 필드 제거). 백엔드 여행 도메인도 2026-07-31 정리: booking/festival/magazine/notification/wishlist/brand 삭제 완료. 2026-08-01 지도 탭을 아트나라 전용(작품 마커 + /api/artworks/nearby)으로 재편하면서 content·recommendation·map 도메인, 프론트 여행 화면·서비스(tour_api, content_api, mate_match 등)도 삭제 완료. 2026-08-02 여행 잔재 정리 마무리: User 의 travelStyle·languages·district·matchingEnabled 및 TravelStyle/District 엔티티 삭제, 시드(test.sql)를 작가/컬렉터·장르·작품 문의 대화로 교체, 채팅 목록·상세를 실제 API + ART NARA 로 재작성(프론트의 임시 Node WebSocket 서버 `frontend/server/` 삭제). 2026-08-02 2차: VerificationType 을 UNIVERSITY 만 남기고, 프론트의 참조 없는 여행 트리(커뮤니티 게시판·약속 달력·메이트 스토리·관광공사 모델·여행 콘텐츠 옵션)와 미사용 i18n 문자열 138개를 삭제. **여행 잔재 정리 완료.**

## 작업 규칙 (사용자 요구)

- 기능 하나마다 **frontend / backend 커밋을 분리**해서 만들고 origin/master로 푸시. 커밋 메시지는 `feat(backend): ...` / `feat(frontend): ...` 형식.
- 커밋 전 검증: 프론트 `flutter test`(flutter는 `C:\Users\worms\dev\flutter\bin\flutter.bat`), 백엔드 `./gradlew test`(JDK 17 — Java 21 API 금지).
- **새 화면 디자인이 필요하면 Figma "Manyfast Wireframe to Figma (커뮤니티)" 파일에 먼저 그린 뒤 구현할 것.**
- Figma 계정은 **lcm97@jnu.ac.kr**(아트나라 전용). 토큰은 git 미추적 파일 `.claude/settings.local.json`의 `env.FIGMA_TOKEN`에 보관 — **절대 커밋 금지**.
- **디자인 읽기는 Figma REST API로** 한다 (PAT 사용, 검증됨): `curl -H "X-Figma-Token: $TOKEN" https://api.figma.com/v1/files/{fileKey}` / 렌더 이미지는 `/v1/images/{fileKey}?ids=`. PAT는 REST 전용이고 **원격 MCP 엔드포인트는 OAuth(scope mcp:connect)만 받으므로 PAT로는 연결 불가**.
- 디자인 *생성/수정*(Manyfast 파일에 새 화면 그리기)이 필요하면 대화형 터미널에서 `/mcp`로 `figma` OAuth 인증 필요. 이 인증은 로컬에 저장되며 claude.ai 계정 커넥터와 무관.
- 파일 키: 디자인 원본 `LghoZTZPejVsF7jndmqJEm`, Manyfast 와이어프레임 `PEgRT86N0VTa1bXgTruP4S`.
- **계정 연동형 Figma 커넥터는 다른 프로젝트(Knot) 소속이므로 이 레포에서 사용 금지** — 아트나라 정보가 그 계정에 남으면 안 됨.
- 같은 이유로 아트나라 컨텍스트는 계정 메모리에 저장하지 말고 이 파일(CLAUDE.md)에 기록할 것.

## 토큰 절약 규칙 (기본값)

- **에뮬레이터 검증·스크린샷은 사용자가 요청할 때만.** 평소 검증은 `flutter test` / `./gradlew test` / API `curl` 로 끝낸다. 스크린샷은 토큰이 가장 비싸다 — 한 작업당 1장 이내, 필요 없으면 0장.
- 화면 변경을 눈으로 확인해야 하면 **마지막에 한 번만** 찍고, 중간 단계는 찍지 않는다.
- 파일은 통째로 읽지 말고 `grep`/부분 읽기로 필요한 구간만 본다. 이미 읽은 파일은 다시 읽지 않는다.
- 빌드·테스트 출력은 `| tail -3` 처럼 잘라서 본다.
- 로그인→프로필→메인 전체 플로우 재현은 금지. 필요하면 JWT 를 직접 만들어(`jwt.secret` 사용) API 로 검증한다.
- 보고는 짧게: 무엇을 고쳤고 어떻게 확인했는지 3~5줄. 코드 전문 붙여넣기 금지.
- 답이 이미 정해진 질문(선택지가 명백한 것)은 묻지 말고 진행한다.

## 백엔드 컨벤션

- 아트나라 도메인은 JPA 전환 완료: 엔티티 Artwork/ArtworkBid/Sale/Commission/CommissionOffer/Ownership/ArtOrder(테이블 `art_orders` — order는 예약어).
- 시드는 `ArtnaraDataInitializer`(CommandLineRunner) — test 프로필은 sql init을 안 돌리므로 시드는 반드시 이 러너에. **작품 id 1~8 순서는 ArtworkService의 위치 mock(LOCATIONS)과 결합되어 있으므로 유지할 것.**
- 서비스 테스트는 `@IntegrationTest`(@SpringBootTest + @Transactional + test 프로필).
- **보안 기본값: 조회(GET)만 공개, 나머지 메서드는 로그인 필수.** 새 조회 API 는 `SecurityConstant.PUBLIC_READ_URLS`, 메서드 무관 공개가 필요하면 `PUBLIC_ANY_METHOD_URLS`(현재 QR 검증만). 프론트 쓰기 호출은 `services/api_headers.dart` 의 `authJsonHeaders()`/`authOnlyHeaders()` 만 쓴다.
- **거래 주체는 JWT 신원에서 결정**(`global/auth/CurrentUser`): 입찰자·구매자·판매자·인증서 소유자 모두 로그인 사용자의 활동명. 낙찰 여부도 서버가 계산해 `ArtworkDetailDto.wonByViewer` 로 내려준다 — 클라이언트가 이름을 비교하지 않는다.
- 이미지(`/images/**`, `/artworks/**`)는 `Cache-Control: max-age=30d, public`. 알림 목록 100건·대화 내역 200건 상한.
- 경매: `Artwork.auctionEndAt` 기준 `AuctionScheduler`가 1분 주기 자동 마감, remainingTime은 동적 계산("D-n"/"HH:mm:ss"). 낙찰자("나")만 낙찰가로 `/api/orders` 결제 가능.
- 주문: 결제수단만 받음(CARD/KAKAO_PAY/NAVER_PAY/TOSS, mock PG). 결제 완료 시 디지털 소유권 + QR 인증서(Certificate 엔티티, `ARTNARA-QR-xxxx`) 자동 발급 — 마이페이지 QR 스캔으로 즉시 조회 가능.
- 채팅: STOMP `/ws`(네이티브 + SockJS 둘 다 등록). 대화 내역은 `GET /api/chat/rooms/{roomId}/messages`(참여자만), 실시간은 `/topic/chat/{roomId}` 구독 + `/app/chat/send`. 목록 `GET /api/chat/rooms/my` 는 상대 프로필·마지막 메시지를 포함하며 대상은 JWT 신원으로 결정된다.
- 이미지: `POST /api/images` multipart → `/images/{파일명}` 정적 서빙, 저장 위치 `app.upload-dir`(기본 uploads/, gitignore됨).
- **에러가 401 로 둔갑하는 함정**: 컨트롤러 예외 → 서블릿이 `/error` 로 ERROR 디스패치 → `JwtAuthenticationFilter`(OncePerRequestFilter 는 ERROR 디스패치를 건너뜀)가 안 돌아 SecurityContext 가 비어 401 빈 응답이 나갔다. `/error` 를 `SecurityConstant.ERROR_URLS` 로 열어 해결(2026-08-01). **401 빈 본문이 보이면 인증이 아니라 서버 예외를 의심할 것.**
- `Sido`(시·도) enum 은 `@JsonCreator`/`@JsonValue` 로 한글 라벨("서울특별시")을 주고받는다. DB 에는 enum 이름(SEOUL)이 저장된다.

## 2026-08-02 추가된 기능 (디자인 리비전 반영 중 발견한 공백들)

- **알림 도메인**(백엔드 `domain/notification`): 의뢰 등록·작가 제안·경매 마감·결제 완료가 알림으로 쌓인다. 앱은 알림 탭 + 헤더 벨 배지, 탭하면 해당 화면으로 이동. 프로토타입 도메인이 사용자 스코프가 없어 그쪽 알림은 `userId=null`(시스템 알림)로 저장한다.
- **관심 작품(하트)**: `ArtworkLike` + `POST /api/artworks/{id}/like`(토글) + `GET /api/artworks/liked`. 홈 피드는 로그인 사용자의 하트 상태를 채워 내려주고, 마이페이지 > 관심 작품에서 모아 본다.
- **작품 문의 채팅**: `POST /api/chat/rooms/direct {opponentNickname}` 로 작가와 1:1 방을 열고(있으면 재사용) 채팅으로 진입. 작품 상세·홈 피드 작가 리스트·작가 포트폴리오의 '문의하기'가 모두 이 경로(`utils/artist_inquiry.dart`).
- **역경매 제안 UI**: 의뢰 카드의 '제안하기' → 금액·메시지 시트 → `POST /api/commissions/{id}/offers`.
- **지도 폴백**: 지도 SDK 초기화가 실패하면 같은 `/api/artworks/nearby` 결과를 거리순 목록으로 보여준다(지도 탭이 죽지 않는다).
- 인증서에 제작 연도·크기·재료가 새겨진다(결제 시 작품 사양을 그대로 복사).
- **리뷰 도메인**(2026-08-02): `POST /api/artworks/{id}/reviews`(구매자만·작품당 1회·별점 1~5), `GET /api/artists/{name}/reviews`(최신 100건+평균). 포트폴리오 평점/리뷰 수는 실제 집계. 주문에 buyerId/buyerName 저장(자격 확인용). 프론트: 포트폴리오 리뷰 탭 + 주문 내역 '리뷰 쓰기' 시트.
- **토큰 재발급·자동 로그인**(2026-08-02): `POST /auth/refresh`(회전 발급, 만료·위조·탈퇴 401). 프론트는 flutter_secure_storage 에 JWT 쌍을 저장하고 스플래시에서 자동 로그인(완료→메인, 미완료→역할 선택). 401 이면 저장 토큰 폐기, 네트워크 오류면 유지.
- **페이징**(2026-08-02): 홈 피드 섹션당 20건 상한. `GET /api/artworks?page=&size=&category=`(최신순, size 1~50 클램프) + '더보기' 무한 스크롤 화면.

## 디자인 커버리지 (2026-08-02 점검)

- **디자인 파일(26.07.29) 8프레임은 전부 구현 완료.** 차이 나는 부분은 의도된 결정: 배송 스텝 제외(4스텝), 채팅은 서랍으로, 시드 검색어·카테고리 칩은 백엔드 연동.
- **디자인 없이 구현했던 화면들의 와이어프레임을 Manyfast 파일(`PEgRT86N0VTa1bXgTruP4S`) > "추가 화면 와이어프레임 (2026-08-02)" 페이지에 사후 작성**: 작품 상세(`22:3`)·주문/결제(`22:4`)·알림(`25:2`)·마이페이지(`25:32`)·작품 문의 목록(`26:2`)·채팅 상세(`26:26`). 구현과 동일 구성, ART 토큰 색.
- 2026-08-03 나머지 7화면도 같은 페이지에 추가: 역할 선택(`27:2`)·프로필 설정(`27:17`)·지도(`27:41`)·관심 작품(`28:2`)·주문 내역(`28:42`)·정품 인증 스캔(`28:78`)·더보기 작품 목록(`28:94`). **이제 구현된 전 화면(13개)이 와이어프레임을 갖는다.**

## QA 스위프 (2026-08-02)

API 27케이스 전건 통과: 공개 조회 6(피드·페이징·상한·상세·포트폴리오·리뷰·주변), 비로그인 쓰기 차단 4(결제·하트·리뷰·판매), 거래 3(결제·중복 409·QR 스캔 소유자/사양), 리뷰 5(작성·중복 409·미구매 403·별점 400·집계), 하트/알림/채팅 7(토글 ON/OFF·목록·알림·신원 스코프·참여 방·남의 방 403), 인증 2(재발급·만료 401). `flutter test`/`./gradlew test` 통과. 유일한 FAIL 은 시드 리뷰와 중복(409가 정답)이라 테스트 스크립트 문제였음 — 새 구매자(Emma)로 검증 시 200.

## 에뮬레이터 QA (2026-08-03) — 실기기 플로우에서 찾은 결함

앱을 실제로 띄워 카카오 로그인 → 역할 → 프로필 → 홈 피드 → 하트 → 작품 상세 → 결제 → 인증서까지 돌린 결과, **API 스위프에서 못 잡은 인가 결함 3건**을 발견해 고쳤다.

- **내 디지털 소유권에 남의 소유권이 보였다** — `Ownership` 에 소유자 컬럼이 없어 `listOwnerships()` 가 전체를 반환. 갓 가입한 계정에 시드 소유권 2건이 표시됨. → `Ownership.ownerId` 추가(구매자 JWT 신원), `findByOwnerIdOrderByIdDesc`.
- **주문 내역도 전체 반환** — `OrderService.list()` → `findByBuyerIdOrderByIdDesc(buyerId)`.
- **'내 판매 작품' 이 전체 판매 등록 목록** — `Sale` 에 판매자 컬럼이 없었다. → `Sale.sellerId` 추가, `findBySellerIdOrderByIdDesc`.
- 위 3개 경로(`/api/certificates`, `/api/orders`, `/api/sales`)는 `PUBLIC_READ_URLS` 에서 제외했다. **QR 검증(`/api/certificates/scan`)만 공개 유지** — 누구나 소유권 이력 확인이 가능해야 하므로.
- **로그인 버튼 아이콘을 네트워크에서 받고 있었다**(google favicon / kakao CDN) — 받아오기 전까지 버튼이 빈 칸으로 렌더되는 걸 실측. 로컬 Material 글리프로 교체.
- 교훈: **목록 API 는 "내 것"인지 "공개 마켓"인지 먼저 정하고, "내 것"이면 예외 없이 JWT 신원으로 스코프한다.** 공개가 맞는 목록은 `/api/artworks`(피드)와 `/api/commissions`(작가가 제안하려면 남의 의뢰를 봐야 함) 뿐이다.
- 환경 메모: 에뮬레이터가 Impeller GLES 로 렌더링하다 가끔 검은 화면으로 멈춘다(앱 결함 아님, 재시작으로 해소). `adb shell input keyevent 111`(ESC)은 Flutter 에서 뒤로가기로 먹으니 키보드 닫기에 쓰지 말 것.
- **AVD 이름은 `art_nara`** (2026-08-05 `knot_pixel` 에서 개명 — `avdmanager move avd -n <old> -r art_nara`, 에뮬레이터를 끈 상태에서 실행). 실행: `emulator -avd art_nara`. `knot_pixel2` 는 Knot 프로젝트 것이라 그대로 뒀다.

## 판매 완료 상태 (2026-08-04)

- `Artwork.sold` 컬럼 + `markSold()`. `OrderService.create` 가 결제 확정 시 잠근다. **주문 테이블을 매 카드마다 조회하면 목록에서 N+1 이 되므로 작품에 상태로 들고 있는다.**
- 응답에 `sold` 를 실어 내린다: `ArtworkDetailDto`(상세·더보기 목록·관심 작품), `HomeFeedDto.Artwork`(피드). 프론트 모델은 없으면 `false` 로 읽는다(구버전 응답 호환).
- 표시: 피드/더보기 카드는 썸네일 위에 딤 + '판매 완료' 칩(`widgets/sold_overlay.dart` 공용), 관심 작품은 부제에 ` · 판매 완료`, 작품 상세는 구매 바 대신 '판매 완료된 작품입니다' 안내(`_ClosedBar(message:)` 재사용).
- 서버 가드는 그대로 유지: `sold || existsByArtworkId` → 409. UI 가 막혀도 서버가 최종 판단한다.
- 회귀 테스트: `frontend/test/sold_state_test.dart`(JSON 파싱 3 + 오버레이 렌더 1), 백엔드 `createMarksArtworkSold`.

## QA 스위프 (2026-08-04) — 28케이스 전건 통과

판매 완료 8(판매 전/후 상세·피드·목록·관심, 타 작품 무영향, 재구매 409), 인가 7(소유권·주문·판매 비로그인 401, QR 공개 200, 소유권/주문 신원 스코프), 리뷰 4(작성·중복 409·미구매 403·별점 400), 기타 9(피드 공개, size 클램프, 비로그인 결제·하트 401, 하트 토글, 만료 토큰 401, 주변 작품, 포트폴리오, 작가 리뷰). `flutter test` 5건 / `./gradlew test` 통과.

## 정리·회귀 QA (2026-08-05)

- **오프라인 mock 폴백 제거**: `getChatRooms()` 가 실패 시 가짜 대화 3건, `getMe()` 가 가짜 프로필(가짜 userId 가 `AuthApiService.userId` 에 캐시되어 채팅 senderId 오염 위험)을 반환하던 것을 빈 목록/null 로 교체. 낡은 TODO 주석 2건(카테고리 필터·여행 필드)도 실상에 맞게 수정. `_OrderCard` 외 dispose 순서 결함 1건(commission_screen, super.dispose 가 컨트롤러 해제보다 먼저) 수정.
- **회귀 스위프**: 공개 조회 9 + 인가 6 + 채팅 4(신원 스코프·문의 방 열기) + 스코프 3 + 알림 1 = 전건 통과. 제작 의뢰(등록→제안→역경매 위반 422→알림) / 경매(증분 미달 422→입찰→마감→비낙찰자 403→낙찰 결제→sold 잠금) 전 구간 통과. 에뮬레이터에서 채팅 STOMP 왕복(전송→에코→말풍선)·서랍 채팅 목록(서버 데이터만 표시) 실측 확인.
- 참고: 의뢰 등록 API 필드는 `{title, description, category, budget, desiredDate, referenceImageUrl}` — budgetMin/Max 가 아니다(QA 스크립트에서 한 번 헛디딤).

## 2026-08-05 오후 작업

- **용어 확정: 서비스에 '정품 인증' 개념은 없다 — 전부 '소유권 인증'(사용자 확정).** 프론트 화면 문구·백엔드 메시지/스웨거·인증서 note 를 일괄 교체했다(12파일). API 경로(`/api/certificates/**`)와 클래스명(Certificate 등)은 내부 식별자라 유지.
- **경매 남은 시간 실시간 카운트다운**: `widgets/auction_countdown.dart` — 서버의 remainingTime("HH:mm:ss")을 받은 시점부터 **로컬에서 1초씩 감소**(매초 서버 폴링 없음, 트래픽 0). "D-n" 은 정적 표시. 0 도달 시 onExpired 1회 호출 — 작품 상세는 이때 재조회해 마감 상태(낙찰자·결제 버튼)를 자동 반영한다. 홈 피드 카드·더보기 목록·작품 상세 3곳 적용, 위젯 테스트 4건(1초 감소·onExpired 1회·D-n 정적·null).
  - 테스트 주의: 위젯 테스트의 가상 시간(pump)은 `DateTime.now()` 를 움직이지 않는다 — 카운트다운을 벽시계 기준으로 짜면 테스트 불가라 틱 기반 감소로 구현했다.
- HH:mm:ss 는 마감 24시간 이내에만 내려온다(그 전엔 D-n). 판매 등록의 경매 마감은 날짜 단위(다음 날 이후만 허용)라 등록 직후엔 항상 D-n 이다.

## 에뮬레이터 전 기능 점검 (2026-08-05 심야) — 결함 0건

작가 계정으로 재가입해 앱 화면에서 직접 완주. 전부 통과:

- **카운트다운 실측**: 피드 00:47:24 → 6초 뒤 00:47:18 (정확히 1초/초 감소), D-n 은 정적. 상세 화면도 틱 + '소유권 인증: QR 소유권 인증 발급' 표기 확인.
- **입찰**: 기억의 조각 20만 입찰 → 현재가·입찰자(경원=JWT 신원) 반영.
- **판매 등록 4스텝**: 필수값 검증 스낵바 → 등록 완료 → '내 판매 작품' 에 내 것만 → 공개 피드·지도 목록에 즉시 노출.
- **역경매**: 제안 시트에서 45만(최저가 위반) → 서버 거절(저장 안 됨), 35만 → 최저가 등록 + 의뢰인 알림 실시간 발행.
- **알림 탭**: 미읽음 배지, 새 소유권 인증서 문구(ARTNARA-2026-0001) 반영.
- **마이페이지/소유권 인증**: '소유권 인증서 · 디지털 소유권' 메뉴, QR 수동 입력 → 골드 카드 '─ 소유권 인증서 ─'(소유자 Andrew) — rename 전면 반영.
- **지도 폴백**: 새 등록 작품·갱신된 현재가가 거리순 목록에 반영.
- QA 조작 팁: 시트가 떠 있을 때 `input keyevent 111` 은 시트를 닫는다(뒤로가기 취급). 시트 안 입력은 키보드를 닫지 말고 좌표 탭으로 진행할 것.

## 개발 DB 영속화 (2026-08-05)

- dev 기본 DB 를 **H2 파일 모드**(`~/artnara-db/artnara`, `ddl-auto: update`)로 전환 — **서버를 재시작해도 계정·거래·소유권이 유지된다**(재로그인 지옥 종료). 검증: 판매·결제·소유권·sold 플래그 재시작 후 생존 + 시드 중복 없음.
- DB 파일을 레포 밖(사용자 홈)에 두는 이유: 레포는 OneDrive 동기화 경로라 동기화가 파일을 잠가 DB 가 깨질 수 있다.
- 시드는 영속 DB 와 공존: `test.sql` 은 INSERT IGNORE, `ArtnaraDataInitializer` 는 count()>0 가드라 재부팅마다 중복되지 않는다.
- **MySQL 전환은 환경변수만으로 가능**: `DB_URL=jdbc:mysql://localhost:3306/artnara DB_DRIVER=com.mysql.cj.jdbc.Driver DB_USERNAME=... DB_PASSWORD=... DDL_AUTO=update`. 이 PC 에 MySQL 8.0 이 설치·구동 중이지만 root 비밀번호를 몰라 연결하지 못했다 — 비밀번호를 받으면 artnara 스키마·전용 계정 생성까지 진행할 것.
- 데이터를 초기화하고 싶으면: 서버 중지 → `~/artnara-db` 폴더 삭제 → 재시작(시드 재생성).
- 테스트 프로필은 여전히 인메모리(격리) — `./gradlew test` 는 영구 DB 를 건드리지 않는다.

## 역할 전환 (2026-08-05)

- 가입 후에도 **작가 ↔ 컬렉터 전환 가능**. 마이페이지의 역할 배지(⇄ 아이콘)를 탭 → 확인 다이얼로그 → 즉시 반영.
- `PATCH /api/users/me` 가 `userType` 을 받는다(**보내지 않으면 기존 역할 유지** — 부분 수정 원칙). `User.updateProfile(..., userType)`, 프론트는 `UserApiService.changeRole()`.
- 전환해도 **등록한 작품·주문·소유권은 그대로** 유지된다(역할은 화면 구성만 바꾼다).
- 테스트: 엔티티 2건(역할 미전송 시 유지 / 전환), 서비스 1건(updateUserType).

## 관리자 콘솔 (2026-08-06)

- **별도 레포**: https://github.com/KYUNGWONS/ART_NARA_ADMIN — 빌드 도구 없는 정적 웹(HTML + ES 모듈). `python -m http.server 5500` 로 띄우고 로그인 화면에서 백엔드 주소를 지정한다(`localStorage: artnara.apiBase`).
- **계정**: `ADMIN` / 초기 비밀번호 `ADMIN`. `admin_accounts` 테이블(앱 `users` 와 분리), BCrypt 해시 저장, 첫 로그인 시 변경 유도(`mustChangePassword`). 부팅 때 `AdminAuthService.ensureDefaultAdmin` 이 없으면 만든다.
- **권한 격리**: 관리자 토큰은 `ROLE_ADMIN`, 앱 토큰은 `ROLE_USER`. `/api/admin/**` 는 `hasRole("ADMIN")`, 그 외 인증 경로는 `hasRole("USER")` — **서로의 API 를 호출할 수 없다**(예전엔 `authenticated()` 라 관리자 토큰이 회원 id 1 로 동작했다).
- **기능**: 대시보드(총/오늘/이번달 매출·환불액·주문/회원/작품 수·14일 매출 그래프·상위 작가), 회원 관리(검색·차단/해제), 주문·환불(검색·환불).
- **연동 규칙**: 매출은 **환불 건 제외**. 회원 차단 시 앱 로그인·토큰 재발급이 `USER_403_BLOCKED` 로 막힌다. 환불하면 `Artwork.sold` 잠금이 풀려 다시 판매된다.
- **함정(해결됨)**: `ddl-auto: update` 는 **기존 행이 있는 테이블에 기본값 없는 NOT NULL 컬럼을 추가하지 못한다** — sold/refunded/blocked 가 조용히 누락돼 관리자 조회가 전부 500 이었다. `@Column(columnDefinition = "boolean default false")` 로 해결. 새 boolean 컬럼을 추가할 땐 항상 DB 기본값을 함께 줄 것.
- 예상 못 한 예외는 이제 `GlobalExceptionHandler.handleUnexpected` 가 스택을 로그로 남긴다(예전엔 빈 500 이라 원인 추적 불가).

## 관리자 콘솔 QA (2026-08-06) — 전 화면 점검

- **앱↔관리자 연동 실측**: 앱에서 토스페이 결제 → 관리자 대시보드/주문에 즉시 반영(구매자·결제수단까지) → 관리자 환불 → **앱 피드에서 판매 잠금 해제 확인** → 관리자 차단 → 앱 재실행 시 `자동 로그인 실패: 403` → 해제 후 복구. 전 구간 통과.
- **화면 점검**: 로그인(실패 메시지·네트워크 오류 안내·백엔드 주소 변경), 대시보드(지표·그래프·상위 작가), 회원(닉네임/이메일 검색·차단/해제·결과 없음), 주문(작가/작품 검색·환불·중복 방지), 비밀번호 변경(불일치·현재 비번 오류), 로그아웃/재로그인 — 전부 정상.
- **디자인 정렬**: `art_tokens.dart` 값을 CSS 변수로 그대로 옮김(teal·ivory·danger #b3261e·success=teal, radius 8/14/22/full, spacing 8/12/16/24). CTA·내비·검색바는 pill, 위험 버튼은 채움 대신 아웃라인(앱에 채운 빨강 버튼이 없다).
- **고친 것**: 구간 매출이 0이면 막대가 전부 2px 로 그려져 깨진 화면처럼 보였다 → 안내 문구로 대체.
- 태블릿(768px)에서도 표가 영역 안에 들어가고 패널이 세로로 접힌다(가로 스크롤 없음).

## 실 결제 연동 — 토스페이먼츠 (2026-08-06)

- **계약 없이 실제 PG 연동이 된다**: 토스 공개 문서 테스트 키(`test_gck_docs_...` / `test_gsk_docs_...`)로 결제 전 과정을 실제 API 로 돌려볼 수 있다(돈은 안 빠진다).
- **켜는 법**: `TOSS_SECRET_KEY=test_gsk_docs_OaPz8L5KdmQXkzRz3y47BMw6 ./gradlew bootRun`. 안 주면 시크릿 키가 비어 mock 결제로 동작한다(`TossPaymentClient.isEnabled()`).
- **흐름**: 앱이 `GET /api/payments/config` 로 실 PG 여부를 확인 → 켜져 있으면 `TossPaymentScreen`(WebView + `assets/toss_checkout.html` 결제위젯) → 결제 완료 시 토스가 `https://artnara.app/payment/success` 로 이동하는 걸 NavigationDelegate 가 가로채 paymentKey 획득 → `POST /api/orders` 에 실어 보내면 **서버가 `/v1/payments/confirm` 으로 승인**.
- **보안 원칙**: 승인은 반드시 서버에서. 토스가 확정한 금액과 주문 금액이 다르면 `PAYMENT_422` 로 거절한다(클라이언트 금액 위조 차단). 실측: 위조 paymentKey → 402 + 주문 미생성 + 작품 판매잠금 안 걸림.
- **환불**: 주문에 paymentKey 가 있으면 관리자 환불이 토스 취소를 **먼저** 호출하고 성공해야 환불 상태로 바꾼다(PG 와 장부가 어긋나지 않게).
- 운영 전환은 가맹 계약 후 `TOSS_SECRET_KEY`/`TOSS_CLIENT_KEY` 만 교체하면 된다. successUrl 인터셉트 주소(`artnara.app`)는 실제 도메인이 아니라 WebView 가 가로채는 용도라 그대로 둬도 된다.

## 실 PG(토스) 결제 실측 (2026-08-06 심야)

에뮬레이터에서 **실제 토스 결제위젯 → 샌드박스 승인 → 서버 confirm → 소유권 인증서 발급 → 관리자 환불 → 토스 취소**까지 전 구간 왕복 확인. `TOSS_SECRET_KEY=test_gsk_docs_...` 로 백엔드를 띄우면 `GET /api/payments/config` 가 enabled=true 를 내리고 앱이 결제창을 띄운다.

- 결제 성공 로그: successUrl `…paymentKey=tgen_2026…&amount=180000` → 서버 승인 → 인증서 `ARTNARA-2026-102` 발급. 관리자 주문 목록에 즉시 반영.
- 환불: `POST /api/admin/orders/{id}/refund` → 토스 `GET /v1/payments/{paymentKey}` 조회 결과 **status CANCELED, balanceAmount 0, 사유 그대로** + `Artwork.sold` 해제(앱 상세가 다시 '구매하기'로 복귀).
- **고친 것 2가지**:
  - `loadFlutterAsset('assets/toss_checkout.html?...')` 은 쿼리스트링을 붙이면 **에셋 키를 통째로 찾아 실패**한다(Asset for key ... not found). → 에셋을 문자열로 읽어 `/*__PAYMENT_CONFIG__*/` 자리에 `window.__ARTNARA_PAYMENT__` 를 심고 `loadHtmlString(baseUrl: 'https://artnara.app/checkout')` 로 로드. baseUrl 을 success/fail URL 과 같은 오리진으로 둬야 리다이렉트를 가로챌 수 있다.
  - 카드 결제는 카드사 앱카드로 넘어가며 `intent://…kb-acp://…` 스킴을 던지는데 WebView 가 `ERR_UNKNOWN_URL_SCHEME` 로 죽었다. → http 가 아닌 스킴은 `url_launcher` 로 외부 앱 실행, 실패 시 `S.browser_fallback_url` → `market://details?id=패키지` 순으로 폴백(매니페스트 `<queries>` 에 VIEW/https·market 추가). **에뮬레이터엔 카드사 앱이 없어 이 경로는 실기기 확인이 남아 있다.**
- 위젯 테스트용 경로: 카드 대신 **퀵계좌이체**를 고르면 웹 안에서 끝난다(테스트 비밀번호 000000). 카드사를 안 고르고 결제하면 위젯이 "카드 결제 정보를 선택해주세요" 로 거절한다.
- 복수 카테고리 의뢰도 앱에서 실측: 회화·조각·사진 선택 → 카드에 `회화 · 조각 · 사진`, 알림 62명(카테고리별 작가 합).

## 경매 실시간 갱신 · 작가 정산 (2026-08-07)

- **입찰 실시간 반영**: 입찰·마감 시 서버가 `/topic/auction/{artworkId}` 로 `AuctionUpdateDto`(현재가·최고 입찰자·입찰 수·마감/낙찰자)를 발행한다(`AuctionBroadcaster`, 발행 실패는 로그만 — 거래를 되돌리지 않는다). 작품 상세는 **진행 중인 경매일 때만** 구독하고, 수신하면 상세를 재조회해 반영한다(부분 갱신 대신 서버 계산 결과를 그대로 씀). 실측: 앱 상세를 열어둔 채 다른 계정이 입찰 → 화면을 건드리지 않았는데 현재가 ₩780,000→₩1,200,000, 최소 입찰가도 함께 갱신.
  - WebSocket URL 헬퍼는 `constants/api_config.dart` 의 `websocketUrl` 로 옮겼다(채팅·경매 공용).
- **작가 정산**: `GET /api/settlements` — 판매 합계·수수료·정산 예정액·이번 달 판매·건별 내역. 대상은 JWT 활동명, **환불 건은 이력에만 남고 합계에서 제외**(관리자 매출 규칙과 동일). 프론트는 마이페이지 > '판매 정산'(작가일 때만 노출). 실측: 500,000 판매 → 수수료 50,000 → 정산 예정 450,000.
  - **플랫폼 수수료 10%는 내가 정한 기본값**(`SettlementService.FEE_RATE`) — 사업계획서에 요율이 없어서 판매자 부담 10%로 잡았다. 정해지면 이 상수만 바꾸면 된다.
- 함정: `bootRun` 이 포트 8080 점유로 조용히 죽고 **구버전 서버가 계속 응답**해 "코드가 반영 안 된다"로 보였다. 재기동 뒤에는 `boot.log` 의 `Started ArtNaraApplication` 을 확인할 것.

## 푸시 알림 FCM (2026-08-07) — 코드 완료, 키만 넣으면 켜짐

- 백엔드: `device_tokens` 테이블 + `POST/DELETE /api/devices`(소유자는 JWT 신원, 토큰이 고유해서 같은 기기를 다른 계정이 쓰면 소유자만 바뀐다). `NotificationService.publishTo` 가 알림을 저장한 뒤 `PushService.sendToUser` 로 푸시를 곁들인다 — **시스템 알림(userId=null)은 대상이 없어 건너뛴다.**
- `FcmClient` 는 **FCM HTTP v1**(레거시 서버 키 API 는 종료됨). 서비스 계정 JSON 으로 RS256 JWT 를 만들어 액세스 토큰을 받고 만료 1분 전까지 재사용한다. 새 의존성 없이 jjwt + java.net.http 로 구현.
- **켜는 법**: `FCM_CREDENTIALS=/경로/service-account.json ./gradlew bootRun` + 앱에 `android/app/google-services.json`(git 미추적) 배치. 둘 다 없으면 서버는 `FCM 푸시 비활성`, 앱은 `[Push] 초기화 실패 — 푸시 없이 진행합니다` 를 찍고 **앱 내 알림만으로 정상 동작**한다(실측 확인).
- **google-services.json 이 없어도 빌드가 깨지지 않게** `app/build.gradle.kts` 가 파일 존재 시에만 `com.google.gms.google-services` 를 적용한다. 파일을 넣으면 그때부터 자동으로 켜진다.
- 앱은 로그인·자동 로그인 직후 `PushService.registerDevice()` 로 토큰을 올리고, `onTokenRefresh` 도 서버에 반영한다. 알림 권한 거부는 정상 흐름으로 취급(등록만 건너뜀).
- **남은 것은 계정 작업뿐**: Firebase 프로젝트 생성 → Android 앱(`com.artnara.artnara`) 등록 → `google-services.json` 다운로드 → 서비스 계정 키 발급. 이건 사용자 구글 계정 로그인이 필요해 내가 대신 할 수 없다.
- 검증: 기기 등록 200 / 비로그인 401 / 해제 200, 서비스 테스트 4건(소유자 재할당·비활성 시 미발송·죽은 토큰 정리·시스템 알림 제외).

## HTTPS 준비 (2026-08-07)

- 앱: `usesCleartextTraffic="true"` 를 **`network_security_config.xml` 로 교체**. 평문 HTTP 는 `10.0.2.2`/`localhost`/`127.0.0.1`(개발 백엔드)에만 허용하고 그 외 도메인은 OS 가 차단한다 — 운영 주소에 실수로 http 를 써도 평문이 나가지 않는다. 실측: 에뮬레이터에서 자동 로그인·알림 조회 정상.
- 백엔드: `server.forward-headers-strategy=framework`(env `FORWARD_HEADERS`). **TLS 는 리버스 프록시(nginx 등)에서 끊는 전제** — 그러면 Spring 이 보는 스킴이 http 라서 X-Forwarded-* 를 신뢰해야 리다이렉트·절대 URL·쿠키 secure 판정이 https 기준으로 맞는다.
- 운영 전환 시 할 일: 도메인·인증서 발급(Let's Encrypt) → 프록시 설정 → 앱 빌드의 `--dart-define=API_BASE_URL=https://...` → 관리자 콘솔의 `artnara.apiBase` 도 https 로(https 페이지에서 http API 를 부르면 브라우저가 mixed content 로 막는다).

## 에뮬레이터에서 카카오맵 띄우기 (2026-08-07) — 해결

- **원인 재정의**: 문제는 "에뮬레이터라서"가 아니라 **앱 프로세스가 x86_64 라서**였다. 이 AVD 는 `ro.product.cpu.abilist = x86_64,arm64-v8a` 로 **arm64 변환을 지원**한다. 그런데 유니버설 APK 에는 x86_64 .so 가 섞여 있어(카메라/MLKit 플러그인) 안드로이드가 앱을 x86_64 로 설치하고, 그러면 arm 전용 `libK3fAndroid.so` 가 dlopen 에서 죽는다.
- **해결**: arm64 만 담은 APK 로 설치하면 앱 전체가 arm64 로 뜨고 지도 SDK 가 정상 로드된다.
  ```bash
  flutter build apk --debug --split-per-abi --target-platform android-arm64     --dart-define=API_BASE_URL=http://10.0.2.2:8080 --dart-define=KAKAO_NATIVE_APP_KEY=...
  adb uninstall com.artnara.artnara   # ABI 가 바뀌므로 재설치가 아니라 지우고 설치
  adb install build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk
  ```
  실측 로그: `libK3fAndroid.so ... ok` → `카카오 지도 SDK 초기화 성공`. (변환 실행이라 평소보다 느리다 — 기능 확인용으로만 쓸 것.)
- **가드 수정**: `main.dart` 가 `getprop ro.product.cpu.abi`(기기 속성)를 보던 것을 **`Abi.current()`(프로세스 ABI)** 로 교체했다. 기기 속성은 arm64 APK 로 설치해도 x86_64 라서 멀쩡한 환경에서 지도를 꺼버렸다.
- **네이버 지도로 바꿀 이유는 없다**: 카카오맵이 에뮬레이터에서 확인되므로, 키 두 벌 관리(로그인=카카오 / 지도=네이버)를 되살릴 필요가 없다. 네이버 SDK 의 x86_64 지원 여부는 이번에 검증하지 못했다(메이븐 저장소 응답 404).
- 릴리스(AOT) 빌드는 이 경로(OneDrive)에서 `app.dill` 을 못 읽어 실패한다 — 필요하면 레포를 OneDrive 밖으로 복사해 빌드할 것.

## 소셜 로그인: 구글 → 네이버 (2026-08-07, 사용자 지시)

- 백엔드: `NaverTokenVerifier` 추가(앱이 준 액세스 토큰으로 `https://openapi.naver.com/v1/nid/me` 조회 → `resultcode == "00"` + `response.id` 확인). **신원 확인은 서버가 한다**(카카오와 동일). `GoogleTokenVerifier` 삭제, `oauth.google.client-id` 설정 제거.
- `OAuthProvider.GOOGLE` **상수는 남겼다** — 구글로 가입한 기존 회원 행을 읽어야 하기 때문. 검증기가 없어 그 값으로는 새 로그인이 안 된다(UNSUPPORTED_PROVIDER).
- 프론트: `google_sign_in` → `flutter_naver_login`, `naver_auth_service.dart`, 로그인 버튼 '네이버로 시작하기'(N 글리프만 네이버 그린 `#03C75A`, 면적 색은 ArtColors 유지). 로그아웃 시 네이버 세션도 끊고 푸시 기기도 해제한다.
- **MainActivity 를 `FlutterFragmentActivity` 로 바꿔야 한다**(네이버 SDK 가 프래그먼트를 띄운다).
- 키: `android/local.properties` 의 `naverClientId` / `naverClientSecret` / `naverClientName`(기본 "ART NARA") → `build.gradle.kts` 가 매니페스트 메타데이터로 주입한다. **커밋 금지.** 네이버 SDK 는 규격상 클라이언트 시크릿을 앱에 요구한다.
- **남은 계정 작업**: 네이버 개발자센터에서 앱 등록(패키지 `com.artnara.artnara`) → 클라이언트 ID/시크릿 발급 → local.properties 기입. 그 전에는 버튼을 눌러도 로그인 창이 뜨지 않는다.

## 지도 줌 버튼 (2026-08-07)

- 핀치 줌은 손가락 두 개가 필요해 **에뮬레이터(마우스 1점)·한 손 조작에서는 쓸 수 없다** — SDK 문제가 아니다. 지도 우측에 확대/축소 버튼(`_ZoomButton` + `CameraUpdate.zoomIn/zoomOut`)을 달아 어느 환경에서든 줌이 되게 했다. 선택 카드가 떠 있으면 버튼이 위로 비켜난다.

## 네이버 로그인 연동 상태 (2026-08-07) — 앱은 완성, 네이버 콘솔 설정에서 막힘

- 키는 받아서 `frontend/android/local.properties` 에 넣었고(`naverClientId`/`naverClientSecret`/`naverClientName`), **로그인 창까지 정상 진입**한다(`ART_NARA_DEV 로그인 중` → 계정 로그인 → 동의 화면).
- **막힌 지점**: 동의 화면에서 '전체 동의하기' 체크 → '동의하기'(초록 활성)를 눌러도 네이버가 동의를 반려하고 같은 화면이 체크 해제된 채 다시 뜬다. SDK 로그는 콜백을 한 번 받았지만 `getDecodedString() | str : null` 로 코드가 비어 있었다.
- **가장 유력한 원인**: 동의 항목에 **휴대전화번호·이름·성별·생일·출생연도·연령대** 가 들어가 있다(화면에서 확인). 네이버는 이 민감 항목들을 **검수 승인 후에만** 제공하며, 개발 단계에서 요구하면 동의가 완료되지 않는다.
  - 조치: 네이버 개발자센터 > 내 애플리케이션 > **API 설정 > 제공 정보 선택**에서 **별명·프로필사진·이메일만 남기고** 나머지를 끄고 재시도할 것. 백엔드가 쓰는 값도 그 셋(+식별자)뿐이다(`NaverTokenVerifier`).
- 실패 경로 자체는 앱이 잘 처리한다(취소/실패 시 '로그인에 실패했어요' 스낵바, 앱 정상 동작). **카카오 로그인은 그대로 동작**하므로 서비스가 막히지는 않는다.

## 지도 마커·줌 (2026-08-07)

- 작품이 **텍스트 라벨만** 찍혀 지도의 지명과 섞여 구분되지 않았다 → 브랜드 색 **핀 아이콘을 런타임에 그려**(에셋 없이 `ArtColors` 사용) POI 에 붙였다. 핀 탭 → 하단 작품 카드 → 상세 진입까지 실측 확인.
- 좌표가 없는 신규 등록 작품이 전부 같은 기본 좌표(홍대입구)에 겹쳐 핀 하나처럼 보였다 → `ArtworkService.locationOf(id)` 가 황금각으로 150~630m 안에 흩뿌린다. **id 가 같으면 항상 같은 위치**라 새로고침해도 핀이 안 움직인다.
- 핀치 줌은 손가락 두 개가 필요해 에뮬레이터·한 손 조작에서 불가 → 우측 **줌 버튼** 추가.

## 관리자 콘솔 재점검 (2026-08-07)

- 대시보드 수치가 앱 활동과 일치(총 매출 ₩820,000 = 결제 2건, 환불 1건 ₩180,000 제외 / 회원 9 / 작품 9 중 판매완료 2).
- 회원: 검색(`query` 파라미터), 차단·해제 왕복, 주문: 검색·빈 결과 안내·환불 버튼 노출 규칙(환불 건은 버튼 없음) 정상. 중복 환불 409, 없는 주문 404.
- 비밀번호 변경: 불일치 / 현재 비밀번호 오류 모두 검증됨. 초기 비밀번호(ADMIN)면 로그인 직후 변경 모달이 뜬다. **비밀번호는 ADMIN 그대로 두었다.**
- 권한 격리 재확인: 토큰 없음 401, **앱 사용자 토큰으로 관리자 API 호출 시 403**(인증은 됐지만 권한 없음 — 정상).
- 고친 것: 좁은 화면에서 표가 눌려 읽히지 않던 것 → 패널에 가로 스크롤(`overflow-x:auto` + `min-width`). 페이지 자체는 가로 스크롤되지 않는다.

## 오류 응답 정리 (2026-08-07)

- 없는 경로 → **404**, 잘못된 메서드 → **405** 로 매핑(`GlobalExceptionHandler`). 전에는 둘 다 500 + 스택 로그라 "서버 장애"로 오인하기 쉬웠다.
- 참고: 인증이 필요한 경로에 **없는 하위 경로**를 부르면 404 가 아니라 **401** 이 난다(스프링 시큐리티가 먼저 막는다 — 경로 존재 여부를 노출하지 않는 정상 동작).

## 환불 시 소유권 회수 (2026-08-07) — 야간 QA 중 발견

- **결함**: 관리자 환불은 `Artwork.sold` 만 풀고 **구매자의 디지털 소유권·인증서를 그대로 뒀다** → 작품은 다시 팔리는데 이전 구매자도 소유권 보유(소유자 둘).
- **수정**: `Ownership.revoked` / `Certificate.revoked` 추가(둘 다 `columnDefinition = "boolean default false"`), `CertificateService.revoke(certificateNo)` 를 `AdminService.refund` 에서 호출. 기록은 지우지 않고 무효 표시만 한다.
  - '내 디지털 소유권' 목록에서 빠지고(`findByOwnerIdAndRevokedFalseOrderByIdDesc`), QR 스캔은 **"환불로 무효 처리된 인증서입니다."** 로 응답한다.
- **소급 정리**: 기능 도입 전 환불 건이 유효한 상태로 남아 있어 `RefundedOwnershipCleanup`(CommandLineRunner)이 부팅 때 한 번 정리한다. 회수는 몇 번 돌려도 결과가 같다.
- 실측: 결제(ARTNARA-2026-165) → 소유권 5건 → 환불 → 4건 + QR 스캔 무효 응답, 재부팅 후 과거 환불 건도 회수됨.

## 남은 작업 후보

- 실 결제 라이브 전환 (가맹 계약 + 키 교체만 남음 — 코드는 완료)

## 로컬 실행 (에뮬레이터)

```bash
# 1) 백엔드
cd backend && ./gradlew bootRun          # http://localhost:8080

# 2) 앱 — 에뮬레이터에서 host 백엔드는 10.0.2.2 로 접근해야 한다
cd frontend && flutter run -d emulator-5554   --dart-define=API_BASE_URL=http://10.0.2.2:8080   --dart-define=KAKAO_NATIVE_APP_KEY=...
```

- **지도는 카카오맵 SDK(`kakao_map_sdk`)로 2026-08-05 전환** — 로그인과 같은 `KAKAO_NATIVE_APP_KEY` 하나로 로그인+지도를 다 처리한다(네이버 지도·NAVER_MAP_CLIENT_ID 제거, 키 두 벌 관리 종료). **주의: 카카오맵 네이티브(libK3fAndroid.so)는 arm 전용이라 x86_64 에뮬레이터에서 dlopen FATAL** — main.dart 가 `getprop ro.product.cpu.abi` 로 x86 이면 초기화를 건너뛰어 지도 탭이 목록 폴백으로 뜬다. 지도 렌더링 확인은 실기기(arm64)에서만 가능. Knot 의 네이버 키는 패키지명 불일치+계정 격리 규칙 때문에 재사용하지 않았다.
- 카카오/구글 키는 `String.fromEnvironment`라 **--dart-define 없이는 로그인·지도가 동작하지 않는다.** 패키지명이 `com.artnara.artnara`로 바뀌었으므로 **Knot용 키는 사용 불가 — 아트나라 전용으로 새로 발급**해야 하고, AndroidManifest 의 `kakao{네이티브키}` scheme 도 함께 교체해야 한다.
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
