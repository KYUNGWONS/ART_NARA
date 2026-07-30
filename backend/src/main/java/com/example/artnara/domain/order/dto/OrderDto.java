package com.example.artnara.domain.order.dto;

import java.util.List;

public class OrderDto {

    public record CreateRequest(
            Long artworkId,
            String paymentMethod,
            String receiverName,
            String phone,
            String deliveryAddress
    ) {}

    public record Response(
            Long orderId,
            Long artworkId,
            String artworkTitle,
            String artistName,
            int price,
            int deliveryFee,
            int totalAmount,
            String paymentMethod,
            String receiverName,
            String deliveryAddress,
            String status,
            String certificateNo,
            String orderedDate
    ) {}

    public record ListResponse(List<Response> orders) {}
}
