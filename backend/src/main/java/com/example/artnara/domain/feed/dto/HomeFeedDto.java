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
            String remainingTime,
            /** 결제 완료로 판매된 작품인지 */
            boolean sold,
            /** 예약된 작품인지 — 결제 전이라 판매 완료와 다르게 표시한다 */
            boolean reserved
    ) {}

    public record Artist(String name, String introduction) {}
}
