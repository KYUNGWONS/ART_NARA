package com.example.artnara.domain.sale;

import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.domain.sale.dto.SaleDto;
import com.example.artnara.domain.sale.service.SaleService;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.global.auth.oauth.OAuthProvider;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import com.example.artnara.support.IntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@IntegrationTest
class SaleServiceTest {

    private static final long SELLER_ID = 1L;
    private static final long OTHER_SELLER_ID = 2L;

    @Autowired
    SaleService saleService;

    @Autowired
    ArtworkService artworkService;

    @Autowired
    UserRepository userRepository;

    private SaleDto.CreateRequest request(boolean auction) {
        return new SaleDto.CreateRequest(
                "새로 그린 정원", "설명", "캔버스에 유화", "10호", 2026,
                300000, auction,
                auction ? 200000 : null,
                auction ? LocalDate.now().plusDays(7) : null,
                "/images/sample.jpg", "회화");
    }

@Test
    @DisplayName("작가 소개는 판매자 프로필에서 가져온다 — 판매자 시점 문구를 넣지 않는다")
    void artistIntroductionComesFromProfile() {
        // 소개를 써 둔 판매자
        User seller = userRepository.save(User.ofOAuth(
                OAuthProvider.KAKAO, "sale-intro-1", "a@test.com", "소개있는작가", null));
        seller.completeProfile(null, null, null, null, null, null, "빛을 그립니다", null);

        saleService.create(request(false), seller.getId(), seller.getNickname());
        var mine = artworkService.listAll().stream()
                .filter(a -> a.artistName().equals(seller.getNickname()))
                .findFirst().orElseThrow();

        assertThat(mine.artistIntroduction()).isEqualTo("빛을 그립니다");
    }

    @Test
    @DisplayName("소개가 없으면 비워 둔다 — 남이 봐도 어색하지 않아야 한다")
    void artistIntroductionEmptyWhenProfileBlank() {
        User seller = userRepository.save(User.ofOAuth(
                OAuthProvider.KAKAO, "sale-intro-2", "b@test.com", "소개없는작가", null));

        saleService.create(request(false), seller.getId(), seller.getNickname());
        var mine = artworkService.listAll().stream()
                .filter(a -> a.artistName().equals(seller.getNickname()))
                .findFirst().orElseThrow();

        assertThat(mine.artistIntroduction()).isEmpty();
    }

    @Test
    @DisplayName("즉시 판매 등록")
    void createDirectSale() {
        SaleDto.Response sale = saleService.create(request(false), SELLER_ID, "나");
        assertThat(sale.id()).isPositive();
        assertThat(sale.auctionEnabled()).isFalse();
        assertThat(sale.status()).isEqualTo("검수 대기");
    }

    @Test
    @DisplayName("경매 포함 판매 등록")
    void createAuctionSale() {
        SaleDto.Response sale = saleService.create(request(true), SELLER_ID, "나");
        assertThat(sale.auctionStartPrice()).isEqualTo(200000);
        assertThat(sale.auctionEndDate()).isAfter(LocalDate.now());
    }

    @Test
    @DisplayName("등록한 판매는 목록 최신순으로 조회된다")
    void listNewestFirst() {
        saleService.create(request(false), SELLER_ID, "나");
        SaleDto.Response latest = saleService.create(request(true), SELLER_ID, "나");
        assertThat(saleService.list(SELLER_ID).sales().get(0).id()).isEqualTo(latest.id());
    }

    @Test
    @DisplayName("내 판매 목록에는 남의 등록이 섞이지 않는다")
    void listScopedToSeller() {
        saleService.create(request(false), SELLER_ID, "나");

        assertThat(saleService.list(OTHER_SELLER_ID).sales()).isEmpty();
    }

    @Test
    @DisplayName("판매 등록 시 작품 저장소에도 이미지와 함께 등록된다")
    void createRegistersArtwork() {
        int artworksBefore = artworkService.listAll().size();

        saleService.create(request(false), SELLER_ID, "나");

        var artworks = artworkService.listAll();
        assertThat(artworks).hasSize(artworksBefore + 1);
        var registered = artworks.get(artworks.size() - 1);
        assertThat(registered.title()).isEqualTo("새로 그린 정원");
        assertThat(registered.artistName()).isEqualTo("나");
        assertThat(registered.imageUrl()).isEqualTo("/images/sample.jpg");
    }

    @Test
    @DisplayName("작품명 없이 등록 시 400")
    void createWithoutTitle() {
        var invalid = new SaleDto.CreateRequest(
                " ", null, null, null, null, 300000, false, null, null, null, null);
        assertThatThrownBy(() -> saleService.create(invalid, SELLER_ID, "나"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.SALE_TITLE_REQUIRED);
    }

    @Test
    @DisplayName("경매 최저가가 즉시 판매가보다 높으면 422")
    void createAuctionStartAboveBuyNow() {
        var invalid = new SaleDto.CreateRequest(
                "작품", null, null, null, null, 300000, true,
                400000, LocalDate.now().plusDays(7), null, null);
        assertThatThrownBy(() -> saleService.create(invalid, SELLER_ID, "나"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.SALE_INVALID_AUCTION);
    }

    @Test
    @DisplayName("경매 마감일이 오늘 이전이면 422")
    void createAuctionPastEndDate() {
        var invalid = new SaleDto.CreateRequest(
                "작품", null, null, null, null, 300000, true,
                200000, LocalDate.now(), null, null);
        assertThatThrownBy(() -> saleService.create(invalid, SELLER_ID, "나"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.SALE_INVALID_AUCTION);
    }
}
