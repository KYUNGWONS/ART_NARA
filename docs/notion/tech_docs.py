# -*- coding: utf-8 -*-
"""ART NARA 기술 문서 원본.

문서 하나가 dict 하나다. body 는 (종류, 값) 튜플의 리스트:
  h   제목        s: 문단        b: 불릿 목록        c: 강조 박스(callout)
  t   표 (첫 행이 헤더)          code: 코드 블록(lang, text)
"""

DOCS = [
    # ================= 0. 아키텍처 =================
    dict(
        id='ARCH-010', group='0_아키텍처', title='서비스 아키텍처',
        summary='앱·백엔드·관리자 콘솔과 외부 연동(카카오/네이버/토스/FCM/카카오맵)의 전체 구성.',
        body=[
            ('c', '한 문장 요약: Flutter 앱과 정적 웹 관리자 콘솔이 같은 Spring Boot 백엔드를 바라보고, 실시간(STOMP)과 푸시(FCM)로 사용자에게 사건을 알린다.'),
            ('h', '시스템 구성도'),
            ('code', ('mermaid', '''graph TB
  subgraph client["클라이언트"]
    APP["Flutter 앱<br/>com.artnara.artnara"]
    ADM["관리자 콘솔<br/>정적 웹"]
  end

  subgraph server["백엔드 · Spring Boot 3"]
    REST["REST API<br/>JWT 인증"]
    WS["STOMP /ws<br/>채팅 · 경매"]
    SCH["스케줄러<br/>경매 자동 마감"]
    DB[("H2 / MySQL")]
  end

  subgraph ext["외부 서비스"]
    KAKAO["카카오<br/>로그인 · 지도"]
    NAVER["네이버 로그인"]
    TOSS["토스페이먼츠"]
    FCM["FCM"]
  end

  APP -->|HTTPS| REST
  APP <-->|WebSocket| WS
  ADM -->|관리자 토큰| REST
  REST --> DB
  WS --> DB
  SCH --> DB
  REST -->|토큰 검증| KAKAO
  REST -->|코드 교환| NAVER
  REST -->|결제 승인 · 취소| TOSS
  REST -->|푸시 발송| FCM
  FCM -.->|알림| APP
  APP -->|SDK| KAKAO''')),
            ('h', '구성 요소'),
            ('t', [
                ['구성', '스택', '역할'],
                ['앱', 'Flutter (Android)', '구매자·작가가 쓰는 화면 전부. 패키지 com.artnara.artnara'],
                ['백엔드', 'Spring Boot 3 · JPA · JDK 17', 'REST API + STOMP + 스케줄러. 모든 판단(신원·금액·상태)의 주체'],
                ['DB', 'H2 파일 모드(dev)', '~/artnara-db. MySQL 전환은 환경변수만으로 가능'],
                ['관리자 콘솔', '정적 웹(HTML + ES 모듈)', '대시보드·회원·주문/환불. 별도 레포'],
            ]),
            ('h', '통신 경로'),
            ('b', [
                'REST: 앱/콘솔 → 백엔드. 인증은 JWT Bearer (관리자는 ROLE_ADMIN 별도)',
                'STOMP WebSocket(/ws): 채팅 /topic/chat/{roomId}, 경매 현황 /topic/auction/{artworkId}',
                'FCM: 백엔드 → 구글 → 기기. 앱이 로그인 직후 기기 토큰을 등록한다',
                '이미지: multipart 업로드 → /images/** 정적 서빙(Cache-Control 30일)',
            ]),
            ('h', '외부 연동'),
            ('t', [
                ['연동', '방식', '비고'],
                ['카카오 로그인', '앱 SDK → 서버가 프로필로 검증', '네이티브 키 + 커스텀 스킴'],
                ['네이버 로그인', '앱 WebView 로 인가 코드 → 서버가 토큰 교환', '시크릿은 서버에만'],
                ['토스페이먼츠', '앱 WebView 결제위젯 → 서버가 승인(confirm)', '금액 대조로 위조 차단'],
                ['FCM', 'HTTP v1 (서비스 계정 JWT)', 'firebase-admin 미사용, 자체 구현'],
                ['카카오맵', '앱 네이티브 SDK', 'arm 전용 — 실패 시 목록 폴백'],
            ]),
            ('h', '설계 원칙'),
            ('b', [
                '거래 주체는 서버가 JWT 신원에서 정한다 — 클라이언트가 보낸 이름·금액을 믿지 않는다',
                '조회(GET)만 공개, 상태를 바꾸는 요청은 로그인 필수. 예외는 QR 소유권 확인 하나',
                '"내 것" 목록(소유권·주문·판매·정산)은 예외 없이 신원으로 스코프한다',
                '목록에서 N+1 이 생기지 않도록 상태를 엔티티에 들고 있는다(예: Artwork.sold/reserved)',
            ]),
            ('h', '도메인 구성(백엔드)'),
            ('b', [
                'artwork · sale — 작품과 판매 등록, 경매 입찰',
                'order — 직거래(예약→수령확인→결제)',
                'certificate — 디지털 소유권·QR 인증서',
                'commission — 제작 의뢰 역경매',
                'chat · notification · push — 소통',
                'settlement · admin — 정산과 운영',
                'global/auth — OAuth·JWT·보안 설정',
            ]),
        ],
    ),
    dict(
        id='ARCH-020', group='0_아키텍처', title='데이터 모델',
        summary='주요 엔티티와 상태 필드, 그리고 상태를 boolean 으로 표현한 이유.',
        body=[
            ('h', '주요 엔티티'),
            ('t', [
                ['엔티티', '핵심 필드', '메모'],
                ['User', 'provider/providerId, nickname, userType, blocked, tokenValidFrom', '활동명(nickname)이 작품·정산의 키'],
                ['Artwork', 'price, auction, currentBid, auctionEndAt, sold, reserved', 'sold 와 reserved 는 다른 상태다'],
                ['ArtOrder', 'amount, sellerConfirmed, buyerConfirmed, paid, cancelled, refunded, certificateNo', '직거래 단계를 boolean 으로'],
                ['Certificate / Ownership', 'qrCode, certificateNo, ownerId, revoked', '환불 시 삭제가 아니라 무효 표시'],
                ['Commission / CommissionOffer', 'budget, category, amount', '역경매 — 최저가 갱신'],
                ['Sale', 'sellerId', '내 판매 작품 스코프'],
            ]),
            ('h', '상태를 enum 이 아니라 boolean 으로 둔 이유'),
            ('c', 'JPA 가 enum 컬럼을 만들 때 값 목록을 CHECK 제약으로 박아 두는데, ddl-auto=update 는 그 제약을 갱신하지 않는다. enum 에 값을 추가하면 기존 DB 에서만 저장이 500 으로 깨진다 — 알림 종류와 OAuth 제공자에서 두 번 겪었다.'),
            ('b', [
                '직거래 단계는 sellerConfirmed / buyerConfirmed / paid / cancelled 네 개의 boolean 으로 표현한다',
                '불가피하게 enum 을 컬럼으로 쓸 땐 columnDefinition = "varchar(n)" 으로 못박는다',
                '이미 만들어진 개발 DB 는 EnumColumnConstraintFix(부팅 러너)가 ALTER 로 정리한다',
                '새 boolean 컬럼에는 columnDefinition = "boolean default false" 를 함께 준다 — 기본값 없는 NOT NULL 은 기존 행이 있는 테이블에 추가되지 않는다',
            ]),
        ],
    ),

    # ================= 1. 프로젝트 개요 =================
    dict(
        id='OVW-010', group='1_개요', title='서비스 소개',
        summary='미대생 미술품 거래 플랫폼. 3탭 거래 + 경매/역경매 + 지도 매칭 + QR 소유권.',
        body=[
            ('h', '핵심 기능'),
            ('t', [
                ['기능', '설명'],
                ['3탭 거래', '구매 / 판매 / 제작 의뢰. 판매는 즉시 판매와 경매 두 방식'],
                ['경매 · 역경매', '작품 경매(입찰·자동 마감), 제작 의뢰 역경매(작가가 더 낮은 금액 제안)'],
                ['지도 매칭', '집 주변 작품을 지도에서 탐색'],
                ['디지털 소유권', '결제 확정 시 인증서 자동 발급, QR 로 누구나 이력 확인'],
            ]),
            ('h', '확정된 제외 사항'),
            ('b', [
                '블록체인 없음 — 디지털 소유권은 서버 DB 기반',
                '배송 없음 — 만나서 전달하는 직거래(결제가 만난 뒤로 미뤄지는 구조의 근거)',
                "'정품 인증' 개념 없음 — 위작 판별이 아니라 전부 '소유권 인증'(2026-08-05 확정)",
            ]),
            ('h', '저장소'),
            ('t', [
                ['레포', '내용'],
                ['ART_NARA', 'Flutter 앱(frontend) + Spring Boot(backend)'],
                ['ART_NARA_ADMIN', '관리자 콘솔(정적 웹)'],
            ]),
        ],
    ),

    # ================= 2. 도메인 =================
    dict(
        id='DOM-010', group='2_도메인', title='직거래 결제 흐름',
        summary='예약 → 만나서 전달 → 양쪽 수령 확인 → 결제 → 소유권 발급. 배송이 없어 결제를 만난 뒤로 미룬다.',
        body=[
            ('c', '왜 이렇게 설계했나: 배송이 없는 서비스라 주문 시점에 결제하면 구매자가 실물을 보기 전에 돈을 내게 된다. 그래서 주문은 예약만 하고, 만나서 주고받은 뒤 양쪽이 확인해야 결제가 열린다.'),
            ('h', '상태 전이'),
            ('code', ('mermaid', '''stateDiagram-v2
  [*] --> 예약중: POST /api/orders
  예약중 --> 수령확인중: 한쪽이 handover
  수령확인중 --> 결제대기: 나머지 한쪽도 handover
  결제대기 --> 거래완료: POST /pay (구매자만)
  예약중 --> 예약취소: cancel
  수령확인중 --> 예약취소: cancel
  결제대기 --> 예약취소: cancel
  거래완료 --> 환불완료: 관리자 환불
  예약취소 --> [*]: 작품 잠금 해제
  환불완료 --> [*]: 소유권 회수 · 재판매 가능
  거래완료 --> [*]''')),
            ('h', '단계'),
            ('t', [
                ['단계', '표시', '무슨 일이 일어나나'],
                ['1. 예약', '예약 중', '작품이 reserved 로 잠긴다. 결제·소유권 없음'],
                ['2. 한쪽 확인', '수령 확인 중', "판매자 '전달했어요' 또는 구매자 '받았어요'"],
                ['3. 양쪽 확인', '결제 대기', '구매자에게 결제 버튼이 열린다'],
                ['4. 결제', '거래 완료', 'sold 잠금 + 소유권·인증서 발급'],
                ['취소/환불', '예약 취소 / 환불 완료', '작품 잠금 해제, 환불은 소유권까지 회수'],
            ]),
            ('h', 'API'),
            ('t', [
                ['메서드', '경로', '설명'],
                ['POST', '/api/orders', '예약(결제 아님). 중복 예약 409'],
                ['POST', '/api/orders/{id}/handover', '수령 확인. 신원으로 판매자/구매자 판별, 제3자 403'],
                ['POST', '/api/orders/{id}/pay', '결제. 구매자만, 양쪽 확인 후에만(아니면 400)'],
                ['POST', '/api/orders/{id}/cancel', '결제 전 취소(양쪽 다 가능)'],
                ['GET', '/api/orders / /api/orders/selling', '구매자 목록 / 판매자 목록'],
            ]),
            ('h', '돈 계산 규칙'),
            ('b', [
                '매출·정산·리뷰 자격은 paid 인 건만 센다 — 예약이 매출로 잡히면 안 된다',
                '관리자 환불은 paid 인 건에만 가능. 미결제 예약은 400 으로 거절하고 예약 취소로 처리한다',
                '기존 주문은 PaidOrderBackfill(부팅 러너)이 인증서 번호 유무로 paid 를 채운다 — 안 하면 지난 매출이 통째로 사라진다',
            ]),
            ('h', '검증'),
            ('b', ['백엔드 흐름 12케이스 + 전 구간 23케이스 통과',
                   '에뮬레이터 2대로 실측: 예약 → 전달했어요 → 받았어요 → 실 토스 승인 → 인증서 발급']),
        ],
    ),
    dict(
        id='DOM-020', group='2_도메인', title='경매',
        summary='입찰 증분 · 자동 마감 · 실시간 반영. 낙찰자만 낙찰가로 예약할 수 있다.',
        body=[
            ('h', '규칙'),
            ('b', [
                '등록 시 경매여도 즉시 판매가(buyNowPrice)가 필수다',
                '마감은 날짜 단위 — 다음 날 이후만 지정 가능(등록 직후엔 항상 D-n 표시)',
                '최소 증분 미달 입찰은 422 로 거절',
                'AuctionScheduler 가 1분 주기로 마감. remainingTime 은 동적 계산(D-n 또는 HH:mm:ss)',
                '마감 전에는 예약할 수 없다(400). 낙찰자가 아니면 403',
            ]),
            ('h', '실시간 반영'),
            ('b', [
                '입찰·마감 시 서버가 /topic/auction/{artworkId} 로 현황을 발행한다',
                '앱은 진행 중인 경매일 때만 구독하고, 수신하면 상세를 재조회한다(부분 갱신 대신 서버 계산 결과를 그대로 사용)',
                '발행 실패는 로그만 남기고 거래를 되돌리지 않는다',
            ]),
            ('c', '카운트다운은 서버에서 받은 남은 시간을 기준으로 앱이 1초씩 줄인다 — 매초 서버를 부르지 않아 트래픽이 0이다. 0에 닿으면 한 번만 재조회한다.'),
        ],
    ),
    dict(
        id='DOM-030', group='2_도메인', title='역경매(제작 의뢰)',
        summary='의뢰를 올리면 해당 장르 작가들에게 알림이 가고, 작가들이 더 낮은 금액을 제안한다.',
        body=[
            ('h', '흐름'),
            ('b', [
                '컬렉터가 의뢰 등록 → 선택 카테고리의 작가 전원에게 알림',
                '작가가 제안 — 현재 최저가보다 낮아야만 등록된다(위반 422)',
                '제안이 들어오면 의뢰가 "역경매 진행 중" 으로 바뀌고 의뢰인에게 알림',
            ]),
            ('h', '요청 필드'),
            ('c', 'POST /api/commissions {title, description, category, budget, desiredDate, referenceImageUrl} — budgetMin/Max 가 아니라 budget 이다.'),
            ('h', '실측'),
            ('b', ['예산 400,000 의뢰에 500,000 제안 → 거절(제안 0건 유지)',
                   '320,000 제안 → 최저가 등록 + 의뢰인 알림 도착']),
        ],
    ),
    dict(
        id='DOM-040', group='2_도메인', title='디지털 소유권 · QR 인증',
        summary='결제 확정 시 인증서 발급. 공개 QR 로 누구나 이력을 확인하고, 환불 시 무효 처리된다.',
        body=[
            ('h', '번호 체계'),
            ('t', [
                ['값', '형식', '용도'],
                ['인증서 번호', 'ARTNARA-2026-{100+주문id}', '화면 표시'],
                ['QR 코드', 'ARTNARA-QR-{인증번호 끝자리}', '스캔 조회 — 인증서 번호와 다른 값이다'],
            ]),
            ('h', '내용'),
            ('b', ['작품 제목·작가·제작 연도·크기·재료를 결제 시점 사양 그대로 복사해 보관',
                   '소유자는 구매자의 JWT 신원']),
            ('h', '공개 스캔'),
            ('c', 'POST /api/certificates/scan 은 메서드 무관 공개인 유일한 API 다 — 누구나 소유권 이력을 확인할 수 있어야 의미가 있기 때문.'),
            ('h', '환불 시'),
            ('b', [
                '기록을 지우지 않고 revoked 로 무효 표시한다',
                "'내 디지털 소유권' 목록에서 빠진다",
                'QR 스캔은 200 + verified:false + "환불로 무효 처리된 인증서입니다" 로 응답(404 아님)',
            ]),
        ],
    ),
    dict(
        id='DOM-050', group='2_도메인', title='정산 · 환불',
        summary='작가 정산(수수료 10%)과 관리자 환불의 순서·부수효과.',
        body=[
            ('h', '정산'),
            ('b', [
                'GET /api/settlements — 대상은 JWT 활동명',
                '판매 합계 · 수수료 · 정산 예정액 · 이번 달 판매 · 건별 내역',
                '결제 완료 건만 집계. 환불 건은 이력에만 남고 합계에서 빠진다',
            ]),
            ('c', '플랫폼 수수료 10% 는 사업계획서에 요율이 없어 정한 기본값이다(SettlementService.FEE_RATE). 정해지면 이 상수만 바꾸면 된다.'),
            ('h', '환불 순서'),
            ('b', [
                '실 PG 건이면 토스 취소를 먼저 호출하고 성공해야 환불 상태로 바꾼다(PG 와 장부가 어긋나지 않게)',
                '부수효과: Artwork.sold 해제 → 소유권·인증서 무효 → 리뷰 자격 상실 → 구매자에게 알림+푸시',
                '미결제 예약은 환불 대상이 아니다(400)',
            ]),
        ],
    ),

    # ================= 3. 인증/보안 =================
    dict(
        id='SEC-010', group='3_인증보안', title='소셜 로그인 (카카오 · 네이버)',
        summary='카카오는 SDK, 네이버는 앱 WebView + 서버 코드 교환. 신원 확인은 언제나 서버가 한다.',
        body=[
            ('h', '카카오'),
            ('b', [
                '앱이 SDK 로 액세스 토큰을 받고, 서버가 카카오 프로필 API 로 검증한다',
                '네이티브 앱이라 패키지명 + 키해시로 등록한다(리다이렉트 URI 불필요)',
                '리다이렉트 인텐트 필터는 MainActivity 가 아니라 SDK 의 AuthCodeCustomTabsActivity 에 붙여야 로그인 Future 가 끝난다',
            ]),
            ('h', '네이버 — 왜 SDK 를 걷어냈나'),
            ('b', [
                'SDK 는 결과를 커스텀탭 → intent:// 로 돌려주는데 그 전달이 막히는 환경이 있었다(인가 코드는 발급되는데 앱이 못 받음)',
                '앱 자체 WebView 는 NavigationDelegate 로 어떤 URL 이든 가로챈다 — 그래서 웹 OAuth 로 전환',
                '앱은 인가 코드만 받고 토큰 교환·프로필 검증은 서버가 한다 → 클라이언트 시크릿이 앱에 없다',
            ]),
            ('c', '한 번 크게 헤맨 것: 동의 화면이 disp_stat=207 로 거절됐는데, 콜백 방식·UA·쿠키를 다 바꿔도 동일했다. 결국 네이버 콘솔의 앱 자체가 망가진 것이었고 새 앱을 만들자 즉시 해결됐다. 코드는 처음부터 정상이었다. backend/check-naver.sh 로 10초 만에 판별할 수 있다.'),
        ],
    ),
    dict(
        id='SEC-020', group='3_인증보안', title='JWT · 토큰 폐기 기준선',
        summary='access/refresh 회전 발급. 로그아웃과 id 재사용을 tokenValidFrom 하나로 막는다.',
        body=[
            ('h', '토큰'),
            ('b', ['access 1시간 / refresh 회전 발급', "클레임 이름은 roles, 값은 USER (ROLE_USER 아님)",
                   '앱은 flutter_secure_storage 에 보관하고 스플래시에서 자동 로그인']),
            ('h', '발견된 문제'),
            ('c', '개발 DB 를 비우고 시드를 다시 넣자 회원 id 가 1부터 재발급됐다. 그런데 다른 기기의 옛 refresh token(sub=9)이 그대로 통해서 새로 생긴 id 9 회원(남의 계정)으로 자동 로그인됐다 — refresh 가 서명·만료·회원 존재만 보고 "같은 사람인지" 는 보지 않았기 때문. 동시에 앱이 부르던 POST /auth/logout 은 서버에 없어 404 였다.'),
            ('h', '해결 — User.tokenValidFrom'),
            ('b', [
                '이 시각보다 먼저 발급된 토큰은 무효로 본다',
                '가입 시 기준선을 "지금" 으로 잡는다 → 그 id 로 예전에 발급된 토큰은 거부',
                '로그아웃 시 "다음 초" 로 올린다 → 잃어버린 기기의 refresh token 이 즉시 무력화',
                'POST /auth/logout 추가. access token 이 만료돼도 body 의 refreshToken 으로 신원을 찾는다(서명·만료가 멀쩡한 토큰만 인정)',
                'nullable 이라 기존 회원은 그대로 통과한다',
            ]),
            ('c', '함정: 기준선을 "지금" 으로 두면 JWT iat 가 초 정밀도라 같은 초에 발급된 토큰이 살아남는다(로그아웃 직후 refresh 가 200 으로 통과해 발견). 로그아웃만 +1초 하고 가입은 그대로 둬야 방금 발급한 토큰이 막히지 않는다.'),
        ],
    ),
    dict(
        id='SEC-030', group='3_인증보안', title='보안 원칙 · 오류 매핑',
        summary='공개 범위, 신원 스코프, 관리자 격리, 상태코드 규칙.',
        body=[
            ('h', '공개 범위'),
            ('b', [
                '원칙: 조회(GET)만 공개, 나머지는 로그인 필수',
                '공개 조회: 피드 · 작품 · 작가 · 의뢰 · 결제설정 · 이미지',
                '메서드 무관 공개는 QR 스캔 하나뿐',
                '공개하지 않는 목록: 소유권·주문·판매·정산(모두 "내 것")',
            ]),
            ('h', '신원 스코프 — 실제로 겪은 사고'),
            ('c', '초기에 소유권·주문·판매 목록이 전체를 반환했다. 갓 가입한 계정에 남의 소유권이 보였다. 교훈: 목록 API 는 "내 것" 인지 "공개 마켓" 인지 먼저 정하고, "내 것" 이면 예외 없이 JWT 신원으로 스코프한다. 공개가 맞는 목록은 작품 피드와 의뢰 목록뿐이다.'),
            ('h', '관리자 격리'),
            ('b', ['관리자 토큰은 ROLE_ADMIN, 앱 토큰은 ROLE_USER',
                   '/api/admin/** 는 hasRole("ADMIN") — 앱 토큰으로 부르면 403',
                   '예전에 authenticated() 였을 때 관리자 토큰이 회원 id 1 로 동작한 적이 있다']),
            ('h', '오류 매핑'),
            ('t', [
                ['상황', '응답'],
                ['본문 해석 실패', '400 COMMON_400_BODY'],
                ['쿼리 파라미터 누락·타입 오류', '400 COMMON_400_PARAM'],
                ['없는 경로', '404 / 잘못된 메서드 405'],
                ['인증 구역의 없는 하위 경로', '401 (경로 존재 여부를 노출하지 않는 정상 동작)'],
            ]),
            ('c', '함정: 컨트롤러 예외가 /error 로 ERROR 디스패치되면 JWT 필터가 안 돌아 SecurityContext 가 비고, 원래 오류가 전부 401 빈 응답으로 둔갑한다. /error 를 열어 해결했다 — 401 빈 본문이 보이면 인증이 아니라 서버 예외를 의심할 것.'),
        ],
    ),

    # ================= 4. 외부 연동 =================
    dict(
        id='EXT-010', group='4_외부연동', title='토스페이먼츠 결제',
        summary='계약 없이 테스트 키로 실 PG 전 구간을 검증했다. 승인은 반드시 서버에서.',
        body=[
            ('h', '흐름'),
            ('b', [
                '앱이 GET /api/payments/config 로 실 PG 여부 확인',
                '켜져 있으면 WebView 결제위젯 → 결제 완료 시 successUrl 이동을 NavigationDelegate 가 가로채 paymentKey 획득',
                'POST /api/orders/{id}/pay 에 실어 보내면 서버가 /v1/payments/confirm 으로 승인',
            ]),
            ('c', '보안 원칙: 승인은 반드시 서버에서 한다. 토스가 확정한 금액과 주문 금액이 다르면 거절한다 — 위조 paymentKey 로 시도하면 402 가 나고 주문도, 작품 잠금도 생기지 않는 것을 실측했다.'),
            ('h', '켜는 법'),
            ('code', ('bash', 'TOSS_SECRET_KEY=test_gsk_docs_... ./gradlew bootRun\n# 키가 없으면 mock 결제로 동작한다')),
            ('h', 'WebView 함정 2가지'),
            ('b', [
                'loadFlutterAsset 에 쿼리스트링을 붙이면 에셋 키를 통째로 찾아 실패한다 → 에셋을 문자열로 읽어 설정을 주입하고 loadHtmlString(baseUrl=성공 URL 과 같은 오리진)',
                '카드 결제는 intent://…kb-acp:// 같은 스킴을 던지는데 WebView 가 죽는다 → url_launcher 로 외부 앱 실행, 실패 시 browser_fallback_url → market:// 순으로 폴백',
            ]),
            ('h', '운영 전환'),
            ('b', ['가맹 계약 후 TOSS_SECRET_KEY/CLIENT_KEY 만 교체하면 된다',
                   'successUrl 인터셉트 주소(artnara.app)는 실제 도메인이 아니라 가로채기용이라 그대로 둬도 된다']),
        ],
    ),
    dict(
        id='EXT-020', group='4_외부연동', title='FCM 푸시',
        summary='HTTP v1 자체 구현. 파일 두 개만 넣으면 켜지고, 없으면 앱 내 알림만으로 정상 동작한다.',
        body=[
            ('h', '구현'),
            ('b', ['레거시 서버 키 API 는 종료 — FCM HTTP v1 사용',
                   '서비스 계정 JSON 으로 RS256 JWT 를 만들어 액세스 토큰을 받고 만료 1분 전까지 재사용',
                   '새 의존성 없이 jjwt + java.net.http 로 구현']),
            ('h', '켜는 법'),
            ('t', [
                ['대상', '필요한 것', '위치'],
                ['앱(수신)', 'google-services.json', 'frontend/android/app/ (git 미추적)'],
                ['서버(발송)', '서비스 계정 JSON 경로', 'backend/local.properties 의 fcmCredentialsPath'],
            ]),
            ('c', '빌드 안전장치: app/build.gradle.kts 가 google-services.json 이 있을 때만 플러그인을 적용한다. 문서대로 plugins {} 에 무조건 넣으면 파일 없는 환경에서 빌드가 깨진다. run-dev.sh 도 파일이 실제로 있을 때만 FCM_CREDENTIALS 를 넘긴다.'),
            ('h', '푸시가 나가는 경로'),
            ('b', [
                'publishTo(userId, …) 로 보낸 알림만 푸시가 간다 — 환불·채팅·주문완료 셋',
                'publish(…) 는 userId=null 시스템 알림이라 대상이 없어 건너뛴다(제작 의뢰·작가 제안 계열) — 푸시 테스트에 쓰면 안 된다',
                '앱이 포그라운드면 알림함에 안 뜬다(안드로이드 규칙). 백그라운드로 내리고 테스트할 것',
            ]),
            ('h', '탭 이동'),
            ('b', ['알림함에서 푸시를 누르면 data{type,targetId} 로 해당 화면까지 이동한다',
                   '앱 내 알림 목록과 같은 규칙을 공용 유틸로 공유한다(예전엔 푸시를 눌러도 앱만 열렸다)']),
        ],
    ),
    dict(
        id='EXT-030', group='4_외부연동', title='카카오맵',
        summary='로그인과 같은 키 하나로 지도까지. arm 전용 SDK 라 x86 에뮬레이터에선 목록으로 폴백한다.',
        body=[
            ('h', 'ABI 함정'),
            ('c', '카카오맵 네이티브(libK3fAndroid.so)는 arm 전용이다. 유니버설 APK 에는 x86_64 .so 가 섞여 있어 안드로이드가 앱을 x86_64 로 설치하고, 그러면 지도 SDK 가 dlopen 에서 죽는다. arm64 만 담은 APK 로 설치하면 앱 전체가 arm64 로 떠서 정상 동작한다.'),
            ('code', ('bash', 'flutter build apk --debug --split-per-abi --target-platform android-arm64 \\\n  --dart-define=API_BASE_URL=http://10.0.2.2:8080 --dart-define=KAKAO_NATIVE_APP_KEY=...\nadb uninstall com.artnara.artnara   # ABI 가 바뀌므로 지우고 설치\nadb install build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk')),
            ('b', [
                '가드는 기기 속성(getprop)이 아니라 프로세스 ABI(Abi.current())로 판단해야 한다 — 기기 속성은 arm64 APK 를 깔아도 x86_64 라서 멀쩡한 환경에서 지도를 꺼버린다',
                'SDK 초기화 실패 시 같은 /api/artworks/nearby 결과를 거리순 목록으로 보여준다(지도 탭이 죽지 않는다)',
            ]),
            ('h', '마커'),
            ('b', ['브랜드 색 핀을 런타임에 그려 POI 에 붙인다(에셋 없이 ArtColors 사용)',
                   '좌표가 없는 작품은 id 기준 황금각으로 150~630m 안에 흩뿌린다 — id 가 같으면 항상 같은 위치',
                   '핀치 줌이 불가한 환경(에뮬레이터·한 손)을 위해 줌 버튼 제공']),
        ],
    ),

    # ================= 5. 관리자 콘솔 =================
    dict(
        id='ADM-010', group='5_관리자', title='관리자 콘솔',
        summary='별도 레포의 정적 웹. 대시보드·회원 관리·주문/환불.',
        body=[
            ('h', '구성'),
            ('b', ['빌드 도구 없는 정적 웹(HTML + ES 모듈). python -m http.server 로 구동',
                   '로그인 화면에서 백엔드 주소를 지정한다(localStorage: artnara.apiBase)',
                   '계정은 admin_accounts 테이블로 앱 users 와 분리, BCrypt 저장, 초기 비밀번호는 첫 로그인 시 변경 유도']),
            ('h', '기능'),
            ('t', [
                ['화면', '내용'],
                ['대시보드', '총/오늘/이번달 매출·환불액·주문/회원/작품 수·14일 매출 그래프·상위 작가'],
                ['회원 관리', '검색 · 차단/해제(차단 시 앱 로그인·토큰 재발급이 막힌다)'],
                ['주문·환불', '검색 · 직거래 단계 배지 · 환불'],
            ]),
            ('h', '직거래 반영'),
            ('b', ['단계 배지: 예약 중 → 수령 확인 중 → 결제 대기 → 거래 완료 / 예약 취소 / 환불',
                   '환불 버튼은 결제된 건에만 보인다 — 결제 전은 돌려줄 돈이 없고, 취소는 앱의 당사자들이 한다',
                   '매출은 결제 완료 && 환불 아님 만 집계']),
            ('c', '함정(해결됨): ddl-auto=update 는 기존 행이 있는 테이블에 기본값 없는 NOT NULL 컬럼을 추가하지 못한다 — sold/refunded/blocked 가 조용히 누락돼 관리자 조회가 전부 500 이었다. columnDefinition 으로 DB 기본값을 함께 주어 해결했다.'),
        ],
    ),

    # ================= 6. 개발 환경 =================
    dict(
        id='ENV-010', group='6_개발환경', title='로컬 실행',
        summary='백엔드·앱·에뮬레이터 2대 실행법과 이 환경 특유의 함정.',
        body=[
            ('h', '백엔드'),
            ('code', ('bash', 'cd backend && ./run-dev.sh --bg\n# 비밀값을 local.properties 에서 읽어 넘기고, 8080 을 잡고 있는 옛 프로세스를 먼저 죽인다')),
            ('c', '구버전 서버가 포트를 잡고 계속 응답해서 "코드가 반영 안 된다" 로 보이는 함정이 있었다. run-dev.sh 가 이를 막는다. 기동 확인은 boot.log 의 "Started ArtNaraApplication".'),
            ('h', '앱'),
            ('b', [
                '한글 경로(문서) 때문에 flutter run 이 실패한다 → build apk → 영문 경로로 복사 → adb install',
                'android.overridePathCheck=true 가 적용돼 있다',
                'flutter analyze 는 비ASCII 경로에서 크래시 — 컴파일 검증은 flutter test 로 대체',
                'OneDrive 경로라 build/ 삭제가 자주 잠긴다 → 실패 시 해당 하위 폴더를 지우고 재시도',
            ]),
            ('h', '에뮬레이터 2대'),
            ('code', ('bash', 'emulator -avd art_nara     # 5554\nemulator -avd art_nara2    # 5556')),
            ('b', ['두 번째 AVD 는 art_nara.avd/config.ini 를 복사해 만들었다(avdmanager 는 devices.xml 을 못 읽어 실패)',
                   'userdata 는 복사하지 않아야 계정이 섞이지 않는다',
                   'Impeller 렌더링이 깨지면 여러 시점의 프레임이 뒤섞여 캡처된다 — 화면을 증거로 쓰지 말고 로그로 판단할 것. adb reboot 로 해소']),
        ],
    ),
    dict(
        id='ENV-020', group='6_개발환경', title='비밀값 관리',
        summary='어떤 키가 어디에 있고, 무엇을 커밋하면 안 되는가.',
        body=[
            ('t', [
                ['용도', '위치', '키'],
                ['앱', 'frontend/android/local.properties', 'kakaoNativeAppKey'],
                ['서버', 'backend/local.properties', 'naverClientId/Secret, tossSecretKey, fcmCredentialsPath'],
                ['앱 푸시', 'frontend/android/app/google-services.json', '(파일 자체)'],
                ['서버 푸시', '레포 밖 (예: C:/Users/…/keys/artnara-fcm.json)', '서비스 계정 JSON'],
                ['도구', '.claude/settings.local.json', 'FIGMA_TOKEN, NOTION_TOKEN'],
            ]),
            ('c', '전부 git 미추적이다(**/local.properties 규칙 등). 서비스 계정 JSON 은 그 키로 누구나 푸시를 보낼 수 있으므로 레포 밖에 두고 경로만 설정에 적는다.'),
            ('b', ['네이버 시크릿은 서버에만 존재한다(웹 OAuth 전환으로 앱에서 제거됨)',
                   'Figma 계정은 아트나라 전용 — 다른 프로젝트 계정 커넥터와 섞지 않는다']),
        ],
    ),
    dict(
        id='ENV-030', group='6_개발환경', title='DB · 시드',
        summary='H2 파일 모드, 초기화 방법, 그리고 스위프를 짤 때 반드시 알아야 할 시드 사실.',
        body=[
            ('h', 'H2 파일 모드'),
            ('b', ['dev DB 는 ~/artnara-db — 서버를 재시작해도 계정·거래가 유지된다',
                   '레포 밖에 두는 이유: 레포가 OneDrive 동기화 경로라 동기화가 파일을 잠가 DB 가 깨질 수 있다',
                   '초기화: 서버 중지 → 폴더 삭제 → 재시작(시드 재생성)',
                   '테스트 프로필은 인메모리라 ./gradlew test 는 영구 DB 를 건드리지 않는다']),
            ('h', '시드 사실(스위프 작성 시 필수)'),
            ('t', [
                ['항목', '값'],
                ['작품', '8건 — id 1~4 즉시 판매, 5~8 경매'],
                ['회원', '8명 — 1 김예진 · 2 박소현 · 3 Andrew · 4 이수민 · 6 Emma'],
                ['기존 리뷰', '작품1=Andrew, 작품2=Emma — 그 조합으로 리뷰를 쓰면 409 가 정답'],
            ]),
            ('c', '시드는 영속 DB 와 공존한다: test.sql 은 INSERT IGNORE, ArtnaraDataInitializer 는 count()>0 가드라 재부팅마다 중복되지 않는다. 작품 id 1~8 순서는 위치 mock 과 결합돼 있으므로 유지할 것.'),
            ('h', 'MySQL 전환'),
            ('code', ('bash', 'DB_URL=jdbc:mysql://localhost:3306/artnara DB_DRIVER=com.mysql.cj.jdbc.Driver \\\n  DB_USERNAME=... DB_PASSWORD=... DDL_AUTO=update')),
        ],
    ),

    # ================= 7. QA =================
    dict(
        id='QA-010', group='7_QA', title='검증 이력',
        summary='회귀 스위프 90케이스와 2대 에뮬레이터 실측 결과.',
        body=[
            ('h', '스위프'),
            ('t', [
                ['스크립트', '케이스', '내용'],
                ['sweep.py', '34', '공개 조회 · 비로그인 차단 · 신원 스코프 · 관리자 격리 · QR · 오류 매핑'],
                ['handover.py', '12', '직거래 가드 — 중복 예약 409 · 확인 전 결제 400 · 제3자 403 · 취소 후 잠금 해제'],
                ['sweep2.py', '21', '관리자 · 정산 · 경매 · 역경매 규칙'],
                ['fullflow.py', '23', '거래 전 구간 — 예약부터 환불 회수까지 돈 흐름 정합'],
            ]),
            ('h', '2대 실측'),
            ('b', [
                '직거래: 예약 → 작가 전달 확인 → 구매자 수령 확인 → 실 토스 승인 → 인증서 발급',
                '경매: 상세를 열어둔 채 다른 계정이 입찰 → 화면 조작 없이 현재가·최소 입찰가 자동 갱신',
                '역경매: 예산 초과 제안 거절 → 정상 제안 등록 → 의뢰인 알림',
                '채팅: 문의 방 개설 → 메시지 → 상대 기기 푸시 도착 → 푸시 탭 시 채팅방 직행',
            ]),
            ('h', '스위프 짤 때 헛디딘 것'),
            ('b', [
                '피드는 /api/feed 가 아니라 /api/feed/home, 응답 키는 recommended/auctions/artists',
                '작품 페이징은 Spring Page 라 키가 content (피드의 artworks 와 다름)',
                '주변 작품 파라미터는 lat/lng 가 아니라 latitude/longitude',
                'QR 스캔은 인증서 번호가 아니라 QR 값(ARTNARA-QR-…)으로 조회',
                '환불된 인증서는 404 가 아니라 200 + verified:false 가 정상',
                '예약 대상 작품은 auction 필드로 걸러야 한다(경매는 마감 전 예약이 막히는 게 정상)',
            ]),
        ],
    ),
    dict(
        id='QA-020', group='7_QA', title='알려진 한계 · 남은 작업',
        summary='미해결 사항과 계정 작업만 남은 항목.',
        body=[
            ('h', '알려진 한계 — 활동명 개명 시 이력 단절'),
            ('c', '작품·주문·소유권이 작가를 활동명 문자열로 들고 있어서, 마이페이지에서 닉네임을 바꾸면 정산에서 이전 판매가 사라지고 포트폴리오도 옛 이름으로 남는다. 지금은 아무도 개명하지 않아 실제 데이터 문제는 없다.'),
            ('b', ['해결 방향 (a) 작품·주문에 작가 id 를 저장하고 id 기준으로 조회 — 정석이지만 화면 다수가 이름 기준이라 범위가 크다',
                   '해결 방향 (b) 닉네임 변경 시 저장된 활동명을 일괄 갱신',
                   '사용자 판단 후 진행']),
            ('h', '남은 작업'),
            ('t', [
                ['항목', '남은 것'],
                ['실 결제 라이브 전환', '가맹 계약 + 키 교체 (코드는 완료)'],
                ['네이버 로그인 검수', '검수 전에는 멤버관리 등록 계정만 로그인 가능'],
                ['카드사 앱카드 결제', '에뮬레이터엔 카드사 앱이 없어 실기기 확인 필요'],
            ]),
            ('h', '완료된 계정 작업'),
            ('b', ['FCM 푸시 — 실기기 도착까지 확인(2026-08-08)',
                   '네이버 로그인 — 새 앱 발급 후 전 구간 실측 완료']),
        ],
    ),
]
