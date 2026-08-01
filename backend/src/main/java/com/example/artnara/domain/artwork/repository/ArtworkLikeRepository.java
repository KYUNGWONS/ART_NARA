package com.example.artnara.domain.artwork.repository;

import com.example.artnara.domain.artwork.entity.ArtworkLike;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ArtworkLikeRepository extends JpaRepository<ArtworkLike, Long> {

    Optional<ArtworkLike> findByUserIdAndArtworkId(Long userId, Long artworkId);

    List<ArtworkLike> findByUserId(Long userId);

    long countByArtworkId(Long artworkId);
}
