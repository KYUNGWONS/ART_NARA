package com.example.artnara.global.auth.oauth;

public enum OAuthProvider {
    KAKAO,
    NAVER,
    /**
     * 구글 로그인은 2026-08-07 네이버로 대체됐다.
     * 이미 구글로 가입한 회원 데이터를 읽을 수 있어야 해서 상수만 남긴다 —
     * 검증기가 없으므로 이 값으로는 새 로그인이 되지 않는다(UNSUPPORTED_PROVIDER).
     */
    GOOGLE
}
