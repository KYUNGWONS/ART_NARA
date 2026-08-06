package com.example.artnara.domain.commission.dto;

import java.time.LocalDate;
import java.util.List;

public class CommissionDto {

    public record CreateRequest(
            String title,
            String description,
            /** 선호 카테고리(복수). 단일 문자열만 보내던 구버전 호환은 category 로 받는다. */
            List<String> categories,
            String category,
            Integer budget,
            LocalDate desiredDate,
            String referenceImageUrl
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
            List<String> categories,
            Integer budget,
            LocalDate desiredDate,
            String referenceImageUrl,
            String status,
            int notifiedArtistCount,
            Integer lowestOffer,
            List<Offer> offers
    ) {}

    public record ListResponse(List<Response> commissions) {}
}
