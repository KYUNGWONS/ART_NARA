package com.example.artnara.global.auth.dto;

import com.example.artnara.domain.user.entity.UserType;
import com.example.artnara.global.auth.oauth.OAuthProvider;
import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

public class AuthDto {

    @Schema(description = "OAuth 로그인 요청")
    public record LoginRequest(
            @Schema(description = "OAuth 제공자", example = "KAKAO")
            OAuthProvider provider,

            @Schema(description = "OAuth 토큰 (KAKAO/NAVER: access token)",
                    example = "ya29.a0Af...")
            String accessToken
    ) {}

    @Schema(description = "네이버 WebView 로그인 콜백에서 받은 인가 코드")
    public record NaverCodeRequest(String code, String state) {}

    @Schema(description = "로그아웃 요청. access token 이 만료됐을 때 신원을 찾는 수단으로 쓴다.")
    public record LogoutRequest(String refreshToken) {}

    @Schema(description = "토큰 재발급 요청")
    public record RefreshRequest(
            @Schema(description = "로그인 시 발급받은 refresh token")
            String refreshToken
    ) {}

    @Schema(description = "토큰 재발급 응답")
    public record RefreshResponse(
            @Schema(description = "새 access token")
            String accessToken,

            @Schema(description = "새 refresh token (회전 발급)")
            String refreshToken,

            @Schema(description = "사용자 유형", example = "KOREAN_STUDENT")
            UserType userType,

            @Schema(description = "프로필 설정 완료 여부", example = "true")
            boolean profileCompleted
    ) {}

    @Schema(description = "OAuth 로그인 응답")
    public record LoginResponse(
            @Schema(description = "앱 JWT access token")
            String accessToken,

            @Schema(description = "앱 refresh token")
            String refreshToken,

            @Schema(description = "신규 가입 여부(프로필 미설정)", example = "true")
            @JsonProperty("isNewUser")
            boolean isNewUser,

            @Schema(description = "사용자 유형(프로필 미설정 시 null)", example = "KOREAN_STUDENT")
            UserType userType,

            @Schema(description = "프로필 설정 완료 여부", example = "false")
            boolean profileCompleted
    ) {}
}
