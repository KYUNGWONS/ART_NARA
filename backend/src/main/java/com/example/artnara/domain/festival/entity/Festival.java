package com.example.artnara.domain.festival.entity;

import com.example.artnara.global.common.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Getter
@Entity
@Table(name = "festivals")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Festival extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    private String region;

    @Column(length = 2000)
    private String description;

    private String coverImageUrl;

    private LocalDate startDate;
    private LocalDate endDate;

    @Builder
    public Festival(String name, String region, String description,
                    String coverImageUrl, LocalDate startDate, LocalDate endDate) {
        this.name = name;
        this.region = region;
        this.description = description;
        this.coverImageUrl = coverImageUrl;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    public void update(String name, String region, String description,
                       String coverImageUrl, LocalDate startDate, LocalDate endDate) {
        if (name != null) this.name = name;
        if (region != null) this.region = region;
        if (description != null) this.description = description;
        if (coverImageUrl != null) this.coverImageUrl = coverImageUrl;
        if (startDate != null) this.startDate = startDate;
        if (endDate != null) this.endDate = endDate;
    }
}
