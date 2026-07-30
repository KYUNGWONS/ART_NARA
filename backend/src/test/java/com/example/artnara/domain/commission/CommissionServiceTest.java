package com.example.artnara.domain.commission;

import com.example.artnara.domain.commission.dto.CommissionDto;
import com.example.artnara.domain.commission.service.CommissionService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class CommissionServiceTest {

    private final CommissionService commissionService = new CommissionService();

    private CommissionDto.CreateRequest request() {
        return new CommissionDto.CreateRequest(
                "결혼 선물용 초상화", "부모님 사진을 바탕으로 유화 초상화를 그려주세요.",
                "회화", 400000, LocalDate.now().plusDays(21), "/images/reference.jpg");
    }

    @Test
    @DisplayName("제작 의뢰 등록 시 카테고리 작가 알림 수가 포함된다")
    void create() {
        CommissionDto.Response commission = commissionService.create(request());
        assertThat(commission.id()).isPositive();
        assertThat(commission.status()).isEqualTo("작가 제안 대기");
        assertThat(commission.notifiedArtistCount()).isEqualTo(42);
    }

    @Test
    @DisplayName("의뢰 목록은 최신순으로 조회된다")
    void listNewestFirst() {
        CommissionDto.Response latest = commissionService.create(request());
        assertThat(commissionService.list().commissions().get(0).id())
                .isEqualTo(latest.id());
    }

    @Test
    @DisplayName("현재 최저가보다 낮은 제안은 성공한다")
    void placeOffer() {
        CommissionDto.Response updated = commissionService.placeOffer(1L,
                new CommissionDto.OfferRequest("정*은", 350000, "수채화로 가능해요"));
        assertThat(updated.lowestOffer()).isEqualTo(350000);
        assertThat(updated.status()).isEqualTo("역경매 진행 중");
    }

    @Test
    @DisplayName("현재 최저가 이상 제안 시 422")
    void placeOfferTooHigh() {
        assertThatThrownBy(() -> commissionService.placeOffer(1L,
                new CommissionDto.OfferRequest("정*은", 450000, null)))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.OFFER_AMOUNT_TOO_HIGH);
    }

    @Test
    @DisplayName("첫 제안은 예산보다 낮아야 한다")
    void firstOfferMustBeUnderBudget() {
        CommissionDto.Response commission = commissionService.create(request());
        assertThatThrownBy(() -> commissionService.placeOffer(commission.id(),
                new CommissionDto.OfferRequest("정*은", 400000, null)))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.OFFER_AMOUNT_TOO_HIGH);
    }

    @Test
    @DisplayName("존재하지 않는 의뢰에 제안 시 404")
    void placeOfferNotFound() {
        assertThatThrownBy(() -> commissionService.placeOffer(999L,
                new CommissionDto.OfferRequest("정*은", 100000, null)))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.COMMISSION_NOT_FOUND);
    }

    @Test
    @DisplayName("예산 없이 등록 시 400")
    void createWithoutBudget() {
        var invalid = new CommissionDto.CreateRequest("제목", null, "회화", null, null, null);
        assertThatThrownBy(() -> commissionService.create(invalid))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.COMMISSION_INVALID_BUDGET);
    }
}
