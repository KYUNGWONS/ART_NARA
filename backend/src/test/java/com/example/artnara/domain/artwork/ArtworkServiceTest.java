package com.example.artnara.domain.artwork;

import com.example.artnara.domain.artwork.dto.ArtworkDetailDto;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ArtworkServiceTest {

    private final ArtworkService artworkService = new ArtworkService();

    @Test
    @DisplayName("작품 상세 조회")
    void getDetail() {
        ArtworkDetailDto detail = artworkService.getDetail(1L);
        assertThat(detail.title()).isEqualTo("봄의 정원");
        assertThat(detail.auction()).isFalse();
        assertThat(detail.bidHistory()).isEmpty();
    }

    @Test
    @DisplayName("경매 작품은 현재가와 입찰 내역을 포함한다")
    void getAuctionDetail() {
        ArtworkDetailDto detail = artworkService.getDetail(5L);
        assertThat(detail.auction()).isTrue();
        assertThat(detail.currentBid()).isEqualTo(780000);
        assertThat(detail.bidHistory()).hasSize(3);
    }

    @Test
    @DisplayName("존재하지 않는 작품 조회 시 404")
    void getDetailNotFound() {
        assertThatThrownBy(() -> artworkService.getDetail(999L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ARTWORK_NOT_FOUND);
    }

    @Test
    @DisplayName("입찰 성공 시 현재가와 입찰 내역이 갱신된다")
    void placeBid() {
        ArtworkDetailDto detail = artworkService.placeBid(5L, new ArtworkDetailDto.BidRequest(800000));
        assertThat(detail.currentBid()).isEqualTo(800000);
        assertThat(detail.bidHistory().get(0).amount()).isEqualTo(800000);
    }

    @Test
    @DisplayName("최소 입찰 단위 미만 입찰 시 422")
    void placeBidTooLow() {
        assertThatThrownBy(() -> artworkService.placeBid(6L, new ArtworkDetailDto.BidRequest(340001)))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.BID_AMOUNT_TOO_LOW);
    }

    @Test
    @DisplayName("집 주변 작품은 가까운 순으로 정렬된다")
    void getNearby() {
        // 홍대입구 좌표 기준
        var nearby = artworkService.getNearby(37.5563, 126.9220);
        assertThat(nearby.artworks()).hasSize(8);
        assertThat(nearby.artworks().get(0).id()).isEqualTo(1L);
        assertThat(nearby.artworks().get(0).distanceKm()).isEqualTo(0.0);
        for (int i = 1; i < nearby.artworks().size(); i++) {
            assertThat(nearby.artworks().get(i).distanceKm())
                    .isGreaterThanOrEqualTo(nearby.artworks().get(i - 1).distanceKm());
        }
    }

    @Test
    @DisplayName("일반 판매 작품에 입찰 시 400")
    void placeBidOnNonAuction() {
        assertThatThrownBy(() -> artworkService.placeBid(1L, new ArtworkDetailDto.BidRequest(500000)))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ARTWORK_NOT_AUCTION);
    }
}
