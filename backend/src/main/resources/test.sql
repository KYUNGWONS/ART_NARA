-- ============================================================
-- UniTrip 더미 데이터 (MySQL / H2 호환)
-- SQL_INIT_MODE=always 로 매 부팅마다 실행됨 → INSERT IGNORE 로 중복 방지
-- ============================================================

-- ── 사용자 (users) ──────────────────────────────────────────
INSERT IGNORE INTO users (id, email, nickname, display_name, age, user_type, profile_completed, profile_image_url, region, about_me, planning, vibe, role, dynamic, matching_enabled, created_at, updated_at)
VALUES
(1, 'chan@example.com', '찬이', '김찬', 25, 'KOREAN_STUDENT', true, 'https://cdn.unitrip.com/profile/chan.jpg', 'SEOUL', '서울 토박이! 맛집과 숨은 명소를 알려드립니다.', 80, -30, 50, 60, true, NOW(), NOW()),
(2, 'minji@example.com', '민지', '이민지', 23, 'KOREAN_STUDENT', true, 'https://cdn.unitrip.com/profile/minji.jpg', 'BUSAN', '부산 바다와 감천문화마을을 함께 탐험해요!', 50, 40, 30, 70, true, NOW(), NOW()),
(3, 'andrew@example.com', 'Andrew', 'Andrew Kim', 28, 'FOREIGN_TOURIST', true, 'https://cdn.unitrip.com/profile/andrew.jpg', 'SEOUL', 'American traveler looking for authentic Korean experiences!', -20, 60, -10, 40, true, NOW(), NOW()),
(4, 'yuki@example.com', 'Yuki', 'Yuki Tanaka', 22, 'FOREIGN_TOURIST', true, 'https://cdn.unitrip.com/profile/yuki.jpg', 'BUSAN', '韓国の文化に興味があります。よろしく！', 30, -50, 20, 80, true, NOW(), NOW()),
(5, 'jiwon@example.com', '지원', '박지원', 27, 'KOREAN_STUDENT', true, 'https://cdn.unitrip.com/profile/jiwon.jpg', 'SEOUL', '한국 전통문화 전공! 한복체험, 다도 등을 소개해드려요.', 90, 20, 70, 30, true, NOW(), NOW()),
(6, 'emma@example.com', 'Emma', 'Emma Dubois', 24, 'FOREIGN_TOURIST', true, 'https://cdn.unitrip.com/profile/emma.jpg', 'SEOUL', 'French student studying in Seoul, love K-food and K-pop!', 10, 70, 0, 50, false, NOW(), NOW()),
(7, 'hyunwoo@example.com', '현우', '정현우', 26, 'KOREAN_STUDENT', true, NULL, 'DAEJEON', '대전 카이스트 재학생입니다. 대전/세종 가이드 가능!', 60, 10, 40, 40, true, NOW(), NOW()),
(8, 'lucas@example.com', 'Lucas', 'Lucas Silva', 30, 'FOREIGN_TOURIST', true, 'https://cdn.unitrip.com/profile/lucas.jpg', 'JEJU', 'Brazilian photographer, exploring Korea for a month.', -40, 80, 60, 90, true, NOW(), NOW());

-- ── 사용자 구사 언어 (user_languages) ───────────────────────
INSERT IGNORE INTO user_languages (user_id, language) VALUES
(1, '한국어'), (1, 'English'),
(2, '한국어'), (2, 'English'),
(3, 'English'), (3, '한국어'),
(4, '日本語'), (4, '한국어'),
(5, '한국어'), (5, 'English'), (5, '中文'),
(6, 'English'), (6, '한국어'),
(7, '한국어'), (7, 'English'),
(8, 'English'), (8, '한국어');

