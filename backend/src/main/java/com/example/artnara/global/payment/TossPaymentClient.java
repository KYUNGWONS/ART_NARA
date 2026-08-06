package com.example.artnara.global.payment;

import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;

/**
 * 토스페이먼츠 결제 승인·취소 클라이언트.
 *
 * 결제 흐름: 앱이 토스 결제창에서 결제를 마치면 paymentKey·orderId·amount 를 받아 서버로 보내고,
 * **서버가 시크릿 키로 승인(confirm)을 호출해야** 실제로 결제가 확정된다.
 * 클라이언트 응답만 믿고 주문을 만들면 금액 위조가 가능하므로 승인은 반드시 서버에서 한다.
 *
 * 시크릿 키가 비어 있으면 미설정으로 보고 호출하지 않는다(프로토타입 mock 결제 유지).
 */
@Slf4j
@Component
public class TossPaymentClient {

    private static final String CONFIRM_URL = "https://api.tosspayments.com/v1/payments/confirm";
    private static final String CANCEL_URL = "https://api.tosspayments.com/v1/payments/%s/cancel";
    private static final Duration TIMEOUT = Duration.ofSeconds(15);

    private final HttpClient httpClient = HttpClient.newBuilder().connectTimeout(TIMEOUT).build();
    private final String secretKey;

    public TossPaymentClient(@Value("${toss.secret-key:}") String secretKey) {
        this.secretKey = secretKey == null ? "" : secretKey.trim();
    }

    /** 시크릿 키가 설정돼 있으면 실 PG 를 쓴다. 비어 있으면 mock 결제. */
    public boolean isEnabled() {
        return !secretKey.isEmpty();
    }

    /**
     * 결제 승인. 성공하면 토스가 확정한 실제 결제 금액을 돌려준다.
     * 승인 금액이 주문 금액과 다르면 호출한 쪽에서 거절해야 한다.
     */
    public int confirm(String paymentKey, String orderId, int amount) {
        String body = """
                {"paymentKey":"%s","orderId":"%s","amount":%d}"""
                .formatted(escape(paymentKey), escape(orderId), amount);
        String response = send(CONFIRM_URL, body, "결제 승인");
        return readInt(response, "totalAmount", amount);
    }

    /** 결제 취소(환불). 이미 취소된 결제면 토스가 오류를 돌려준다. */
    public void cancel(String paymentKey, String reason) {
        String body = """
                {"cancelReason":"%s"}""".formatted(escape(reason));
        send(CANCEL_URL.formatted(paymentKey), body, "결제 취소");
    }

    private String send(String url, String body, String action) {
        HttpRequest request = HttpRequest.newBuilder(URI.create(url))
                .header("Authorization", basicAuth())
                .header("Content-Type", "application/json")
                .timeout(TIMEOUT)
                .POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8))
                .build();
        try {
            HttpResponse<String> response =
                    httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (response.statusCode() / 100 != 2) {
                // 토스가 주는 사유(예: 잔액 부족, 이미 취소됨)를 그대로 사용자에게 전달한다.
                String message = readString(response.body(), "message");
                log.warn("토스 {} 실패: status={}, body={}", action, response.statusCode(), response.body());
                throw new GlobalException(DomainResultCode.PAYMENT_FAILED,
                        message == null ? action + "에 실패했습니다." : message);
            }
            return response.body();
        } catch (GlobalException e) {
            throw e;
        } catch (java.io.IOException e) {
            log.error("토스 {} 통신 오류", action, e);
            throw new GlobalException(DomainResultCode.PAYMENT_FAILED,
                    "결제 서버와 통신하지 못했습니다. 잠시 후 다시 시도해주세요.");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new GlobalException(DomainResultCode.PAYMENT_FAILED, "결제 처리가 중단되었습니다.");
        }
    }

    /** 토스는 "시크릿키:" 를 Base64 로 인코딩한 Basic 인증을 쓴다(콜론 뒤 비밀번호는 빈 값). */
    private String basicAuth() {
        String raw = secretKey + ":";
        return "Basic " + Base64.getEncoder()
                .encodeToString(raw.getBytes(StandardCharsets.UTF_8));
    }

    /** 응답에서 숫자 필드 하나만 꺼낸다(JSON 라이브러리 없이 — 의존성을 늘리지 않는다). */
    private int readInt(String json, String field, int fallback) {
        String value = rawValue(json, field);
        if (value == null) return fallback;
        try {
            return Integer.parseInt(value.trim().split("\\.")[0]);
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private String readString(String json, String field) {
        String value = rawValue(json, field);
        if (value == null) return null;
        String trimmed = value.trim();
        if (trimmed.startsWith("\"") && trimmed.endsWith("\"") && trimmed.length() >= 2) {
            return trimmed.substring(1, trimmed.length() - 1);
        }
        return trimmed;
    }

    private String rawValue(String json, String field) {
        if (json == null) return null;
        int start = json.indexOf("\"" + field + "\"");
        if (start < 0) return null;
        int colon = json.indexOf(':', start);
        if (colon < 0) return null;
        int end = colon + 1;
        boolean inString = false;
        while (end < json.length()) {
            char c = json.charAt(end);
            if (c == '"') inString = !inString;
            else if (!inString && (c == ',' || c == '}')) break;
            end++;
        }
        return json.substring(colon + 1, end);
    }

    /** 값에 따옴표·역슬래시가 섞여도 JSON 이 깨지지 않게 한다. */
    private String escape(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
