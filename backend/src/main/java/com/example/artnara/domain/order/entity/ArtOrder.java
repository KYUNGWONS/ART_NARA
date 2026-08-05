package com.example.artnara.domain.order.entity;

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

/** 작품 주문. (order 는 SQL 예약어라 테이블명은 art_orders 를 사용한다) */
@Getter
@Entity
@Table(name = "art_orders")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ArtOrder extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long artworkId;

    @Column(nullable = false)
    private String artworkTitle;

    @Column(nullable = false)
    private String artistName;

    @Column(nullable = false)
    private int amount;

    @Column(nullable = false)
    private String paymentMethod;

    @Column(nullable = false)
    private String status;

    @Column(nullable = false)
    private String certificateNo;

    /** 표시용 주문일 문자열 (예: "2026-07-31") */
    private String orderedDate;

    /** 구매자(로그인 사용자). 리뷰 작성 자격 확인에 쓴다. */
    private Long buyerId;

    private String buyerName;

    /** 관리자 환불 처리 여부 — 환불하면 작품 판매 잠금도 함께 풀린다. */
    @Column(nullable = false)
    private boolean refunded = false;

    private String refundReason;

    private String refundedAt;

    @Builder
    public ArtOrder(Long artworkId, String artworkTitle, String artistName,
                    int amount, String paymentMethod, String status,
                    String certificateNo, String orderedDate,
                    Long buyerId, String buyerName) {
        this.artworkId = artworkId;
        this.buyerId = buyerId;
        this.buyerName = buyerName;
        this.artworkTitle = artworkTitle;
        this.artistName = artistName;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.status = status;
        this.certificateNo = certificateNo;
        this.orderedDate = orderedDate;
    }

    /** 관리자 환불 처리. 이미 환불된 주문은 다시 처리하지 않는다(서비스에서 검사). */
    public void refund(String reason, String at) {
        this.refunded = true;
        this.refundReason = reason;
        this.refundedAt = at;
        this.status = "환불 완료";
    }

    public void issueCertificate(String certificateNo) {
        this.certificateNo = certificateNo;
    }
}
