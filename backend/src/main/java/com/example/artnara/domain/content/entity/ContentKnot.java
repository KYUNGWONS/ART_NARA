package com.example.artnara.domain.content.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "content_knots")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ContentKnot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "content_id")
    private Content content;

    @Column(nullable = false)
    private int orderIndex;

    @Column(nullable = false)
    private String place;

    @Column(nullable = false)
    private String activity;

    private Integer durationMinutes;

    @Builder
    public ContentKnot(int orderIndex, String place, String activity, Integer durationMinutes) {
        this.orderIndex = orderIndex;
        this.place = place;
        this.activity = activity;
        this.durationMinutes = durationMinutes;
    }

    void assignContent(Content content) {
        this.content = content;
    }
}
