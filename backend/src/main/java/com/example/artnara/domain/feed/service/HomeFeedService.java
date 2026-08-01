package com.example.artnara.domain.feed.service;

import com.example.artnara.domain.artwork.dto.ArtworkDetailDto;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.domain.feed.dto.HomeFeedDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class HomeFeedService {

    private static final List<HomeFeedDto.Artist> ARTISTS = List.of(
            new HomeFeedDto.Artist("김예진", "자연의 빛을 기록하는 작가"),
            new HomeFeedDto.Artist("이수민", "일상의 감정을 색으로 표현합니다"),
            new HomeFeedDto.Artist("박소현", "고요한 순간을 그립니다")
    );

    private final ArtworkService artworkService;

    public HomeFeedDto getHomeFeed(String query) {
        return getHomeFeed(query, null, null);
    }

    public HomeFeedDto getHomeFeed(String query, String category) {
        return getHomeFeed(query, category, null);
    }

    /** [userId] 가 있으면 그 사용자의 관심 작품(하트) 상태를 함께 내려준다. */
    public HomeFeedDto getHomeFeed(String query, String category, Long userId) {
        String normalizedQuery = query == null ? "" : query.trim().toLowerCase();
        String normalizedCategory = category == null || category.isBlank()
                || category.equals("추천") ? null : category.trim();
        List<ArtworkDetailDto> artworks = artworkService.listAll();
        Set<Long> liked = artworkService.likedArtworkIds(userId);
        return new HomeFeedDto(
                "봄빛을 담은 작가들의 이야기",
                "DUST-ART 에디터가 직접 고른 이번 주 주목작",
                filter(artworks, normalizedQuery, normalizedCategory, false, liked),
                filter(artworks, normalizedQuery, normalizedCategory, true, liked),
                filterArtists(normalizedQuery)
        );
    }

    private List<HomeFeedDto.Artwork> filter(
            List<ArtworkDetailDto> artworks, String query, String category, boolean auction,
            Set<Long> liked) {
        return artworks.stream()
                .filter(artwork -> artwork.auction() == auction)
                .filter(artwork -> category == null || category.equals(artwork.category()))
                .filter(artwork -> !artwork.auctionClosed())
                .filter(artwork -> query.isEmpty()
                        || artwork.title().toLowerCase().contains(query)
                        || artwork.artistName().toLowerCase().contains(query))
                .map(artwork -> toFeedArtwork(artwork, liked.contains(artwork.id())))
                .toList();
    }

    private HomeFeedDto.Artwork toFeedArtwork(ArtworkDetailDto artwork, boolean liked) {
        return new HomeFeedDto.Artwork(
                artwork.id(), artwork.title(), artwork.artistName(),
                artwork.price(), artwork.imageUrl(), liked,
                artwork.auction(), artwork.currentBid(), artwork.remainingTime());
    }

    private List<HomeFeedDto.Artist> filterArtists(String query) {
        if (query.isEmpty()) return ARTISTS;
        return ARTISTS.stream()
                .filter(artist -> artist.name().toLowerCase().contains(query)
                        || artist.introduction().toLowerCase().contains(query))
                .toList();
    }
}
