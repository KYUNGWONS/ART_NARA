package com.example.artnara.domain.content.dto;

import com.example.artnara.domain.content.entity.Content;
import com.example.artnara.domain.content.entity.ContentKnot;
import com.example.artnara.domain.content.entity.Language;
import com.example.artnara.domain.content.entity.Theme;
import com.example.artnara.domain.content.entity.TimeSlot;
import com.example.artnara.domain.user.entity.Sido;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.DayOfWeek;
import java.util.List;

public class ContentDto {

    public record KnotRequest(
            String place,
            String activity,
            Integer durationMinutes
    ) {}

    public record KnotResponse(
            int orderIndex,
            String place,
            String activity,
            Integer durationMinutes
    ) {
        public static KnotResponse from(ContentKnot k) {
            return new KnotResponse(k.getOrderIndex(), k.getPlace(), k.getActivity(), k.getDurationMinutes());
        }
    }

    @Schema(name = "ContentCreateRequest")
    public record CreateRequest(
            String title,
            String shortIntro,
            String description,
            Theme theme,
            Sido sido,
            String neighborhood,
            Long districtId,
            List<Language> languages,
            List<String> imageUrls,
            List<KnotRequest> knots,
            List<DayOfWeek> availableDays,
            List<TimeSlot> availableTimeSlots,
            String meetingPoint,
            Integer maxParticipants,
            Integer pricePerHour
    ) {}

    @Schema(name = "ContentUpdateRequest")
    public record UpdateRequest(
            String title,
            String shortIntro,
            String description,
            Theme theme,
            Sido sido,
            String neighborhood,
            Long districtId,
            List<Language> languages,
            List<String> imageUrls,
            List<KnotRequest> knots,
            List<DayOfWeek> availableDays,
            List<TimeSlot> availableTimeSlots,
            String meetingPoint,
            Integer maxParticipants,
            Integer pricePerHour
    ) {}

    @Schema(name = "ContentResponse")
    public record Response(
            Long id,
            Long authorId,
            String authorNickname,
            String title,
            String shortIntro,
            String description,
            Theme theme,
            Sido sido,
            String neighborhood,
            Long districtId,
            String districtName,
            List<Language> languages,
            List<String> imageUrls,
            List<KnotResponse> knots,
            List<DayOfWeek> availableDays,
            List<TimeSlot> availableTimeSlots,
            String meetingPoint,
            Integer maxParticipants,
            Integer pricePerHour,
            boolean visible
    ) {
        public static Response from(Content c) {
            return new Response(
                    c.getId(), c.getAuthor().getId(), c.getAuthor().getNickname(),
                    c.getTitle(), c.getShortIntro(), c.getDescription(), c.getTheme(),
                    c.getSido(), c.getNeighborhood(),
                    c.getDistrict() != null ? c.getDistrict().getId() : null,
                    c.getDistrict() != null ? c.getDistrict().getName() : null,
                    c.getLanguages(), c.getImageUrls(),
                    c.getKnots().stream().map(KnotResponse::from).toList(),
                    c.getAvailableDays(), c.getAvailableTimeSlots(),
                    c.getMeetingPoint(), c.getMaxParticipants(), c.getPricePerHour(), c.isVisible()
            );
        }
    }
}
