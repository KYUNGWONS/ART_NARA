package com.example.unitrip.domain.recommendation.entity;

import com.example.unitrip.domain.content.entity.Theme;
import com.example.unitrip.domain.user.entity.Sido;
import com.example.unitrip.domain.user.entity.TravelStyle;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Getter
@Entity
@Table(name = "recommended_places")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class RecommendedPlace {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Sido sido;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Theme theme;

    @Column(nullable = false)
    private String name;

    private String imageUrl;

    @Embedded
    private TravelStyle travelStyle;

    // 위치 상세(구/동 등 자유 텍스트). 예: "완산구 교동 한옥마을"
    private String location;

    private Integer estimatedDurationMinutes;

    @Column(length = 1000)
    private String description;

    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "recommended_place_content_ideas", joinColumns = @JoinColumn(name = "place_id"))
    @Column(name = "idea")
    private List<String> contentIdeas = new ArrayList<>();

    @Builder
    public RecommendedPlace(Sido sido, Theme theme, String name, String imageUrl, TravelStyle travelStyle,
                             String location, Integer estimatedDurationMinutes, String description,
                             List<String> contentIdeas) {
        this.sido = sido;
        this.theme = theme;
        this.name = name;
        this.imageUrl = imageUrl;
        this.travelStyle = travelStyle;
        this.location = location;
        this.estimatedDurationMinutes = estimatedDurationMinutes;
        this.description = description;
        if (contentIdeas != null) this.contentIdeas = contentIdeas;
    }
}
