package com.example.artnara.domain.settlement.service;

import com.example.artnara.domain.order.entity.ArtOrder;
import com.example.artnara.domain.order.repository.ArtOrderRepository;
import com.example.artnara.domain.settlement.dto.SettlementDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

/**
 * 작가가 자기 판매분을 정산 관점으로 본다.
 *
 * 대상은 **로그인 신원(활동명)이 판매한 작품**뿐이다 — 남의 매출이 섞이면 안 된다.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SettlementService {

    /** 플랫폼 수수료율(%). 구매자에게는 수수료를 받지 않고 판매 대금에서 뗀다. */
    public static final int FEE_RATE = 10;

    private final ArtOrderRepository artOrderRepository;

    public SettlementDto forArtist(String artistName) {
        List<ArtOrder> orders = artistName == null || artistName.isBlank()
                ? List.of()
                : artOrderRepository.findByArtistNameOrderByIdDesc(artistName);

        String thisMonth = LocalDate.now().toString().substring(0, 7); // yyyy-MM
        int totalSales = 0;
        int feeAmount = 0;
        int thisMonthSales = 0;
        int saleCount = 0;

        List<SettlementDto.Item> items = orders.stream().map(order -> {
            int fee = feeOf(order.getAmount());
            return new SettlementDto.Item(
                    order.getId(), order.getArtworkId(), order.getArtworkTitle(),
                    order.getBuyerName(), order.getAmount(), fee, order.getAmount() - fee,
                    order.getOrderedDate(), order.isRefunded());
        }).toList();

        for (ArtOrder order : orders) {
            // 결제까지 끝난 건만 정산 대상이다. 예약·수령확인 단계는 아직 돈이 오가지 않았고,
            // 환불된 건은 이력에만 남긴다.
            if (!order.isPaid() || order.isRefunded()) continue;
            totalSales += order.getAmount();
            feeAmount += feeOf(order.getAmount());
            saleCount++;
            if (order.getOrderedDate() != null && order.getOrderedDate().startsWith(thisMonth)) {
                thisMonthSales += order.getAmount();
            }
        }

        return new SettlementDto(totalSales, FEE_RATE, feeAmount, totalSales - feeAmount,
                thisMonthSales, saleCount, items);
    }

    private int feeOf(int amount) {
        return amount * FEE_RATE / 100;
    }
}
