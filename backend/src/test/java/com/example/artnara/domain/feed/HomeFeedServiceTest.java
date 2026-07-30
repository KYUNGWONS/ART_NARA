package com.example.artnara.domain.feed;

import com.example.artnara.domain.artwork.dto.ArtworkCreate;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.domain.feed.dto.HomeFeedDto;
import com.example.artnara.domain.feed.service.HomeFeedService;
import com.example.artnara.support.IntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;

@IntegrationTest
class HomeFeedServiceTest {

    @Autowired
    ArtworkService artworkService;

    @Autowired
    HomeFeedService homeFeedService;

    @Test
    @DisplayName("홈 피드는 추천 작품과 경매 작품으로 나뉜다")
    void getHomeFeed() {
        HomeFeedDto feed = homeFeedService.getHomeFeed("");
        assertThat(feed.recommended()).hasSize(4);
        assertThat(feed.auctions()).hasSize(4);
        assertThat(feed.artists()).hasSize(3);
    }

    @Test
    @DisplayName("검색어는 작품명과 작가명을 필터링한다")
    void getHomeFeedWithQuery() {
        HomeFeedDto feed = homeFeedService.getHomeFeed("봄의 정원");
        assertThat(feed.recommended()).hasSize(1);
        assertThat(feed.auctions()).isEmpty();
    }

    @Test
    @DisplayName("새로 등록된 작품이 이미지와 함께 피드에 노출된다")
    void registeredArtworkAppearsInFeed() {
        artworkService.register(new ArtworkCreate(
                "새 작품", "나", "소개", "설명", "유화", "10호", 2026,
                150000, false, null, null, "/images/new.jpg"));

        HomeFeedDto feed = homeFeedService.getHomeFeed("새 작품");

        assertThat(feed.recommended()).hasSize(1);
        assertThat(feed.recommended().get(0).imageUrl()).isEqualTo("/images/new.jpg");
    }

    @Test
    @DisplayName("마감된 경매는 피드에서 제외된다")
    void closedAuctionExcluded() {
        artworkService.closeAuction(5L);
        HomeFeedDto feed = homeFeedService.getHomeFeed("");
        assertThat(feed.auctions()).hasSize(3);
    }
}
