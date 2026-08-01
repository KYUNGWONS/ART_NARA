package com.example.artnara.global.config;

import org.springframework.context.annotation.Configuration;

import java.util.Arrays;
import java.util.stream.Stream;

@Configuration
public class SecurityConstant {

    public static final String[] PUBLIC_AUTH_URLS = {
            "/auth/**"
    };

    public static final String[] PUBLIC_FEED_URLS = {
            "/api/feed/**"
    };

    public static final String[] PUBLIC_ARTWORK_URLS = {
            "/api/artworks/**",
            "/api/sales/**",
            "/api/commissions/**",
            "/api/certificates/**",
            "/api/orders/**",
            "/api/images/**",
            "/images/**",
            "/api/artists/**"
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

    public static final String[] ADMIN_URLS = {
    };

    public static final String[] PUBLIC_URLS =
            Stream.of(PUBLIC_AUTH_URLS, PUBLIC_FEED_URLS,
                            PUBLIC_ARTWORK_URLS, SWAGGER_URLS, WEBSOCKET_URLS, H2_URLS, ERROR_URLS)
                    .flatMap(Arrays::stream)
                    .toArray(String[]::new);
}
