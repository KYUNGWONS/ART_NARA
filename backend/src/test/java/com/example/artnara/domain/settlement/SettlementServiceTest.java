package com.example.artnara.domain.settlement;

import com.example.artnara.domain.artwork.dto.ArtworkCreate;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.domain.order.dto.OrderDto;
import com.example.artnara.domain.order.service.OrderService;
import com.example.artnara.domain.settlement.dto.SettlementDto;
import com.example.artnara.domain.settlement.service.SettlementService;
import com.example.artnara.support.IntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;

@IntegrationTest
class SettlementServiceTest {

    @Autowired
    SettlementService settlementService;
    @Autowired
    ArtworkService artworkService;
    @Autowired
    OrderService orderService;

    private Long registerArtwork(String artist, int price) {
        return artworkService.register(new ArtworkCreate(
                "정산용 작품", artist, "소개", "설명", "유화", "10호", 2026,
                price, false, null, null, "", "회화"));
    }

    /** 직거래라 예약 → 양쪽 수령 확인 → 결제까지 마쳐야 정산 대상이 된다. */
    private void sell(Long artworkId, String artist) {
        var order = orderService.reserve(
                new OrderDto.CreateRequest(artworkId), 99L, "구매자");
        orderService.confirmHandover(order.orderId(), 99L, "구매자");
        orderService.confirmHandover(order.orderId(), -1L, artist);
        orderService.pay(order.orderId(),
                new OrderDto.PayRequest("CARD", null, null), 99L, "구매자");
    }

    @Test
    @DisplayName("판매 금액에서 수수료를 뺀 금액이 정산 예정액이 된다")
    void settlementForArtist() {
        Long artworkId = registerArtwork("정산작가", 200000);
        sell(artworkId, "정산작가");

        SettlementDto settlement = settlementService.forArtist("정산작가");

        assertThat(settlement.saleCount()).isEqualTo(1);
        assertThat(settlement.totalSales()).isEqualTo(200000);
        assertThat(settlement.feeAmount()).isEqualTo(20000);   // 10%
        assertThat(settlement.netAmount()).isEqualTo(180000);
        assertThat(settlement.items()).hasSize(1);
        assertThat(settlement.items().get(0).buyerName()).isEqualTo("구매자");
    }

    @Test
    @DisplayName("다른 작가의 판매는 섞이지 않는다")
    void scopedToArtist() {
        Long artworkId = registerArtwork("남의작가", 300000);
        sell(artworkId, "남의작가");

        assertThat(settlementService.forArtist("정산작가").totalSales()).isZero();
        assertThat(settlementService.forArtist("남의작가").totalSales()).isEqualTo(300000);
    }

    @Test
    @DisplayName("활동명이 없으면 빈 정산을 돌려준다")
    void emptyForAnonymous() {
        SettlementDto settlement = settlementService.forArtist(null);
        assertThat(settlement.totalSales()).isZero();
        assertThat(settlement.items()).isEmpty();
    }
}
