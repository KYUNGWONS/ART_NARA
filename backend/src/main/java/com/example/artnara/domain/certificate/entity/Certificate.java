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

/** QR 코드로 조회되는 디지털 정품 인증서. */
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

    @Column(nullable = false)
    private boolean verified;

    private String note;

    @Builder
    public Certificate(String qrCode, String certificateNo, String artworkTitle,
                       String artistName, String ownerName, String issuedDate,
                       boolean verified, String note) {
        this.qrCode = qrCode;
        this.certificateNo = certificateNo;
        this.artworkTitle = artworkTitle;
        this.artistName = artistName;
        this.ownerName = ownerName;
        this.issuedDate = issuedDate;
        this.verified = verified;
        this.note = note;
    }
}
