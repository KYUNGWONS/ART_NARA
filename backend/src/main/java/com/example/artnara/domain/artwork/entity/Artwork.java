package com.example.artnara.domain.artwork.entity;

import com.example.artnara.global.common.BaseTimeEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@Entity
@Table(name = "artworks")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Artwork extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String artistName;

    private String artistIntroduction;

    @Column(length = 2000)
    private String description;

    private String medium;

    private String sizeInfo;

    private int yearCreated;

    @Column(nullable = false)
    private int price;

    @Column(nullable = false)
    private boolean auction;

    private Integer currentBid;

    @Column(nullable = false)
    private boolean auctionClosed;

    private String winnerName;

    private String imageUrl;

    /** 경매 마감 시각 — 스케줄러가 이 시각이 지나면 자동 마감한다. */
    private LocalDateTime auctionEndAt;

    @Builder
    public Artwork(String title, String artistName, String artistIntroduction,
                   String description, String medium, String sizeInfo, int yearCreated,
                   int price, boolean auction, Integer currentBid,
                   String imageUrl, LocalDateTime auctionEndAt) {
        this.title = title;
        this.artistName = artistName;
        this.artistIntroduction = artistIntroduction;
        this.description = description;
        this.medium = medium;
        this.sizeInfo = sizeInfo;
        this.yearCreated = yearCreated;
        this.price = price;
        this.auction = auction;
        this.currentBid = currentBid;
        this.auctionClosed = false;
        this.imageUrl = imageUrl == null ? "" : imageUrl;
        this.auctionEndAt = auctionEndAt;
    }

    public void updateCurrentBid(int amount) {
        this.currentBid = amount;
    }

    public void closeAuction(String winnerName) {
        this.auctionClosed = true;
        this.winnerName = winnerName;
    }
}
