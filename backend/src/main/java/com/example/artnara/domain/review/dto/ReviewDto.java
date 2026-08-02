package com.example.artnara.domain.review.dto;

import com.example.artnara.domain.review.entity.Review;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.List;

public class ReviewDto {

    @Schema(name = "ReviewCreateRequest")
    public record CreateRequest(
            @Schema(description = "별점 1~5", example = "5") Integer rating,
            @Schema(description = "리뷰 내용", example = "실물이 더 좋아요") String content
    ) {}

    @Schema(name = "ReviewItem")
    public record Item(
            Long id,
            Long artworkId,
            String artworkTitle,
            String authorNickname,
            int rating,
            String content,
            LocalDateTime createdAt
    ) {
        public static Item from(Review r) {
            return new Item(r.getId(), r.getArtworkId(), r.getArtworkTitle(),
                    r.getAuthorNickname(), r.getRating(), r.getContent(), r.getCreatedAt());
        }
    }

    @Schema(name = "ReviewListResponse")
    public record ListResponse(List<Item> reviews, long totalCount, Double averageRating) {}
}