-- ── 사용자 관심사 (user_interests) ──────────────────────────
INSERT IGNORE INTO user_interests (user_id, interest) VALUES
(1, '맛집'), (1, '야경'), (1, '카페투어'),
(2, '바다'), (2, '서핑'), (2, '해산물'),
(3, 'street food'), (3, 'nightlife'), (3, 'hiking'),
(4, 'temple'), (4, 'shopping'), (4, 'photography'),
(5, '한복'), (5, '다도'), (5, '궁궐'),
(6, 'K-pop'), (6, 'cooking class'), (6, 'vintage shopping'),
(7, '과학관'), (7, '빵'), (7, '자연'),
(8, 'nature'), (8, 'photography'), (8, 'surfing');

-- ── 콘텐츠/활동 (contents) ──────────────────────────────────
INSERT IGNORE INTO contents (id, author_id, title, short_intro, description, theme, sido, neighborhood, meeting_point, max_participants, price_per_hour, visible, created_at, updated_at)
VALUES
(1, 1, '서촌 골목 산책', '서촌 골목골목 숨은 명소를 함께 걸어요', '경복궁 서쪽 서촌 골목골목을 걸으며 숨겨진 카페와 갤러리를 탐방합니다. 인왕산 자락길도 포함!', 'PLACE', 'SEOUL', '서촌', '경복궁역 2번 출구', 4, 5000, true, NOW(), NOW()),
(2, 1, '을지로 레트로 탐방', '힙지로 골목 노포와 인쇄소 카페 탐방', '힙지로의 골목 공장, 노포 맛집, 인쇄소 카페를 돌아보는 레트로 감성 투어.', 'PLACE', 'SEOUL', '을지로', '을지로3가역 4번 출구', 4, 7000, true, NOW(), NOW()),
(3, 2, '해운대 서핑 체험', '바다에서 서핑 기초부터 배워요', '해운대 해변에서 서핑 기초를 배우고 함께 바다를 즐겨요!', 'ACTIVITY', 'BUSAN', '해운대', '해운대역 5번 출구', 3, 15000, true, NOW(), NOW()),
(4, 2, '감천문화마을 포토 투어', '알록달록 감천마을에서 인생샷 찍기', '알록달록한 감천문화마을에서 인생샷을 찍어봐요. 벽화와 조형물 포인트 안내!', 'PLACE', 'BUSAN', '감천문화마을', '감천문화마을 입구', 6, 5000, true, NOW(), NOW()),
(5, 5, '경복궁 한복 체험', '한복 입고 경복궁 거닐기', '한복을 입고 경복궁을 거닐며 한국 전통문화를 체험합니다. 한복 대여 포함!', 'ACTIVITY', 'SEOUL', '경복궁', '경복궁 정문 앞', 4, 12000, true, NOW(), NOW()),
(6, 5, '북촌 다도 체험', '한옥에서 배우는 전통 다도', '북촌 한옥에서 전통 다도를 배우고 한국 차를 맛봅니다.', 'ACTIVITY', 'SEOUL', '북촌', '북촌한옥마을 입구', 4, 10000, true, NOW(), NOW()),
(7, 1, '한강 야경 치맥', '치킨과 맥주로 즐기는 한강 야경', '여의도 한강공원에서 치킨과 맥주를 즐기며 야경을 감상합니다.', 'ACTIVITY', 'SEOUL', '여의도', '여의나루역 1번 출구', 6, 8000, true, NOW(), NOW()),
(8, 7, '대전 빵 투어', '성심당부터 시작하는 빵집 투어', '대전의 유명 빵집 성심당부터 시작하는 빵 투어! 빵 맛집 5곳을 돌아봅니다.', 'PLACE', 'DAEJEON', '은행동', '대전역 동광장', 5, 4000, true, NOW(), NOW()),
(9, 2, '부산 자갈치 시장 투어', '신선한 해산물과 시장 문화 체험', '자갈치 시장에서 신선한 해산물을 맛보고 시장 문화를 체험합니다.', 'PLACE', 'BUSAN', '자갈치', '자갈치시장역 3번 출구', 6, 6000, true, NOW(), NOW()),
(10, 5, '인사동 공방 체험', '도자기 또는 한지 공예 체험', '인사동에서 도자기 만들기 또는 한지 공예를 체험합니다.', 'ACTIVITY', 'SEOUL', '인사동', '안국역 6번 출구', 4, 9000, false, NOW(), NOW());

