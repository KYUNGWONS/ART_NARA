package com.example.artnara.domain.commission.service;

import com.example.artnara.domain.commission.dto.CommissionDto;
import com.example.artnara.domain.commission.entity.Commission;
import com.example.artnara.domain.commission.entity.CommissionOffer;
import com.example.artnara.domain.commission.repository.CommissionOfferRepository;
import com.example.artnara.domain.commission.repository.CommissionRepository;
import com.example.artnara.domain.notification.entity.NotificationType;
import com.example.artnara.domain.notification.service.NotificationService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional
public class CommissionService {

    // 카테고리별 매칭 희망을 설정해둔 작가 수 (알림 발송 대상 mock)
    private static final Map<String, Integer> ARTIST_POOL = Map.of(
            "회화", 42,
            "일러스트", 65,
            "조소", 18,
            "공예", 27,
            "디지털 아트", 53
    );

    private final CommissionRepository commissionRepository;
    private final CommissionOfferRepository commissionOfferRepository;
    private final NotificationService notificationService;

    public CommissionDto.Response create(CommissionDto.CreateRequest request) {
        List<String> categories = selectedCategories(request);
        validate(request, categories);
        Commission commission = commissionRepository.save(Commission.builder()
                .title(request.title().trim())
                .description(request.description() == null ? "" : request.description().trim())
                .categories(categories)
                .budget(request.budget())
                .desiredDate(request.desiredDate())
                .referenceImageUrl(request.referenceImageUrl() == null
                        ? "" : request.referenceImageUrl().trim())
                .notifiedArtistCount(notifiedArtistCount(categories))
                .build());
        notificationService.publish(NotificationType.COMMISSION_CREATED,
                "의뢰가 작가들에게 전달되었어요",
                commission.getNotifiedArtistCount() + "명의 "
                        + String.join("·", categories)
                        + " 작가에게 '" + commission.getTitle() + "' 의뢰가 전달되었습니다.",
                commission.getId());
        return toDto(commission);
    }

    /**
     * 화면에서 고른 카테고리 목록. 구버전 클라이언트는 category 하나만 보내므로
     * 그 경우에도 한 개짜리 목록으로 받아준다.
     */
    private List<String> selectedCategories(CommissionDto.CreateRequest request) {
        List<String> selected = request.categories() == null
                ? List.of()
                : request.categories().stream()
                        .filter(category -> category != null && !category.isBlank())
                        .map(String::trim)
                        .distinct()
                        .toList();
        if (!selected.isEmpty()) return selected;
        return (request.category() == null || request.category().isBlank())
                ? List.of()
                : List.of(request.category().trim());
    }

    /** 선택한 카테고리들의 매칭 희망 작가를 합산한다(중복 작가는 고려하지 않는 mock). */
    private int notifiedArtistCount(List<String> categories) {
        return categories.stream()
                .mapToInt(category -> ARTIST_POOL.getOrDefault(category, 10))
                .sum();
    }

    @Transactional(readOnly = true)
    public CommissionDto.ListResponse list() {
        return new CommissionDto.ListResponse(
                commissionRepository.findAllByOrderByIdDesc().stream()
                        .map(this::toDto)
                        .toList());
    }

    public CommissionDto.Response placeOffer(Long commissionId, CommissionDto.OfferRequest request) {
        Commission commission = commissionRepository.findById(commissionId)
                .orElseThrow(() -> new GlobalException(DomainResultCode.COMMISSION_NOT_FOUND));
        if (request.amount() == null || request.amount() <= 0) {
            throw new GlobalException(DomainResultCode.OFFER_INVALID_AMOUNT);
        }
        int ceiling = commissionOfferRepository
                .findFirstByCommissionIdOrderByAmountAsc(commissionId)
                .map(CommissionOffer::getAmount)
                .orElse(commission.getBudget());
        if (request.amount() >= ceiling) {
            throw new GlobalException(DomainResultCode.OFFER_AMOUNT_TOO_HIGH,
                    "역경매 제안가는 현재 최저가(" + ceiling + "원)보다 낮아야 합니다.");
        }
        String artistName = request.artistName() == null || request.artistName().isBlank()
                ? "익명 작가" : request.artistName().trim();
        commissionOfferRepository.save(CommissionOffer.builder()
                .commissionId(commissionId)
                .artistName(artistName)
                .amount(request.amount())
                .message(request.message() == null ? "" : request.message().trim())
                .offerTime("방금 전")
                .build());
        notificationService.publish(NotificationType.COMMISSION_OFFER,
                "새 제안이 도착했어요",
                artistName + " 작가가 '" + commission.getTitle() + "' 의뢰에 "
                        + String.format("%,d", request.amount()) + "원을 제안했습니다.",
                commission.getId());
        return toDto(commission);
    }

    private CommissionDto.Response toDto(Commission commission) {
        List<CommissionDto.Offer> offers = commissionOfferRepository
                .findByCommissionIdOrderByAmountAsc(commission.getId()).stream()
                .map(offer -> new CommissionDto.Offer(
                        offer.getArtistName(), offer.getAmount(),
                        offer.getMessage(), offer.getOfferTime()))
                .toList();
        Integer lowestOffer = offers.isEmpty() ? null : offers.get(0).amount();
        return new CommissionDto.Response(
                commission.getId(), commission.getTitle(), commission.getDescription(),
                commission.getCategory(), commission.getCategories(),
                commission.getBudget(), commission.getDesiredDate(),
                commission.getReferenceImageUrl(),
                offers.isEmpty() ? "작가 제안 대기" : "역경매 진행 중",
                commission.getNotifiedArtistCount(), lowestOffer, offers);
    }

    private void validate(CommissionDto.CreateRequest request, List<String> categories) {
        if (request.title() == null || request.title().isBlank()) {
            throw new GlobalException(DomainResultCode.COMMISSION_TITLE_REQUIRED);
        }
        if (categories.isEmpty()) {
            throw new GlobalException(DomainResultCode.COMMISSION_CATEGORY_REQUIRED);
        }
        if (request.budget() == null || request.budget() <= 0) {
            throw new GlobalException(DomainResultCode.COMMISSION_INVALID_BUDGET);
        }
    }
}
