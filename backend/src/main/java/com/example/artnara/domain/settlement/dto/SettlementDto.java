package com.example.artnara.domain.settlement.dto;

import java.util.List;

/**
 * 작가 판매 정산.
 *
 * 금액은 모두 원 단위이고, **환불된 주문은 합계에서 제외**한다(관리자 매출 집계와 같은 규칙).
 */
public record SettlementDto(
        /** 판매 금액 합계 (환불 제외) */
        int totalSales,
        /** 플랫폼 수수료율 (%) */
        int feeRate,
        /** 수수료 합계 */
        int feeAmount,
        /** 정산 예정액 = 판매 금액 - 수수료 */
        int netAmount,
        /** 이번 달 판매 금액 (환불 제외) */
        int thisMonthSales,
        /** 정산 대상 판매 수 (환불 제외) */
        int saleCount,
        List<Item> items
) {
    /** 판매 건별 정산 내역. 환불 건도 이력으로 보여주되 합계에는 넣지 않는다. */
    public record Item(
            Long orderId,
            Long artworkId,
            String artworkTitle,
            String buyerName,
            int amount,
            int feeAmount,
            int netAmount,
            String soldDate,
            boolean refunded
    ) {}
}
