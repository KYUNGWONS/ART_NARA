package com.example.artnara.domain.sale.service;

import com.example.artnara.domain.artwork.dto.ArtworkCreate;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.domain.sale.dto.SaleDto;
import com.example.artnara.domain.sale.entity.Sale;
import com.example.artnara.domain.sale.repository.SaleRepository;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
@Transactional
public class SaleService {


    private final SaleRepository saleRepository;
    private final ArtworkService artworkService;
    private final UserRepository userRepository;

    public SaleDto.Response create(SaleDto.CreateRequest request,
                                   Long sellerId, String sellerName) {
        validate(request);
        Sale sale = saleRepository.save(Sale.builder()
                .sellerId(sellerId)
                .title(request.title().trim())
                .description(request.description() == null ? "" : request.description().trim())
                .medium(request.medium() == null ? "" : request.medium().trim())
                .sizeInfo(request.size() == null ? "" : request.size().trim())
                .yearCreated(request.year())
                .buyNowPrice(request.buyNowPrice())
                .auctionEnabled(request.auctionEnabled())
                .auctionStartPrice(request.auctionEnabled() ? request.auctionStartPrice() : null)
                .auctionEndDate(request.auctionEnabled() ? request.auctionEndDate() : null)
                .imageUrl(request.imageUrl() == null ? "" : request.imageUrl().trim())
                .category(request.category() == null ? "회화" : request.category().trim())
                .status("검수 대기")
                .build());

        // 프로토타입: 검수 절차 없이 바로 작품 저장소에 등록해 홈 피드에 노출한다.
        artworkService.register(new ArtworkCreate(
                sale.getTitle(), sellerName, artistIntroductionOf(sellerId),
                sale.getDescription(), sale.getMedium(), sale.getSizeInfo(),
                sale.getYearCreated() == null ? LocalDate.now().getYear() : sale.getYearCreated(),
                sale.getBuyNowPrice(), sale.isAuctionEnabled(),
                sale.getAuctionStartPrice(),
                sale.getAuctionEndDate() == null ? null : sale.getAuctionEndDate().toString(),
                sale.getImageUrl(), sale.getCategory()));
        return toDto(sale);
    }

    /**
     * 작품 상세·피드에 붙는 작가 소개.
     *
     * 예전에는 "내가 등록한 작품입니다." 를 그대로 박아 넣었는데, 이 문구는 **판매자 시점**이라
     * 남이 작품을 볼 때 말이 되지 않았다(실제로 구매자 화면에 그대로 보였다).
     * 판매자가 프로필에 써 둔 소개를 쓰고, 비어 있으면 문구를 넣지 않는다.
     */
    private String artistIntroductionOf(Long sellerId) {
        if (sellerId == null) return "";
        return userRepository.findById(sellerId)
                .map(User::getAboutMe)
                .filter(about -> about != null && !about.isBlank())
                .map(String::trim)
                .orElse("");
    }

    @Transactional(readOnly = true)
    /** '내 판매 작품' 목록 — 로그인한 판매자 본인 것만. */
    public SaleDto.ListResponse list(Long sellerId) {
        return new SaleDto.ListResponse(
                saleRepository.findBySellerIdOrderByIdDesc(sellerId).stream()
                        .map(this::toDto)
                        .toList());
    }

    private SaleDto.Response toDto(Sale sale) {
        return new SaleDto.Response(
                sale.getId(), sale.getTitle(), sale.getDescription(),
                sale.getMedium(), sale.getSizeInfo(), sale.getYearCreated(),
                sale.getBuyNowPrice(), sale.isAuctionEnabled(),
                sale.getAuctionStartPrice(), sale.getAuctionEndDate(),
                sale.getImageUrl(), sale.getCategory(), sale.getStatus());
    }

    private void validate(SaleDto.CreateRequest request) {
        if (request.title() == null || request.title().isBlank()) {
            throw new GlobalException(DomainResultCode.SALE_TITLE_REQUIRED);
        }
        if (request.buyNowPrice() == null || request.buyNowPrice() <= 0) {
            throw new GlobalException(DomainResultCode.SALE_INVALID_PRICE);
        }
        if (request.auctionEnabled()) {
            if (request.auctionStartPrice() == null || request.auctionStartPrice() <= 0) {
                throw new GlobalException(DomainResultCode.SALE_INVALID_AUCTION,
                        "경매 최저가를 입력해주세요.");
            }
            if (request.auctionStartPrice() > request.buyNowPrice()) {
                throw new GlobalException(DomainResultCode.SALE_INVALID_AUCTION,
                        "경매 최저가는 즉시 판매가보다 높을 수 없습니다.");
            }
            if (request.auctionEndDate() == null || !request.auctionEndDate().isAfter(LocalDate.now())) {
                throw new GlobalException(DomainResultCode.SALE_INVALID_AUCTION,
                        "경매 마감일은 내일 이후여야 합니다.");
            }
        }
    }
}
