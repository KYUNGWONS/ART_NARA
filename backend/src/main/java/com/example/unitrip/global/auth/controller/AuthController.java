package com.example.unitrip.global.auth.controller;

import com.example.unitrip.global.auth.dto.AuthDto;
import com.example.unitrip.global.auth.service.AuthService;
import com.example.unitrip.global.common.BaseResponse;
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
}
