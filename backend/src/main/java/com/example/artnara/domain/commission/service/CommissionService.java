package com.example.artnara.domain.commission.service;

import com.example.artnara.domain.commission.dto.CommissionDto;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class CommissionService {

    // 카테고리별 매칭 희망을 설정해둔 작가 수 (알림 발송 대상 mock)
    private static final Map<String, Integer> ARTIST_POOL = Map.of(
            "회화", 42,
            "일러스트", 65,
            "조소", 18,
            "공예", 27,
            "디지털 아트", 53
    );

    private final Map<Long, MutableCommission> commissions = new LinkedHashMap<>();
    private final AtomicLong idSequence = new AtomicLong(0);

    public CommissionService() {
        MutableCommission sample = new MutableCommission(
                idSequence.incrementAndGet(),
                "거실에 걸 바다 풍경화 의뢰",
                "3m 폭 거실 벽에 어울리는 잔잔한 바다 풍경을 원해요. 파란색 계열이면 좋겠습니다.",
                "회화", 500000, LocalDate.now().plusDays(30), "",
                ARTIST_POOL.get("회화"));
        sample.offers.add(new CommissionDto.Offer("김*진", 450000, "유화로 30호 작업 가능합니다.", "2시간 전"));
        sample.offers.add(new CommissionDto.Offer("박*현", 400000, "아크릴로 2주 내 완성 가능해요.", "1시간 전"));
        commissions.put(sample.id, sample);
    }

    public synchronized CommissionDto.Response create(CommissionDto.CreateRequest request) {
        validate(request);
        MutableCommission commission = new MutableCommission(
                idSequence.incrementAndGet(),
                request.title().trim(),
                request.description() == null ? "" : request.description().trim(),
                request.category().trim(),
                request.budget(),
                request.desiredDate(),
                request.referenceImageUrl() == null ? "" : request.referenceImageUrl().trim(),
                ARTIST_POOL.getOrDefault(request.category().trim(), 10));
        commissions.put(commission.id, commission);
        return commission.toDto();
    }

    public synchronized CommissionDto.ListResponse list() {
        List<CommissionDto.Response> result = new ArrayList<>();
        commissions.values().forEach(commission -> result.add(0, commission.toDto()));
        return new CommissionDto.ListResponse(List.copyOf(result));
    }

    public synchronized CommissionDto.Response placeOffer(Long commissionId, CommissionDto.OfferRequest request) {
        MutableCommission commission = commissions.get(commissionId);
        if (commission == null) {
            throw new GlobalException(DomainResultCode.COMMISSION_NOT_FOUND);
        }
        if (request.amount() == null || request.amount() <= 0) {
            throw new GlobalException(DomainResultCode.OFFER_INVALID_AMOUNT);
        }
        Integer lowest = commission.lowestOffer();
        int ceiling = lowest != null ? lowest : commission.budget;
        if (request.amount() >= ceiling) {
            throw new GlobalException(DomainResultCode.OFFER_AMOUNT_TOO_HIGH,
                    "역경매 제안가는 현재 최저가(" + ceiling + "원)보다 낮아야 합니다.");
        }
        String artistName = request.artistName() == null || request.artistName().isBlank()
                ? "익명 작가" : request.artistName().trim();
        commission.offers.add(0, new CommissionDto.Offer(
                artistName, request.amount(),
                request.message() == null ? "" : request.message().trim(), "방금 전"));
        return commission.toDto();
    }

    private void validate(CommissionDto.CreateRequest request) {
        if (request.title() == null || request.title().isBlank()) {
            throw new GlobalException(DomainResultCode.COMMISSION_TITLE_REQUIRED);
        }
        if (request.category() == null || request.category().isBlank()) {
            throw new GlobalException(DomainResultCode.COMMISSION_CATEGORY_REQUIRED);
        }
        if (request.budget() == null || request.budget() <= 0) {
            throw new GlobalException(DomainResultCode.COMMISSION_INVALID_BUDGET);
        }
    }

    private static final class MutableCommission {
        private final Long id;
        private final String title;
        private final String description;
        private final String category;
        private final int budget;
        private final LocalDate desiredDate;
        private final String referenceImageUrl;
        private final int notifiedArtistCount;
        private final List<CommissionDto.Offer> offers = new ArrayList<>();

        private MutableCommission(Long id, String title, String description, String category,
                                  int budget, LocalDate desiredDate, String referenceImageUrl,
                                  int notifiedArtistCount) {
            this.id = id;
            this.title = title;
            this.description = description;
            this.category = category;
            this.budget = budget;
            this.desiredDate = desiredDate;
            this.referenceImageUrl = referenceImageUrl;
            this.notifiedArtistCount = notifiedArtistCount;
        }

        private Integer lowestOffer() {
            return offers.stream()
                    .map(CommissionDto.Offer::amount)
                    .min(Integer::compareTo)
                    .orElse(null);
        }

        private CommissionDto.Response toDto() {
            return new CommissionDto.Response(
                    id, title, description, category, budget, desiredDate, referenceImageUrl,
                    offers.isEmpty() ? "작가 제안 대기" : "역경매 진행 중",
                    notifiedArtistCount, lowestOffer(), List.copyOf(offers));
        }
    }
}
