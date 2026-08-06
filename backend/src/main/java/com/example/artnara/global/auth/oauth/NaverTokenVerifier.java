package com.example.artnara.global.auth.oauth;

import com.example.artnara.global.auth.exception.AuthErrorCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import tools.jackson.databind.JsonNode;

/**
 * 네이버 액세스 토큰 검증.
 *
 * 앱이 받아온 액세스 토큰으로 프로필을 조회해, **서버가 직접 신원을 확인**한다
 * (클라이언트가 보내온 사용자 정보를 그대로 믿지 않는다 — 카카오와 같은 방식).
 * 응답은 `{resultcode, message, response:{id, email, nickname, profile_image}}` 형태다.
 */
@Slf4j
@Component
public class NaverTokenVerifier implements OAuthTokenVerifier {

    private static final String USER_INFO_URI = "https://openapi.naver.com/v1/nid/me";

    private final RestClient restClient = RestClient.create();

    @Override
    public OAuthProvider getProvider() {
        return OAuthProvider.NAVER;
    }

    @Override
    public OAuthUserInfo verify(String accessToken) {
        JsonNode body;
        try {
            body = restClient.get()
                    .uri(USER_INFO_URI)
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken)
                    .retrieve()
                    .body(JsonNode.class);
        } catch (RestClientException e) {
            log.warn("네이버 액세스 토큰 검증 실패: {}", e.getMessage());
            throw new GlobalException(AuthErrorCode.OAUTH_VERIFICATION_FAILED);
        }

        // resultcode 가 "00" 이 아니면 토큰이 유효하지 않거나 동의가 철회된 상태다.
        if (body == null || !"00".equals(text(body, "resultcode"))) {
            throw new GlobalException(AuthErrorCode.OAUTH_VERIFICATION_FAILED);
        }
        JsonNode profile = body.get("response");
        if (profile == null || text(profile, "id") == null) {
            throw new GlobalException(AuthErrorCode.OAUTH_VERIFICATION_FAILED);
        }

        return new OAuthUserInfo(
                OAuthProvider.NAVER,
                text(profile, "id"),
                text(profile, "email"),
                text(profile, "nickname"),
                text(profile, "profile_image"));
    }

    private static String text(JsonNode node, String field) {
        return node.hasNonNull(field) ? node.get(field).asText() : null;
    }
}
