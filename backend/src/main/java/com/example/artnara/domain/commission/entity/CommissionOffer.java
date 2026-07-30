package com.example.artnara.domain.commission.entity;

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
@Table(name = "commission_offers")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class CommissionOffer extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long commissionId;

    @Column(nullable = false)
    private String artistName;

    @Column(nullable = false)
    private int amount;

    @Column(length = 1000)
    private String message;

    /** 프로토타입 표시용 시각 문자열 (예: "1시간 전", "방금 전") */
    private String offerTime;

    @Builder
    public CommissionOffer(Long commissionId, String artistName, int amount,
                           String message, String offerTime) {
        this.commissionId = commissionId;
        this.artistName = artistName;
        this.amount = amount;
        this.message = message;
        this.offerTime = offerTime;
    }
}
