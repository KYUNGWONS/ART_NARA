package com.example.artnara.global.auth.controller;

import com.example.artnara.global.auth.dto.AuthDto;
import com.example.artnara.global.auth.service.AuthService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Auth", description = "인증 API")
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "OAuth 로그인",
            description = "클라이언트에서 발급받은 OAuth 토큰(KAKAO: access token, GOOGLE: idToken)을 검증하고 " +
                    "앱 JWT(access/refresh)를 발급합니다. 신규 유저는 profileCompleted=false로 응답되며, " +
                    "발급된 토큰으로 프로필 설정(POST /api/users)을 진행합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "로그인 성공"),
            @ApiResponse(responseCode = "400", description = "지원하지 않는 제공자 / 이메일 정보 없음"),
            @ApiResponse(responseCode = "401", description = "OAuth 토큰 검증 실패")
    })
    public BaseResponse<AuthDto.LoginResponse> login(@RequestBody AuthDto.LoginRequest request) {
        return BaseResponse.success(null, authService.login(request));
    }

    @PostMapping("/refresh")
    @Operation(summary = "토큰 재발급",
            description = "refresh token 으로 새 access/refresh 쌍을 발급합니다. 자동 로그인과 " +
                    "access token(1시간) 만료 갱신에 사용합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "재발급 성공"),
            @ApiResponse(responseCode = "401", description = "refresh token 이 유효하지 않음")
    })
    public BaseResponse<AuthDto.RefreshResponse> refresh(@RequestBody AuthDto.RefreshRequest request) {
        return BaseResponse.success(null, authService.refresh(request));
    }
}
