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

    /** 카테고리 (회화·조각·디지털·사진·일러스트 등) */
    private String category;

    /** 경매 마감 시각 — 스케줄러가 이 시각이 지나면 자동 마감한다. */
    private LocalDateTime auctionEndAt;

    /**
     * 결제 완료로 판매된 작품인지. 피드·상세가 '판매 완료' 를 표시하는 근거다.
     * 주문 테이블을 매번 조회하면 목록에서 N+1 이 되므로 작품에 상태로 들고 있는다.
     */
    @Column(nullable = false, columnDefinition = "boolean default false")
    private boolean sold;

    /**
     * 예약된 작품인지. 직거래라 결제가 만난 뒤에 일어나므로, 예약 시점부터 남이 못 사게 잠근다.
     * 판매 완료({@link #sold})와 구분해야 한다 — 예약은 취소되면 다시 풀린다.
     */
    @Column(nullable = false, columnDefinition = "boolean default false")
    private boolean reserved;

    @Builder
    public Artwork(String title, String artistName, String artistIntroduction,
                   String description, String medium, String sizeInfo, int yearCreated,
                   int price, boolean auction, Integer currentBid,
                   String imageUrl, LocalDateTime auctionEndAt, String category) {
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
        this.category = category == null ? "회화" : category;
    }

    public void updateCurrentBid(int amount) {
        this.currentBid = amount;
    }

    public void closeAuction(String winnerName) {
        this.auctionClosed = true;
        this.winnerName = winnerName;
    }

    /** 결제가 완료되면 판매 완료로 잠근다. 예약 상태는 여기서 끝난다. */
    public void markSold() {
        this.sold = true;
        this.reserved = false;
    }

    /** 환불되면 잠금을 풀어 다시 판매 가능하게 한다. */
    public void markUnsold() {
        this.sold = false;
        this.reserved = false;
    }

    /** 구매자가 예약하면 남이 못 사게 잠근다(결제 전이라 판매 완료는 아니다). */
    public void markReserved() {
        this.reserved = true;
    }

    /** 예약이 취소되면 다시 판매 가능하게 한다. */
    public void releaseReservation() {
        this.reserved = false;
    }
}
