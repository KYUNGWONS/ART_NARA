package com.example.unitrip.global.auth.oauth;

/**
 * OAuth 제공자로부터 검증·조회한 사용자 식별 정보.
 */
public record OAuthUserInfo(
        OAuthProvider provider,
        String providerId,
        String email,
        String nickname,
        String profileImageUrl
) {}