-- ── 콘텐츠 대표/추가 사진 (content_images) ──────────────────
INSERT IGNORE INTO content_images (content_id, image_order, image_url) VALUES
(1, 0, 'https://cdn.unitrip.com/content/seochon.jpg'),
(2, 0, 'https://cdn.unitrip.com/content/euljiro.jpg'),
(3, 0, 'https://cdn.unitrip.com/content/surfing.jpg'),
(4, 0, 'https://cdn.unitrip.com/content/gamcheon.jpg'),
(5, 0, 'https://cdn.unitrip.com/content/hanbok.jpg'),
(6, 0, 'https://cdn.unitrip.com/content/dado.jpg'),
(7, 0, 'https://cdn.unitrip.com/content/chimac.jpg'),
(8, 0, 'https://cdn.unitrip.com/content/bread.jpg'),
(9, 0, 'https://cdn.unitrip.com/content/jagalchi.jpg'),
(10, 0, 'https://cdn.unitrip.com/content/insadong.jpg');

-- ── 콘텐츠 가능 언어 (content_languages) ─────────────────────
INSERT IGNORE INTO content_languages (content_id, language) VALUES
(1, 'KOREAN'), (1, 'ENGLISH'),
(2, 'KOREAN'), (2, 'ENGLISH'),
(3, 'KOREAN'), (3, 'ENGLISH'),
(4, 'KOREAN'), (4, 'ENGLISH'),
(5, 'KOREAN'), (5, 'ENGLISH'),
(6, 'KOREAN'), (6, 'ENGLISH'),
(7, 'KOREAN'), (7, 'ENGLISH'),
(8, 'KOREAN'), (8, 'ENGLISH'), (8, 'JAPANESE'),
(9, 'KOREAN'), (9, 'ENGLISH'),
(10, 'KOREAN'), (10, 'ENGLISH');

-- ── 콘텐츠 매듭(장소·활동·소요시간) (content_knots) ──────────
INSERT IGNORE INTO content_knots (id, content_id, order_index, place, activity, duration_minutes) VALUES
(1, 1, 1, '서촌 골목', '도보 투어', 120),
(2, 2, 1, '을지로 골목', '도보 투어', 120),
(3, 3, 1, '해운대 해변', '서핑', 150),
(4, 4, 1, '감천문화마을', '사진촬영', 90),
(5, 5, 1, '경복궁', '한복 체험', 150),
(6, 6, 1, '북촌 한옥마을', '다도', 90),
(7, 7, 1, '여의도 한강공원', '치맥', 150),
(8, 8, 1, '대전 은행동', '빵 투어', 120),
(9, 9, 1, '자갈치시장', '시장 투어', 90),
(10, 10, 1, '인사동', '공방 체험', 120);

-- ── 콘텐츠 이용 가능 요일 (content_available_days) ──────────
INSERT IGNORE INTO content_available_days (content_id, day_of_week) VALUES
(1, 'TUESDAY'), (1, 'WEDNESDAY'), (1, 'SATURDAY'), (1, 'SUNDAY'),
(2, 'FRIDAY'), (2, 'SATURDAY'),
(3, 'MONDAY'), (3, 'WEDNESDAY'), (3, 'FRIDAY'), (3, 'SATURDAY'), (3, 'SUNDAY'),
(4, 'TUESDAY'), (4, 'THURSDAY'), (4, 'SATURDAY'),
(5, 'MONDAY'), (5, 'TUESDAY'), (5, 'WEDNESDAY'), (5, 'THURSDAY'), (5, 'FRIDAY'), (5, 'SATURDAY'), (5, 'SUNDAY'),
(6, 'WEDNESDAY'), (6, 'SATURDAY'), (6, 'SUNDAY'),
(7, 'FRIDAY'), (7, 'SATURDAY'),
(8, 'SATURDAY'), (8, 'SUNDAY'),
(9, 'MONDAY'), (9, 'TUESDAY'), (9, 'WEDNESDAY'), (9, 'THURSDAY'), (9, 'FRIDAY'), (9, 'SATURDAY'),
(10, 'THURSDAY'), (10, 'FRIDAY');

