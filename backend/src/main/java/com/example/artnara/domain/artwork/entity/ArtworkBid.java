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

@Getter
@Entity
@Table(name = "artwork_bids")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ArtworkBid extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long artworkId;

    @Column(nullable = false)
    private String bidderName;

    @Column(nullable = false)
    private int amount;

    /** 프로토타입 표시용 시각 문자열 (예: "12분 전", "방금 전") */
    private String bidTime;

    @Builder
    public ArtworkBid(Long artworkId, String bidderName, int amount, String bidTime) {
        this.artworkId = artworkId;
        this.bidderName = bidderName;
        this.amount = amount;
        this.bidTime = bidTime;
    }
}
