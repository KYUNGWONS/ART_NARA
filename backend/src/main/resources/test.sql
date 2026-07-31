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
(1, 1, 3, 'Hi! I''d love to join the Seochon walking tour!', 'TEXT', true, TIMESTAMPADD(HOUR, -3, NOW())),
(2, 1, 1, '안녕하세요! 반갑습니다 :) 어떤 날짜가 좋으세요?', 'TEXT', true, TIMESTAMPADD(HOUR, -2, NOW())),
(3, 1, 3, 'How about May 10th? Saturday works best for me.', 'TEXT', true, TIMESTAMPADD(HOUR, -1, NOW())),
(4, 1, 1, '좋아요! 5월 10일 토요일에 서촌에서 만나요. 오전 10시 경복궁역 2번 출구에서 만날까요?', 'TEXT', false, TIMESTAMPADD(MINUTE, -30, NOW())),
(5, 2, 6, 'Bonjour! I''m interested in surfing at Haeundae!', 'TEXT', true, TIMESTAMPADD(HOUR, -5, NOW())),
(6, 2, 2, '안녕하세요 Emma! 서핑 재밌을 거예요! 5월 15일 어때요?', 'TEXT', true, TIMESTAMPADD(HOUR, -4, NOW())),
(7, 2, 6, 'Sounds perfect! What should I bring?', 'TEXT', false, TIMESTAMPADD(HOUR, -3, NOW())),
(8, 3, 4, 'こんにちは！夜景ツアーに参加したいです。', 'TEXT', true, TIMESTAMPADD(HOUR, -6, NOW())),
(9, 3, 1, '반갑습니다 Yuki! 한강 야경 치맥 투어 좋은 선택이에요! 영어로 대화 가능합니다 ㅎㅎ', 'TEXT', true, TIMESTAMPADD(HOUR, -5, NOW())),
(10, 4, 8, 'Hey! I saw the Jagalchi market tour. Looks amazing!', 'TEXT', true, TIMESTAMPADD(HOUR, -2, NOW())),
(11, 4, 2, '감사합니다 Lucas! 사진작가시면 시장에서 좋은 사진 많이 찍으실 수 있을 거예요!', 'TEXT', false, TIMESTAMPADD(HOUR, -1, NOW())),
(12, 5, 3, 'I want to try the Hanbok experience at Gyeongbokgung!', 'TEXT', true, TIMESTAMPADD(HOUR, -8, NOW())),
(13, 5, 5, '좋아요 Andrew! 경복궁 한복체험 정말 추천해요. 날짜를 정할까요?', 'TEXT', true, TIMESTAMPADD(HOUR, -7, NOW())),
(14, 5, 3, '[약속 요청] 약속 잡기를 원합니다.', 'APPOINTMENT', true, TIMESTAMPADD(HOUR, -6, NOW()));

-- ── 약속 (appointments) ─────────────────────────────────────
INSERT IGNORE INTO appointments (id, chat_room_id, requester_id, responder_id, status, appointment_time, location, created_at)
VALUES
(1, 1, 3, 1, 'ACCEPTED', '2026-05-10 10:00:00', '경복궁역 2번 출구', TIMESTAMPADD(HOUR, -1, NOW())),
(2, 2, 6, 2, 'PENDING', '2026-05-15 09:00:00', '해운대역 5번 출구', TIMESTAMPADD(HOUR, -3, NOW())),
(3, 5, 3, 5, 'ACCEPTED', '2026-05-12 09:30:00', '경복궁 정문 앞', TIMESTAMPADD(HOUR, -6, NOW())),
(4, 3, 4, 1, 'PENDING', '2026-05-17 18:00:00', '여의나루역 1번 출구', TIMESTAMPADD(HOUR, -4, NOW()));

-- ── 소속 인증 (verifications) ───────────────────────────────
INSERT IGNORE INTO verifications (id, user_id, type, status, document_url, reject_reason, created_at, updated_at)
VALUES
(1, 1, 'UNIVERSITY', 'APPROVED', 'https://cdn.artnara.com/docs/chan-univ.jpg', NULL, TIMESTAMPADD(DAY, -30, NOW()), TIMESTAMPADD(DAY, -29, NOW())),
(2, 2, 'UNIVERSITY', 'APPROVED', 'https://cdn.artnara.com/docs/minji-univ.jpg', NULL, TIMESTAMPADD(DAY, -25, NOW()), TIMESTAMPADD(DAY, -24, NOW())),
(3, 3, 'PASSPORT', 'APPROVED', 'https://cdn.artnara.com/docs/andrew-passport.jpg', NULL, TIMESTAMPADD(DAY, -20, NOW()), TIMESTAMPADD(DAY, -19, NOW())),
(4, 4, 'FLIGHT', 'PENDING', 'https://cdn.artnara.com/docs/yuki-flight.jpg', NULL, TIMESTAMPADD(DAY, -2, NOW()), TIMESTAMPADD(DAY, -2, NOW())),
(5, 5, 'UNIVERSITY', 'APPROVED', 'https://cdn.artnara.com/docs/jiwon-univ.jpg', NULL, TIMESTAMPADD(DAY, -28, NOW()), TIMESTAMPADD(DAY, -27, NOW())),
(6, 6, 'PASSPORT', 'REJECTED', 'https://cdn.artnara.com/docs/emma-passport.jpg', '서류가 불명확합니다. 여권 사진면을 다시 업로드해주세요.', TIMESTAMPADD(DAY, -10, NOW()), TIMESTAMPADD(DAY, -9, NOW())),
(7, 7, 'UNIVERSITY', 'APPROVED', 'https://cdn.artnara.com/docs/hyunwoo-univ.jpg', NULL, TIMESTAMPADD(DAY, -15, NOW()), TIMESTAMPADD(DAY, -14, NOW())),
(8, 8, 'PASSPORT', 'APPROVED', 'https://cdn.artnara.com/docs/lucas-passport.jpg', NULL, TIMESTAMPADD(DAY, -12, NOW()), TIMESTAMPADD(DAY, -11, NOW()));
