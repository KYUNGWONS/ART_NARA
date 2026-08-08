# -*- coding: utf-8 -*-
"""화면 → API 호출 매핑.

frontend/lib/screens/*.dart 가 쓰는 서비스와 그 서비스의 엔드포인트를 대조해 만들었다.
화면 ID 를 키로 두어 screens.py 와 따로 관리한다(코드가 바뀌면 여기만 고치면 된다).
"""

SCREEN_API = {
    'AN-ENT-010': [  # 스플래시 · 온보딩
        ('POST', '/auth/refresh', '자동 로그인(저장된 refresh token)'),
        ('POST', '/api/devices', 'FCM 기기 토큰 등록'),
    ],
    'AN-ENT-020': [  # 로그인
        ('POST', '/auth/login', '카카오 액세스 토큰 → 앱 JWT'),
        ('GET', '/auth/naver/config', '네이버 동의 화면 주소'),
        ('POST', '/auth/naver/code', '네이버 인가 코드 → 앱 JWT'),
        ('POST', '/api/devices', '로그인 직후 기기 등록'),
    ],
    'AN-ENT-030': [  # 네이버 로그인 WebView
        ('GET', '/auth/naver/config', 'state 를 실어 동의 URL 수신'),
        ('—', '(WebView)', '인가 코드는 리다이렉트 인터셉트로 획득'),
    ],
    'AN-ENT-040': [],  # 역할 선택 — 로컬 상태만
    'AN-ENT-050': [  # 프로필 설정
        ('POST', '/api/users', '프로필 저장(가입 완료)'),
    ],
    'AN-ENT-060': [  # 메인 셸
        ('GET', '/api/notifications', '헤더 벨 미읽음 배지'),
        ('POST', '/auth/logout', '서랍 > 설정 > 로그아웃'),
        ('DELETE', '/api/devices', '로그아웃 시 기기 해제'),
    ],
    'AN-HOME-010': [  # 홈 피드
        ('GET', '/api/feed/home', '검색어·카테고리 필터 포함'),
        ('POST', '/api/artworks/{id}/like', '하트 토글'),
    ],
    'AN-HOME-020': [  # 더보기 목록
        ('GET', '/api/artworks?page=&size=&category=', '무한 스크롤 페이징'),
    ],
    'AN-HOME-030': [  # 작품 상세
        ('GET', '/api/artworks/{id}', '상세 조회(재조회로 실시간 반영)'),
        ('POST', '/api/artworks/{id}/bids', '입찰'),
        ('POST', '/api/artworks/{id}/close', '경매 마감'),
        ('POST', '/api/orders', '예약하기'),
        ('WS', '/topic/auction/{id}', '진행 중 경매만 구독'),
        ('POST', '/api/chat/rooms/direct', '문의하기'),
    ],
    'AN-HOME-040': [  # 작가 포트폴리오
        ('GET', '/api/artists/{활동명}', '작가 정보 + 작품'),
        ('GET', '/api/artists/{활동명}/reviews', '리뷰 + 평균 평점'),
        ('POST', '/api/chat/rooms/direct', '문의하기'),
    ],
    'AN-TRADE-010': [  # 결제
        ('GET', '/api/payments/config', '실 PG 사용 여부'),
        ('POST', '/api/orders/{id}/pay', '결제(구매자만)'),
    ],
    'AN-TRADE-011': [  # 토스 WebView
        ('—', '(외부 토스)', 'successUrl 인터셉트로 paymentKey 획득 → 서버가 승인'),
    ],
    'AN-TRADE-020': [  # 주문 내역
        ('GET', '/api/orders', '내 주문(구매자 스코프)'),
        ('POST', '/api/orders/{id}/handover', "'받았어요'"),
        ('POST', '/api/orders/{id}/cancel', '예약 취소'),
        ('POST', '/api/artworks/{id}/reviews', '리뷰 작성'),
    ],
    'AN-TRADE-030': [  # 내 작품 거래
        ('GET', '/api/orders/selling', '내 작품에 걸린 거래'),
        ('POST', '/api/orders/{id}/handover', "'전달했어요'"),
        ('POST', '/api/orders/{id}/cancel', '예약 취소'),
    ],
    'AN-SELL-010': [  # 판매 등록
        ('POST', '/api/images', '작품 이미지 업로드'),
        ('POST', '/api/sales', '판매 등록(즉시 판매·경매)'),
    ],
    'AN-SELL-020': [  # 판매 정산
        ('GET', '/api/settlements', '판매 합계·수수료·정산 예정액'),
    ],
    'AN-REQ-010': [  # 제작 의뢰
        ('GET', '/api/commissions', '의뢰 목록'),
        ('POST', '/api/commissions', '의뢰 등록'),
        ('POST', '/api/commissions/{id}/offers', '작가 제안'),
        ('POST', '/api/images', '참고 이미지 업로드'),
        ('GET', '/api/users/me', '역할 확인(제안 가능 여부)'),
    ],
    'AN-MAP-010': [  # 지도
        ('GET', '/api/artworks/nearby?latitude=&longitude=', '주변 작품(지도·목록 폴백 공용)'),
    ],
    'AN-OWN-010': [  # 소유권 목록
        ('GET', '/api/certificates', '내 디지털 소유권'),
        ('POST', '/api/certificates/scan', 'QR·수동 입력 조회'),
    ],
    'AN-OWN-020': [],  # 인증서 상세 — 목록에서 받은 데이터로 그린다
    'AN-OWN-030': [  # QR 스캔
        ('POST', '/api/certificates/scan', '스캔 결과 조회(비로그인 가능)'),
    ],
    'AN-NOTI-010': [  # 알림
        ('GET', '/api/notifications', '알림 목록'),
        ('PATCH', '/api/notifications/{id}/read', '읽음 처리'),
        ('PATCH', '/api/notifications/read-all', '모두 읽음'),
    ],
    'AN-CHAT-010': [  # 문의 목록
        ('GET', '/api/chat/rooms/my', '내 대화 목록'),
    ],
    'AN-CHAT-020': [  # 채팅 상세
        ('GET', '/api/chat/rooms/{roomId}/messages', '이전 대화(참여자만)'),
        ('WS', '/topic/chat/{roomId}', '수신 구독'),
        ('WS', '/app/chat/send', '전송'),
    ],
    'AN-MY-010': [  # 마이페이지
        ('GET', '/api/users/me', '프로필 조회'),
        ('PATCH', '/api/users/me', '역할 전환(userType)'),
    ],
    'AN-MY-020': [  # 관심 작품
        ('GET', '/api/artworks/liked', '하트 누른 작품'),
        ('POST', '/api/artworks/{id}/like', '하트 해제'),
    ],
}
