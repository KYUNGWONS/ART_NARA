package com.example.artnara.domain.order.dto;

import java.util.List;

public class OrderDto {

    public record CreateRequest(
            Long artworkId,
            String paymentMethod,
            /** 토스 결제창이 돌려준 값. 없으면 mock 결제로 처리한다(프로토타입). */
            String paymentKey,
            String tossOrderId
    ) {}

    public record Response(
            Long orderId,
            Long artworkId,
            String artworkTitle,
            String artistName,
            int amount,
            String paymentMethod,
            String status,
            String certificateNo,
            String orderedDate,
            /** 환불된 주문인지 — 앱이 리뷰 버튼을 감추고 환불 표시를 하는 근거 */
            boolean refunded
    ) {}

    public record ListResponse(List<Response> orders) {}
}
