package com.example.artnara.global.auth.jwt;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.List;

public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtProvider jwtProvider;
    private final AppTokenGuard appTokenGuard;
    // 로컬 테스트 전용: 비어있지 않으면 토큰 검증 없이 이 userId로 항상 인증 처리한다.
    // AUTH_DEV_BYPASS_USER_ID 환경변수로만 켜지며 기본값은 빈 문자열(=평소처럼 정상 검증).
    private final String devBypassUserId;

    public JwtAuthenticationFilter(JwtProvider jwtProvider, AppTokenGuard appTokenGuard,
                                  String devBypassUserId) {
        this.jwtProvider = jwtProvider;
        this.appTokenGuard = appTokenGuard;
        this.devBypassUserId = devBypassUserId;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        if (devBypassUserId != null && !devBypassUserId.isBlank()) {
            SecurityContextHolder.getContext().setAuthentication(devBypassAuthentication());
            filterChain.doFilter(request, response);
            return;
        }

        String token = resolveToken(request);

        if (token != null) {
            if (!jwtProvider.validateSignature(token)) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "유효하지 않은 토큰입니다.");
                return;
            }

            if (!jwtProvider.isExpired(token)) {
                // 로그아웃·차단된 계정의 토큰은 만료를 기다리지 않고 여기서 끊는다.
                if (!accepted(token)) {
                    response.sendError(HttpServletResponse.SC_UNAUTHORIZED,
                            "다시 로그인해주세요.");
                    return;
                }
                Authentication auth = jwtProvider.getAuthentication(token);
                SecurityContextHolder.getContext().setAuthentication(auth);
            }
            // 만료된 토큰은 인증 없이 통과시켜 뒤쪽 인가 규칙이 401 을 내게 둔다.
        }

        filterChain.doFilter(request, response);
    }

    /**
     * 앱 토큰(ROLE_USER)만 회원 상태를 확인한다 — 관리자 토큰은 users 테이블과 무관하다.
     */
    private boolean accepted(String token) {
        var claims = jwtProvider.getClaims(token);
        if (!"USER".equals(claims.get("roles", String.class))) return true;
        Date issuedAt = claims.getIssuedAt();
        return appTokenGuard.accepts(claims.getSubject(), issuedAt == null ? null
                : LocalDateTime.ofInstant(issuedAt.toInstant(), ZoneId.systemDefault()));
    }

    private String resolveToken(HttpServletRequest request) {
        String bearer = request.getHeader("Authorization");
        if (bearer != null && bearer.startsWith("Bearer ")) {
            return bearer.substring(7);
        }
        return null;
    }

    private Authentication devBypassAuthentication() {
        List<SimpleGrantedAuthority> authorities = List.of(new SimpleGrantedAuthority("ROLE_USER"));
        return new UsernamePasswordAuthenticationToken(
                new User(devBypassUserId, "", authorities), devBypassUserId, authorities);
    }
}
