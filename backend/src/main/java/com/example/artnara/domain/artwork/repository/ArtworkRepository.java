package com.example.artnara.domain.artwork.repository;

import com.example.artnara.domain.artwork.entity.Artwork;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface ArtworkRepository extends JpaRepository<Artwork, Long> {

    List<Artwork> findAllByOrderByIdAsc();

    List<Artwork> findByArtistNameOrderByIdDesc(String artistName);

    List<Artwork> findByAuctionTrueAndAuctionClosedFalseAndAuctionEndAtLessThanEqual(LocalDateTime now);
}
