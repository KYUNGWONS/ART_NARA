package com.example.artnara.domain.magazine.controller;

import com.example.artnara.domain.magazine.dto.MagazineDto;
import com.example.artnara.domain.magazine.entity.MagazineCategory;
import com.example.artnara.domain.magazine.service.MagazineService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Magazine", description = "매거진 API")
@RestController
@RequestMapping("/api/magazines")
@RequiredArgsConstructor
public class MagazineController {

    private final MagazineService magazineService;

    @PostMapping
    @Operation(summary = "매거진 생성", description = "새로운 매거진을 생성합니다.")
    @ApiResponse(responseCode = "200", description = "매거진 생성 성공")
    public BaseResponse<MagazineDto.Response> create(@RequestBody MagazineDto.CreateRequest req) {
        return BaseResponse.success("매거진 생성", magazineService.create(req));
    }

    @GetMapping
    @Operation(summary = "매거진 목록 조회", description = "카테고리별 필터 또는 전체 매거진 목록을 조회합니다.")
    @ApiResponse(responseCode = "200", description = "매거진 목록 조회 성공")
    public BaseResponse<List<MagazineDto.Response>> list(
            @Parameter(description = "카테고리 필터 (BEST_MATE_STORY, KNOT_GUIDE, QNA_TIPS)")
            @RequestParam(required = false) MagazineCategory category) {
        return BaseResponse.success("매거진 목록", magazineService.list(category));
    }

    @GetMapping("/{id}")
    @Operation(summary = "매거진 조회", description = "ID로 매거진 상세 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "매거진 조회 성공"),
            @ApiResponse(responseCode = "404", description = "매거진을 찾을 수 없음")
    })
    public BaseResponse<MagazineDto.Response> get(
            @Parameter(description = "매거진 ID", example = "1") @PathVariable Long id) {
        return BaseResponse.success("매거진 조회", magazineService.get(id));
    }

    @PatchMapping("/{id}")
    @Operation(summary = "매거진 수정", description = "매거진 정보를 부분 수정합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "매거진 수정 성공"),
            @ApiResponse(responseCode = "404", description = "매거진을 찾을 수 없음")
    })
    public BaseResponse<MagazineDto.Response> update(
            @Parameter(description = "매거진 ID", example = "1") @PathVariable Long id,
            @RequestBody MagazineDto.UpdateRequest req) {
        return BaseResponse.success("매거진 수정", magazineService.update(id, req));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "매거진 삭제", description = "매거진을 삭제합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "매거진 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "매거진을 찾을 수 없음")
    })
    public BaseResponse<Void> delete(
            @Parameter(description = "매거진 ID", example = "1") @PathVariable Long id) {
        magazineService.delete(id);
        return BaseResponse.success("매거진 삭제", null);
    }
}
