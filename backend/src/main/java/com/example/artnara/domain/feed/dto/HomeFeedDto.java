package com.example.artnara.domain.feed.dto;

import java.util.List;

public record HomeFeedDto(
        String curationTitle,
        String curationDescription,
        List<Artwork> recommended,
        List<Artwork> auctions,
        List<Artist> artists
) {
    public record Artwork(
            Long id,
            String title,
            String artistName,
            int price,
            String imageUrl,
            boolean liked,
            boolean auction,
            Integer currentBid,
            String remainingTime
    ) {}

    public record Artist(String name, String introduction) {}
}
