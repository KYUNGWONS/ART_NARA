package com.example.artnara.global.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * 이미 만들어진 개발 DB 의 알림 타입 컬럼을 문자열로 되돌린다.
 *
 * 예전 스키마는 알림 종류 목록을 CHECK 제약으로 박아 뒀는데, `ddl-auto=update` 는 그 제약을
 * 갱신하지 않는다. 그래서 새 알림 종류(ORDER_REFUNDED 등)를 저장하려 하면 DB 가 거절한다.
 * 컬럼을 varchar 로 바꾸면 제약이 사라지고, 이후 종류 추가는 코드 수정만으로 끝난다.
 *
 * 여러 번 실행해도 결과가 같고, 실패해도 서버는 뜬다(운영 DB 는 처음부터 varchar 로 생성된다).
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class NotificationTypeColumnFix implements CommandLineRunner {

    private final JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) {
        try {
            jdbcTemplate.execute("ALTER TABLE notifications ALTER COLUMN type VARCHAR(40) NOT NULL");
        } catch (RuntimeException e) {
            log.debug("알림 타입 컬럼 정리를 건너뜁니다: {}", e.getMessage());
        }
    }
}
