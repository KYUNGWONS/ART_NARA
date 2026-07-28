package com.example.unitrip.global.auth.oauth;

import com.example.unitrip.global.auth.exception.AuthErrorCode;
import com.example.unitrip.global.exception.GlobalException;
import tools.jackson.databind.JsonNode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.util.UriComponentsBuilder;

/**
 * 구글 idToken 검증.
 * 구글 tokeninfo 엔드포인트로 서명·만료를 서버에서 검증한다.
 * (요청 필드명은 accessToken이지만 구글은 값으로 idToken을 넘겨받는다.)
 */
@Slf4j
@Component
public class GoogleTokenVerifier implements OAuthTokenVerifier {

    private static final String TOKEN_INFO_URI = "https://oauth2.googleapis.com/tokeninfo";

    private final RestClient restClient = RestClient.create();

    /** 설정 시 idToken의 aud(대상 클라이언트) 일치 여부를 검증한다. 비어 있으면 검증을 건너뛴다. */
    @Value("${oauth.google.client-id:}")
    private String clientId;

    @Override
    public OAuthProvider getProvider() {
        return OAuthProvider.GOOGLE;
    }

    @Override
    public OAuthUserInfo verify(String idToken) {
        String uri = UriComponentsBuilder.fromUriString(TOKEN_INFO_URI)
                .queryParam("id_token", idToken)
                .toUriString();

        JsonNode body;
        try {
            body = restClient.get()
                    .uri(uri)
                    .retrieve()
                    .body(JsonNode.class);
        } catch (RestClientException e) {
            log.warn("구글 idToken 검증 실패: {}", e.getMessage());
            throw new GlobalException(AuthErrorCode.OAUTH_VERIFICATION_FAILED);
        }

        if (body == null || body.get("sub") == null) {
            throw new GlobalException(AuthErrorCode.OAUTH_VERIFICATION_FAILED);
        }

        if (clientId != null && !clientId.isBlank()) {
            String aud = body.hasNonNull("aud") ? body.get("aud").asText() : null;
            if (!clientId.equals(aud)) {
                log.warn("구글 idToken aud 불일치: expected={}, actual={}", clientId, aud);
                throw new GlobalException(AuthErrorCode.OAUTH_VERIFICATION_FAILED);
            }
        }

        // 이메일 미제공 가능. 이메일은 옵션으로 둔다.
        String email = body.hasNonNull("email") ? body.get("email").asText() : null;

        String providerId = body.get("sub").asText();
        String nickname = body.hasNonNull("name") ? body.get("name").asText() : null;
        String profileImageUrl = body.hasNonNull("picture") ? body.get("picture").asText() : null;

        return new OAuthUserInfo(OAuthProvider.GOOGLE, providerId, email, nickname, profileImageUrl);
    }
}
