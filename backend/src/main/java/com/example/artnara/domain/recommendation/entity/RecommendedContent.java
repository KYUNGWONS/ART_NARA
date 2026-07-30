package com.example.artnara.domain.recommendation.entity;

import com.example.artnara.domain.user.entity.District;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * 지도(Map)의 구 단위 "컨텐츠 둘러보기" 카드 전용 데이터.
 * RecommendedPlace/RecommendedActivity(TravelStyle 매칭 기반 개인화 추천)와는 별개로,
 * 구별 정적 큐레이션 카드(한 줄 제안 문구·평점)를 보여주기 위한 엔티티다.
 */
@Getter
@Entity
@Table(name = "recommended_contents")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class RecommendedContent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "district_id")
    private District district;

    @Column(nullable = false)
    private String name;

    private String imageUrl;

    // 카드에 보여줄 한 줄 제안 문구 목록(예: "한복 입고 인생샷 남기기"). 카테고리 배지가 아니라 액션 문구다.
    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "recommended_content_suggestions", joinColumns = @JoinColumn(name = "recommended_content_id"))
    @Column(name = "suggestion")
    private List<String> suggestions = new ArrayList<>();

    // 위치 상세(구/동 등 자유 텍스트). 예: "완산구 한옥마을"
    private String location;

    private Double rating;

    // 상세화면 "콘텐츠 아이디어" 태그 목록
    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "recommended_content_content_ideas", joinColumns = @JoinColumn(name = "recommended_content_id"))
    @Column(name = "idea")
    private List<String> contentIdeas = new ArrayList<>();

    @Builder
    public RecommendedContent(District district, String name, String imageUrl,
                              List<String> suggestions, String location, Double rating, List<String> contentIdeas) {
        this.district = district;
        this.name = name;
        this.imageUrl = imageUrl;
        if (suggestions != null) this.suggestions = suggestions;
        this.location = location;
        this.rating = rating;
        if (contentIdeas != null) this.contentIdeas = contentIdeas;
    }
}
