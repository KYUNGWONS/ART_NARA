-- ============================================================
-- ArtNara 더미 데이터 (MySQL / H2 호환)
-- SQL_INIT_MODE=always 로 매 부팅마다 실행됨 → INSERT IGNORE 로 중복 방지
-- ============================================================

-- ── 사용자 (users) ──────────────────────────────────────────
INSERT IGNORE INTO users (id, email, nickname, display_name, age, user_type, profile_completed, profile_image_url, region, about_me, planning, vibe, role, dynamic, matching_enabled, created_at, updated_at)
VALUES
(1, 'chan@example.com', '찬이', '김찬', 25, 'KOREAN_STUDENT', true, 'https://cdn.artnara.com/profile/chan.jpg', 'SEOUL', '서울 토박이! 맛집과 숨은 명소를 알려드립니다.', 80, -30, 50, 60, true, NOW(), NOW()),
(2, 'minji@example.com', '민지', '이민지', 23, 'KOREAN_STUDENT', true, 'https://cdn.artnara.com/profile/minji.jpg', 'BUSAN', '부산 바다와 감천문화마을을 함께 탐험해요!', 50, 40, 30, 70, true, NOW(), NOW()),
(3, 'andrew@example.com', 'Andrew', 'Andrew Kim', 28, 'FOREIGN_TOURIST', true, 'https://cdn.artnara.com/profile/andrew.jpg', 'SEOUL', 'American traveler looking for authentic Korean experiences!', -20, 60, -10, 40, true, NOW(), NOW()),
(4, 'yuki@example.com', 'Yuki', 'Yuki Tanaka', 22, 'FOREIGN_TOURIST', true, 'https://cdn.artnara.com/profile/yuki.jpg', 'BUSAN', '韓国の文化に興味があります。よろしく！', 30, -50, 20, 80, true, NOW(), NOW()),
(5, 'jiwon@example.com', '지원', '박지원', 27, 'KOREAN_STUDENT', true, 'https://cdn.artnara.com/profile/jiwon.jpg', 'SEOUL', '한국 전통문화 전공! 한복체험, 다도 등을 소개해드려요.', 90, 20, 70, 30, true, NOW(), NOW()),
(6, 'emma@example.com', 'Emma', 'Emma Dubois', 24, 'FOREIGN_TOURIST', true, 'https://cdn.artnara.com/profile/emma.jpg', 'SEOUL', 'French student studying in Seoul, love K-food and K-pop!', 10, 70, 0, 50, false, NOW(), NOW()),
(7, 'hyunwoo@example.com', '현우', '정현우', 26, 'KOREAN_STUDENT', true, NULL, 'DAEJEON', '대전 카이스트 재학생입니다. 대전/세종 가이드 가능!', 60, 10, 40, 40, true, NOW(), NOW()),
(8, 'lucas@example.com', 'Lucas', 'Lucas Silva', 30, 'FOREIGN_TOURIST', true, 'https://cdn.artnara.com/profile/lucas.jpg', 'JEJU', 'Brazilian photographer, exploring Korea for a month.', -40, 80, 60, 90, true, NOW(), NOW());

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
(1, 0, 'https://cdn.artnara.com/content/seochon.jpg'),
(2, 0, 'https://cdn.artnara.com/content/euljiro.jpg'),
(3, 0, 'https://cdn.artnara.com/content/surfing.jpg'),
(4, 0, 'https://cdn.artnara.com/content/gamcheon.jpg'),
(5, 0, 'https://cdn.artnara.com/content/hanbok.jpg'),
(6, 0, 'https://cdn.artnara.com/content/dado.jpg'),
(7, 0, 'https://cdn.artnara.com/content/chimac.jpg'),
(8, 0, 'https://cdn.artnara.com/content/bread.jpg'),
(9, 0, 'https://cdn.artnara.com/content/jagalchi.jpg'),
(10, 0, 'https://cdn.artnara.com/content/insadong.jpg');

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

-- ── 소속 인증 (verifications) ───────────────────────────────
INSERT IGNORE INTO verifications (id, user_id, type, status, document_url, reject_reason, created_at, updated_at)
VALUES
(1, 1, 'UNIVERSITY', 'APPROVED', 'https://cdn.artnara.com/docs/chan-univ.jpg', NULL, DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 29 DAY)),
(2, 2, 'UNIVERSITY', 'APPROVED', 'https://cdn.artnara.com/docs/minji-univ.jpg', NULL, DATE_SUB(NOW(), INTERVAL 25 DAY), DATE_SUB(NOW(), INTERVAL 24 DAY)),
(3, 3, 'PASSPORT', 'APPROVED', 'https://cdn.artnara.com/docs/andrew-passport.jpg', NULL, DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 19 DAY)),
(4, 4, 'FLIGHT', 'PENDING', 'https://cdn.artnara.com/docs/yuki-flight.jpg', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(5, 5, 'UNIVERSITY', 'APPROVED', 'https://cdn.artnara.com/docs/jiwon-univ.jpg', NULL, DATE_SUB(NOW(), INTERVAL 28 DAY), DATE_SUB(NOW(), INTERVAL 27 DAY)),
(6, 6, 'PASSPORT', 'REJECTED', 'https://cdn.artnara.com/docs/emma-passport.jpg', '서류가 불명확합니다. 여권 사진면을 다시 업로드해주세요.', DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY)),
(7, 7, 'UNIVERSITY', 'APPROVED', 'https://cdn.artnara.com/docs/hyunwoo-univ.jpg', NULL, DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY)),
(8, 8, 'PASSPORT', 'APPROVED', 'https://cdn.artnara.com/docs/lucas-passport.jpg', NULL, DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY));
