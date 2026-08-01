package com.example.artnara.domain.order.repository;

import com.example.artnara.domain.order.entity.ArtOrder;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ArtOrderRepository extends JpaRepository<ArtOrder, Long> {

    List<ArtOrder> findAllByOrderByIdDesc();

    boolean existsByArtworkId(Long artworkId);

    /** 작가 포트폴리오의 판매 수 */
    long countByArtistName(String artistName);
}
