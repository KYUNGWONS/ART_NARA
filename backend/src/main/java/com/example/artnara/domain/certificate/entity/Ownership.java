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

@Getter
@Entity
@Table(name = "ownerships")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Ownership extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String certificateNo;

    @Column(nullable = false)
    private String artworkTitle;

    @Column(nullable = false)
    private String artistName;

    /** 표시용 취득일 문자열 (예: "2026-05-12") */
    private String acquiredDate;

    @Column(nullable = false)
    private boolean qrIssued;

    @Builder
    public Ownership(String certificateNo, String artworkTitle, String artistName,
                     String acquiredDate, boolean qrIssued) {
        this.certificateNo = certificateNo;
        this.artworkTitle = artworkTitle;
        this.artistName = artistName;
        this.acquiredDate = acquiredDate;
        this.qrIssued = qrIssued;
    }
}