-- ── 콘텐츠 가능 시간대 (content_available_time_slots) ────────
INSERT IGNORE INTO content_available_time_slots (content_id, time_slot) VALUES
(1, 'MORNING_TO_LUNCH'),
(2, 'LUNCH_TO_DINNER'),
(3, 'MORNING_TO_LUNCH'),
(4, 'LUNCH_TO_DINNER'),
(5, 'MORNING_TO_LUNCH'),
(6, 'LUNCH_TO_DINNER'),
(7, 'DINNER_TO_NIGHT'),
(8, 'MORNING_TO_LUNCH'),
(9, 'LUNCH_TO_DINNER'),
(10, 'LUNCH_TO_DINNER');

-- ── 예약 (bookings) ─────────────────────────────────────────
INSERT IGNORE INTO bookings (id, content_id, guest_id, mate_id, date, start_time, end_time, total_price, status, created_at, updated_at)
VALUES
(1, 1, 3, 1, '2026-05-10', '10:00:00', '13:00:00', 15000, 'CONFIRMED', NOW(), NOW()),
(2, 5, 3, 5, '2026-05-12', '09:30:00', '12:30:00', 35000, 'CONFIRMED', NOW(), NOW()),
(3, 3, 6, 2, '2026-05-15', '09:00:00', '12:00:00', 45000, 'PENDING_PAYMENT', NOW(), NOW()),
(4, 7, 4, 1, '2026-05-17', '18:00:00', '21:00:00', 30000, 'PENDING_PAYMENT', NOW(), NOW()),
(5, 2, 8, 1, '2026-05-20', '13:00:00', '17:00:00', 20000, 'CONFIRMED', NOW(), NOW()),
(6, 4, 3, 2, '2026-05-22', '14:00:00', '17:00:00', 10000, 'COMPLETED', NOW(), NOW()),
(7, 6, 6, 5, '2026-05-25', '14:00:00', '16:00:00', 25000, 'CANCELLED', NOW(), NOW()),
(8, 8, 4, 7, '2026-05-28', '10:00:00', '13:00:00', 12000, 'PENDING_PAYMENT', NOW(), NOW()),
(9, 9, 8, 2, '2026-06-01', '12:00:00', '15:00:00', 18000, 'CONFIRMED', NOW(), NOW()),
(10, 1, 6, 1, '2026-06-05', '10:00:00', '13:00:00', 15000, 'PENDING_PAYMENT', NOW(), NOW());

-- ── 채팅방 (chat_rooms) ─────────────────────────────────────
INSERT IGNORE INTO chat_rooms (id, creator_id, joiner_id, status, creator_left, joiner_left, created_at)
VALUES
(1, 3, 1, 'ACTIVE', false, false, NOW()),
(2, 6, 2, 'ACTIVE', false, false, NOW()),
(3, 4, 1, 'ACTIVE', false, false, NOW()),
(4, 8, 2, 'ACTIVE', false, false, NOW()),
(5, 3, 5, 'ACTIVE', false, false, NOW()),
(6, 6, 5, 'CLOSED', true, true, NOW()),
(7, 4, NULL, 'WAITING', false, false, NOW()),
(8, 8, NULL, 'WAITING', false, false, NOW());

