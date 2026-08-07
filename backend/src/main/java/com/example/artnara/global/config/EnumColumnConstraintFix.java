package com.example.artnara.global.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * 이미 만들어진 개발 DB 에서 enum 컬럼의 CHECK 제약을 걷어낸다.
 *
 * JPA 가 enum 컬럼을 만들 때 값 목록을 CHECK 제약으로 박아 두는데, `ddl-auto=update` 는
 * **그 제약을 갱신하지 않는다**. 그래서 enum 에 값을 추가하면(알림 종류 ORDER_REFUNDED,
 * OAuth 제공자 NAVER 등) 기존 DB 에서만 저장이 500 으로 깨진다 — 둘 다 실제로 겪었다.
 * 컬럼을 varchar 로 바꾸면 제약이 사라지고 이후 값 추가는 코드 수정만으로 끝난다.
 *
 * 엔티티 쪽에도 `columnDefinition = "varchar(...)"` 를 함께 줘야 새로 만드는 DB 에
 * 제약이 다시 생기지 않는다. 여러 번 실행해도 결과가 같고, 실패해도 서버는 뜬다.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class EnumColumnConstraintFix implements CommandLineRunner {

    /** 제약을 풀어야 하는 enum 컬럼들. 새 함정이 나오면 여기에 한 줄 추가한다. */
    private static final List<String> ALTER_STATEMENTS = List.of(
            "ALTER TABLE notifications ALTER COLUMN type VARCHAR(40) NOT NULL",
            "ALTER TABLE users ALTER COLUMN provider VARCHAR(20)"
    );

    private final JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) {
        for (String sql : ALTER_STATEMENTS) {
            try {
                jdbcTemplate.execute(sql);
            } catch (RuntimeException e) {
                // 운영 DB 는 처음부터 varchar 로 생성되므로 여기서 실패하는 게 정상이다.
                log.debug("enum 컬럼 정리를 건너뜁니다 [{}]: {}", sql, e.getMessage());
            }
        }
    }
}
