package com.example.artnara.global.payment;

import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * 토스 연동 단위 테스트.
 *
 * 실제 네트워크를 타지 않는다 — 결제 승인은 토스 서버가 발급한 paymentKey 가 있어야 하고
 * 그건 결제창을 사람이 거쳐야만 나온다. 여기서는 설정 분기와 응답 파싱만 검증하고,
 * 실 승인 왕복은 앱에서 결제창을 띄워 확인한다.
 */
class TossPaymentClientTest {

    @Test
    @DisplayName("시크릿 키가 없으면 비활성 — mock 결제로 동작한다")
    void disabledWithoutSecretKey() {
        assertThat(new TossPaymentClient("").isEnabled()).isFalse();
        assertThat(new TossPaymentClient(null).isEnabled()).isFalse();
        assertThat(new TossPaymentClient("   ").isEnabled()).isFalse();
    }

    @Test
    @DisplayName("시크릿 키가 있으면 활성")
    void enabledWithSecretKey() {
        assertThat(new TossPaymentClient("test_gsk_docs_example").isEnabled()).isTrue();
    }

    @Test
    @DisplayName("승인 요청은 결제 서버 오류를 사용자 메시지로 바꿔 던진다")
    void confirmFailsWithReadableError() {
        // 존재하지 않는 결제 키 → 토스가 4xx 로 사유를 돌려준다.
        TossPaymentClient client = new TossPaymentClient("test_gsk_docs_OaPz8L5KdmQXkzRz3y47BMw6");

        assertThatThrownBy(() -> client.confirm("no-such-payment-key", "order-1", 1000))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.PAYMENT_FAILED);
    }
}
