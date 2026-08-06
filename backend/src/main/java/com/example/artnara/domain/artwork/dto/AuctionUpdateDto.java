package com.example.artnara.domain.artwork.dto;

/**
 * 경매 현황 실시간 알림 페이로드.
 *
 * `/topic/auction/{artworkId}` 로 발행되며, 작품 상세를 보고 있는 사용자는
 * 이 값만 반영하면 된다(전체 상세를 다시 받지 않는다 — 목록·상세 재조회 트래픽 절감).
 */
public record AuctionUpdateDto(
        Long artworkId,
        /** 최신 현재가 */
        int currentBid,
        /** 최고 입찰자 활동명 (입찰이 없으면 null) */
        String topBidderName,
        int bidCount,
        boolean auctionClosed,
        /** 마감됐을 때의 낙찰자 (유찰이면 null) */
        String winnerName
) {}
