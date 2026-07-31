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
- 워드마크/배경은 Figma에서 내려받은 에셋 사용: `assets/images/dust_wordmark.png`(흰 배경이라 `BlendMode.multiply`로 합성), `dust_splash_bg.jpg`.
- 서비스 내부 텍스트는 ART NARA 혼용 중 — 통일 여부는 사용자 결정 대기.
- 주요 화면 node id: 스플래시/온보딩 `1:309`, 홈 피드 `1:325`·`1:437`, 작품 판매 등록 `1:274`, 제작 의뢰 신청 `23:67`, 작가 포트폴리오 `41:850`, 정품 인증서 `50:1034`·`60:302`.
- 디자인 반영 현황(2026-07-31): 스플래시·로그인·홈 피드(칩 필터=백엔드 category 연동)·하단 내비(홈/판매/지도/제작의뢰/채팅)·판매 등록(4스텝 위저드) 완료. 전 화면 색상은 DustColors 토큰으로 통일됨. 제작 의뢰(23:67 멀티칩+안내박스)·정품 인증서(50:1034 골드 프레임 카드)도 완료. 작가 포트폴리오(41:850)도 완료(`GET /api/artists/{작가명}` + artist_portfolio_screen, 홈 피드 작가 리스트·작품 상세 작가 카드에서 진입). **디자인 6화면 전부 반영 완료.** 렌더 이미지는 Figma REST `/v1/images`로 받는다(MCP는 호출 제한 있음).
- 코드베이스는 Knot/UniTrip(여행 매칭 앱)에서 가져와 리네임한 것. 프론트 화면 잔재는 2026-07-31 정리 완료(랜딩/여행 온보딩/브랜드 화면 삭제, 역할=작가·컬렉터, 프로필 설정 아트나라화, 마이페이지 여행 필드 제거). 백엔드 여행 도메인도 2026-07-31 정리: booking/festival/magazine/notification/wishlist/brand 삭제 완료. 2026-08-01 지도 탭을 아트나라 전용(작품 마커 + /api/artworks/nearby)으로 재편하면서 content·recommendation·map 도메인, 프론트 여행 화면·서비스(tour_api, content_api, mate_match 등)도 삭제 완료. **남은 여행 잔재**: verification(UserService 참조), User 엔티티의 여행 필드(travelStyle 등 — 프론트 회원가입 계약과 결합), 채팅의 Knot 스타일 화면.

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
- 이미지: `POST /api/images` multipart → `/images/{파일명}` 정적 서빙, 저장 위치 `app.upload-dir`(기본 uploads/, gitignore됨).

## 남은 작업 후보

- 실제 PG SDK 연동 (가맹 계약 필요 — 프로토타입은 mock 유지)

## 환경 주의사항

- OneDrive 경로라 `build/` 폴더 삭제가 자주 잠김 → 빌드 실패 시 `rm -rf build`(또는 하위 폴더) 후 재시도.
- `flutter analyze`는 비ASCII 경로 때문에 analysis server가 크래시 → 컴파일 검증은 `flutter test`로 대체.
- 레포 루트의 사업계획서 PDF·외주계약서 docx는 의도적으로 git 미추적 상태.
