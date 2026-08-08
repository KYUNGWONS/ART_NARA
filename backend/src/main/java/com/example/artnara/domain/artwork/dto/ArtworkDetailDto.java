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
        /** 이 응답을 보는 사용자가 낙찰자인지 (비로그인이면 false) */
        boolean wonByViewer,
        boolean certified,
        /** 결제 완료로 판매된 작품인지 — 구매 버튼을 잠그는 근거 */
        boolean sold,
        /** 예약된 작품인지 — 결제 전이라 판매 완료와는 다르게 표시한다(예약이 풀리면 다시 살 수 있다) */
        boolean reserved,
        String category,
        List<Bid> bidHistory
) {
    public record Bid(String bidderName, int amount, String bidTime) {}

    public record BidRequest(int amount) {}
}
