package com.example.artnara.domain.order.repository;

import com.example.artnara.domain.order.entity.ArtOrder;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ArtOrderRepository extends JpaRepository<ArtOrder, Long> {

    /** 주문 내역은 반드시 구매자로 스코프한다(남의 주문 노출 방지). */
    List<ArtOrder> findByBuyerIdOrderByIdDesc(Long buyerId);

    /**
     * 살아 있는 예약이 있는 작품인지. 취소·환불된 건은 세지 않는다 —
     * 그러면 예약을 무른 작품이 영영 다시 예약되지 못한다.
     */
    boolean existsByArtworkIdAndCancelledFalseAndRefundedFalse(Long artworkId);

    /**
     * 리뷰 작성 자격 확인 — 이 사용자가 그 작품을 **결제까지 마쳤고** 환불하지 않았는가.
     * 예약만 하고 결제하지 않은 건은 자격이 없다.
     */
    boolean existsByArtworkIdAndBuyerIdAndPaidTrueAndRefundedFalse(Long artworkId, Long buyerId);

    /** 이 사용자가 이 작품에 걸어 둔 살아 있는 예약이 있는지 (본인 예약 안내용) */
    boolean existsByArtworkIdAndBuyerIdAndCancelledFalseAndRefundedFalse(Long artworkId, Long buyerId);

    /** 작가 포트폴리오의 판매 수 */
    long countByArtistName(String artistName);

    /** 작가 정산 — 내가 판 작품의 주문만 (활동명 기준) */
    List<ArtOrder> findByArtistNameOrderByIdDesc(String artistName);
}
