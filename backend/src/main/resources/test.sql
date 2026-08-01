-- ============================================================
-- ArtNara 더미 데이터 (MySQL / H2 호환)
-- SQL_INIT_MODE=always 로 매 부팅마다 실행됨 → INSERT IGNORE 로 중복 방지
-- ============================================================

-- ── 사용자 (users) ──────────────────────────────────────────
-- KOREAN_STUDENT = 작가(미대생), FOREIGN_TOURIST = 컬렉터
INSERT IGNORE INTO users (id, email, nickname, display_name, age, user_type, profile_completed, profile_image_url, region, about_me, created_at, updated_at)
VALUES
(1, 'yejin@example.com', '김예진', '김예진', 25, 'KOREAN_STUDENT', true, 'https://cdn.artnara.com/profile/yejin.jpg', 'SEOUL', '자연의 빛을 기록하는 작가입니다. 유화와 수채를 함께 다룹니다.', NOW(), NOW()),
(2, 'sohyun@example.com', '박소현', '박소현', 23, 'KOREAN_STUDENT', true, 'https://cdn.artnara.com/profile/sohyun.jpg', 'BUSAN', '무채색으로 위로를 건네는 작업을 합니다.', NOW(), NOW()),
(3, 'andrew@example.com', 'Andrew', 'Andrew Kim', 28, 'FOREIGN_TOURIST', true, 'https://cdn.artnara.com/profile/andrew.jpg', 'SEOUL', '신진 작가의 회화를 모으고 있습니다.', NOW(), NOW()),
(4, 'sumin@example.com', '이수민', '이수민', 22, 'KOREAN_STUDENT', true, 'https://cdn.artnara.com/profile/sumin.jpg', 'SEOUL', '빛과 그림자의 경계를 그립니다.', NOW(), NOW()),
(5, 'junhyuk@example.com', '최준혁', '최준혁', 27, 'KOREAN_STUDENT', true, 'https://cdn.artnara.com/profile/junhyuk.jpg', 'JEJU', '바다의 시간을 수집하는 작가입니다.', NOW(), NOW()),
(6, 'emma@example.com', 'Emma', 'Emma Dubois', 24, 'FOREIGN_TOURIST', true, 'https://cdn.artnara.com/profile/emma.jpg', 'SEOUL', '작은 드로잉부터 모으기 시작한 컬렉터입니다.', NOW(), NOW()),
(7, 'daeun@example.com', '정다은', '정다은', 26, 'KOREAN_STUDENT', true, NULL, 'DAEJEON', '숲의 사계를 그립니다. 제작 의뢰도 받습니다.', NOW(), NOW()),
(8, 'lucas@example.com', 'Lucas', 'Lucas Silva', 30, 'FOREIGN_TOURIST', true, 'https://cdn.artnara.com/profile/lucas.jpg', 'JEJU', '사진과 판화를 좋아하는 컬렉터.', NOW(), NOW());

-- ── 주요/관심 장르 (user_interests) ─────────────────────────
INSERT IGNORE INTO user_interests (user_id, interest) VALUES
(1, '회화'), (1, '일러스트'),
(2, '회화'), (2, '드로잉'),
(3, '회화'), (3, '조각'),
(4, '회화'), (4, '사진'),
(5, '회화'), (5, '공예'),
(6, '일러스트'), (6, '디지털'),
(7, '회화'), (7, '일러스트'),
(8, '사진'), (8, '판화');

-- ── 채팅방 (chat_rooms) — 컬렉터(문의) ↔ 작가 ────────────────
INSERT IGNORE INTO chat_rooms (id, creator_id, joiner_id, status, creator_left, joiner_left, created_at)
VALUES
(1, 3, 1, 'ACTIVE', false, false, NOW()),
(2, 6, 2, 'ACTIVE', false, false, NOW()),
(3, 8, 5, 'ACTIVE', false, false, NOW()),
(4, 6, 4, 'ACTIVE', false, false, NOW()),
(5, 3, 7, 'ACTIVE', false, false, NOW()),
(6, 8, 2, 'CLOSED', true, true, NOW()),
(7, 4, NULL, 'WAITING', false, false, NOW()),
(8, 7, NULL, 'WAITING', false, false, NOW());

