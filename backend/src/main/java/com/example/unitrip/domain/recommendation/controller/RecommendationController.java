package com.example.unitrip.domain.recommendation.controller;

import com.example.unitrip.domain.content.entity.Theme;
import com.example.unitrip.domain.recommendation.dto.RecommendationDto;
import com.example.unitrip.domain.recommendation.service.RecommendationService;
import com.example.unitrip.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@Tag(name = "Recommendation", description = "거주지역·여행스타일 기반 콘텐츠 추천 API")
@RestController
@RequestMapping("/api/recommendations")
@RequiredArgsConstructor
public class RecommendationController {

    private final RecommendationService recommendationService;

    @GetMapping("/places")
    @Operation(summary = "추천 장소 조회",
            description = "로그인한 사용자의 거주지역(Sido)과 여행스타일을 기반으로 추천 장소를 매칭 점수 내림차순으로 반환합니다. " +
                    "거주지역이 설정되지 않았으면 빈 목록을 반환합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "추천 장소 조회 성공"),
            @ApiResponse(responseCode = "401", description = "인증 필요"),
            @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음")
    })
    public BaseResponse<List<RecommendationDto.PlaceResponse>> places(
            @Parameter(description = "테마 필터 (PLACE, PERFORMANCE, ACTIVITY)") @RequestParam(required = false) Theme theme,
            Principal principal) {
        Long userId = Long.parseLong(principal.getName());
        return BaseResponse.success("추천 장소 조회", recommendationService.recommendPlaces(userId, theme));
    }

    @GetMapping("/places/{placeId}/activities")
    @Operation(summary = "추천 활동 조회",
            description = "선택한 장소 상세 화면의 \"이런 걸 해보세요\" 목록. 사용자의 여행스타일을 기반으로 " +
                    "그 장소의 추천 활동을 매칭 점수 내림차순으로 반환합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "추천 활동 조회 성공"),
            @ApiResponse(responseCode = "401", description = "인증 필요"),
            @ApiResponse(responseCode = "404", description = "장소 또는 사용자를 찾을 수 없음")
    })
    public BaseResponse<List<RecommendationDto.ActivityResponse>> activities(
            @Parameter(description = "추천 장소 ID", example = "1") @PathVariable Long placeId,
            Principal principal) {
        Long userId = Long.parseLong(principal.getName());
        return BaseResponse.success("추천 활동 조회", recommendationService.recommendActivities(userId, placeId));
    }
}
