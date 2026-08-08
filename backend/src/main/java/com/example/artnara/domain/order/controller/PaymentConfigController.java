package com.example.artnara.domain.order.controller;

import com.example.artnara.global.common.BaseResponse;
import com.example.artnara.global.payment.TossPaymentClient;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 앱이 결제 방식을 정할 수 있도록 PG 설정을 알려준다.
 *
 * 클라이언트 키는 공개해도 되는 값(결제창을 띄우는 용도)이고,
 * 승인에 쓰는 시크릿 키는 절대 내려보내지 않는다.
 */
@Tag(name = "Payment", description = "결제 설정 API")
@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentConfigController {

    private final TossPaymentClient tossPaymentClient;

    @Value("${toss.client-key:}")
    private String clientKey;

    @SecurityRequirements
    @GetMapping("/config")
    @Operation(summary = "결제 설정 조회",
            description = "실 PG(토스) 사용 여부와 결제창용 클라이언트 키를 알려줍니다. "
                    + "enabled 가 false 면 앱은 프로토타입 mock 결제로 진행합니다.")
    public BaseResponse<PaymentConfig> config() {
        boolean enabled = tossPaymentClient.isEnabled() && !clientKey.isBlank();
        return BaseResponse.success("결제 설정",
                new PaymentConfig(enabled, enabled ? clientKey : null));
    }

    public record PaymentConfig(boolean enabled, String clientKey) {}
}
