package com.example.artnara.domain.order;

import com.example.artnara.domain.artwork.dto.ArtworkDetailDto;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.domain.certificate.service.CertificateService;
import com.example.artnara.domain.order.dto.OrderDto;
import com.example.artnara.domain.order.service.OrderService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import com.example.artnara.support.IntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@IntegrationTest
class OrderServiceTest {

    /** 시드 작품 1번의 작가. 판매자 확인은 활동명으로 판단한다. */
    private static final String ARTIST_OF_1 = "김예진";

    @Autowired
    OrderService orderService;

    @Autowired
    ArtworkService artworkService;

    @Autowired
    CertificateService certificateService;

    private OrderDto.CreateRequest request(Long artworkId) {
        return new OrderDto.CreateRequest(artworkId);
    }

    private OrderDto.PayRequest pay() {
        return new OrderDto.PayRequest("CARD", null, null);
    }

    /** 예약 → 양쪽 수령 확인까지 진행한 주문을 만든다. */
    private OrderDto.Response readyToPay(Long artworkId, String artistName) {
        OrderDto.Response order = orderService.reserve(request(artworkId), 1L, "나");
        orderService.confirmHandover(order.orderId(), 1L, "나");            // 구매자
        orderService.confirmHandover(order.orderId(), 99L, artistName);     // 판매자
        return order;
    }

    @Test
    @DisplayName("예약한 본인에게만 '내 예약'으로 보인다 — 남에게는 그냥 예약 중")
    void reservedByViewerOnlyForTheBuyer() {
        orderService.reserve(request(1L), 1L, "나");

        assertThat(artworkService.getDetail(1L, "나", 1L).reservedByViewer()).isTrue();
        assertThat(artworkService.getDetail(1L, "남", 2L).reservedByViewer()).isFalse();
        assertThat(artworkService.getDetail(1L).reservedByViewer()).isFalse();   // 비로그인
    }

    @Test
    @DisplayName("예약하면 결제 전이라 소유권은 생기지 않고 작품만 잠긴다")
    void reserveLocksArtworkWithoutPaying() {
        int ownershipsBefore = certificateService.listOwnerships(1L).ownerships().size();

        OrderDto.Response order = orderService.reserve(request(1L), 1L, "나");

        assertThat(order.status()).isEqualTo("예약 중");
        assertThat(order.paid()).isFalse();
        assertThat(order.certificateNo()).isEmpty();
        assertThat(artworkService.getDetail(1L).reserved()).isTrue();
        assertThat(artworkService.getDetail(1L).sold()).isFalse();
        assertThat(certificateService.listOwnerships(1L).ownerships())
                .hasSize(ownershipsBefore);
    }

