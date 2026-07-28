package com.example.unitrip.domain.feed.service;

import com.example.unitrip.domain.feed.dto.HomeFeedDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class HomeFeedService {

    private static final List<HomeFeedDto.Artwork> RECOMMENDED = List.of(
            artwork(1L, "봄의 정원", "김예진", 320000, false, null, null),
            artwork(2L, "무채색의 위로", "박소현", 180000, false, null, null),
            artwork(3L, "빛과 그림자 사이", "이수민", 450000, false, 450000, null),
            artwork(4L, "고요한 파도", "최준혁", 260000, false, null, null)
    );

    private static final List<HomeFeedDto.Artwork> AUCTIONS = List.of(
            artwork(5L, "붉은 기억", "한지원", 780000, true, 780000, "02:14:33"),
            artwork(6L, "도시의 새벽", "오민서", 340000, true, 340000, "05:47:10"),
            artwork(7L, "흐린 날의 숲", "정다은", 520000, true, 520000, "00:58:22"),
            artwork(8L, "기억의 조각", "윤재호", 190000, true, 190000, "09:30:05")
    );

    private static final List<HomeFeedDto.Artist> ARTISTS = List.of(
            new HomeFeedDto.Artist("김예진", "자연의 빛을 기록하는 작가"),
            new HomeFeedDto.Artist("이수민", "일상의 감정을 색으로 표현합니다"),
            new HomeFeedDto.Artist("박소현", "고요한 순간을 그립니다")
    );

    public HomeFeedDto getHomeFeed(String query) {
        String normalizedQuery = query == null ? "" : query.trim().toLowerCase();
        return new HomeFeedDto(
                "봄빛을 담은 작가들의 이야기",
                "ART NARA 에디터가 직접 고른 이번 주 주목작",
                filter(RECOMMENDED, normalizedQuery),
                filter(AUCTIONS, normalizedQuery),
                filterArtists(normalizedQuery)
        );
    }

    private List<HomeFeedDto.Artwork> filter(List<HomeFeedDto.Artwork> artworks, String query) {
        if (query.isEmpty()) return artworks;
        return artworks.stream()
                .filter(artwork -> artwork.title().toLowerCase().contains(query)
                        || artwork.artistName().toLowerCase().contains(query))
                .toList();
    }

    private List<HomeFeedDto.Artist> filterArtists(String query) {
        if (query.isEmpty()) return ARTISTS;
        return ARTISTS.stream()
                .filter(artist -> artist.name().toLowerCase().contains(query)
                        || artist.introduction().toLowerCase().contains(query))
                .toList();
    }

    private static HomeFeedDto.Artwork artwork(
            Long id,
            String title,
            String artistName,
            int price,
            boolean auction,
            Integer currentBid,
            String remainingTime) {
        return new HomeFeedDto.Artwork(
                id, title, artistName, price, "", false, auction, currentBid, remainingTime);
    }
}
