package com.example.artnara.domain.artwork.service;

import com.example.artnara.domain.artwork.dto.ArtworkDetailDto;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.springframework.stereotype.Service;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class ArtworkService {

    private static final int MIN_BID_INCREMENT = 10000;

    private final Map<Long, MutableArtwork> artworks = new LinkedHashMap<>();

    public ArtworkService() {
        seed(1L, "봄의 정원", "김예진", "자연의 빛을 기록하는 작가",
                "따스한 봄 햇살 아래 피어난 정원의 색을 캔버스에 옮겼습니다. 유화 특유의 두터운 질감으로 꽃잎의 생동감을 살렸습니다.",
                "캔버스에 유화", "53.0 x 45.5cm (10호)", 2026, 320000, false, null);
        seed(2L, "무채색의 위로", "박소현", "고요한 순간을 그립니다",
                "말 없는 위로가 필요한 날, 무채색의 결로 마음의 온도를 담아낸 작품입니다.",
                "종이에 목탄", "42.0 x 29.7cm (A3)", 2025, 180000, false, null);
        seed(3L, "빛과 그림자 사이", "이수민", "일상의 감정을 색으로 표현합니다",
                "창가에 스며드는 오후의 빛과 그림자의 경계를 관찰하며 그린 연작 중 세 번째 작품입니다.",
                "캔버스에 아크릴", "72.7 x 60.6cm (20호)", 2026, 450000, false, null);
        seed(4L, "고요한 파도", "최준혁", "바다의 시간을 수집하는 작가",
                "새벽 바다의 잔잔한 파도를 푸른 색층으로 쌓아 올렸습니다.",
                "캔버스에 유화", "65.1 x 50.0cm (15호)", 2025, 260000, false, null);
        seed(5L, "붉은 기억", "한지원", "기억의 잔상을 붉은 색채로 남깁니다",
                "지나간 기억의 온도를 붉은 색층으로 표현한 졸업 전시 출품작입니다.",
                "캔버스에 유화", "90.9 x 72.7cm (30호)", 2026, 780000, true, "02:14:33");
        seed(6L, "도시의 새벽", "오민서", "도시의 표정을 기록합니다",
                "아무도 깨지 않은 새벽 도시의 푸른 공기를 담았습니다.",
                "캔버스에 아크릴", "72.7 x 53.0cm (20호)", 2026, 340000, true, "05:47:10");
        seed(7L, "흐린 날의 숲", "정다은", "숲의 사계를 그리는 작가",
                "비 오기 직전 흐린 날 숲의 습기와 냄새까지 담고자 했습니다.",
                "종이에 수채", "56.0 x 38.0cm", 2025, 520000, true, "00:58:22");
        seed(8L, "기억의 조각", "윤재호", "조각난 기억을 화면 위에 재조립합니다",
                "콜라주 기법으로 기억의 파편들을 하나의 화면에 재구성한 작품입니다.",
                "혼합 매체", "60.6 x 60.6cm", 2026, 190000, true, "09:30:05");
    }

    public ArtworkDetailDto getDetail(Long artworkId) {
        return find(artworkId).toDto();
    }

    public synchronized ArtworkDetailDto placeBid(Long artworkId, ArtworkDetailDto.BidRequest request) {
        MutableArtwork artwork = find(artworkId);
        if (!artwork.auction) {
            throw new GlobalException(DomainResultCode.ARTWORK_NOT_AUCTION);
        }
        int minimumBid = artwork.currentBid + MIN_BID_INCREMENT;
        if (request.amount() < minimumBid) {
            throw new GlobalException(DomainResultCode.BID_AMOUNT_TOO_LOW,
                    "입찰가는 현재가보다 최소 " + MIN_BID_INCREMENT + "원 높아야 합니다.");
        }
        artwork.currentBid = request.amount();
        artwork.bidHistory.addFirst(new ArtworkDetailDto.Bid("나", request.amount(), "방금 전"));
        return artwork.toDto();
    }

    private MutableArtwork find(Long artworkId) {
        MutableArtwork artwork = artworks.get(artworkId);
        if (artwork == null) {
            throw new GlobalException(DomainResultCode.ARTWORK_NOT_FOUND);
        }
        return artwork;
    }

    private void seed(Long id, String title, String artistName, String artistIntroduction,
                      String description, String medium, String size, int year,
                      int price, boolean auction, String remainingTime) {
        MutableArtwork artwork = new MutableArtwork(
                id, title, artistName, artistIntroduction, description,
                medium, size, year, price, auction, remainingTime);
        if (auction) {
            artwork.currentBid = price;
            artwork.bidHistory.addFirst(new ArtworkDetailDto.Bid("김*진", price - MIN_BID_INCREMENT * 2, "1시간 전"));
            artwork.bidHistory.addFirst(new ArtworkDetailDto.Bid("이*수", price - MIN_BID_INCREMENT, "40분 전"));
            artwork.bidHistory.addFirst(new ArtworkDetailDto.Bid("박*현", price, "12분 전"));
        }
        artworks.put(id, artwork);
    }

    private static final class MutableArtwork {
        private final Long id;
        private final String title;
        private final String artistName;
        private final String artistIntroduction;
        private final String description;
        private final String medium;
        private final String size;
        private final int year;
        private final int price;
        private final boolean auction;
        private final String remainingTime;
        private int currentBid;
        private final Deque<ArtworkDetailDto.Bid> bidHistory = new ArrayDeque<>();

        private MutableArtwork(Long id, String title, String artistName, String artistIntroduction,
                               String description, String medium, String size, int year,
                               int price, boolean auction, String remainingTime) {
            this.id = id;
            this.title = title;
            this.artistName = artistName;
            this.artistIntroduction = artistIntroduction;
            this.description = description;
            this.medium = medium;
            this.size = size;
            this.year = year;
            this.price = price;
            this.auction = auction;
            this.remainingTime = remainingTime;
        }

        private ArtworkDetailDto toDto() {
            return new ArtworkDetailDto(
                    id, title, artistName, artistIntroduction, description, "",
                    medium, size, year, price, auction,
                    auction ? currentBid : null, MIN_BID_INCREMENT, remainingTime,
                    true, "전문 포장 후 배송 (3~5일 소요)",
                    List.copyOf(new ArrayList<>(bidHistory)));
        }
    }
}
