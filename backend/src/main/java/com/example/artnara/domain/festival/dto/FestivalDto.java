package com.example.artnara.domain.festival.dto;

import com.example.artnara.domain.festival.entity.Festival;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDate;

public class FestivalDto {

    @Schema(name = "FestivalCreateRequest")
    public record CreateRequest(String name, String region, String description,
                                String coverImageUrl, LocalDate startDate, LocalDate endDate) {}

    @Schema(name = "FestivalUpdateRequest")
    public record UpdateRequest(String name, String region, String description,
                                String coverImageUrl, LocalDate startDate, LocalDate endDate) {}

    @Schema(name = "FestivalResponse")
    public record Response(Long id, String name, String region, String description,
                           String coverImageUrl, LocalDate startDate, LocalDate endDate) {
        public static Response from(Festival f) {
            return new Response(f.getId(), f.getName(), f.getRegion(), f.getDescription(),
                    f.getCoverImageUrl(), f.getStartDate(), f.getEndDate());
        }
    }
}