    @Test
    @DisplayName("한쪽만 확인했으면 결제할 수 없다")
    void payRequiresBothConfirmations() {
        OrderDto.Response order = orderService.reserve(request(1L), 1L, "나");
        orderService.confirmHandover(order.orderId(), 1L, "나");

        assertThatThrownBy(() -> orderService.pay(order.orderId(), pay(), 1L, "나"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ORDER_HANDOVER_REQUIRED);
    }

    @Test
    @DisplayName("양쪽 확인 뒤 결제하면 소유권이 발급되고 작품이 판매 완료로 잠긴다")
    void payAfterHandover() {
        int ownershipsBefore = certificateService.listOwnerships(1L).ownerships().size();
        OrderDto.Response reserved = readyToPay(1L, ARTIST_OF_1);

        OrderDto.Response paid = orderService.pay(reserved.orderId(), pay(), 1L, "나");

        assertThat(paid.paid()).isTrue();
        assertThat(paid.status()).isEqualTo("거래 완료");
        assertThat(paid.amount()).isEqualTo(320000);
        assertThat(paid.certificateNo()).startsWith("ARTNARA-2026-");
        assertThat(artworkService.getDetail(1L).sold()).isTrue();
        assertThat(artworkService.getDetail(1L).reserved()).isFalse();
        assertThat(certificateService.listOwnerships(1L).ownerships())
                .hasSize(ownershipsBefore + 1);
    }

    @Test
    @DisplayName("거래 당사자가 아니면 수령 확인 시 403")
    void confirmByStranger() {
        OrderDto.Response order = orderService.reserve(request(1L), 1L, "나");

        assertThatThrownBy(() -> orderService.confirmHandover(order.orderId(), 77L, "남"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ORDER_NOT_PARTICIPANT);
    }

    @Test
    @DisplayName("구매자가 아니면 결제 시 403")
    void payByNonBuyer() {
        OrderDto.Response order = readyToPay(1L, ARTIST_OF_1);

        assertThatThrownBy(() -> orderService.pay(order.orderId(), pay(), 77L, "남"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ORDER_BUYER_ONLY);
    }

    @Test
    @DisplayName("예약을 취소하면 작품이 다시 판매 가능해지고 재예약된다")
    void cancelReleasesArtwork() {
        OrderDto.Response order = orderService.reserve(request(1L), 1L, "나");

        orderService.cancel(order.orderId(), 1L, "나");

        assertThat(artworkService.getDetail(1L).reserved()).isFalse();
        // 취소된 예약 때문에 영영 못 사면 안 된다
        assertThat(orderService.reserve(request(1L), 2L, "다른사람").orderId()).isNotNull();
    }

    @Test
    @DisplayName("이미 예약된 작품을 다시 예약하면 409")
    void reserveAlreadyReserved() {
        orderService.reserve(request(1L), 1L, "나");

        assertThatThrownBy(() -> orderService.reserve(request(1L), 2L, "다른사람"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ORDER_ALREADY_RESERVED);
    }

    @Test
    @DisplayName("주문 내역은 최신순이고 남의 주문이 섞이지 않는다")
    void listNewestFirstAndScoped() {
        orderService.reserve(request(1L), 1L, "나");
        OrderDto.Response latest = orderService.reserve(request(2L), 1L, "나");

        assertThat(orderService.list(1L).orders().get(0).orderId())
                .isEqualTo(latest.orderId());
        assertThat(orderService.list(2L).orders()).isEmpty();
    }

    @Test
    @DisplayName("판매자는 자기 작품에 걸린 거래를 조회할 수 있다")
    void listSelling() {
        OrderDto.Response order = orderService.reserve(request(1L), 1L, "나");

        assertThat(orderService.listSelling(ARTIST_OF_1).orders())
                .extracting(OrderDto.Response::orderId)
                .contains(order.orderId());
        assertThat(orderService.listSelling("남의작가").orders()).isEmpty();
    }

    @Test
    @DisplayName("진행 중인 경매 작품 즉시 예약 시 400")
    void reserveAuctionArtwork() {
        assertThatThrownBy(() -> orderService.reserve(request(5L), 1L, "나"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ORDER_AUCTION_NOT_BUYABLE);
    }

    @Test
    @DisplayName("낙찰자는 마감된 경매 작품을 낙찰가로 예약할 수 있다")
    void reserveForWonAuction() {
        artworkService.placeBid(5L, new ArtworkDetailDto.BidRequest(800000), "나");
        artworkService.closeAuction(5L);

        OrderDto.Response order = orderService.reserve(request(5L), 1L, "나");

        assertThat(order.amount()).isEqualTo(800000);
        assertThat(order.status()).isEqualTo("예약 중");
    }

    @Test
    @DisplayName("낙찰자가 아니면 마감된 경매 작품 예약 시 403")
    void reserveForLostAuction() {
        // 입찰 없이 마감 → 낙찰자는 시드 최고 입찰자(박*현)
        artworkService.closeAuction(6L);
        assertThatThrownBy(() -> orderService.reserve(request(6L), 1L, "나"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ORDER_NOT_WINNER);
    }

    @Test
    @DisplayName("지원하지 않는 결제 수단이면 400")
    void payInvalidPaymentMethod() {
        OrderDto.Response order = readyToPay(1L, ARTIST_OF_1);
        var invalid = new OrderDto.PayRequest("BITCOIN", null, null);

        assertThatThrownBy(() -> orderService.pay(order.orderId(), invalid, 1L, "나"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ORDER_INVALID_PAYMENT_METHOD);
    }

    @Test
    @DisplayName("존재하지 않는 작품 예약 시 404")
    void reserveUnknownArtwork() {
        assertThatThrownBy(() -> orderService.reserve(request(999L), 1L, "나"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ARTWORK_NOT_FOUND);
    }
}
