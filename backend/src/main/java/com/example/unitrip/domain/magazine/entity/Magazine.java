package com.example.unitrip.domain.magazine.entity;

import com.example.unitrip.global.common.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "magazines")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Magazine extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(length = 500)
    private String summary;

    @Lob
    private String content;

    private String coverImageUrl;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MagazineCategory category;

    @Builder
    public Magazine(String title, String summary, String content,
                    String coverImageUrl, MagazineCategory category) {
        this.title = title;
        this.summary = summary;
        this.content = content;
        this.coverImageUrl = coverImageUrl;
        this.category = category;
    }

    public void update(String title, String summary, String content,
                       String coverImageUrl, MagazineCategory category) {
        if (title != null) this.title = title;
        if (summary != null) this.summary = summary;
        if (content != null) this.content = content;
        if (coverImageUrl != null) this.coverImageUrl = coverImageUrl;
        if (category != null) this.category = category;
    }
}
