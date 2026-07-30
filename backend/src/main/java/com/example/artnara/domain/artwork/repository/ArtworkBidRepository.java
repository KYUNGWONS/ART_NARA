package com.example.artnara.domain.artwork.repository;

import com.example.artnara.domain.artwork.entity.ArtworkBid;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ArtworkBidRepository extends JpaRepository<ArtworkBid, Long> {

    List<ArtworkBid> findByArtworkIdOrderByAmountDesc(Long artworkId);

    Optional<ArtworkBid> findFirstByArtworkIdOrderByAmountDesc(Long artworkId);
}
