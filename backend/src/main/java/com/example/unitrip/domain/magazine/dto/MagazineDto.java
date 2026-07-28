package com.example.unitrip.domain.magazine.dto;

import com.example.unitrip.domain.magazine.entity.Magazine;
import com.example.unitrip.domain.magazine.entity.MagazineCategory;
import io.swagger.v3.oas.annotations.media.Schema;

public class MagazineDto {

    @Schema(name = "MagazineCreateRequest")
    public record CreateRequest(String title, String summary, String content,
                                String coverImageUrl, MagazineCategory category) {}

    @Schema(name = "MagazineUpdateRequest")
    public record UpdateRequest(String title, String summary, String content,
                                String coverImageUrl, MagazineCategory category) {}

    @Schema(name = "MagazineResponse")
    public record Response(Long id, String title, String summary, String content,
                           String coverImageUrl, MagazineCategory category) {
        public static Response from(Magazine m) {
            return new Response(m.getId(), m.getTitle(), m.getSummary(),
                    m.getContent(), m.getCoverImageUrl(), m.getCategory());
        }
    }
}
