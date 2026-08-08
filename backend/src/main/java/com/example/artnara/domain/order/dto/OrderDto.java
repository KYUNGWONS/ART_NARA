package com.example.artnara.domain.order.dto;

import java.util.List;

public class OrderDto {

    /** 예약 요청. 배송이 없어 결제는 만난 뒤에 하므로 여기서는 결제 정보를 받지 않는다. */
    public record CreateRequest(Long artworkId) {}

    /** 결제 요청. 양쪽 수령 확인이 끝난 예약에만 쓸 수 있다. */
    public record PayRequest(
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
            boolean refunded,
            /** 직거래 진행 상태 — 앱이 어떤 버튼을 보여줄지 정하는 근거 */
            boolean sellerConfirmed,
            boolean buyerConfirmed,
            boolean paid,
            boolean cancelled,
            /** 이 주문을 보는 사람이 판매자인지(아니면 구매자). 버튼 문구가 달라진다. */
            boolean viewerIsSeller,
            String buyerName
    ) {}

    public record ListResponse(List<Response> orders) {}
}
