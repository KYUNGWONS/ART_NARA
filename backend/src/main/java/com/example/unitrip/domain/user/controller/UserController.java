package com.example.unitrip.domain.user.controller;

import com.example.unitrip.domain.user.dto.UserDto;
import com.example.unitrip.domain.user.service.UserService;
import com.example.unitrip.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;

@Tag(name = "User", description = "사용자 API")
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping
    @Operation(summary = "회원가입(프로필 설정)",
            description = "로그인 시 발급된 JWT로 인증된 본인의 프로필을 설정합니다. 프로필 설정 화면에서 입력한 정보" +
                    "(대표명, 나이, 프로필 사진, 닉네임, 거주지역, 구사 언어, 관심사, 여행 스타일, 자기소개, " +
                    "사용자 유형)로 프로필을 채우고 회원가입을 완료 처리합니다. 대상 유저는 body가 아닌 JWT 신원에서 결정됩니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "프로필 설정 성공"),
            @ApiResponse(responseCode = "401", description = "인증 필요"),
            @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음")
    })
    public BaseResponse<UserDto.Response> create(@RequestBody UserDto.CreateRequest req,
                                                 Principal principal) {
        return BaseResponse.success("회원가입", userService.completeProfile(userId(principal), req));
    }

    @GetMapping("/me")
    @Operation(summary = "내 프로필 조회",
            description = "로그인한 본인의 프로필을 조회합니다. 대상은 JWT 신원에서 결정됩니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "401", description = "인증 필요"),
            @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음")
    })
    public BaseResponse<UserDto.Response> getMe(Principal principal) {
        return BaseResponse.success("내 프로필 조회", userService.get(userId(principal)));
    }

    @PatchMapping("/me")
    @Operation(summary = "내 프로필 수정",
            description = "로그인한 본인의 프로필을 부분 수정합니다. null인 필드는 변경되지 않습니다. 대상은 JWT 신원에서 결정됩니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "수정 성공"),
            @ApiResponse(responseCode = "401", description = "인증 필요"),
            @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음")
    })
    public BaseResponse<UserDto.Response> updateMe(@RequestBody UserDto.UpdateRequest req,
                                                   Principal principal) {
        return BaseResponse.success("내 프로필 수정", userService.update(userId(principal), req));
    }

    @PatchMapping("/me/matching")
    @Operation(summary = "매칭 설정 변경",
            description = "로그인한 본인의 매칭 활성화/비활성화를 설정합니다. 대상은 JWT 신원에서 결정됩니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "매칭 설정 변경 성공"),
            @ApiResponse(responseCode = "401", description = "인증 필요"),
            @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음")
    })
    public BaseResponse<Void> setMatching(
            @Parameter(description = "매칭 활성화 여부", example = "true") @RequestParam boolean enabled,
            Principal principal) {
        userService.setMatchingEnabled(userId(principal), enabled);
        return BaseResponse.success("매칭 설정 변경", null);
    }

    @DeleteMapping("/me")
    @Operation(summary = "회원 탈퇴",
            description = "로그인한 본인을 삭제합니다. 대상은 JWT 신원에서 결정됩니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "삭제 성공"),
            @ApiResponse(responseCode = "401", description = "인증 필요"),
            @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음")
    })
    public BaseResponse<Void> deleteMe(Principal principal) {
        userService.delete(userId(principal));
        return BaseResponse.success("회원 탈퇴", null);
    }

    private Long userId(Principal principal) {
        return Long.parseLong(principal.getName());
    }
}
