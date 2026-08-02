package com.example.artnara.domain.review.entity;

import com.example.artnara.global.common.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 구매자가 남기는 작품·작가 리뷰.
 *
 * 작성 자격은 "그 작품을 실제로 결제한 사용자"로 제한한다(서비스에서 주문을 확인).
 * 작가 이름을 함께 저장해 두어 포트폴리오 평점 집계가 작품 조인 없이 끝난다.
 */
@Getter
@Entity
@Table(name = "reviews",
        uniqueConstraints = @UniqueConstraint(columnNames = {"authorId", "artworkId"}))
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Review extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long artworkId;

    @Column(nullable = false)
    private String artworkTitle;

    @Column(nullable = false)
    private String artistName;

    @Column(nullable = false)
    private Long authorId;

    @Column(nullable = false)
    private String authorNickname;

    /** 1~5 */
    @Column(nullable = false)
    private int rating;

    @Column(nullable = false, length = 1000)
    private String content;

    @Builder
    public Review(Long artworkId, String artworkTitle, String artistName,
                  Long authorId, String authorNickname, int rating, String content) {
        this.artworkId = artworkId;
        this.artworkTitle = artworkTitle;
        this.artistName = artistName;
        this.authorId = authorId;
        this.authorNickname = authorNickname;
        this.rating = rating;
        this.content = content;
    }
}
