package com.example.artnara.global.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * 판매 등록으로 만들어진 작품에 박혀 있던 판매자 시점 문구를 지운다.
 *
 * 예전 SaleService 는 작가 소개를 "내가 등록한 작품입니다." 로 고정해 저장했는데,
 * 이 문구는 남이 작품을 볼 때 말이 되지 않는다(구매자 화면에 그대로 보였다).
 * 지금은 판매자 프로필의 소개를 쓰므로, 이미 저장된 문구만 비운다.
 *
 * 여러 번 실행해도 결과가 같고, 실패해도 서버는 뜬다.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ArtistIntroductionFix implements CommandLineRunner {

    private final JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) {
        try {
            int updated = jdbcTemplate.update(
                    "UPDATE artworks SET artist_introduction = ''"
                            + " WHERE artist_introduction = ?", "내가 등록한 작품입니다.");
            if (updated > 0) {
                log.info("판매자 시점 작가 소개 {}건을 비웠습니다", updated);
            }
        } catch (RuntimeException e) {
            log.debug("작가 소개 정리를 건너뜁니다: {}", e.getMessage());
        }
    }
}
