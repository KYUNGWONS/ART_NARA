package com.example.artnara.global.auth.jwt;

import com.example.artnara.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 서명·만료가 멀쩡한 앱 토큰이라도 지금도 유효한지 되묻는다.
 *
 * 예전에는 이 판단을 {@code /auth/refresh} 에서만 했다. 그래서 로그아웃하거나 관리자가 차단해도
 * **이미 발급된 액세스 토큰은 만료될 때까지(최대 1시간) 그대로 통했다** — 잃어버린 기기가
 * 한 시간 동안 결제·입찰을 계속할 수 있다는 뜻이다(실측으로 확인했다).
 *
 * 토큰이 실린 요청에서만 회원 한 건을 기본키로 읽는다. 공개 조회는 토큰이 없어 조회도 없다.
 */
@Component
@RequiredArgsConstructor
public class AppTokenGuard {

    private final UserRepository userRepository;

    /**
     * @param subject  토큰 sub (회원 id)
     * @param issuedAt 토큰 발급 시각 (iat)
     * @return 이 토큰을 계속 받아줄지
     */
    public boolean accepts(String subject, LocalDateTime issuedAt) {
        Long userId;
        try {
            userId = Long.valueOf(subject);
        } catch (NumberFormatException e) {
            return false;
        }
        return userRepository.findById(userId)
                .filter(user -> !user.isBlocked())
                .filter(user -> user.acceptsTokenIssuedAt(issuedAt))
                .map(user -> true)
                .orElse(false);
    }

}
