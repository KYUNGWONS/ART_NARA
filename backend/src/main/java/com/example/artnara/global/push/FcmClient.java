package com.example.artnara.global.push;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.Date;
import java.util.Map;

import static java.nio.charset.StandardCharsets.UTF_8;

/**
 * FCM HTTP v1 발송 클라이언트.
 *
 * 서비스 계정 JSON 경로(`FCM_CREDENTIALS`)를 주면 켜지고, 없으면 **꺼진 상태로 동작**한다
 * (푸시 없이도 앱 내 알림은 그대로 쌓인다 — 토스 결제와 같은 방식).
 *
 * 레거시 서버 키 API 는 종료돼 v1 만 쓴다. v1 은 OAuth 액세스 토큰이 필요해서
 * 서비스 계정으로 JWT 를 만들어 교환하고, 만료 전까지 재사용한다.
 */
@Slf4j
@Component
public class FcmClient {

    private static final String TOKEN_URL = "https://oauth2.googleapis.com/token";
    private static final String SCOPE = "https://www.googleapis.com/auth/firebase.messaging";
    private static final String SEND_URL = "https://fcm.googleapis.com/v1/projects/%s/messages:send";

    /** 액세스 토큰은 보통 1시간짜리다. 만료 1분 전에 갱신한다. */
    private static final Duration REFRESH_MARGIN = Duration.ofMinutes(1);

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(5)).build();

    private final String projectId;
    private final String clientEmail;
    private final PrivateKey privateKey;

    private String accessToken;
    private Instant accessTokenExpiresAt = Instant.EPOCH;

    public FcmClient(@Value("${fcm.credentials-path:}") String credentialsPath) {
        String project = null;
        String email = null;
        PrivateKey key = null;
        if (credentialsPath != null && !credentialsPath.isBlank()) {
            try {
                JsonNode json = new ObjectMapper().readTree(
                        Files.readString(Path.of(credentialsPath.trim()), UTF_8));
                project = json.path("project_id").asText(null);
                email = json.path("client_email").asText(null);
                key = readPrivateKey(json.path("private_key").asText(""));
            } catch (Exception e) {
                // 자격증명이 잘못돼도 서버는 떠야 한다 — 푸시만 꺼진다.
                log.warn("FCM 자격증명을 읽지 못해 푸시를 끕니다: {}", e.getMessage());
                project = null;
                email = null;
                key = null;
            }
        }
        this.projectId = project;
        this.clientEmail = email;
        this.privateKey = key;
        log.info("FCM 푸시 {}", isEnabled() ? "활성 (project=" + projectId + ")" : "비활성");
    }

    public boolean isEnabled() {
        return projectId != null && clientEmail != null && privateKey != null;
    }

    /**
     * 한 기기에 알림을 보낸다.
     *
     * @return 토큰이 더 이상 유효하지 않으면 false (호출자가 정리한다)
     */
    public boolean send(String deviceToken, String title, String body, Map<String, String> data) {
        if (!isEnabled()) return true;
        try {
            var payload = objectMapper.createObjectNode();
            var message = payload.putObject("message");
            message.put("token", deviceToken);
            var notification = message.putObject("notification");
            notification.put("title", title);
            notification.put("body", body);
            var dataNode = message.putObject("data");
            data.forEach(dataNode::put);

            HttpResponse<String> response = httpClient.send(
                    HttpRequest.newBuilder(URI.create(String.format(SEND_URL, projectId)))
                            .header("Authorization", "Bearer " + accessToken())
                            .header("Content-Type", "application/json; charset=utf-8")
                            .timeout(Duration.ofSeconds(10))
                            .POST(HttpRequest.BodyPublishers.ofString(payload.toString(), UTF_8))
                            .build(),
                    HttpResponse.BodyHandlers.ofString(UTF_8));

            if (response.statusCode() == 200) return true;
            // 404 UNREGISTERED / 400 INVALID_ARGUMENT: 앱 삭제·토큰 만료 → 저장된 토큰을 버린다.
            boolean stale = response.statusCode() == 404
                    || response.body().contains("UNREGISTERED")
                    || response.body().contains("INVALID_ARGUMENT");
            log.warn("FCM 발송 실패 status={} stale={}", response.statusCode(), stale);
            return !stale;
        } catch (IOException | InterruptedException e) {
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            log.warn("FCM 발송 오류: {}", e.getMessage());
            return true; // 네트워크 문제로 멀쩡한 토큰을 지우면 안 된다.
        }
    }

    /** 서비스 계정 JWT 를 액세스 토큰으로 교환한다(만료 전까지 재사용). */
    private synchronized String accessToken() throws IOException, InterruptedException {
        if (accessToken != null && Instant.now().isBefore(accessTokenExpiresAt.minus(REFRESH_MARGIN))) {
            return accessToken;
        }
        Instant now = Instant.now();
        String assertion = Jwts.builder()
                .setIssuer(clientEmail)
                .setAudience(TOKEN_URL)
                .claim("scope", SCOPE)
                .setIssuedAt(Date.from(now))
                .setExpiration(Date.from(now.plus(Duration.ofHours(1))))
                .signWith(privateKey, SignatureAlgorithm.RS256)
                .compact();

        String form = "grant_type=" + URLEncoder.encode(
                "urn:ietf:params:oauth:grant-type:jwt-bearer", UTF_8)
                + "&assertion=" + URLEncoder.encode(assertion, UTF_8);

        HttpResponse<String> response = httpClient.send(
                HttpRequest.newBuilder(URI.create(TOKEN_URL))
                        .header("Content-Type", "application/x-www-form-urlencoded")
                        .timeout(Duration.ofSeconds(10))
                        .POST(HttpRequest.BodyPublishers.ofString(form, UTF_8))
                        .build(),
                HttpResponse.BodyHandlers.ofString(UTF_8));
        if (response.statusCode() != 200) {
            throw new IOException("FCM 토큰 발급 실패: " + response.statusCode());
        }
        JsonNode json = objectMapper.readTree(response.body());
        accessToken = json.path("access_token").asText();
        accessTokenExpiresAt = now.plusSeconds(json.path("expires_in").asLong(3600));
        return accessToken;
    }

    private static PrivateKey readPrivateKey(String pem) throws Exception {
        String base64 = pem.replace("-----BEGIN PRIVATE KEY-----", "")
                .replace("-----END PRIVATE KEY-----", "")
                .replaceAll("\\s", "");
        return KeyFactory.getInstance("RSA")
                .generatePrivate(new PKCS8EncodedKeySpec(Base64.getDecoder().decode(base64)));
    }
}
