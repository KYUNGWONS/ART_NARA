package com.example.artnara.global.auth.oauth;

import com.example.artnara.global.auth.exception.AuthErrorCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.util.UriComponentsBuilder;
import tools.jackson.databind.JsonNode;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * 네이버 OAuth 인가 코드를 액세스 토큰으로 교환한다.
 *
 * 앱은 WebView 로 동의만 받아 **인가 코드**를 가져오고, 토큰 교환은 여기서 한다 —
 * 클라이언트 시크릿이 앱에 들어가지 않도록 서버가 들고 있는다.
 * (네이버 SDK 는 커스텀탭 → `intent://` 콜백에 의존하는데, 그 전달이 막히는 환경이 있어
 *  앱 자체 WebView 로 흐름을 돌렸다.)
 */
@Slf4j
@Component
public class NaverOAuthClient {

    private static final String TOKEN_URI = "https://nid.naver.com/oauth2.0/token";
    private static final String AUTHORIZE_URI = "https://nid.naver.com/oauth2.0/authorize";

    private final RestClient restClient = RestClient.create();

    private final String clientId;
    private final String clientSecret;
    private final String redirectUri;

    public NaverOAuthClient(
            @Value("${oauth.naver.client-id:}") String clientId,
            @Value("${oauth.naver.client-secret:}") String clientSecret,
            @Value("${oauth.naver.redirect-uri:https://artnara.app/oauth/naver}") String redirectUri) {
        this.clientId = clientId;
        this.clientSecret = clientSecret;
        this.redirectUri = redirectUri;
        log.info("네이버 로그인 {}", isConfigured() ? "설정됨" : "미설정 (NAVER_CLIENT_ID/SECRET 필요)");
    }

    public boolean isConfigured() {
        return !clientId.isBlank() && !clientSecret.isBlank();
    }

    public String clientId() {
        return clientId;
    }

    public String redirectUri() {
        return redirectUri;
    }

    /**
     * 앱이 WebView 로 열 동의 화면 주소. state 는 앱이 만들어 넘기고 콜백에서 대조한다.
     *
     * redirect_uri 의 `:`·`/` 는 RFC 상 쿼리에서 합법이라 스프링 인코더({@code encode()},
     * {@code UriUtils.encodeQueryParam})가 그대로 두지만, 네이버 문서는 `%3A%2F%2F` 형태의
     * 퍼센트 인코딩을 예시한다 — 규격 해석 여지를 없애기 위해 {@link URLEncoder} 로 못박는다.
     */
    public String authorizeUrl(String state) {
        return AUTHORIZE_URI
                + "?response_type=code"
                + "&client_id=" + URLEncoder.encode(clientId, StandardCharsets.UTF_8)
                + "&redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8)
                + "&state=" + URLEncoder.encode(state, StandardCharsets.UTF_8);
    }

    /** 인가 코드 → 액세스 토큰. 실패하면 로그인 실패로 처리한다. */
    public String exchangeCodeForAccessToken(String code, String state) {
        if (!isConfigured()) {
            throw new GlobalException(AuthErrorCode.OAUTH_VERIFICATION_FAILED);
        }
        String uri = UriComponentsBuilder.fromUriString(TOKEN_URI)
                .queryParam("grant_type", "authorization_code")
                .queryParam("client_id", clientId)
                .queryParam("client_secret", clientSecret)
                .queryParam("code", code)
                .queryParam("state", state)
                .encode()
                .toUriString();

        JsonNode body;
        try {
            body = restClient.get().uri(uri).retrieve().body(JsonNode.class);
        } catch (RestClientException e) {
            log.warn("네이버 토큰 교환 실패: {}", e.getMessage());
            throw new GlobalException(AuthErrorCode.OAUTH_VERIFICATION_FAILED);
        }
        if (body == null || !body.hasNonNull("access_token")) {
            log.warn("네이버 토큰 응답에 access_token 이 없습니다: {}",
                    body == null ? "null" : body.path("error_description").asText(""));
            throw new GlobalException(AuthErrorCode.OAUTH_VERIFICATION_FAILED);
        }
        return body.get("access_token").asText();
    }
}
