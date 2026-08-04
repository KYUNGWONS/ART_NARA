# CLAUDE.md — ART NARA

미대생 미술품 거래 플랫폼. 원격: https://github.com/KYUNGWONS/ART_NARA (master에 직접 커밋·푸시).
기능 명세 원천은 레포 루트의 사업계획서 PDF(DUST-ART_...pdf): 3탭(구매/판매/제작의뢰) + 경매, 지도 집 주변 매칭, QR 정품 인증, 디지털 소유권. **블록체인 없음, 배송 없음** (사용자 확정).

## 역할·품질 기준 (이 프로젝트 ART_NARA 에서만 적용)

> 이 파일은 ART_NARA 레포에서만 로드되므로, 아래 지시는 다른 프로젝트에 영향을 주지 않는다.

- **역할**: 너는 시니어 Flutter 개발자이자 시니어 Spring 개발자이며, 고급 보안 지식(OWASP, 인증/인가, 입력 검증)을 갖춘 고급 앱 개발자로서 작업한다.
- **품질 기준**: 모든 코드 구현은 100점 만점에 **90점 이상** 수준이어야 한다. 커밋 전에 스스로 검토해서 다음을 만족하지 못하면 고치고 나서 커밋한다:
  - 정확성: 테스트(`flutter test`/`./gradlew test`) 통과 + 경계/실패 케이스 처리
  - 보안: 인증·인가 확인(대상은 JWT 신원에서, 남의 리소스 접근 차단), 입력 검증, 비밀키·토큰 하드코딩 금지(local.properties/환경변수), 민감정보 로그 금지
  - 성능/부하: 불필요한 N+1·전체 로드 금지, 목록은 필요한 필드만 내려주기, 무거운 작업은 비동기/스케줄러로, 클라이언트는 불필요한 리빌드·중복 요청 방지 — **가벼우면서 퀄리티 높게**. 트래픽 분산이 필요한 지점(이미지 서빙, 조회 API)은 캐시 헤더·페이징 등 확장 가능한 구조를 우선한다.
  - 가독성: 기존 코드 스타일·토큰(DustColors 등) 준수, 의도가 드러나는 주석
- **디자인 기준**: 새 화면/와이어프레임은 **Figma 파일 `ZqY7Mo7424n3gMp5kZJ4AZ`("26.07.29 1-6")의 색감·형태를 기준**으로 구성한다. 색은 `dust_tokens.dart` 토큰만 사용하고, 새 와이어프레임을 그릴 때도 이 파일의 레이아웃 문법(헤더 한 줄, 6탭 내비, 카드/칩 형태)을 따른다.
- **자율 진행**: 사용자가 멈추라고 하기 전까지 **묻지 말고 알아서 끝까지 진행**한다. 애매한 지점은 합리적으로 판단해 구현하고 멈추지 않는다. 단, **작업이 끝나면 채팅 보고에 "헷갈렸지만 이렇게 판단해서 구현했다" 항목을 반드시 명시**한다(판단 근거 1줄씩). 사용자가 보고를 보고 뒤집으면 그때 수정한다.

## 구조

- `frontend/` — Flutter 앱 (상세 규칙은 frontend/CLAUDE.md). 하단 탭: 홈/판매/지도/제작의뢰/채팅.
- `backend/` — Spring Boot 3, 패키지 `com.example.artnara`, H2(dev)/JPA.

## 디자인 시스템 (Figma "DUST-ART" 파일 기준)

- Figma "DUST-ART Foundations"(파일 `LghoZTZPejVsF7jndmqJEm`, node `25:210`)에서 추출한 토큰을 `frontend/lib/constants/dust_tokens.dart`에 정의해 둠. **새 화면은 하드코딩 대신 이 토큰 사용.**
  - 브랜드: teal `#07524E` / deep `#084742` (네이비 아님)
  - 배경: canvas ivory `#F8F3E8`, surface `#FEFCF7`, subtle `#F0EBE3`
  - 텍스트: primary `#141413`, secondary `#6B665E`, on-brand `#FFFFFF`, 테두리 `#E0DBD1`
  - 타이포: Noto Sans KR — Heading 28 Bold / Section 22 Bold / Body 16 Regular / Caption 12 Regular
  - Spacing 8·12·16·24, Radius 8·14·22·Full
