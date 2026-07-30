# CLAUDE.md — ART NARA (DUST-ART)

미대생 미술품 거래 플랫폼. 원격: https://github.com/KYUNGWONS/ART_NARA (master에 직접 커밋·푸시).
기능 명세 원천은 레포 루트의 사업계획서 PDF(DUST-ART_...pdf): 3탭(구매/판매/제작의뢰) + 경매, 지도 집 주변 매칭, QR 정품 인증, 디지털 소유권. **블록체인 없음, 배송 없음** (사용자 확정).

## 구조

- `frontend/` — Flutter 앱 (상세 규칙은 frontend/CLAUDE.md). 하단 탭: 맵/판매/홈/채팅/의뢰.
- `backend/` — Spring Boot 3, 패키지 `com.example.artnara`, H2(dev)/JPA.

## 브랜딩

- 스플래시/로그인 워드마크는 Figma 디자인대로 **DUST-ART** (크림 0xFFF6F1E8 + 네이비 0xFF25333B 팔레트), 서비스 내부 텍스트는 ART NARA 혼용 중 — 통일 여부는 사용자 결정 대기.
- 코드베이스는 Knot/UniTrip(여행 매칭 앱)에서 가져와 리네임한 것이라 여행 도메인(booking, festival, magazine 등)이 남아 있음 — 점진적으로 대체 중.

## 작업 규칙 (사용자 요구)

- 기능 하나마다 **frontend / backend 커밋을 분리**해서 만들고 origin/master로 푸시. 커밋 메시지는 `feat(backend): ...` / `feat(frontend): ...` 형식.
- 커밋 전 검증: 프론트 `flutter test`(flutter는 `C:\Users\worms\dev\flutter\bin\flutter.bat`), 백엔드 `./gradlew test`(JDK 17 — Java 21 API 금지).
- **새 화면 디자인이 필요하면 Figma "Manyfast Wireframe to Figma (커뮤니티)" 파일에 먼저 그린 뒤 구현할 것.** Figma 작업은 이 레포의 `.mcp.json`에 등록된 프로젝트 전용 `figma-dustart` 서버로만 할 것 (다른 Figma 커넥터 계정은 별개 프로젝트 소속이므로 사용 금지).

## 백엔드 컨벤션

- 아트나라 도메인은 JPA 전환 완료: 엔티티 Artwork/ArtworkBid/Sale/Commission/CommissionOffer/Ownership/ArtOrder(테이블 `art_orders` — order는 예약어).
- 시드는 `ArtnaraDataInitializer`(CommandLineRunner) — test 프로필은 sql init을 안 돌리므로 시드는 반드시 이 러너에. **작품 id 1~8 순서는 ArtworkService의 위치 mock(LOCATIONS)과 결합되어 있으므로 유지할 것.**
- 서비스 테스트는 `@IntegrationTest`(@SpringBootTest + @Transactional + test 프로필).
- 새 공개 API는 `SecurityConstant.PUBLIC_URLS`에 경로 추가 필요.
- 경매: `Artwork.auctionEndAt` 기준 `AuctionScheduler`가 1분 주기 자동 마감, remainingTime은 동적 계산("D-n"/"HH:mm:ss"). 낙찰자("나")만 낙찰가로 `/api/orders` 결제 가능.
- 주문: 결제수단만 받음(CARD/KAKAO_PAY/NAVER_PAY/TOSS, mock PG). 결제 완료 시 디지털 소유권 자동 등록.
- 이미지: `POST /api/images` multipart → `/images/{파일명}` 정적 서빙, 저장 위치 `app.upload-dir`(기본 uploads/, gitignore됨).

## 남은 작업 후보

- 실제 PG SDK 연동 (가맹 계약 필요 — 프로토타입은 mock 유지)
- Knot 잔재 화면 정리: 랜딩/온보딩(여행 취향)/역할 선택(→작가·컬렉터)/상단바 knot 로고
- QR 인증서 mock(CertificateService의 정적 CERTIFICATES 맵) DB 전환

## 환경 주의사항

- OneDrive 경로라 `build/` 폴더 삭제가 자주 잠김 → 빌드 실패 시 `rm -rf build`(또는 하위 폴더) 후 재시도.
- `flutter analyze`는 비ASCII 경로 때문에 analysis server가 크래시 → 컴파일 검증은 `flutter test`로 대체.
- 레포 루트의 사업계획서 PDF·외주계약서 docx는 의도적으로 git 미추적 상태.
