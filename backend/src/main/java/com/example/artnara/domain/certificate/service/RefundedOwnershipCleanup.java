package com.example.artnara.domain.certificate.service;

import com.example.artnara.domain.order.entity.ArtOrder;
import com.example.artnara.domain.order.repository.ArtOrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

/**
 * 소유권 회수 기능이 생기기 전에 환불된 주문을 정리한다.
 *
 * 그 시절 환불은 작품만 다시 판매 가능하게 만들고 구매자의 소유권·인증서는 그대로 뒀다 —
 * 같은 작품의 소유자가 둘이 되는 상태가 실제 데이터에 남아 있다.
 * 회수는 여러 번 돌려도 결과가 같아(이미 회수된 건 그대로) 매 부팅마다 안전하다.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class RefundedOwnershipCleanup implements CommandLineRunner {

    private final ArtOrderRepository artOrderRepository;
    private final CertificateService certificateService;

    @Override
    public void run(String... args) {
        int revoked = 0;
        for (ArtOrder order : artOrderRepository.findAll()) {
            if (!order.isRefunded() || order.getCertificateNo() == null) continue;
            certificateService.revoke(order.getCertificateNo());
            revoked++;
        }
        if (revoked > 0) {
            log.info("환불된 주문 {}건의 소유권·인증서를 회수했습니다.", revoked);
        }
    }
}
