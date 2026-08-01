package com.example.artnara.domain.artist.dto;

import java.util.List;

public class ArtistDto {

    public record Response(
            String name,
            String introduction,
            String location,
            int artworkCount,
            long salesCount,
            /** 리뷰 기능이 아직 없어 null (있는 척하지 않는다) */
            Double rating,
            Integer reviewCount,
            List<ArtworkSummary> artworks
    ) {}

    public record ArtworkSummary(
            Long id,
            String title,
            String imageUrl,
            int price,
            boolean auction
    ) {}
}