-- ── 채팅 메시지 (chat_messages) ─────────────────────────────
INSERT IGNORE INTO chat_messages (id, chat_room_id, sender_id, content, message_type, is_read, created_at)
VALUES
(1, 1, 3, 'Hi! I''d love to join the Seochon walking tour!', 'TEXT', true, DATE_SUB(NOW(), INTERVAL 3 HOUR)),
(2, 1, 1, '안녕하세요! 반갑습니다 :) 어떤 날짜가 좋으세요?', 'TEXT', true, DATE_SUB(NOW(), INTERVAL 2 HOUR)),
(3, 1, 3, 'How about May 10th? Saturday works best for me.', 'TEXT', true, DATE_SUB(NOW(), INTERVAL 1 HOUR)),
(4, 1, 1, '좋아요! 5월 10일 토요일에 서촌에서 만나요. 오전 10시 경복궁역 2번 출구에서 만날까요?', 'TEXT', false, DATE_SUB(NOW(), INTERVAL 30 MINUTE)),
(5, 2, 6, 'Bonjour! I''m interested in surfing at Haeundae!', 'TEXT', true, DATE_SUB(NOW(), INTERVAL 5 HOUR)),
(6, 2, 2, '안녕하세요 Emma! 서핑 재밌을 거예요! 5월 15일 어때요?', 'TEXT', true, DATE_SUB(NOW(), INTERVAL 4 HOUR)),
(7, 2, 6, 'Sounds perfect! What should I bring?', 'TEXT', false, DATE_SUB(NOW(), INTERVAL 3 HOUR)),
(8, 3, 4, 'こんにちは！夜景ツアーに参加したいです。', 'TEXT', true, DATE_SUB(NOW(), INTERVAL 6 HOUR)),
(9, 3, 1, '반갑습니다 Yuki! 한강 야경 치맥 투어 좋은 선택이에요! 영어로 대화 가능합니다 ㅎㅎ', 'TEXT', true, DATE_SUB(NOW(), INTERVAL 5 HOUR)),
(10, 4, 8, 'Hey! I saw the Jagalchi market tour. Looks amazing!', 'TEXT', true, DATE_SUB(NOW(), INTERVAL 2 HOUR)),
(11, 4, 2, '감사합니다 Lucas! 사진작가시면 시장에서 좋은 사진 많이 찍으실 수 있을 거예요!', 'TEXT', false, DATE_SUB(NOW(), INTERVAL 1 HOUR)),
(12, 5, 3, 'I want to try the Hanbok experience at Gyeongbokgung!', 'TEXT', true, DATE_SUB(NOW(), INTERVAL 8 HOUR)),
(13, 5, 5, '좋아요 Andrew! 경복궁 한복체험 정말 추천해요. 날짜를 정할까요?', 'TEXT', true, DATE_SUB(NOW(), INTERVAL 7 HOUR)),
(14, 5, 3, '[약속 요청] 약속 잡기를 원합니다.', 'APPOINTMENT', true, DATE_SUB(NOW(), INTERVAL 6 HOUR));

-- ── 약속 (appointments) ─────────────────────────────────────
INSERT IGNORE INTO appointments (id, chat_room_id, requester_id, responder_id, status, appointment_time, location, created_at)
VALUES
(1, 1, 3, 1, 'ACCEPTED', '2026-05-10 10:00:00', '경복궁역 2번 출구', DATE_SUB(NOW(), INTERVAL 1 HOUR)),
(2, 2, 6, 2, 'PENDING', '2026-05-15 09:00:00', '해운대역 5번 출구', DATE_SUB(NOW(), INTERVAL 3 HOUR)),
(3, 5, 3, 5, 'ACCEPTED', '2026-05-12 09:30:00', '경복궁 정문 앞', DATE_SUB(NOW(), INTERVAL 6 HOUR)),
(4, 3, 4, 1, 'PENDING', '2026-05-17 18:00:00', '여의나루역 1번 출구', DATE_SUB(NOW(), INTERVAL 4 HOUR));

