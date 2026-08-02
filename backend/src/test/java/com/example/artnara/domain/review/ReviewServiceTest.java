package com.example.artnara.domain.review;

import com.example.artnara.domain.order.dto.OrderDto;
import com.example.artnara.domain.order.service.OrderService;
import com.example.artnara.domain.review.dto.ReviewDto;
import com.example.artnara.domain.review.service.ReviewService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import com.example.artnara.support.IntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@IntegrationTest
class ReviewServiceTest {

    private static final long BUYER_ID = 100L;
    private static final String BUYER = "구매자";

    @Autowired ReviewService reviewService;
    @Autowired OrderService orderService;

    private void buy(long artworkId) {
        orderService.create(new OrderDto.CreateRequest(artworkId, "CARD"), BUYER_ID, BUYER);
    }

    private ReviewDto.CreateRequest request(int rating) {
        return new ReviewDto.CreateRequest(rating, "실물이 더 좋아요");
    }

    @Test
    @DisplayName("구매한 작품에는 리뷰를 쓸 수 있다")
    void createAfterPurchase() {
        buy(1L);

        ReviewDto.Item review = reviewService.create(1L, request(5), BUYER_ID, BUYER);

        assertThat(review.rating()).isEqualTo(5);
        assertThat(review.authorNickname()).isEqualTo(BUYER);
        assertThat(review.artworkTitle()).isNotBlank();
    }

    @Test
    @DisplayName("구매하지 않은 작품에는 리뷰를 쓸 수 없다")
    void createWithoutPurchase() {
        assertThatThrownBy(() -> reviewService.create(2L, request(5), BUYER_ID, BUYER))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.REVIEW_NOT_PURCHASED);
    }

    @Test
    @DisplayName("같은 작품에 두 번 리뷰를 쓸 수 없다")
    void createTwice() {
        buy(1L);
        reviewService.create(1L, request(4), BUYER_ID, BUYER);

        assertThatThrownBy(() -> reviewService.create(1L, request(4), BUYER_ID, BUYER))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.REVIEW_ALREADY_WRITTEN);
    }

    @Test
    @DisplayName("별점이 1~5 를 벗어나면 거절한다")
    void createWithInvalidRating() {
        buy(1L);

        assertThatThrownBy(() -> reviewService.create(1L, request(6), BUYER_ID, BUYER))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.REVIEW_INVALID_RATING);
    }

    @Test
    @DisplayName("작가 리뷰 목록은 평균 평점과 총 개수를 함께 준다")
    void listByArtist() {
        buy(1L);
        reviewService.create(1L, request(4), BUYER_ID, BUYER);

        ReviewDto.ListResponse response = reviewService.listByArtist("김예진");

        assertThat(response.reviews()).isNotEmpty();
        assertThat(response.totalCount()).isEqualTo(response.reviews().size());
        assertThat(response.averageRating()).isBetween(1.0, 5.0);
    }
}
