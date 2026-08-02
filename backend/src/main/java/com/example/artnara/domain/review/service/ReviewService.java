package com.example.artnara.domain.review.service;

import com.example.artnara.domain.artwork.entity.Artwork;
import com.example.artnara.domain.artwork.repository.ArtworkRepository;
import com.example.artnara.domain.order.repository.ArtOrderRepository;
import com.example.artnara.domain.review.dto.ReviewDto;
import com.example.artnara.domain.review.entity.Review;
import com.example.artnara.domain.review.repository.ReviewRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Limit;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReviewService {

    /** 한 번에 내려주는 리뷰 상한 (목록이 커져도 응답이 무거워지지 않게) */
    private static final int LIST_LIMIT = 100;

    private final ReviewRepository reviewRepository;
    private final ArtworkRepository artworkRepository;
    private final ArtOrderRepository artOrderRepository;

    /**
     * 리뷰 작성. **그 작품을 결제한 사용자만** 쓸 수 있고, 작품당 1회로 제한한다.
     */
    @Transactional
    public ReviewDto.Item create(Long artworkId, ReviewDto.CreateRequest request,
                                 Long authorId, String authorNickname) {
        Artwork artwork = artworkRepository.findById(artworkId)
                .orElseThrow(() -> new GlobalException(DomainResultCode.ARTWORK_NOT_FOUND));

        if (request.rating() == null || request.rating() < 1 || request.rating() > 5) {
            throw new GlobalException(DomainResultCode.REVIEW_INVALID_RATING);
        }
        String content = request.content() == null ? "" : request.content().trim();
        if (content.isEmpty()) {
            throw new GlobalException(DomainResultCode.REVIEW_CONTENT_REQUIRED);
        }
        if (!artOrderRepository.existsByArtworkIdAndBuyerId(artworkId, authorId)) {
            throw new GlobalException(DomainResultCode.REVIEW_NOT_PURCHASED);
        }
        if (reviewRepository.existsByAuthorIdAndArtworkId(authorId, artworkId)) {
            throw new GlobalException(DomainResultCode.REVIEW_ALREADY_WRITTEN);
        }

        Review review = reviewRepository.save(Review.builder()
                .artworkId(artwork.getId())
                .artworkTitle(artwork.getTitle())
                .artistName(artwork.getArtistName())
                .authorId(authorId)
                .authorNickname(authorNickname)
                .rating(request.rating())
                .content(content)
                .build());
        return ReviewDto.Item.from(review);
    }

    public ReviewDto.ListResponse listByArtist(String artistName) {
        String name = artistName.trim();
        return new ReviewDto.ListResponse(
                reviewRepository.findByArtistNameOrderByIdDesc(name, Limit.of(LIST_LIMIT)).stream()
                        .map(ReviewDto.Item::from)
                        .toList(),
                reviewRepository.countByArtistName(name),
                roundedAverage(name));
    }

    /** 포트폴리오 헤더용 평균 평점 (소수 첫째 자리). 리뷰가 없으면 null. */
    public Double roundedAverage(String artistName) {
        Double average = reviewRepository.averageRatingOf(artistName.trim());
        return average == null ? null : Math.round(average * 10) / 10.0;
    }

    public long countOf(String artistName) {
        return reviewRepository.countByArtistName(artistName.trim());
    }
}
