package com.example.artnara.domain.content.entity;

import com.example.artnara.domain.user.entity.District;
import com.example.artnara.domain.user.entity.Sido;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.global.common.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.DayOfWeek;
import java.util.ArrayList;
import java.util.List;

@Getter
@Entity
@Table(name = "contents")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Content extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "author_id")
    private User author;

    @Column(nullable = false)
    private String title;

    @Column(length = 200)
    private String shortIntro;

    @Column(length = 2000)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Theme theme;

    @Enumerated(EnumType.STRING)
    private Sido sido;

    private String neighborhood;

    // neighborhood(자유 텍스트)와 병행. 구 단위 필터링(GET /api/contents?districtId=)을 위한 구조화된 위치.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "district_id")
    private District district;

    @ElementCollection(targetClass = Language.class, fetch = FetchType.LAZY)
    @Enumerated(EnumType.STRING)
    @CollectionTable(name = "content_languages", joinColumns = @JoinColumn(name = "content_id"))
    @Column(name = "language")
    private List<Language> languages = new ArrayList<>();

    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "content_images", joinColumns = @JoinColumn(name = "content_id"))
    @OrderColumn(name = "image_order")
    @Column(name = "image_url")
    private List<String> imageUrls = new ArrayList<>();

    @OneToMany(mappedBy = "content", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @OrderBy("orderIndex asc")
    private List<ContentKnot> knots = new ArrayList<>();

    @ElementCollection(targetClass = DayOfWeek.class, fetch = FetchType.LAZY)
    @Enumerated(EnumType.STRING)
    @CollectionTable(name = "content_available_days", joinColumns = @JoinColumn(name = "content_id"))
    @Column(name = "day_of_week")
    private List<DayOfWeek> availableDays = new ArrayList<>();

    @ElementCollection(targetClass = TimeSlot.class, fetch = FetchType.LAZY)
    @Enumerated(EnumType.STRING)
    @CollectionTable(name = "content_available_time_slots", joinColumns = @JoinColumn(name = "content_id"))
    @Column(name = "time_slot")
    private List<TimeSlot> availableTimeSlots = new ArrayList<>();

    private String meetingPoint;

    private Integer maxParticipants;

    private Integer pricePerHour;

    private boolean visible = true;

    @Builder
    public Content(User author, String title, String shortIntro, String description, Theme theme,
                   Sido sido, String neighborhood, District district, List<Language> languages, List<String> imageUrls,
                   List<DayOfWeek> availableDays, List<TimeSlot> availableTimeSlots,
                   String meetingPoint, Integer maxParticipants, Integer pricePerHour) {
        this.author = author;
        this.title = title;
        this.shortIntro = shortIntro;
        this.description = description;
        this.theme = theme;
        this.sido = sido;
        this.neighborhood = neighborhood;
        this.district = district;
        if (languages != null) this.languages = languages;
        if (imageUrls != null) this.imageUrls = imageUrls;
        if (availableDays != null) this.availableDays = availableDays;
        if (availableTimeSlots != null) this.availableTimeSlots = availableTimeSlots;
        this.meetingPoint = meetingPoint;
        this.maxParticipants = maxParticipants;
        this.pricePerHour = pricePerHour;
    }

    public void setVisible(boolean visible) {
        this.visible = visible;
    }

    public void replaceKnots(List<ContentKnot> newKnots) {
        knots.clear();
        for (ContentKnot knot : newKnots) {
            knot.assignContent(this);
            knots.add(knot);
        }
    }

    public void update(String title, String shortIntro, String description, Theme theme,
                        Sido sido, String neighborhood, District district, List<Language> languages, List<String> imageUrls,
                        List<DayOfWeek> availableDays, List<TimeSlot> availableTimeSlots,
                        String meetingPoint, Integer maxParticipants, Integer pricePerHour) {
        if (title != null) this.title = title;
        if (shortIntro != null) this.shortIntro = shortIntro;
        if (description != null) this.description = description;
        if (theme != null) this.theme = theme;
        if (sido != null) this.sido = sido;
        if (neighborhood != null) this.neighborhood = neighborhood;
        if (district != null) this.district = district;
        if (languages != null) this.languages = languages;
        if (imageUrls != null) this.imageUrls = imageUrls;
        if (availableDays != null) this.availableDays = availableDays;
        if (availableTimeSlots != null) this.availableTimeSlots = availableTimeSlots;
        if (meetingPoint != null) this.meetingPoint = meetingPoint;
        if (maxParticipants != null) this.maxParticipants = maxParticipants;
        if (pricePerHour != null) this.pricePerHour = pricePerHour;
    }
}
