package com.example.artnara.domain.artwork.dto;

import java.util.List;

public record ArtworkDetailDto(
        Long id,
        String title,
        String artistName,
        String artistIntroduction,
        String description,
        String imageUrl,
        String medium,
        String size,
        int year,
        int price,
        boolean auction,
        Integer currentBid,
        int minBidIncrement,
        String remainingTime,
        boolean auctionClosed,
        String winnerName,
        boolean certified,
        String category,
        List<Bid> bidHistory
) {
    public record Bid(String bidderName, int amount, String bidTime) {}

    public record BidRequest(int amount) {}
}
