package com.example.artnara.domain.artwork.service;

import com.example.artnara.domain.artwork.dto.ArtworkCreate;
import com.example.artnara.domain.artwork.dto.ArtworkDetailDto;
import com.example.artnara.domain.artwork.dto.NearbyArtworkDto;
import com.example.artnara.domain.artwork.entity.Artwork;
import com.example.artnara.domain.artwork.entity.ArtworkBid;
import com.example.artnara.domain.artwork.entity.ArtworkLike;
import com.example.artnara.domain.artwork.repository.ArtworkBidRepository;
import com.example.artnara.domain.artwork.repository.ArtworkLikeRepository;
import com.example.artnara.domain.artwork.repository.ArtworkRepository;
import com.example.artnara.domain.notification.entity.NotificationType;
import com.example.artnara.domain.notification.service.NotificationService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class ArtworkService {

    private static final int MIN_BID_INCREMENT = 10000;

    /** 프로토타입 단일 사용자 입찰자명. */
    private static final String BIDDER_NAME = "나";

    // 작품 위치 mock (판매자 동네 기준) — 시드 id 순서대로 홍대, 성수, 이태원, 연남, 망원, 합정, 상수, 서교
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

    private final ArtworkRepository artworkRepository;
    private final ArtworkBidRepository artworkBidRepository;
    private final ArtworkLikeRepository artworkLikeRepository;
    private final NotificationService notificationService;

    @Transactional(readOnly = true)
    public ArtworkDetailDto getDetail(Long artworkId) {
        return toDto(find(artworkId));
    }

    @Transactional(readOnly = true)
    public List<ArtworkDetailDto> listAll() {
        return artworkRepository.findAllByOrderByIdAsc().stream()
                .map(this::toDto)
                .toList();
    }

    /** 판매 등록된 작품을 작품 저장소에 추가하고 발급된 작품 id를 반환한다. */
    public Long register(ArtworkCreate create) {
        Artwork artwork = Artwork.builder()
                .title(create.title())
                .artistName(create.artistName())
                .artistIntroduction(create.artistIntroduction())
                .description(create.description())
                .medium(create.medium())
                .sizeInfo(create.size())
                .yearCreated(create.year())
                .price(create.price())
                .auction(create.auction())
                .currentBid(create.auction()
                        ? (create.auctionStartPrice() != null
                                ? create.auctionStartPrice() : create.price())
                        : null)
                .imageUrl(create.imageUrl())
                .category(create.category())
                .auctionEndAt(create.auction() && create.auctionEndDate() != null
                        ? LocalDate.parse(create.auctionEndDate()).atTime(23, 59, 59)
                        : null)
                .build();
        return artworkRepository.save(artwork).getId();
    }

    public ArtworkDetailDto placeBid(Long artworkId, ArtworkDetailDto.BidRequest request) {
        Artwork artwork = find(artworkId);
        if (!artwork.isAuction()) {
            throw new GlobalException(DomainResultCode.ARTWORK_NOT_AUCTION);
        }
        if (artwork.isAuctionClosed()) {
            throw new GlobalException(DomainResultCode.AUCTION_ALREADY_CLOSED);
        }
        int currentBid = artwork.getCurrentBid() == null
                ? artwork.getPrice() : artwork.getCurrentBid();
        int minimumBid = currentBid + MIN_BID_INCREMENT;
        if (request.amount() < minimumBid) {
            throw new GlobalException(DomainResultCode.BID_AMOUNT_TOO_LOW,
                    "입찰가는 현재가보다 최소 " + MIN_BID_INCREMENT + "원 높아야 합니다.");
        }
        artwork.updateCurrentBid(request.amount());
        artworkBidRepository.save(ArtworkBid.builder()
                .artworkId(artworkId)
                .bidderName(BIDDER_NAME)
                .amount(request.amount())
                .bidTime("방금 전")
                .build());
        return toDto(artwork);
    }

    /** 경매 마감 처리 — 최고 입찰자가 낙찰자로 확정된다. (프로토타입: 수동 마감) */
    public ArtworkDetailDto closeAuction(Long artworkId) {
        Artwork artwork = find(artworkId);
        if (!artwork.isAuction()) {
            throw new GlobalException(DomainResultCode.ARTWORK_NOT_AUCTION);
        }
        if (artwork.isAuctionClosed()) {
            throw new GlobalException(DomainResultCode.AUCTION_ALREADY_CLOSED);
        }
        artwork.closeAuction(topBidderName(artworkId));
        return toDto(artwork);
    }

    /** 마감 시각이 지난 경매를 일괄 마감한다. 스케줄러가 주기적으로 호출한다. */
    public int closeExpiredAuctions() {
        List<Artwork> expired = artworkRepository
                .findByAuctionTrueAndAuctionClosedFalseAndAuctionEndAtLessThanEqual(LocalDateTime.now());
        expired.forEach(artwork -> {
            String winner = topBidderName(artwork.getId());
            artwork.closeAuction(winner);
            notificationService.publish(NotificationType.AUCTION_CLOSED,
                    winner == null ? "경매가 유찰되었어요" : "경매가 마감되었어요",
                    winner == null
                            ? "'" + artwork.getTitle() + "' 경매가 입찰 없이 마감되었습니다."
                            : "'" + artwork.getTitle() + "' 경매가 " + winner + "님께 낙찰되었습니다.",
                    artwork.getId());
        });
        return expired.size();
    }

    private String topBidderName(Long artworkId) {
        return artworkBidRepository
                .findFirstByArtworkIdOrderByAmountDesc(artworkId)
                .map(ArtworkBid::getBidderName)
                .orElse(null);
    }

    /** 관심 작품 토글. 반환값은 토글 후 상태(true = 관심 등록됨). */
    public boolean toggleLike(Long artworkId, Long userId) {
        if (!artworkRepository.existsById(artworkId)) {
            throw new GlobalException(DomainResultCode.ARTWORK_NOT_FOUND);
        }
        return artworkLikeRepository.findByUserIdAndArtworkId(userId, artworkId)
                .map(like -> {
                    artworkLikeRepository.delete(like);
                    return false;
                })
                .orElseGet(() -> {
                    artworkLikeRepository.save(ArtworkLike.builder()
                            .userId(userId).artworkId(artworkId).build());
                    return true;
                });
    }

    /** 사용자가 하트를 누른 작품 id 집합. 비로그인(userId null)이면 빈 집합. */
    @Transactional(readOnly = true)
    public Set<Long> likedArtworkIds(Long userId) {
        if (userId == null) return Set.of();
        return artworkLikeRepository.findByUserId(userId).stream()
                .map(ArtworkLike::getArtworkId)
                .collect(Collectors.toSet());
    }

    @Transactional(readOnly = true)
    public NearbyArtworkDto getNearby(double latitude, double longitude) {
        List<NearbyArtworkDto.Item> items = artworkRepository.findAllByOrderByIdAsc().stream()
                .map(artwork -> {
                    double[] location = LOCATIONS.getOrDefault(artwork.getId(), DEFAULT_LOCATION);
                    double distance = haversineKm(latitude, longitude, location[0], location[1]);
                    return new NearbyArtworkDto.Item(
                            artwork.getId(), artwork.getTitle(), artwork.getArtistName(),
                            artwork.isAuction() && artwork.getCurrentBid() != null
                                    ? artwork.getCurrentBid() : artwork.getPrice(),
                            artwork.isAuction(), location[0], location[1],
                            ADDRESSES.getOrDefault(artwork.getId(), "서울 마포구"),
                            Math.round(distance * 10) / 10.0);
                })
                .sorted(Comparator.comparingDouble(NearbyArtworkDto.Item::distanceKm))
                .toList();
        return new NearbyArtworkDto(items);
    }

    private Artwork find(Long artworkId) {
        return artworkRepository.findById(artworkId)
                .orElseThrow(() -> new GlobalException(DomainResultCode.ARTWORK_NOT_FOUND));
    }

    private ArtworkDetailDto toDto(Artwork artwork) {
        List<ArtworkDetailDto.Bid> bids = artwork.isAuction()
                ? artworkBidRepository.findByArtworkIdOrderByAmountDesc(artwork.getId()).stream()
                        .map(bid -> new ArtworkDetailDto.Bid(
                                bid.getBidderName(), bid.getAmount(), bid.getBidTime()))
                        .toList()
                : List.of();
        return new ArtworkDetailDto(
                artwork.getId(), artwork.getTitle(), artwork.getArtistName(),
                artwork.getArtistIntroduction(), artwork.getDescription(),
                artwork.getImageUrl(), artwork.getMedium(), artwork.getSizeInfo(),
                artwork.getYearCreated(), artwork.getPrice(), artwork.isAuction(),
                artwork.isAuction() ? artwork.getCurrentBid() : null,
                MIN_BID_INCREMENT,
                remainingTimeOf(artwork),
                artwork.isAuctionClosed(), artwork.getWinnerName(),
                true, artwork.getCategory(), bids);
    }

    private String remainingTimeOf(Artwork artwork) {
        if (!artwork.isAuction()) return null;
        if (artwork.isAuctionClosed()) return "00:00:00";
        if (artwork.getAuctionEndAt() == null) return null;
        Duration remaining = Duration.between(LocalDateTime.now(), artwork.getAuctionEndAt());
        if (remaining.isNegative() || remaining.isZero()) return "00:00:00";
        long days = remaining.toDays();
        if (days > 0) return "D-" + days;
        return String.format("%02d:%02d:%02d",
                remaining.toHours(), remaining.toMinutesPart(), remaining.toSecondsPart());
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
}
