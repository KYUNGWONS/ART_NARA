package com.example.unitrip.domain.recommendation.entity;

import com.example.unitrip.domain.user.entity.TravelStyle;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "recommended_activities")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class RecommendedActivity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "place_id")
    private RecommendedPlace place;

    @Column(nullable = false)
    private String name;

    private String imageUrl;

    @Embedded
    private TravelStyle travelStyle;

    @Builder
    public RecommendedActivity(RecommendedPlace place, String name, String imageUrl, TravelStyle travelStyle) {
        this.place = place;
        this.name = name;
        this.imageUrl = imageUrl;
        this.travelStyle = travelStyle;
    }
}
