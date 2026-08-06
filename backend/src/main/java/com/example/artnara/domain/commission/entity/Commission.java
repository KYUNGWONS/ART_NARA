package com.example.artnara.domain.commission.entity;

import com.example.artnara.global.common.BaseTimeEntity;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

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

    /** 대표 카테고리 — 목록 요약·알림 문구에 쓴다(categories 의 첫 번째). */
    @Column(nullable = false)
    private String category;

    /**
     * 선호 카테고리 전체(복수 선택). 화면에서 여러 개를 고를 수 있으므로
     * 전부 저장해야 알림 대상 작가를 제대로 모을 수 있다.
     */
    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "commission_categories",
            joinColumns = @JoinColumn(name = "commission_id"))
    @Column(name = "category")
    private List<String> categories = new ArrayList<>();

    @Column(nullable = false)
    private int budget;

    private LocalDate desiredDate;

    private String referenceImageUrl;

    @Column(nullable = false)
    private int notifiedArtistCount;

    @Builder
    public Commission(String title, String description, List<String> categories, int budget,
                      LocalDate desiredDate, String referenceImageUrl, int notifiedArtistCount) {
        this.title = title;
        this.description = description;
        this.categories = categories == null ? new ArrayList<>() : List.copyOf(categories);
        // 대표 카테고리는 첫 선택. 목록 요약과 알림 문구에 쓴다.
        this.category = this.categories.isEmpty() ? "기타" : this.categories.get(0);
        this.budget = budget;
        this.desiredDate = desiredDate;
        this.referenceImageUrl = referenceImageUrl;
        this.notifiedArtistCount = notifiedArtistCount;
    }
}
