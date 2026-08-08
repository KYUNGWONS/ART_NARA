package com.example.artnara.global.auth.controller;

import com.example.artnara.global.auth.CurrentUser;
import com.example.artnara.global.auth.dto.AuthDto;
import com.example.artnara.global.auth.service.AuthService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

@Tag(name = "Auth", description = "인증 API")
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final com.example.artnara.global.auth.oauth.NaverOAuthClient naverOAuthClient;
    private final CurrentUser currentUser;

    @SecurityRequirements
    @PostMapping("/login")
    @Operation(summary = "OAuth 로그인",
            description = "클라이언트에서 발급받은 OAuth 토큰(KAKAO/NAVER: access token)을 검증하고 " +
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

    @SecurityRequirements
    @GetMapping("/naver/config")
    @Operation(summary = "네이버 로그인 설정",
            description = "앱이 WebView 로 열 네이버 동의 화면 주소를 만들어 돌려줍니다. "
                    + "클라이언트 시크릿은 서버에만 있으므로 내려보내지 않습니다.")
    public BaseResponse<NaverConfig> naverConfig(@RequestParam String state) {
        return BaseResponse.success("네이버 로그인 설정", new NaverConfig(
                naverOAuthClient.isConfigured(),
                naverOAuthClient.isConfigured() ? naverOAuthClient.authorizeUrl(state) : null,
                naverOAuthClient.redirectUri()));
    }

    public record NaverConfig(boolean enabled, String authorizeUrl, String redirectUri) {}

    @SecurityRequirements
    @PostMapping("/naver/code")
    @Operation(summary = "네이버 인가 코드 로그인",
            description = "앱 WebView 가 콜백에서 가로챈 인가 코드를 넘기면, 서버가 액세스 토큰으로 교환하고 "
                    + "네이버 프로필로 신원을 확인한 뒤 앱 JWT 를 발급합니다.")
    public BaseResponse<AuthDto.LoginResponse> naverCodeLogin(
            @RequestBody AuthDto.NaverCodeRequest request) {
        return BaseResponse.success(null, authService.loginWithNaverCode(request));
    }

    @SecurityRequirements
    @PostMapping("/logout")
    @Operation(summary = "로그아웃",
            description = "이 계정으로 지금까지 발급된 토큰을 모두 무효로 만듭니다. "
                    + "기기를 잃어버렸을 때도 남아 있는 refresh token 이 더는 통하지 않습니다.")
    public BaseResponse<Void> logout(@RequestBody(required = false) AuthDto.LogoutRequest request,
                                     Principal principal) {
        // access token 이 만료된 채 로그아웃하는 경우가 있어 refresh token 으로도 신원을 찾는다.
        authService.logout(principal != null ? currentUser.idOf(principal) : null,
                request == null ? null : request.refreshToken());
        return BaseResponse.success("로그아웃", null);
    }

    @SecurityRequirements
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
