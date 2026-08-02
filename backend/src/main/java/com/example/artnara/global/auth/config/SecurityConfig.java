package com.example.artnara.global.auth.config;

import com.example.artnara.global.auth.jwt.JwtAuthenticationFilter;
import com.example.artnara.global.auth.jwt.JwtProvider;
import com.example.artnara.global.config.SecurityConstant;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpMethod;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
@EnableMethodSecurity
public class SecurityConfig {

    private final JwtProvider jwtProvider;

    // 로컬 테스트 전용 우회 스위치. 비워두면(기본값) 평소처럼 JWT를 정상 검증한다.
    @Value("${auth.dev-bypass-user-id:}")
    private String devBypassUserId;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .addFilterBefore(new JwtAuthenticationFilter(jwtProvider, devBypassUserId),
                        UsernamePasswordAuthenticationFilter.class)
                .csrf(AbstractHttpConfigurer::disable)
                // H2 콘솔은 iframe 사용하므로 frameOptions 해제
                .headers(headers -> headers
                        .frameOptions(frame -> frame.sameOrigin())
                )
                .authorizeHttpRequests(auth -> auth
                        // 인프라·인증·QR 검증은 메서드 무관 공개
                        .requestMatchers(SecurityConstant.PUBLIC_URLS).permitAll()
                        // 조회는 공개, 나머지(POST/PATCH/DELETE)는 로그인 필요
                        .requestMatchers(HttpMethod.GET, SecurityConstant.PUBLIC_READ_URLS).permitAll()
                        .anyRequest().authenticated()
                )
                .exceptionHandling(ex -> ex
                        .authenticationEntryPoint((req, res, e) ->
                                res.sendError(HttpServletResponse.SC_UNAUTHORIZED)
                        )
                        .accessDeniedHandler((req, res, e) ->
                                res.sendError(HttpServletResponse.SC_FORBIDDEN)
                        )
                )
                .cors(cors -> cors.configurationSource(corsConfigurationSource()));

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(List.of("*"));
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);
        configuration.setExposedHeaders(List.of("Authorization"));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);

        return source;
    }
}