package com.example.artnara.global.auth.oauth;

import com.example.artnara.global.auth.exception.AuthErrorCode;
import com.example.artnara.global.exception.GlobalException;
import tools.jackson.databind.JsonNode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

/**
 * 카카오 access token 검증.
 * 카카오 사용자 정보 조회 API(GET /v2/user/me)를 호출하고, 성공 시 토큰이 유효한 것으로 간주한다.
 */
@Slf4j
@Component
public class KakaoTokenVerifier implements OAuthTokenVerifier {

    private static final String USER_INFO_URI = "https://kapi.kakao.com/v2/user/me";

    private final RestClient restClient = RestClient.create();

    @Override
    public OAuthProvider getProvider() {
        return OAuthProvider.KAKAO;
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
            log.warn("카카오 토큰 검증 실패: {}", e.getMessage());
            throw new GlobalException(AuthErrorCode.OAUTH_VERIFICATION_FAILED);
        }

        if (body == null || body.get("id") == null) {
            throw new GlobalException(AuthErrorCode.OAUTH_VERIFICATION_FAILED);
        }

        String providerId = body.get("id").asText();
        JsonNode account = body.get("kakao_account");
        JsonNode profile = account != null ? account.get("profile") : null;

        // 카카오가 이메일을 제공하지 않을 수 있다(동의 미획득/비즈앱 미전환). 이메일은 옵션으로 둔다.
        String email = account != null && account.hasNonNull("email")
                ? account.get("email").asText() : null;

        String nickname = profile != null && profile.hasNonNull("nickname")
                ? profile.get("nickname").asText() : null;
        String profileImageUrl = profile != null && profile.hasNonNull("profile_image_url")
                ? profile.get("profile_image_url").asText() : null;

        return new OAuthUserInfo(OAuthProvider.KAKAO, providerId, email, nickname, profileImageUrl);
    }
}
