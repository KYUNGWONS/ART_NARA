package com.example.unitrip.global.auth.oauth;

/**
 * 제공자별 OAuth 토큰 검증 전략.
 * 클라이언트에서 발급받은 토큰(카카오 access token / 구글 idToken)을 제공자 서버로 검증하고
 * 사용자 정보를 반환한다.
 */
public interface OAuthTokenVerifier {

    OAuthProvider getProvider();

    OAuthUserInfo verify(String token);
}
