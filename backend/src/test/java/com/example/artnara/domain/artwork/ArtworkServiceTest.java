package com.example.artnara.domain.artwork;

import com.example.artnara.domain.artwork.dto.ArtworkDetailDto;
import com.example.artnara.domain.artwork.dto.AuctionUpdateDto;
import com.example.artnara.domain.artwork.service.AuctionBroadcaster;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import com.example.artnara.support.IntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;

@IntegrationTest
class ArtworkServiceTest {

    @Autowired
    ArtworkService artworkService;

    // 발행 자체를 검증한다 — 실제 STOMP 브로커 없이 호출 여부만 보면 충분하다.
    @MockitoSpyBean
    AuctionBroadcaster auctionBroadcaster;

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
        ArtworkDetailDto detail = artworkService.placeBid(5L, new ArtworkDetailDto.BidRequest(800000), "나");
        assertThat(detail.currentBid()).isEqualTo(800000);
        assertThat(detail.bidHistory().get(0).amount()).isEqualTo(800000);
    }

    @Test
    @DisplayName("입찰하면 경매 현황이 구독자에게 발행된다")
    void placeBidBroadcasts() {
        artworkService.placeBid(5L, new ArtworkDetailDto.BidRequest(900000), "경원");

        ArgumentCaptor<AuctionUpdateDto> captor = ArgumentCaptor.forClass(AuctionUpdateDto.class);
        verify(auctionBroadcaster).publish(captor.capture());
        AuctionUpdateDto update = captor.getValue();
        assertThat(update.artworkId()).isEqualTo(5L);
        assertThat(update.currentBid()).isEqualTo(900000);
        assertThat(update.topBidderName()).isEqualTo("경원");
        assertThat(update.auctionClosed()).isFalse();
    }

    @Test
    @DisplayName("최소 입찰 단위 미만 입찰 시 422")
    void placeBidTooLow() {
        assertThatThrownBy(() -> artworkService.placeBid(6L, new ArtworkDetailDto.BidRequest(340001), "나"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.BID_AMOUNT_TOO_LOW);
    }

    @Test
    @DisplayName("일반 판매 작품에 입찰 시 400")
    void placeBidOnNonAuction() {
        assertThatThrownBy(() -> artworkService.placeBid(1L, new ArtworkDetailDto.BidRequest(500000), "나"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ARTWORK_NOT_AUCTION);
    }

    @Test
    @DisplayName("경매 마감 시 최고 입찰자가 낙찰자가 된다")
    void closeAuction() {
        artworkService.placeBid(5L, new ArtworkDetailDto.BidRequest(800000), "나");
        ArtworkDetailDto closed = artworkService.closeAuction(5L);
        assertThat(closed.auctionClosed()).isTrue();
        assertThat(closed.winnerName()).isEqualTo("나");
        assertThat(closed.currentBid()).isEqualTo(800000);
        assertThat(closed.remainingTime()).isEqualTo("00:00:00");
    }

    @Test
    @DisplayName("이미 마감된 경매를 다시 마감하면 409")
    void closeAuctionTwice() {
        artworkService.closeAuction(6L);
        assertThatThrownBy(() -> artworkService.closeAuction(6L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.AUCTION_ALREADY_CLOSED);
    }

    @Test
    @DisplayName("마감된 경매에 입찰 시 409")
    void placeBidAfterClose() {
        artworkService.closeAuction(7L);
        assertThatThrownBy(() -> artworkService.placeBid(7L, new ArtworkDetailDto.BidRequest(600000), "나"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.AUCTION_ALREADY_CLOSED);
    }

    @Test
    @DisplayName("마감 시각이 지난 경매는 스케줄러 로직이 자동 마감한다")
    void closeExpiredAuctions() {
        Long expiredId = artworkService.register(new com.example.artnara.domain.artwork.dto.ArtworkCreate(
                "만료 경매", "나", "소개", "설명", "유화", "10호", 2026,
                100000, true, 50000, "2020-01-01", "", "회화"));

        int closed = artworkService.closeExpiredAuctions();

        assertThat(closed).isGreaterThanOrEqualTo(1);
        ArtworkDetailDto detail = artworkService.getDetail(expiredId);
        assertThat(detail.auctionClosed()).isTrue();
        assertThat(detail.winnerName()).isNull(); // 입찰 없이 마감 → 유찰
        assertThat(detail.remainingTime()).isEqualTo("00:00:00");
    }

    @Test
    @DisplayName("일반 판매 작품 마감 시도 시 400")
    void closeNonAuction() {
        assertThatThrownBy(() -> artworkService.closeAuction(1L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ARTWORK_NOT_AUCTION);
    }

    @Test
    @DisplayName("새로 등록한 작품들은 지도에서 서로 다른 좌표를 갖는다")
    void registeredArtworksDoNotShareOneSpot() {
        Long first = artworkService.register(new com.example.artnara.domain.artwork.dto.ArtworkCreate(
                "좌표1", "작가", "소개", "설명", "유화", "10호", 2026,
                100000, false, null, null, "", "회화"));
        Long second = artworkService.register(new com.example.artnara.domain.artwork.dto.ArtworkCreate(
                "좌표2", "작가", "소개", "설명", "유화", "10호", 2026,
                100000, false, null, null, "", "회화"));

        var items = artworkService.getNearby(37.5563, 126.9220).artworks();
        var a = items.stream().filter(i -> i.id().equals(first)).findFirst().orElseThrow();
        var b = items.stream().filter(i -> i.id().equals(second)).findFirst().orElseThrow();

        assertThat(a.latitude() == b.latitude() && a.longitude() == b.longitude()).isFalse();
        // 기준점(홍대입구)에서 1km 안쪽에 머문다 — 엉뚱한 동네로 튀지 않는다.
        assertThat(a.distanceKm()).isLessThan(1.0);
        assertThat(b.distanceKm()).isLessThan(1.0);
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
}
