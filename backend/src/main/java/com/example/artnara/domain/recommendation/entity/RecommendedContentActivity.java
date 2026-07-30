package com.example.artnara.domain.recommendation.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * RecommendedContent 상세 화면의 "이런 걸 해보세요" 목록 항목.
 * RecommendedPlace-RecommendedActivity 관계와 같은 구조를, 지도 큐레이션 카드(RecommendedContent) 쪽에도 둔 것.
 */
@Getter
@Entity
@Table(name = "recommended_content_activities")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class RecommendedContentActivity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "recommended_content_id")
    private RecommendedContent recommendedContent;

    @Column(nullable = false)
    private String name;

    private String imageUrl;

    @Column(length = 500)
    private String description;

    @Builder
    public RecommendedContentActivity(RecommendedContent recommendedContent, String name, String imageUrl, String description) {
        this.recommendedContent = recommendedContent;
        this.name = name;
        this.imageUrl = imageUrl;
        this.description = description;
    }
}
