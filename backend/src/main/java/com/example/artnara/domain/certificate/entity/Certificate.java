package com.example.artnara.domain.certificate.entity;

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

/** QR 코드로 조회되는 디지털 소유권 인증서. */
@Getter
@Entity
@Table(name = "certificates")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Certificate extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String qrCode;

    @Column(nullable = false, unique = true)
    private String certificateNo;

    @Column(nullable = false)
    private String artworkTitle;

    @Column(nullable = false)
    private String artistName;

    @Column(nullable = false)
    private String ownerName;

    /** 표시용 발급일 문자열 (예: "2026-05-12") */
    private String issuedDate;

    /** 인증서에 함께 새기는 작품 사양 (디자인: 제작 연도 · 크기 · 재료) */
    private Integer yearCreated;

    private String sizeInfo;

    private String medium;

    @Column(nullable = false)
    private boolean verified;

    private String note;

    /** 환불로 무효가 된 인증서인지. QR 로 조회하면 무효임을 알려준다. */
    @Column(columnDefinition = "boolean default false")
    private boolean revoked = false;

    public void revoke() {
        this.revoked = true;
        this.verified = false;
        this.note = "환불로 무효 처리된 인증서입니다.";
    }

    @Builder
    public Certificate(String qrCode, String certificateNo, String artworkTitle,
                       String artistName, String ownerName, String issuedDate,
                       Integer yearCreated, String sizeInfo, String medium,
                       boolean verified, String note) {
        this.qrCode = qrCode;
        this.certificateNo = certificateNo;
        this.artworkTitle = artworkTitle;
        this.artistName = artistName;
        this.ownerName = ownerName;
        this.issuedDate = issuedDate;
        this.yearCreated = yearCreated;
        this.sizeInfo = sizeInfo;
        this.medium = medium;
        this.verified = verified;
        this.note = note;
    }
}
