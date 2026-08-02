package com.example.artnara.domain.order.repository;

import com.example.artnara.domain.order.entity.ArtOrder;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ArtOrderRepository extends JpaRepository<ArtOrder, Long> {

    List<ArtOrder> findAllByOrderByIdDesc();

    boolean existsByArtworkId(Long artworkId);

    /** 리뷰 작성 자격 확인 — 이 사용자가 그 작품을 결제했는가 */
    boolean existsByArtworkIdAndBuyerId(Long artworkId, Long buyerId);

    /** 작가 포트폴리오의 판매 수 */
    long countByArtistName(String artistName);
}
