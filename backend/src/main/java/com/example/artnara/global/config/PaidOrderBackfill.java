package com.example.artnara.global.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * 직거래 흐름(예약 → 수령 확인 → 결제) 도입 전에 쌓인 주문을 '결제 완료' 로 표시한다.
 *
 * 예전 주문은 만들어지는 순간이 곧 결제였다. 새로 생긴 `paid` 컬럼은 기본값이 false 라
 * 그냥 두면 지난 매출·정산·리뷰 자격이 통째로 사라진다. 인증서 번호가 붙어 있으면
 * 결제까지 끝난 주문이므로 그것을 근거로 채운다.
 *
 * 여러 번 실행해도 결과가 같고, 실패해도 서버는 뜬다.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class PaidOrderBackfill implements CommandLineRunner {

    private final JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) {
        try {
            int updated = jdbcTemplate.update(
                    "UPDATE art_orders SET paid = TRUE"
                            + " WHERE paid = FALSE"
                            + " AND certificate_no IS NOT NULL AND certificate_no <> ''");
            if (updated > 0) {
                log.info("직거래 도입 전 주문 {}건을 결제 완료로 표시했습니다", updated);
            }
        } catch (RuntimeException e) {
            log.debug("주문 결제 여부 이관을 건너뜁니다: {}", e.getMessage());
        }
    }
}
