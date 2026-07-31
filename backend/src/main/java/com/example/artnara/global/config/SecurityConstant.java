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

    public static final String[] PUBLIC_BRAND_URLS = {
            "/api/brand/**"
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

    public static final String[] ADMIN_URLS = {
    };

    public static final String[] PUBLIC_URLS =
            Stream.of(PUBLIC_AUTH_URLS, PUBLIC_FEED_URLS, PUBLIC_BRAND_URLS,
                            PUBLIC_ARTWORK_URLS, SWAGGER_URLS, WEBSOCKET_URLS, H2_URLS)
                    .flatMap(Arrays::stream)
                    .toArray(String[]::new);
}