-- ── 페스티벌 (festivals) ────────────────────────────────────
INSERT IGNORE INTO festivals (id, name, region, description, cover_image_url, start_date, end_date, created_at, updated_at)
VALUES
(1, '서울 불꽃축제', '서울', '여의도 한강에서 펼쳐지는 대규모 불꽃축제! 국내외 팀이 참여하는 화려한 불꽃쇼를 감상하세요.', 'https://cdn.unitrip.com/festival/fireworks.jpg', '2026-10-03', '2026-10-03', NOW(), NOW()),
(2, '부산 국제영화제 (BIFF)', '부산', '아시아 최대 영화제! 해운대 영화의전당에서 세계 영화를 만나보세요.', 'https://cdn.unitrip.com/festival/biff.jpg', '2026-10-07', '2026-10-16', NOW(), NOW()),
(3, '진해 벚꽃축제', '경남', '진해 군항제와 함께하는 벚꽃 축제. 여좌천 벚꽃터널이 압권!', 'https://cdn.unitrip.com/festival/cherry.jpg', '2026-03-28', '2026-04-06', NOW(), NOW()),
(4, '보령 머드축제', '충남', '보령 대천해수욕장에서 진흙을 온몸에 바르고 즐기는 여름 축제!', 'https://cdn.unitrip.com/festival/mud.jpg', '2026-07-17', '2026-07-26', NOW(), NOW()),
(5, '안동 탈춤 페스티벌', '경북', '유네스코 무형문화유산 안동 하회탈춤을 직접 볼 수 있는 축제.', 'https://cdn.unitrip.com/festival/mask.jpg', '2026-09-25', '2026-10-04', NOW(), NOW()),
(6, '서울 빛초롱축제', '서울', '청계천을 수놓는 아름다운 등불 축제. 가을 밤 산책하기 좋아요.', 'https://cdn.unitrip.com/festival/lantern.jpg', '2026-11-06', '2026-11-22', NOW(), NOW()),
(7, '제주 들불축제', '제주', '제주 새별오름에서 펼쳐지는 들불놓기 행사. 장관입니다!', 'https://cdn.unitrip.com/festival/fire.jpg', '2026-03-12', '2026-03-14', NOW(), NOW());

-- ── 매거진 (magazines) ──────────────────────────────────────
INSERT IGNORE INTO magazines (id, title, summary, content, cover_image_url, category, created_at, updated_at)
VALUES
(1, '찬이와 Andrew의 서촌 하루', '한국인 메이트 찬이와 외국인 Andrew가 함께한 서촌 골목 산책 이야기', '서촌은 경복궁 서쪽에 위치한 조용한 마을입니다. 찬이는 Andrew에게 숨겨진 카페와 골목 갤러리를 소개해주었고, Andrew는 한국 전통 건축의 아름다움에 감탄했습니다. 통인시장에서 도시락 카페를 체험하고, 수성동 계곡에서 잠시 쉬어가기도 했습니다. "한국의 진짜 모습을 볼 수 있었어요!" Andrew의 후기에 찬이도 뿌듯했습니다.', 'https://cdn.unitrip.com/magazine/seochon-story.jpg', 'BEST_MATE_STORY', NOW(), NOW()),
(2, 'UniTrip 이용 가이드', 'UniTrip을 처음 사용하는 분들을 위한 완벽 가이드', '1. 회원가입 후 프로필을 완성하세요. 여행 스타일과 관심사를 입력하면 더 나은 매칭이 가능합니다. 2. 마음에 드는 콘텐츠를 찾아 예약하세요. 3. 채팅방에서 메이트와 소통하며 약속을 잡으세요. 4. 만남 후 리뷰를 남겨주세요! 5. 소속 인증(대학교, 여권 등)을 하면 신뢰도가 올라갑니다.', 'https://cdn.unitrip.com/magazine/guide.jpg', 'KNOT_GUIDE', NOW(), NOW()),
(3, '한국 여행 Q&A: 자주 묻는 질문 TOP 10', '외국인 관광객들이 가장 많이 묻는 한국 여행 질문 모음', 'Q1. 교통카드는 어디서 사나요? A. 편의점이나 지하철역에서 구매 가능합니다. Q2. 한국어를 못해도 괜찮나요? A. UniTrip 메이트가 도와드려요! Q3. 팁 문화가 있나요? A. 한국에는 팁 문화가 없습니다. Q4. 현금이 필요한가요? A. 대부분의 장소에서 카드 결제가 가능합니다.', 'https://cdn.unitrip.com/magazine/qna.jpg', 'QNA_TIPS', NOW(), NOW()),
(4, '민지와 Emma의 해운대 서핑 데이', '부산 메이트 민지와 프랑스인 Emma의 서핑 도전기!', '처음에 겁이 났다는 Emma. 하지만 민지의 도움으로 보드 위에 서는 데 성공! 서핑 후에는 해운대 포장마차에서 씨앗호떡을 먹으며 부산의 밤을 즐겼습니다. "Best day in Korea so far!" - Emma', 'https://cdn.unitrip.com/magazine/surfing-story.jpg', 'BEST_MATE_STORY', NOW(), NOW()),
(5, '한국 길거리 음식 완전정복', '떡볶이부터 호떡까지, 한국 길거리 음식 A to Z', '한국의 길거리 음식은 세계적으로 유명합니다. 떡볶이, 순대, 어묵, 호떡, 붕어빵, 계란빵, 핫도그(명랑핫도그), 타코야키 등 다양한 메뉴가 있습니다. 서울에서는 명동, 홍대, 광장시장이 유명하고, 부산에서는 BIFF 광장과 국제시장을 추천합니다.', 'https://cdn.unitrip.com/magazine/streetfood.jpg', 'QNA_TIPS', NOW(), NOW());

