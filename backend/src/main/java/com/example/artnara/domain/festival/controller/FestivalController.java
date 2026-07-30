package com.example.artnara.domain.festival.controller;

import com.example.artnara.domain.festival.dto.FestivalDto;
import com.example.artnara.domain.festival.service.FestivalService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Festival", description = "페스티벌 API")
@RestController
@RequestMapping("/api/festivals")
@RequiredArgsConstructor
public class FestivalController {

    private final FestivalService festivalService;

    @PostMapping
    @Operation(summary = "페스티벌 생성", description = "새로운 페스티벌을 생성합니다.")
    @ApiResponse(responseCode = "200", description = "페스티벌 생성 성공")
    public BaseResponse<FestivalDto.Response> create(@RequestBody FestivalDto.CreateRequest req) {
        return BaseResponse.success("페스티벌 생성", festivalService.create(req));
    }

    @GetMapping
    @Operation(summary = "페스티벌 목록 조회", description = "지역별 필터 또는 전체 페스티벌 목록을 조회합니다.")
    @ApiResponse(responseCode = "200", description = "페스티벌 목록 조회 성공")
    public BaseResponse<List<FestivalDto.Response>> list(
            @Parameter(description = "지역 필터", example = "서울") @RequestParam(required = false) String region) {
        return BaseResponse.success("페스티벌 목록", festivalService.list(region));
    }

    @GetMapping("/{id}")
    @Operation(summary = "페스티벌 조회", description = "ID로 페스티벌 상세 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "페스티벌 조회 성공"),
            @ApiResponse(responseCode = "404", description = "페스티벌을 찾을 수 없음")
    })
    public BaseResponse<FestivalDto.Response> get(
            @Parameter(description = "페스티벌 ID", example = "1") @PathVariable Long id) {
        return BaseResponse.success("페스티벌 조회", festivalService.get(id));
    }

    @PatchMapping("/{id}")
    @Operation(summary = "페스티벌 수정", description = "페스티벌 정보를 부분 수정합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "페스티벌 수정 성공"),
            @ApiResponse(responseCode = "404", description = "페스티벌을 찾을 수 없음")
    })
    public BaseResponse<FestivalDto.Response> update(
            @Parameter(description = "페스티벌 ID", example = "1") @PathVariable Long id,
            @RequestBody FestivalDto.UpdateRequest req) {
        return BaseResponse.success("페스티벌 수정", festivalService.update(id, req));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "페스티벌 삭제", description = "페스티벌을 삭제합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "페스티벌 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "페스티벌을 찾을 수 없음")
    })
    public BaseResponse<Void> delete(
            @Parameter(description = "페스티벌 ID", example = "1") @PathVariable Long id) {
        festivalService.delete(id);
        return BaseResponse.success("페스티벌 삭제", null);
    }
}