- 워드마크는 `widgets/artnara_wordmark.dart`(ART·NARA 텍스트 + 오렌지 점)로 그린다. Figma 워드마크 PNG 는 옛 브랜드명이라 삭제했다. 배경은 `assets/images/dust_splash_bg.jpg` 유지.
- 브랜드 표기는 **ART NARA 로 통일**(2026-08-02, 사용자 확정). 앱 이름·화면 문구·서버 문구 모두 ART NARA. 디자인 파일명/토큰 클래스명(DUST-ART, `DustColors`)은 Figma 파일에서 온 **내부 식별자**라 그대로 둔다.
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
- **지도 폴백**: `NAVER_MAP_CLIENT_ID` 가 없으면 같은 `/api/artworks/nearby` 결과를 거리순 목록으로 보여준다(지도 탭이 죽지 않는다).
- 인증서에 제작 연도·크기·재료가 새겨진다(결제 시 작품 사양을 그대로 복사).
- **리뷰 도메인**(2026-08-02): `POST /api/artworks/{id}/reviews`(구매자만·작품당 1회·별점 1~5), `GET /api/artists/{name}/reviews`(최신 100건+평균). 포트폴리오 평점/리뷰 수는 실제 집계. 주문에 buyerId/buyerName 저장(자격 확인용). 프론트: 포트폴리오 리뷰 탭 + 주문 내역 '리뷰 쓰기' 시트.
- **토큰 재발급·자동 로그인**(2026-08-02): `POST /auth/refresh`(회전 발급, 만료·위조·탈퇴 401). 프론트는 flutter_secure_storage 에 JWT 쌍을 저장하고 스플래시에서 자동 로그인(완료→메인, 미완료→역할 선택). 401 이면 저장 토큰 폐기, 네트워크 오류면 유지.
- **페이징**(2026-08-02): 홈 피드 섹션당 20건 상한. `GET /api/artworks?page=&size=&category=`(최신순, size 1~50 클램프) + '더보기' 무한 스크롤 화면.

## 디자인 커버리지 (2026-08-02 점검)

- **디자인 파일(26.07.29) 8프레임은 전부 구현 완료.** 차이 나는 부분은 의도된 결정: 배송 스텝 제외(4스텝), 채팅은 서랍으로, 시드 검색어·카테고리 칩은 백엔드 연동.
- **디자인 없이 구현했던 화면들의 와이어프레임을 Manyfast 파일(`PEgRT86N0VTa1bXgTruP4S`) > "추가 화면 와이어프레임 (2026-08-02)" 페이지에 사후 작성**: 작품 상세(`22:3`)·주문/결제(`22:4`)·알림(`25:2`)·마이페이지(`25:32`)·작품 문의 목록(`26:2`)·채팅 상세(`26:26`). 구현과 동일 구성, DUST 토큰 색.
- 2026-08-03 나머지 7화면도 같은 페이지에 추가: 역할 선택(`27:2`)·프로필 설정(`27:17`)·지도(`27:41`)·관심 작품(`28:2`)·주문 내역(`28:42`)·정품 인증 스캔(`28:78`)·더보기 작품 목록(`28:94`). **이제 구현된 전 화면(13개)이 와이어프레임을 갖는다.**

## QA 스위프 (2026-08-02)

API 27케이스 전건 통과: 공개 조회 6(피드·페이징·상한·상세·포트폴리오·리뷰·주변), 비로그인 쓰기 차단 4(결제·하트·리뷰·판매), 거래 3(결제·중복 409·QR 스캔 소유자/사양), 리뷰 5(작성·중복 409·미구매 403·별점 400·집계), 하트/알림/채팅 7(토글 ON/OFF·목록·알림·신원 스코프·참여 방·남의 방 403), 인증 2(재발급·만료 401). `flutter test`/`./gradlew test` 통과. 유일한 FAIL 은 시드 리뷰와 중복(409가 정답)이라 테스트 스크립트 문제였음 — 새 구매자(Emma)로 검증 시 200.