-- ── 채팅 메시지 (chat_messages) ─────────────────────────────
INSERT IGNORE INTO chat_messages (id, chat_room_id, sender_id, content, message_type, is_read, created_at)
VALUES
(1, 1, 3, '''봄의 정원'' 실물로 볼 수 있을까요?', 'TEXT', true, TIMESTAMPADD(HOUR, -3, NOW())),
(2, 1, 1, '안녕하세요! 작업실이 서촌이라 편하실 때 오시면 보여드릴 수 있어요.', 'TEXT', true, TIMESTAMPADD(HOUR, -2, NOW())),
(3, 1, 3, '이번 주 토요일 오전 괜찮으세요?', 'TEXT', true, TIMESTAMPADD(HOUR, -1, NOW())),
(4, 1, 1, '좋아요! 토요일 오전 11시에 뵐게요. 액자 없이 캔버스 상태로 보여드릴게요.', 'TEXT', false, TIMESTAMPADD(MINUTE, -30, NOW())),
(5, 2, 6, '무채색의 위로, 크기가 어떻게 되나요?', 'TEXT', true, TIMESTAMPADD(HOUR, -5, NOW())),
(6, 2, 2, '45.5 x 53.0cm(10호)이고 캔버스에 유채입니다.', 'TEXT', true, TIMESTAMPADD(HOUR, -4, NOW())),
(7, 2, 6, '감사합니다! 조금 더 고민해볼게요.', 'TEXT', false, TIMESTAMPADD(HOUR, -3, NOW())),
(8, 3, 8, '''고요한 파도'' 시리즈 다른 작업도 있나요?', 'TEXT', true, TIMESTAMPADD(HOUR, -6, NOW())),
(9, 3, 5, '네! 같은 시리즈 3점이 더 있어요. 포트폴리오에서 확인하실 수 있습니다.', 'TEXT', true, TIMESTAMPADD(HOUR, -5, NOW())),
(10, 4, 6, '제작 의뢰도 가능할까요? 반려동물 초상화를 원해요.', 'TEXT', true, TIMESTAMPADD(HOUR, -2, NOW())),
(11, 4, 4, '가능합니다! 제작 의뢰 탭에 예산과 일정 남겨주시면 제안드릴게요.', 'TEXT', false, TIMESTAMPADD(HOUR, -1, NOW())),
(12, 5, 3, '숲 연작 중 소품도 판매하시나요?', 'TEXT', true, TIMESTAMPADD(HOUR, -8, NOW())),
(13, 5, 7, '네, 4호 소품은 상시 판매하고 있어요.', 'TEXT', true, TIMESTAMPADD(HOUR, -7, NOW())),
(14, 5, 3, '[약속 요청] 작품 실물을 보고 싶습니다.', 'APPOINTMENT', true, TIMESTAMPADD(HOUR, -6, NOW()));

-- ── 약속 (appointments) — 작품 실물 확인/직거래 ──────────────
INSERT IGNORE INTO appointments (id, chat_room_id, requester_id, responder_id, status, appointment_time, location, created_at)
VALUES
(1, 1, 3, 1, 'ACCEPTED', '2026-05-10 11:00:00', '서촌 작업실', TIMESTAMPADD(HOUR, -1, NOW())),
(2, 2, 6, 2, 'PENDING', '2026-05-15 15:00:00', '부산 전포동 공유 작업실', TIMESTAMPADD(HOUR, -3, NOW())),
(3, 5, 3, 7, 'ACCEPTED', '2026-05-12 14:00:00', '대전 예술가의집 로비', TIMESTAMPADD(HOUR, -6, NOW())),
(4, 3, 8, 5, 'PENDING', '2026-05-17 13:00:00', '제주 아라동 스튜디오', TIMESTAMPADD(HOUR, -4, NOW()));

-- ── 대학교(미대) 인증 (verifications) ───────────────────────
INSERT IGNORE INTO verifications (id, user_id, type, status, document_url, reject_reason, created_at, updated_at)
VALUES
(1, 1, 'UNIVERSITY', 'APPROVED', 'https://cdn.artnara.com/docs/yejin-univ.jpg', NULL, TIMESTAMPADD(DAY, -30, NOW()), TIMESTAMPADD(DAY, -29, NOW())),
(2, 2, 'UNIVERSITY', 'APPROVED', 'https://cdn.artnara.com/docs/sohyun-univ.jpg', NULL, TIMESTAMPADD(DAY, -25, NOW()), TIMESTAMPADD(DAY, -24, NOW())),
(3, 4, 'UNIVERSITY', 'APPROVED', 'https://cdn.artnara.com/docs/sumin-univ.jpg', NULL, TIMESTAMPADD(DAY, -20, NOW()), TIMESTAMPADD(DAY, -19, NOW())),
(4, 5, 'UNIVERSITY', 'PENDING', 'https://cdn.artnara.com/docs/junhyuk-univ.jpg', NULL, TIMESTAMPADD(DAY, -2, NOW()), TIMESTAMPADD(DAY, -2, NOW())),
(5, 7, 'UNIVERSITY', 'APPROVED', 'https://cdn.artnara.com/docs/daeun-univ.jpg', NULL, TIMESTAMPADD(DAY, -15, NOW()), TIMESTAMPADD(DAY, -14, NOW()));
