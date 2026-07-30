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

            @Schema(description = "OAuth 토큰 (KAKAO: access token, GOOGLE: idToken)",
                    example = "ya29.a0Af...")
            String accessToken
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