## 에뮬레이터 QA (2026-08-03) — 실기기 플로우에서 찾은 결함

앱을 실제로 띄워 카카오 로그인 → 역할 → 프로필 → 홈 피드 → 하트 → 작품 상세 → 결제 → 인증서까지 돌린 결과, **API 스위프에서 못 잡은 인가 결함 3건**을 발견해 고쳤다.

- **내 디지털 소유권에 남의 소유권이 보였다** — `Ownership` 에 소유자 컬럼이 없어 `listOwnerships()` 가 전체를 반환. 갓 가입한 계정에 시드 소유권 2건이 표시됨. → `Ownership.ownerId` 추가(구매자 JWT 신원), `findByOwnerIdOrderByIdDesc`.
- **주문 내역도 전체 반환** — `OrderService.list()` → `findByBuyerIdOrderByIdDesc(buyerId)`.
- **'내 판매 작품' 이 전체 판매 등록 목록** — `Sale` 에 판매자 컬럼이 없었다. → `Sale.sellerId` 추가, `findBySellerIdOrderByIdDesc`.
- 위 3개 경로(`/api/certificates`, `/api/orders`, `/api/sales`)는 `PUBLIC_READ_URLS` 에서 제외했다. **QR 검증(`/api/certificates/scan`)만 공개 유지** — 누구나 진품 확인이 가능해야 하므로.
- **로그인 버튼 아이콘을 네트워크에서 받고 있었다**(google favicon / kakao CDN) — 받아오기 전까지 버튼이 빈 칸으로 렌더되는 걸 실측. 로컬 Material 글리프로 교체.
- 교훈: **목록 API 는 "내 것"인지 "공개 마켓"인지 먼저 정하고, "내 것"이면 예외 없이 JWT 신원으로 스코프한다.** 공개가 맞는 목록은 `/api/artworks`(피드)와 `/api/commissions`(작가가 제안하려면 남의 의뢰를 봐야 함) 뿐이다.
- 환경 메모: 에뮬레이터가 Impeller GLES 로 렌더링하다 가끔 검은 화면으로 멈춘다(앱 결함 아님, 재시작으로 해소). `adb shell input keyevent 111`(ESC)은 Flutter 에서 뒤로가기로 먹으니 키보드 닫기에 쓰지 말 것.

## 판매 완료 상태 (2026-08-04)

- `Artwork.sold` 컬럼 + `markSold()`. `OrderService.create` 가 결제 확정 시 잠근다. **주문 테이블을 매 카드마다 조회하면 목록에서 N+1 이 되므로 작품에 상태로 들고 있는다.**
- 응답에 `sold` 를 실어 내린다: `ArtworkDetailDto`(상세·더보기 목록·관심 작품), `HomeFeedDto.Artwork`(피드). 프론트 모델은 없으면 `false` 로 읽는다(구버전 응답 호환).
- 표시: 피드/더보기 카드는 썸네일 위에 딤 + '판매 완료' 칩(`widgets/sold_overlay.dart` 공용), 관심 작품은 부제에 ` · 판매 완료`, 작품 상세는 구매 바 대신 '판매 완료된 작품입니다' 안내(`_ClosedBar(message:)` 재사용).
- 서버 가드는 그대로 유지: `sold || existsByArtworkId` → 409. UI 가 막혀도 서버가 최종 판단한다.
- 회귀 테스트: `frontend/test/sold_state_test.dart`(JSON 파싱 3 + 오버레이 렌더 1), 백엔드 `createMarksArtworkSold`.

## QA 스위프 (2026-08-04) — 28케이스 전건 통과

판매 완료 8(판매 전/후 상세·피드·목록·관심, 타 작품 무영향, 재구매 409), 인가 7(소유권·주문·판매 비로그인 401, QR 공개 200, 소유권/주문 신원 스코프), 리뷰 4(작성·중복 409·미구매 403·별점 400), 기타 9(피드 공개, size 클램프, 비로그인 결제·하트 401, 하트 토글, 만료 토큰 401, 주변 작품, 포트폴리오, 작가 리뷰). `flutter test` 5건 / `./gradlew test` 통과.

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
