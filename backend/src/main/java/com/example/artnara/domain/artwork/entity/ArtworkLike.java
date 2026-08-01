package com.example.artnara.domain.artwork.entity;

import com.example.artnara.global.common.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/** 관심 작품(하트). 사용자당 작품 하나에 한 번만 눌린다. */
@Getter
@Entity
@Table(name = "artwork_likes",
        uniqueConstraints = @UniqueConstraint(columnNames = {"userId", "artworkId"}))
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ArtworkLike extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private Long artworkId;

    @Builder
    public ArtworkLike(Long userId, Long artworkId) {
        this.userId = userId;
        this.artworkId = artworkId;
    }
}
