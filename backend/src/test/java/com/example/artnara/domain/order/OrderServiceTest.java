package com.example.artnara.domain.order;

import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.domain.certificate.service.CertificateService;
import com.example.artnara.domain.order.dto.OrderDto;
import com.example.artnara.domain.order.service.OrderService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class OrderServiceTest {

    private ArtworkService artworkService;
    private CertificateService certificateService;
    private OrderService orderService;

    @BeforeEach
    void setUp() {
        artworkService = new ArtworkService();
        certificateService = new CertificateService();
        orderService = new OrderService(artworkService, certificateService);
    }

    private OrderDto.CreateRequest request(Long artworkId) {
        return new OrderDto.CreateRequest(
                artworkId, "CARD", "신경원", "010-1234-5678", "서울 마포구 홍대입구 1길 1");
    }

    @Test
    @DisplayName("결제 완료 시 주문과 디지털 소유권이 생성된다")
    void create() {
        int ownershipsBefore = certificateService.listOwnerships().ownerships().size();

        OrderDto.Response order = orderService.create(request(1L));

        assertThat(order.status()).isEqualTo("결제 완료");
        assertThat(order.totalAmount()).isEqualTo(order.price() + order.deliveryFee());
        assertThat(order.certificateNo()).startsWith("ARTNARA-2026-");
        assertThat(certificateService.listOwnerships().ownerships())
                .hasSize(ownershipsBefore + 1);
        assertThat(certificateService.listOwnerships().ownerships().get(0).certificateNo())
                .isEqualTo(order.certificateNo());
    }

    @Test
    @DisplayName("주문 내역은 최신순으로 조회된다")
    void listNewestFirst() {
        orderService.create(request(1L));
        OrderDto.Response latest = orderService.create(request(2L));
        assertThat(orderService.list().orders().get(0).orderId())
                .isEqualTo(latest.orderId());
    }

    @Test
    @DisplayName("이미 판매된 작품 재구매 시 409")
    void createAlreadySold() {
        orderService.create(request(1L));
        assertThatThrownBy(() -> orderService.create(request(1L)))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ORDER_ALREADY_SOLD);
    }

    @Test
    @DisplayName("진행 중인 경매 작품 즉시 구매 시 400")
    void createAuctionArtwork() {
        assertThatThrownBy(() -> orderService.create(request(5L)))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ORDER_AUCTION_NOT_BUYABLE);
    }

    @Test
    @DisplayName("낙찰자는 마감된 경매 작품을 낙찰가로 결제할 수 있다")
    void createForWonAuction() {
        artworkService.placeBid(5L, new com.example.artnara.domain.artwork.dto.ArtworkDetailDto.BidRequest(800000));
        artworkService.closeAuction(5L);

        OrderDto.Response order = orderService.create(request(5L));

        assertThat(order.price()).isEqualTo(800000);
        assertThat(order.totalAmount()).isEqualTo(800000 + order.deliveryFee());
        assertThat(order.status()).isEqualTo("결제 완료");
    }

    @Test
    @DisplayName("낙찰자가 아니면 마감된 경매 작품 결제 시 403")
    void createForLostAuction() {
        // 입찰 없이 마감 → 낙찰자는 시드 최고 입찰자(박*현)
        artworkService.closeAuction(6L);
        assertThatThrownBy(() -> orderService.create(request(6L)))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ORDER_NOT_WINNER);
    }

    @Test
    @DisplayName("지원하지 않는 결제 수단이면 400")
    void createInvalidPaymentMethod() {
        var invalid = new OrderDto.CreateRequest(
                1L, "BITCOIN", "신경원", "010-1234-5678", "서울 마포구");
        assertThatThrownBy(() -> orderService.create(invalid))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ORDER_INVALID_PAYMENT_METHOD);
    }

    @Test
    @DisplayName("배송지 없이 결제 시 400")
    void createWithoutAddress() {
        var invalid = new OrderDto.CreateRequest(
                1L, "CARD", "신경원", "010-1234-5678", " ");
        assertThatThrownBy(() -> orderService.create(invalid))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ORDER_ADDRESS_REQUIRED);
    }

    @Test
    @DisplayName("존재하지 않는 작품 결제 시 404")
    void createUnknownArtwork() {
        assertThatThrownBy(() -> orderService.create(request(999L)))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ARTWORK_NOT_FOUND);
    }
}
