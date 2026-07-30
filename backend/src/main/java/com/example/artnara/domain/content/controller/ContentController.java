package com.example.artnara.domain.content.controller;

import com.example.artnara.domain.content.dto.ContentDto;
import com.example.artnara.domain.content.entity.Theme;
import com.example.artnara.domain.content.service.ContentService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@Tag(name = "Content", description = "콘텐츠(활동) API")
@RestController
@RequestMapping("/api/contents")
@RequiredArgsConstructor
public class ContentController {

    private final ContentService contentService;

    @PostMapping
    @Operation(summary = "콘텐츠 등록",
            description = "새로운 콘텐츠(활동)를 등록합니다. 작성자는 body가 아닌 로그인 JWT 신원에서 결정됩니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "콘텐츠 등록 성공"),
            @ApiResponse(responseCode = "401", description = "인증 필요"),
            @ApiResponse(responseCode = "404", description = "작성자를 찾을 수 없음")
    })
    public BaseResponse<ContentDto.Response> create(@RequestBody ContentDto.CreateRequest req,
                                                    Principal principal) {
        Long authorId = Long.parseLong(principal.getName());
        return BaseResponse.success("콘텐츠 등록", contentService.create(authorId, req));
    }

    @GetMapping
    @Operation(summary = "콘텐츠 목록 조회", description = "테마별, 작성자별, 구(district)별 또는 전체 공개 콘텐츠를 조회합니다. 필터가 없으면 공개 콘텐츠 전체를 반환합니다.")
    @ApiResponse(responseCode = "200", description = "콘텐츠 목록 조회 성공")
    public BaseResponse<List<ContentDto.Response>> list(
            @Parameter(description = "테마 필터 (PLACE, PERFORMANCE, ACTIVITY)") @RequestParam(required = false) Theme theme,
            @Parameter(description = "작성자 ID 필터") @RequestParam(required = false) Long authorId,
            @Parameter(description = "구(district) ID 필터") @RequestParam(required = false) Long districtId) {
        if (theme != null) return BaseResponse.success("테마별 조회", contentService.listByTheme(theme));
        if (authorId != null) return BaseResponse.success("작성자별 조회", contentService.listByAuthor(authorId));
        if (districtId != null) return BaseResponse.success("구별 조회", contentService.listByDistrict(districtId));
        return BaseResponse.success("공개 콘텐츠 조회", contentService.listVisible());
    }

    @GetMapping("/{id}")
    @Operation(summary = "콘텐츠 조회", description = "ID로 콘텐츠 상세 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "콘텐츠 조회 성공"),
            @ApiResponse(responseCode = "404", description = "콘텐츠를 찾을 수 없음")
    })
    public BaseResponse<ContentDto.Response> get(
            @Parameter(description = "콘텐츠 ID", example = "1") @PathVariable Long id) {
        return BaseResponse.success("콘텐츠 조회", contentService.get(id));
    }

    @PatchMapping("/{id}")
    @Operation(summary = "콘텐츠 수정", description = "콘텐츠 정보를 부분 수정합니다. null인 필드는 변경되지 않습니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "콘텐츠 수정 성공"),
            @ApiResponse(responseCode = "404", description = "콘텐츠를 찾을 수 없음")
    })
    public BaseResponse<ContentDto.Response> update(
            @Parameter(description = "콘텐츠 ID", example = "1") @PathVariable Long id,
            @RequestBody ContentDto.UpdateRequest req) {
        return BaseResponse.success("콘텐츠 수정", contentService.update(id, req));
    }

    @PatchMapping("/{id}/visibility")
    @Operation(summary = "콘텐츠 공개 설정 변경", description = "콘텐츠의 공개/비공개 상태를 변경합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "공개 설정 변경 성공"),
            @ApiResponse(responseCode = "404", description = "콘텐츠를 찾을 수 없음")
    })
    public BaseResponse<Void> setVisible(
            @Parameter(description = "콘텐츠 ID", example = "1") @PathVariable Long id,
            @Parameter(description = "공개 여부", example = "true") @RequestParam boolean visible) {
        contentService.setVisible(id, visible);
        return BaseResponse.success("공개 설정 변경", null);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "콘텐츠 삭제", description = "콘텐츠를 삭제합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "콘텐츠 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "콘텐츠를 찾을 수 없음")
    })
    public BaseResponse<Void> delete(
            @Parameter(description = "콘텐츠 ID", example = "1") @PathVariable Long id) {
        contentService.delete(id);
        return BaseResponse.success("콘텐츠 삭제", null);
    }
}
