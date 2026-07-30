package com.example.artnara.domain.artwork.service;

import com.example.artnara.domain.artwork.dto.ArtworkCreate;
import com.example.artnara.domain.artwork.dto.ArtworkDetailDto;
import com.example.artnara.domain.artwork.dto.NearbyArtworkDto;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.springframework.stereotype.Service;

import java.util.Comparator;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class ArtworkService {

    private static final int MIN_BID_INCREMENT = 10000;

    private final Map<Long, MutableArtwork> artworks = new LinkedHashMap<>();
    private final AtomicLong idSequence = new AtomicLong(8); // 시드 작품 1~8 이후부터 발급

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

    // 작품 위치 mock (판매자 동네 기준) — id 순서대로 홍대, 성수, 이태원, 연남, 망원, 합정, 상수, 서교
    private static final Map<Long, double[]> LOCATIONS = Map.of(
            1L, new double[]{37.5563, 126.9220}, 2L, new double[]{37.5446, 127.0559},
            3L, new double[]{37.5340, 126.9948}, 4L, new double[]{37.5628, 126.9256},
            5L, new double[]{37.5556, 126.9019}, 6L, new double[]{37.5495, 126.9139},
            7L, new double[]{37.5478, 126.9227}, 8L, new double[]{37.5525, 126.9180});

    private static final Map<Long, String> ADDRESSES = Map.of(
            1L, "서울 마포구 홍대입구", 2L, "서울 성동구 성수동",
            3L, "서울 용산구 이태원동", 4L, "서울 마포구 연남동",
            5L, "서울 마포구 망원동", 6L, "서울 마포구 합정동",
            7L, "서울 마포구 상수동", 8L, "서울 마포구 서교동");

    // 위치 정보가 없는 등록 작품의 기본 좌표 (홍대입구)
    private static final double[] DEFAULT_LOCATION = {37.5563, 126.9220};

    public synchronized ArtworkDetailDto getDetail(Long artworkId) {
        return find(artworkId).toDto();
    }

    public synchronized List<ArtworkDetailDto> listAll() {
        return artworks.values().stream().map(MutableArtwork::toDto).toList();
    }

    /** 판매 등록된 작품을 작품 저장소에 추가하고 발급된 작품 id를 반환한다. */
    public synchronized Long register(ArtworkCreate create) {
        Long id = idSequence.incrementAndGet();
        MutableArtwork artwork = new MutableArtwork(
                id, create.title(), create.artistName(), create.artistIntroduction(),
                create.description(), create.medium(), create.size(), create.year(),
                create.price(), create.auction(),
                create.auction() ? "~" + create.auctionEndDate() : null);
        artwork.imageUrl = create.imageUrl() == null ? "" : create.imageUrl();
        if (create.auction()) {
            artwork.currentBid = create.auctionStartPrice() != null
                    ? create.auctionStartPrice() : create.price();
        }
        artworks.put(id, artwork);
        return id;
    }

    public synchronized NearbyArtworkDto getNearby(double latitude, double longitude) {
        List<NearbyArtworkDto.Item> items = artworks.values().stream()
                .map(artwork -> {
                    double[] location = LOCATIONS.getOrDefault(artwork.id, DEFAULT_LOCATION);
                    double distance = haversineKm(latitude, longitude, location[0], location[1]);
                    return new NearbyArtworkDto.Item(
                            artwork.id, artwork.title, artwork.artistName,
                            artwork.auction ? artwork.currentBid : artwork.price,
                            artwork.auction, location[0], location[1],
                            ADDRESSES.getOrDefault(artwork.id, "서울 마포구"),
                            Math.round(distance * 10) / 10.0);
                })
                .sorted(Comparator.comparingDouble(NearbyArtworkDto.Item::distanceKm))
                .toList();
        return new NearbyArtworkDto(items);
    }

    private static double haversineKm(double lat1, double lng1, double lat2, double lng2) {
        double earthRadiusKm = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return earthRadiusKm * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    public synchronized ArtworkDetailDto placeBid(Long artworkId, ArtworkDetailDto.BidRequest request) {
        MutableArtwork artwork = find(artworkId);
        if (!artwork.auction) {
            throw new GlobalException(DomainResultCode.ARTWORK_NOT_AUCTION);
        }
        if (artwork.auctionClosed) {
            throw new GlobalException(DomainResultCode.AUCTION_ALREADY_CLOSED);
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

    /** 경매 마감 처리 — 최고 입찰자가 낙찰자로 확정된다. (프로토타입: 수동 마감) */
    public synchronized ArtworkDetailDto closeAuction(Long artworkId) {
        MutableArtwork artwork = find(artworkId);
        if (!artwork.auction) {
            throw new GlobalException(DomainResultCode.ARTWORK_NOT_AUCTION);
        }
        if (artwork.auctionClosed) {
            throw new GlobalException(DomainResultCode.AUCTION_ALREADY_CLOSED);
        }
        artwork.auctionClosed = true;
        artwork.winnerName = artwork.bidHistory.isEmpty()
                ? null : artwork.bidHistory.peekFirst().bidderName();
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
        private boolean auctionClosed;
        private String winnerName;
        private String imageUrl = "";
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
                    id, title, artistName, artistIntroduction, description, imageUrl,
                    medium, size, year, price, auction,
                    auction ? currentBid : null, MIN_BID_INCREMENT,
                    auctionClosed ? "00:00:00" : remainingTime,
                    auctionClosed, winnerName,
                    true, "전문 포장 후 배송 (3~5일 소요)",
                    List.copyOf(new ArrayList<>(bidHistory)));
        }
    }
}
