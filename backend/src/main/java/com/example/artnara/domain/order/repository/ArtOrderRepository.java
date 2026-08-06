package com.example.artnara.domain.order.repository;

import com.example.artnara.domain.order.entity.ArtOrder;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ArtOrderRepository extends JpaRepository<ArtOrder, Long> {

    /** 주문 내역은 반드시 구매자로 스코프한다(남의 주문 노출 방지). */
    List<ArtOrder> findByBuyerIdOrderByIdDesc(Long buyerId);

    boolean existsByArtworkId(Long artworkId);

    /** 리뷰 작성 자격 확인 — 이 사용자가 그 작품을 결제했는가 */
    boolean existsByArtworkIdAndBuyerId(Long artworkId, Long buyerId);

    /** 작가 포트폴리오의 판매 수 */
    long countByArtistName(String artistName);

    /** 작가 정산 — 내가 판 작품의 주문만 (활동명 기준) */
    List<ArtOrder> findByArtistNameOrderByIdDesc(String artistName);
}
