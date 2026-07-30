package com.example.artnara.domain.sale.entity;

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

import java.time.LocalDate;

@Getter
@Entity
@Table(name = "sales")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Sale extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(length = 2000)
    private String description;

    private String medium;

    private String sizeInfo;

    private Integer yearCreated;

    @Column(nullable = false)
    private int buyNowPrice;

    @Column(nullable = false)
    private boolean auctionEnabled;

    private Integer auctionStartPrice;

    private LocalDate auctionEndDate;

    private String imageUrl;

    @Column(nullable = false)
    private String status;

    @Builder
    public Sale(String title, String description, String medium, String sizeInfo,
                Integer yearCreated, int buyNowPrice, boolean auctionEnabled,
                Integer auctionStartPrice, LocalDate auctionEndDate,
                String imageUrl, String status) {
        this.title = title;
        this.description = description;
        this.medium = medium;
        this.sizeInfo = sizeInfo;
        this.yearCreated = yearCreated;
        this.buyNowPrice = buyNowPrice;
        this.auctionEnabled = auctionEnabled;
        this.auctionStartPrice = auctionStartPrice;
        this.auctionEndDate = auctionEndDate;
        this.imageUrl = imageUrl;
        this.status = status;
    }
}
