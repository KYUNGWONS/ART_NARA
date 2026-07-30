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

import java.time.LocalDate;

@Getter
@Entity
@Table(name = "commissions")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Commission extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(length = 2000)
    private String description;

    @Column(nullable = false)
    private String category;

    @Column(nullable = false)
    private int budget;

    private LocalDate desiredDate;

    private String referenceImageUrl;

    @Column(nullable = false)
    private int notifiedArtistCount;

    @Builder
    public Commission(String title, String description, String category, int budget,
                      LocalDate desiredDate, String referenceImageUrl, int notifiedArtistCount) {
        this.title = title;
        this.description = description;
        this.category = category;
        this.budget = budget;
        this.desiredDate = desiredDate;
        this.referenceImageUrl = referenceImageUrl;
        this.notifiedArtistCount = notifiedArtistCount;
    }
}