-- ── 알림 (notifications) ────────────────────────────────────
INSERT IGNORE INTO notifications (id, user_id, type, title, body, is_read, created_at, updated_at)
VALUES
(1, 3, 'BOOKING_CONFIRMED', '예약이 확정되었습니다', '서촌 골목 산책 (5월 10일) 예약이 확정되었습니다. 메이트 찬이와의 만남을 준비하세요!', true, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(2, 3, 'APPOINTMENT_REMINDER', '약속 2시간 전입니다', '오늘 오전 10시 경복궁역 2번 출구에서 찬이를 만납니다. 시간에 맞춰 도착해주세요!', false, DATE_SUB(NOW(), INTERVAL 2 HOUR), DATE_SUB(NOW(), INTERVAL 2 HOUR)),
(3, 1, 'NEW_MESSAGE', '새로운 메시지가 도착했습니다', 'Andrew님이 메시지를 보냈습니다: "How about May 10th?"', true, DATE_SUB(NOW(), INTERVAL 1 HOUR), DATE_SUB(NOW(), INTERVAL 1 HOUR)),
(4, 6, 'PAYMENT_PENDING', '결제를 완료해주세요', '해운대 서핑 체험 (5월 15일) 예약의 결제가 아직 완료되지 않았습니다. 24시간 내에 결제해주세요.', false, DATE_SUB(NOW(), INTERVAL 5 HOUR), DATE_SUB(NOW(), INTERVAL 5 HOUR)),
(5, 2, 'APPOINTMENT_REQUEST', '새로운 약속 요청', 'Emma님이 약속을 요청했습니다. 5월 15일 09:00 해운대역 5번 출구', false, DATE_SUB(NOW(), INTERVAL 3 HOUR), DATE_SUB(NOW(), INTERVAL 3 HOUR)),
(6, 3, 'BOOKING_CONFIRMED', '예약이 확정되었습니다', '경복궁 한복 체험 (5월 12일) 예약이 확정되었습니다.', true, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(7, 1, 'REVIEW_REQUEST', '리뷰를 작성해주세요', 'Andrew님과의 감천문화마을 포토 투어는 어떠셨나요? 리뷰를 남겨주세요!', false, NOW(), NOW()),
(8, 4, 'HOT_THIS_WEEK', '이번 주 인기 콘텐츠', '서촌 골목 산책이 이번 주 가장 인기 있는 콘텐츠입니다. 확인해보세요!', false, NOW(), NOW()),
(9, 8, 'EVENT_STARTED', '페스티벌이 시작되었습니다', '보령 머드축제가 오늘 시작합니다! 관심 있으시면 확인해보세요.', false, NOW(), NOW()),
(10, 5, 'UNREAD_MESSAGES', '읽지 않은 메시지가 있습니다', '3개의 읽지 않은 메시지가 있습니다. 확인해주세요.', false, NOW(), NOW());

-- ── 소속 인증 (verifications) ───────────────────────────────
INSERT IGNORE INTO verifications (id, user_id, type, status, document_url, reject_reason, created_at, updated_at)
VALUES
(1, 1, 'UNIVERSITY', 'APPROVED', 'https://cdn.unitrip.com/docs/chan-univ.jpg', NULL, DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 29 DAY)),
(2, 2, 'UNIVERSITY', 'APPROVED', 'https://cdn.unitrip.com/docs/minji-univ.jpg', NULL, DATE_SUB(NOW(), INTERVAL 25 DAY), DATE_SUB(NOW(), INTERVAL 24 DAY)),
(3, 3, 'PASSPORT', 'APPROVED', 'https://cdn.unitrip.com/docs/andrew-passport.jpg', NULL, DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 19 DAY)),
(4, 4, 'FLIGHT', 'PENDING', 'https://cdn.unitrip.com/docs/yuki-flight.jpg', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(5, 5, 'UNIVERSITY', 'APPROVED', 'https://cdn.unitrip.com/docs/jiwon-univ.jpg', NULL, DATE_SUB(NOW(), INTERVAL 28 DAY), DATE_SUB(NOW(), INTERVAL 27 DAY)),
(6, 6, 'PASSPORT', 'REJECTED', 'https://cdn.unitrip.com/docs/emma-passport.jpg', '서류가 불명확합니다. 여권 사진면을 다시 업로드해주세요.', DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY)),
(7, 7, 'UNIVERSITY', 'APPROVED', 'https://cdn.unitrip.com/docs/hyunwoo-univ.jpg', NULL, DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY)),
(8, 8, 'PASSPORT', 'APPROVED', 'https://cdn.unitrip.com/docs/lucas-passport.jpg', NULL, DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY));

