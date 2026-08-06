package com.example.artnara.global.config;

import org.springframework.context.annotation.Configuration;

import java.util.Arrays;
import java.util.stream.Stream;

/**
 * 보안 경로 정의.
 *
 * 원칙: **조회(GET)는 열고, 상태를 바꾸는 요청(POST/PATCH/DELETE)은 로그인 필요.**
 * 예전에는 도메인 경로 전체(`/api/artworks/**` 등)를 permitAll 로 열어 두어 비로그인 상태에서도
 * 입찰·결제·판매 등록이 가능했다. 조회만 열도록 분리한다.
 */
@Configuration
public class SecurityConstant {

    /** 로그인/토큰 재발급 — 메서드 무관 공개 */
    public static final String[] PUBLIC_AUTH_URLS = {
            "/auth/**",
            // 관리자 로그인은 토큰 없이 호출해야 하므로 공개(그 외 관리자 경로는 ADMIN_URLS)
            "/api/admin/login"
    };

    /** 관리자 전용 — ROLE_ADMIN 토큰이 있어야 한다. */
    public static final String[] ADMIN_URLS = {
            "/api/admin/**"
    };

    /** 조회(GET)만 공개하는 경로 */
    public static final String[] PUBLIC_READ_URLS = {
            "/api/feed/**",
            "/api/artworks/**",
            "/api/artists/**",
            // "/api/sales/**" 도 공개하지 않는다 — '내 판매 작품' 목록이라 로그인 스코프가 필요하다.
            // (마켓에 노출되는 작품은 /api/artworks 로 따로 공개된다.)
            "/api/commissions/**",
            "/api/payments/config",
            // "/api/certificates/**" 는 공개하지 않는다 — 목록은 내 소유권이라 로그인 스코프가 필요하고,
            // 누구나 확인해야 하는 QR 검증만 PUBLIC_ANY_METHOD_URLS 로 따로 연다.
            "/images/**",
            "/artworks/**"
    };

    /**
     * 메서드와 무관하게 공개해야 하는 예외.
     * QR 소유권 인증은 "누구나 소유권 이력을 확인할 수 있어야" 의미가 있어 비로그인도 허용한다.
     */
    public static final String[] PUBLIC_ANY_METHOD_URLS = {
            "/api/certificates/scan"
    };

    public static final String[] SWAGGER_URLS = {
            "/v3/api-docs/**",
            "/swagger-ui/**",
            "/swagger-ui.html"
    };

    // WebSocket 엔드포인트 (SockJS fallback 포함)
    public static final String[] WEBSOCKET_URLS = {
            "/ws/**"
    };

    // H2 콘솔 (개발용)
    public static final String[] H2_URLS = {
            "/h2-console/**"
    };

    // 컨트롤러에서 예외가 나면 서블릿이 /error 로 ERROR 디스패치를 한다. 이때 JwtAuthenticationFilter는
    // (OncePerRequestFilter 기본값상) 건너뛰어져 SecurityContext가 비어 있으므로, /error 가 인증 대상이면
    // 원래 에러(400/500)가 전부 401 빈 응답으로 둔갑한다. 실제 상태코드가 그대로 나가도록 열어둔다.
    public static final String[] ERROR_URLS = {
            "/error"
    };

    /** 메서드 무관 공개 경로 (인프라 + 예외) */
    public static final String[] PUBLIC_URLS =
            Stream.of(PUBLIC_AUTH_URLS, PUBLIC_ANY_METHOD_URLS,
                            SWAGGER_URLS, WEBSOCKET_URLS, H2_URLS, ERROR_URLS)
                    .flatMap(Arrays::stream)
                    .toArray(String[]::new);
}
