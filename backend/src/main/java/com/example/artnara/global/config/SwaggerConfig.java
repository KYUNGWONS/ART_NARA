package com.example.artnara.global.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    private static final String JWT_SCHEME = "bearer-jwt";

    /**
     * 기본적으로 모든 API 에 JWT 를 요구하도록 두고, 공개 API 에만
     * {@code @SecurityRequirements}(빈 값)를 붙여 자물쇠를 뗀다 —
     * 실제 보안 규칙(SecurityConstant)과 문서가 어긋나지 않게 하기 위해서다.
     */
    @Bean
    public OpenAPI openAPI() {
        Components components = new Components()
                .addSecuritySchemes(JWT_SCHEME, new SecurityScheme()
                        .name(JWT_SCHEME)
                        .type(SecurityScheme.Type.HTTP)
                        .scheme("bearer")
                        .bearerFormat("JWT")
                        .description("로그인 응답의 accessToken 을 넣는다. "
                                + "관리자 API 는 /api/admin/login 으로 받은 별도 토큰을 쓴다."));

        return new OpenAPI()
                .addServersItem(new Server().url("/").description("현재 서버"))
                .addSecurityItem(new SecurityRequirement().addList(JWT_SCHEME))
                .components(components)
                .info(apiInfo());
    }

    private Info apiInfo() {
        return new Info()
                .title("ART NARA API")
                .version("v1.0.0")
                .description("""
                        미대생 미술품 거래 플랫폼 백엔드 API.

                        **인증**
                        - 조회(GET)는 대체로 공개, 상태를 바꾸는 요청은 로그인 필수.
                        - 자물쇠가 없는 API 는 토큰 없이 호출할 수 있다.
                        - 앱 토큰은 ROLE_USER, 관리자 토큰은 ROLE_ADMIN 으로 서로의 API 를 호출할 수 없다.
                        - "내 것" 목록(주문·소유권·판매·정산)은 토큰 신원으로 스코프된다 \
                        — 파라미터로 남의 것을 조회할 수 없다.

                        **직거래 흐름** (배송이 없어 결제를 만난 뒤로 미룬다)
                        1. `POST /api/orders` 예약 — 작품이 잠기고 결제는 하지 않는다
                        2. `POST /api/orders/{id}/handover` 판매자·구매자가 각각 수령 확인
                        3. `POST /api/orders/{id}/pay` 양쪽 확인 후 구매자만 결제 → 소유권 발급
                        """);
    }
}
