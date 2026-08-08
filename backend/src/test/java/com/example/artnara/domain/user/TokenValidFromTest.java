package com.example.artnara.domain.user;

import com.example.artnara.domain.user.entity.User;
import com.example.artnara.global.auth.oauth.OAuthProvider;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 무상태 JWT 라 서버가 토큰을 회수할 수 없어, 회원마다 "이 시각 이후 발급분만 유효" 기준선을 둔다.
 * 로그아웃한 기기의 토큰 재사용과, 재사용된 id 로 남의 토큰이 붙는 것을 함께 막는다.
 */
class TokenValidFromTest {

    private User newUser() {
        return User.ofOAuth(OAuthProvider.KAKAO, "kakao-1", "a@test.com", "테스터", null);
    }

    @Test
    @DisplayName("가입 이전에 발급된 토큰은 거부한다 — 같은 id 를 쓰던 예전 회원의 토큰")
    void rejectsTokenIssuedBeforeSignup() {
        User user = newUser();

        assertThat(user.acceptsTokenIssuedAt(LocalDateTime.now().minusDays(1))).isFalse();
        assertThat(user.acceptsTokenIssuedAt(LocalDateTime.now().plusSeconds(1))).isTrue();
    }

    @Test
    @DisplayName("로그아웃하면 같은 초에 발급된 토큰까지 막힌다")
    void logoutInvalidatesIssuedTokens() {
        User user = newUser();
        // JWT iat 는 초 단위라, 로그아웃과 같은 초에 발급된 토큰이 실제로 살아남았다.
        LocalDateTime sameSecond = LocalDateTime.now().withNano(0);
        assertThat(user.acceptsTokenIssuedAt(sameSecond)).isTrue();

        user.invalidateIssuedTokens();

        assertThat(user.acceptsTokenIssuedAt(sameSecond)).isFalse();
        // 로그아웃 다음 초부터 받은 토큰(재로그인)은 통과해야 한다
        assertThat(user.acceptsTokenIssuedAt(sameSecond.plusSeconds(2))).isTrue();
    }

    @Test
    @DisplayName("기준선이 없는 구회원은 그대로 통과시킨다")
    void legacyUserWithoutBaselinePasses() {
        User user = newUser();
        ReflectionTestUtils.setField(user, "tokenValidFrom", null);

        assertThat(user.acceptsTokenIssuedAt(LocalDateTime.now().minusYears(1))).isTrue();
    }

    @Test
    @DisplayName("발급 시각을 모르는 토큰(iat 없음)은 기준선 검사를 건너뛴다")
    void tokenWithoutIssuedAtPasses() {
        assertThat(newUser().acceptsTokenIssuedAt(null)).isTrue();
    }
}
