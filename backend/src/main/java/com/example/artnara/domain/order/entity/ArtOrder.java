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

    /** 토스 결제 키 — 환불(취소) 호출에 필요하다. mock 결제면 비어 있다. */
    private String paymentKey;

    /**
     * 관리자 환불 처리 여부 — 환불하면 작품 판매 잠금도 함께 풀린다.
     * 기본값을 DB 에도 남긴다: ddl-auto=update 는 기존 행이 있는 테이블에
     * 기본값 없는 NOT NULL 컬럼을 추가하지 못해 스키마 갱신이 실패한다.
     */
    @Column(nullable = false, columnDefinition = "boolean default false")
    private boolean refunded = false;

    private String refundReason;

    private String refundedAt;

    /**
     * 직거래 흐름: 예약 → (만나서 전달) → 양쪽 수령 확인 → 결제.
     *
     * 배송이 없는 서비스라 결제를 만난 뒤로 미룬다. 판매자·구매자가 각각 확인해야
     * 결제가 열리므로 어느 한쪽 주장만으로 거래가 확정되지 않는다.
     * enum 대신 boolean 을 쓰는 이유: enum 컬럼은 값 목록이 CHECK 제약으로 굳어
     * 나중에 단계를 추가할 때 기존 DB 에서 저장이 깨진다(실제로 두 번 겪었다).
     */
    @Column(nullable = false, columnDefinition = "boolean default false")
    private boolean sellerConfirmed = false;

    @Column(nullable = false, columnDefinition = "boolean default false")
    private boolean buyerConfirmed = false;

    /** 결제까지 끝난 주문인지. 정산·소유권은 이게 true 인 것만 센다. */
    @Column(nullable = false, columnDefinition = "boolean default false")
    private boolean paid = false;

    /** 예약이 취소된 주문인지(작품 잠금이 풀린다). */
    @Column(nullable = false, columnDefinition = "boolean default false")
    private boolean cancelled = false;

    /** 양쪽이 모두 확인해야 결제할 수 있다. */
    public boolean isHandoverConfirmed() {
        return sellerConfirmed && buyerConfirmed;
    }

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

    /** 실 PG 로 승인된 결제의 키를 남긴다. */
    public void linkPayment(String paymentKey) {
        this.paymentKey = paymentKey;
    }

    public void issueCertificate(String certificateNo) {
        this.certificateNo = certificateNo;
    }

    /** 판매자가 '전달했어요' 를 눌렀다. */
    public void confirmBySeller() {
        this.sellerConfirmed = true;
        refreshStage();
    }

    /** 구매자가 '받았어요' 를 눌렀다. */
    public void confirmByBuyer() {
        this.buyerConfirmed = true;
        refreshStage();
    }

    /** 결제 완료. 여기서부터 소유권·정산 대상이 된다. */
    public void markPaid(String paymentMethod) {
        this.paid = true;
        this.paymentMethod = paymentMethod;
        this.status = "거래 완료";
    }

    /** 만나기 전에 예약을 무른다. 작품 잠금은 서비스가 함께 푼다. */
    public void cancel() {
        this.cancelled = true;
        this.status = "예약 취소";
    }

    private void refreshStage() {
        this.status = isHandoverConfirmed() ? "결제 대기" : "수령 확인 중";
    }
}
