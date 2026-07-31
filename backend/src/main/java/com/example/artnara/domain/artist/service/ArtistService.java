package com.example.artnara.domain.artist.service;

import com.example.artnara.domain.artist.dto.ArtistDto;
import com.example.artnara.domain.artwork.entity.Artwork;
import com.example.artnara.domain.artwork.repository.ArtworkRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ArtistService {

    /** 작가 포트폴리오 조회 — 작품 저장소를 작가명 기준으로 묶어 프로필을 구성한다. */
    public ArtistDto.Response getPortfolio(String artistName) {
        List<Artwork> artworks =
                artworkRepository.findByArtistNameOrderByIdDesc(artistName.trim());
        if (artworks.isEmpty()) {
            throw new GlobalException(DomainResultCode.ARTIST_NOT_FOUND);
        }
        // 판매 수·평점은 프로토타입 mock — 작가명 해시로 고정된 값을 만든다.
        int seed = Math.abs(artistName.hashCode());
        int salesCount = 30 + seed % 120;
        double rating = Math.round((4.0 + (seed % 10) / 10.0) * 10) / 10.0;
        int reviewCount = 5 + seed % 40;

        return new ArtistDto.Response(
                artistName.trim(),
                artworks.get(0).getArtistIntroduction(),
                "Seoul, Korea",
                artworks.size(),
                salesCount,
                rating,
                reviewCount,
                artworks.stream()
                        .map(artwork -> new ArtistDto.ArtworkSummary(
                                artwork.getId(), artwork.getTitle(), artwork.getImageUrl(),
                                artwork.isAuction() && artwork.getCurrentBid() != null
                                        ? artwork.getCurrentBid() : artwork.getPrice(),
                                artwork.isAuction()))
                        .toList());
    }

    private final ArtworkRepository artworkRepository;
}
