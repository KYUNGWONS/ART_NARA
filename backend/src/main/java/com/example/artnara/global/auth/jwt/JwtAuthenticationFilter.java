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
import java.util.List;

public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtProvider jwtProvider;
    // 로컬 테스트 전용: 비어있지 않으면 토큰 검증 없이 이 userId로 항상 인증 처리한다.
    // AUTH_DEV_BYPASS_USER_ID 환경변수로만 켜지며 기본값은 빈 문자열(=평소처럼 정상 검증).
    private final String devBypassUserId;

    public JwtAuthenticationFilter(JwtProvider jwtProvider, String devBypassUserId) {
        this.jwtProvider = jwtProvider;
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
                Authentication auth = jwtProvider.getAuthentication(token);
                SecurityContextHolder.getContext().setAuthentication(auth);
            }
            // 만료된 토큰: 추후 RefreshToken 로직 추가 예정
        }

        filterChain.doFilter(request, response);
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
