package com.example.artnara.domain.commission.dto;

import java.time.LocalDate;
import java.util.List;

public class CommissionDto {

    public record CreateRequest(
            String title,
            String description,
            String category,
            Integer budget,
            LocalDate desiredDate
    ) {}

    public record OfferRequest(
            String artistName,
            Integer amount,
            String message
    ) {}

    public record Offer(
            String artistName,
            int amount,
            String message,
            String offerTime
    ) {}

    public record Response(
            Long id,
            String title,
            String description,
            String category,
            Integer budget,
            LocalDate desiredDate,
            String status,
            int notifiedArtistCount,
            Integer lowestOffer,
            List<Offer> offers
    ) {}

    public record ListResponse(List<Response> commissions) {}
}