-- ── 위시리스트 폴더 (wishlist_folders) ──────────────────────
INSERT IGNORE INTO wishlist_folders (id, owner_id, name, created_at, updated_at)
VALUES
(1, 3, 'Seoul Must-Do', DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
(2, 3, 'Food Tours', DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY)),
(3, 6, 'Mes favoris', DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY)),
(4, 4, 'お気に入り', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
(5, 8, 'Photo Spots', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY));

-- ── 위시리스트 항목 (wishlist_items) ────────────────────────
INSERT IGNORE INTO wishlist_items (id, folder_id, content_id, memo, created_at, updated_at)
VALUES
(1, 1, 1, 'Looks like an amazing walking tour!', DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
(2, 1, 5, 'Must try Hanbok experience!', DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY)),
(3, 1, 6, 'Tea ceremony sounds interesting', DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY)),
(4, 2, 2, 'Retro vibes in Euljiro', DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY)),
(5, 2, 7, 'Chicken and beer by the Han River - YES!', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY)),
(6, 3, 5, 'Essayer le hanbok!', DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY)),
(7, 3, 3, 'Surf à Busan!', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY)),
(8, 4, 7, '夜景がきれいそう', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
(9, 4, 4, '写真を撮りたい', DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),
(10, 5, 4, 'Great photo opportunity at Gamcheon Village', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
(11, 5, 9, 'Jagalchi market - lots of character', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY));
