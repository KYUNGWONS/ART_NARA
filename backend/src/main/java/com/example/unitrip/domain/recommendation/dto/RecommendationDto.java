package com.example.unitrip.domain.recommendation.dto;

import com.example.unitrip.domain.content.entity.Theme;
import com.example.unitrip.domain.recommendation.entity.RecommendedActivity;
import com.example.unitrip.domain.recommendation.entity.RecommendedPlace;
import com.example.unitrip.domain.user.entity.Sido;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

public class RecommendationDto {

    @Schema(name = "RecommendedPlaceResponse", description = "여행스타일 매칭 기반 추천 장소. 장소 상세 화면(위치/소요시간/소개/콘텐츠 아이디어)을 채운다.")
    public record PlaceResponse(
            @Schema(description = "추천 장소 ID") Long id,
            @Schema(description = "장소명", example = "전주한옥마을") String name,
            @Schema(description = "이미지 URL") String imageUrl,
            @Schema(description = "시/도") Sido sido,
            @Schema(description = "테마") Theme theme,
            @Schema(description = "위치 상세(구/동 등)", example = "전주 완산구 교동 한옥마을") String location,
            @Schema(description = "예상 소요시간(분)", example = "180") Integer estimatedDurationMinutes,
            @Schema(description = "장소 소개") String description,
            @Schema(description = "\"콘텐츠 아이디어\" 태그 목록", example = "[\"포토 에세이\", \"숏폼 브이로그\"]") List<String> contentIdeas,
            @Schema(description = "사용자 travelStyle과의 매칭 점수(0~100)") int matchScore
    ) {
        public static PlaceResponse of(RecommendedPlace p, int matchScore) {
            return new PlaceResponse(p.getId(), p.getName(), p.getImageUrl(), p.getSido(), p.getTheme(),
                    p.getLocation(), p.getEstimatedDurationMinutes(), p.getDescription(), p.getContentIdeas(),
                    matchScore);
        }
    }

    @Schema(name = "RecommendedActivityResponse",
            description = "선택한 장소 상세 화면의 \"이런 걸 해보세요\" 목록 항목(여행스타일 매칭 기반).")
    public record ActivityResponse(
            @Schema(description = "추천 활동 ID") Long id,
            @Schema(description = "활동명", example = "한복 대여 인증샷") String name,
            @Schema(description = "이미지 URL") String imageUrl,
            @Schema(description = "사용자 travelStyle과의 매칭 점수(0~100)") int matchScore
    ) {
        public static ActivityResponse of(RecommendedActivity a, int matchScore) {
            return new ActivityResponse(a.getId(), a.getName(), a.getImageUrl(), matchScore);
        }
    }
}
