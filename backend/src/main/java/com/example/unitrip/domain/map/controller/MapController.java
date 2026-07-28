package com.example.unitrip.domain.map.controller;

import com.example.unitrip.domain.map.dto.MapDto;
import com.example.unitrip.domain.map.service.MapService;
import com.example.unitrip.domain.user.entity.Sido;
import com.example.unitrip.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Map", description = "지도 시/도·구 단위 메이트 분포 및 구별 컨텐츠 둘러보기 API")
@RestController
@RequestMapping("/api/map")
@RequiredArgsConstructor
public class MapController {

    private final MapService mapService;

    @GetMapping("/sido")
    @Operation(summary = "시/도 단위 지도 조회",
            description = "전국 17개 시/도의 대표 좌표와 시/도별 매칭 활성화된 메이트 수를 반환합니다. (광역 단위 보기)")
    @ApiResponse(responseCode = "200", description = "조회 성공")
    public BaseResponse<List<MapDto.SidoResponse>> sido() {
        return BaseResponse.success("시/도 단위 지도 조회", mapService.getSidoMap());
    }

    @GetMapping("/districts")
    @Operation(summary = "구 단위 지도 조회",
            description = "선택한 시/도에 속한 구 목록을 좌표와 메이트 수와 함께 반환합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "400", description = "sido 파라미터 누락 또는 잘못된 값")
    })
    public BaseResponse<List<MapDto.DistrictResponse>> districts(
            @Parameter(description = "시/도", example = "BUSAN") @RequestParam Sido sido) {
        return BaseResponse.success("구 단위 지도 조회", mapService.getDistricts(sido));
    }

    @GetMapping("/districts/{districtId}/mates")
    @Operation(summary = "구 메이트 수 조회",
            description = "지도에서 특정 구 핀을 클릭했을 때 표시할 메이트 수를 반환합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "구를 찾을 수 없음")
    })
    public BaseResponse<MapDto.DistrictMateResponse> districtMates(
            @Parameter(description = "구 ID", example = "1") @PathVariable Long districtId) {
        return BaseResponse.success("구 메이트 수 조회", mapService.getDistrictMates(districtId));
    }

    @GetMapping("/districts/{districtId}/contents")
    @Operation(summary = "구 컨텐츠 둘러보기 (목록)",
            description = "'컨텐츠 둘러보기' 클릭 시 화면 하나를 채우는 API입니다. 그 구가 속한 시/도의 소개문·특징 태그, " +
                    "그 구의 공개 콘텐츠(매듭) 목록, 그 구에 배정된 추천 컨텐츠 카드 목록을 함께 반환합니다. " +
                    "추천 컨텐츠 카드는 목록을 가볍게 유지하기 위해 상세 정보(제안 문구·콘텐츠 아이디어·이런 걸 해보세요) 없이 " +
                    "미리보기 필드(이름/이미지/위치/평점)만 담고 있으며, 카드 클릭 시에는 " +
                    "GET /api/map/recommended-contents/{recommendedContentId}로 상세를 조회해야 합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "구를 찾을 수 없음")
    })
    public BaseResponse<MapDto.DistrictContentsResponse> districtContents(
            @Parameter(description = "구 ID", example = "1") @PathVariable Long districtId) {
        return BaseResponse.success("구 컨텐츠 둘러보기", mapService.getDistrictContents(districtId));
    }

    @GetMapping("/recommended-contents/{recommendedContentId}")
    @Operation(summary = "추천 컨텐츠 카드 상세 조회",
            description = "구 컨텐츠 둘러보기 목록에서 추천 컨텐츠 카드 하나를 클릭했을 때 조회하는 상세 API입니다. " +
                    "목록 카드에는 없는 '제안 문구 목록(suggestions)', '콘텐츠 아이디어 태그(contentIdeas)', " +
                    "그리고 세부 활동인 '이런 걸 해보세요' 목록(activities)을 반환합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "추천 컨텐츠를 찾을 수 없음")
    })
    public BaseResponse<MapDto.RecommendedContentDetailResponse> recommendedContentDetail(
            @Parameter(description = "추천 컨텐츠 ID", example = "1") @PathVariable Long recommendedContentId) {
        return BaseResponse.success("추천 컨텐츠 상세 조회", mapService.getRecommendedContentDetail(recommendedContentId));
    }
}
