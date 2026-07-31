package com.example.artnara.domain.artist.dto;

import java.util.List;

public class ArtistDto {

    public record Response(
            String name,
            String introduction,
            String location,
            int artworkCount,
            int salesCount,
            double rating,
            int reviewCount,
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
