package com.example.artnara.domain.verification.controller;

import com.example.artnara.domain.verification.dto.VerificationDto;
import com.example.artnara.domain.verification.service.VerificationService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Verification", description = "소속 인증 API")
@RestController
@RequestMapping("/api/verifications")
@RequiredArgsConstructor
public class VerificationController {

    private final VerificationService verificationService;

    @PostMapping
    @Operation(summary = "인증 제출", description = "소속 인증 서류를 제출합니다. 초기 상태는 PENDING입니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "인증 제출 성공"),
            @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음")
    })
    public BaseResponse<VerificationDto.Response> submit(@RequestBody VerificationDto.SubmitRequest req) {
        return BaseResponse.success("인증 제출", verificationService.submit(req));
    }

    @GetMapping
    @Operation(summary = "인증 목록 조회", description = "사용자의 인증 제출 목록을 조회합니다.")
    @ApiResponse(responseCode = "200", description = "인증 목록 조회 성공")
    public BaseResponse<List<VerificationDto.Response>> list(
            @Parameter(description = "사용자 ID", example = "1") @RequestParam Long userId) {
        return BaseResponse.success("인증 목록", verificationService.listByUser(userId));
    }

    @PostMapping("/{id}/approve")
    @Operation(summary = "인증 승인", description = "인증을 승인합니다. 상태가 APPROVED로 변경됩니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "인증 승인 성공"),
            @ApiResponse(responseCode = "404", description = "인증 정보를 찾을 수 없음")
    })
    public BaseResponse<Void> approve(
            @Parameter(description = "인증 ID", example = "1") @PathVariable Long id) {
        verificationService.approve(id);
        return BaseResponse.success("인증 승인", null);
    }

    @PostMapping("/{id}/reject")
    @Operation(summary = "인증 반려", description = "인증을 반려합니다. 상태가 REJECTED로 변경되고 반려 사유가 저장됩니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "인증 반려 성공"),
            @ApiResponse(responseCode = "404", description = "인증 정보를 찾을 수 없음")
    })
    public BaseResponse<Void> reject(
            @Parameter(description = "인증 ID", example = "1") @PathVariable Long id,
            @RequestBody VerificationDto.RejectRequest req) {
        verificationService.reject(id, req);
        return BaseResponse.success("인증 반려", null);
    }
}
