package com.example.artnara.domain.order.dto;

import java.util.List;

public class OrderDto {

    public record CreateRequest(
            Long artworkId,
            String paymentMethod
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
            String orderedDate
    ) {}

    public record ListResponse(List<Response> orders) {}
}
