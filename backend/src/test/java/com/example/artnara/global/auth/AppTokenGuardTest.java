package com.example.artnara.global.auth;

import com.example.artnara.global.auth.oauth.OAuthProvider;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.global.auth.jwt.AppTokenGuard;
import com.example.artnara.support.IntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

@IntegrationTest
@DisplayName("요청마다 토큰이 아직 유효한지 되묻는다")
class AppTokenGuardTest {

    @Autowired
    AppTokenGuard appTokenGuard;

    @Autowired
    UserRepository userRepository;

    /** 테스트 프로필에는 회원 시드가 없으므로 검사용 회원을 직접 만든다. */
    private User seedUser() {
        return userRepository.save(User.ofOAuth(
                OAuthProvider.KAKAO, "token-guard-test", "guard@test.com", "토큰가드", null));
    }

    @Test
    @DisplayName("멀쩡한 회원의 토큰은 통과한다")
    void acceptsLiveUser() {
        User user = seedUser();

        assertThat(appTokenGuard.accepts(String.valueOf(user.getId()), LocalDateTime.now()))
                .isTrue();
    }

    @Test
    @DisplayName("로그아웃하면 그 전에 발급된 토큰은 만료를 기다리지 않고 끊긴다")
    void rejectsTokenIssuedBeforeLogout() {
        User user = seedUser();
        LocalDateTime issuedAt = LocalDateTime.now();

        user.invalidateIssuedTokens();
        userRepository.save(user);

        assertThat(appTokenGuard.accepts(String.valueOf(user.getId()), issuedAt)).isFalse();
    }

    @Test
    @DisplayName("차단된 회원의 토큰은 즉시 끊긴다 — 만료까지 결제·입찰을 계속할 수 없다")
    void rejectsBlockedUser() {
        User user = seedUser();
        user.block("QA 점검");
        userRepository.save(user);

        assertThat(appTokenGuard.accepts(String.valueOf(user.getId()), LocalDateTime.now()))
                .isFalse();
    }

    @Test
    @DisplayName("사라진 회원 id·숫자가 아닌 sub 는 거부한다")
    void rejectsUnknownSubject() {
        assertThat(appTokenGuard.accepts("999999", LocalDateTime.now())).isFalse();
        assertThat(appTokenGuard.accepts("not-a-number", LocalDateTime.now())).isFalse();
    }
}
