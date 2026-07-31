package com.example.artnara.domain.artist;

import com.example.artnara.domain.artist.dto.ArtistDto;
import com.example.artnara.domain.artist.service.ArtistService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import com.example.artnara.support.IntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@IntegrationTest
class ArtistServiceTest {

    @Autowired
    ArtistService artistService;

    @Test
    @DisplayName("작가 포트폴리오는 소개·통계·작품 목록을 포함한다")
    void getPortfolio() {
        ArtistDto.Response portfolio = artistService.getPortfolio("김예진");

        assertThat(portfolio.name()).isEqualTo("김예진");
        assertThat(portfolio.introduction()).isEqualTo("자연의 빛을 기록하는 작가");
        assertThat(portfolio.artworkCount()).isEqualTo(1);
        assertThat(portfolio.artworks()).hasSize(1);
        assertThat(portfolio.artworks().get(0).title()).isEqualTo("봄의 정원");
        assertThat(portfolio.rating()).isBetween(4.0, 5.0);
        assertThat(portfolio.salesCount()).isPositive();
    }

    @Test
    @DisplayName("경매 작품은 현재가로 노출된다")
    void getPortfolioAuctionPrice() {
        ArtistDto.Response portfolio = artistService.getPortfolio("한지원");
        assertThat(portfolio.artworks().get(0).auction()).isTrue();
        assertThat(portfolio.artworks().get(0).price()).isEqualTo(780000);
    }

    @Test
    @DisplayName("작품이 없는 작가 조회 시 404")
    void getPortfolioNotFound() {
        assertThatThrownBy(() -> artistService.getPortfolio("없는작가"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ARTIST_NOT_FOUND);
    }
}
