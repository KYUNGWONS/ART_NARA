package com.example.artnara.domain.sale.dto;

import java.time.LocalDate;
import java.util.List;

public class SaleDto {

    public record CreateRequest(
            String title,
            String description,
            String medium,
            String size,
            Integer year,
            Integer buyNowPrice,
            boolean auctionEnabled,
            Integer auctionStartPrice,
            LocalDate auctionEndDate,
            String imageUrl,
            String category
    ) {}

    public record Response(
            Long id,
            String title,
            String description,
            String medium,
            String size,
            Integer year,
            Integer buyNowPrice,
            boolean auctionEnabled,
            Integer auctionStartPrice,
            LocalDate auctionEndDate,
            String imageUrl,
            String category,
            String status
    ) {}

    public record ListResponse(List<Response> sales) {}
}
