package com.example.artnara.domain.artwork.dto;

/** 판매 등록 등으로 새 작품을 작품 저장소에 추가할 때 사용하는 생성 명세. */
public record ArtworkCreate(
        String title,
        String artistName,
        String artistIntroduction,
        String description,
        String medium,
        String size,
        int year,
        int price,
        boolean auction,
        Integer auctionStartPrice,
        String auctionEndDate,
        String imageUrl
) {}
