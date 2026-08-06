package com.example.artnara.domain.push;

import com.example.artnara.domain.push.repository.DeviceTokenRepository;
import com.example.artnara.domain.push.service.PushService;
import com.example.artnara.global.push.FcmClient;
import com.example.artnara.support.IntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

@IntegrationTest
class PushServiceTest {

    @Autowired
    PushService pushService;
    @Autowired
    DeviceTokenRepository deviceTokenRepository;

    // 실제 FCM 을 부르지 않는다 — 발송 여부와 토큰 정리만 검증한다.
    @MockitoBean
    FcmClient fcmClient;

    @Test
    @DisplayName("같은 기기를 다른 계정이 쓰면 소유자만 바뀐다")
    void reassignDevice() {
        pushService.register("token-a", 1L, "ANDROID");
        pushService.register("token-a", 2L, "ANDROID");

        assertThat(deviceTokenRepository.findByUserId(1L)).isEmpty();
        assertThat(deviceTokenRepository.findByUserId(2L)).hasSize(1);
    }

    @Test
    @DisplayName("푸시가 꺼져 있으면 발송을 시도하지 않는다")
    void skipWhenDisabled() {
        given(fcmClient.isEnabled()).willReturn(false);
        pushService.register("token-b", 3L, "ANDROID");

        pushService.sendToUser(3L, "제목", "내용", Map.of());

        verify(fcmClient, never()).send(anyString(), anyString(), anyString(), any());
    }

    @Test
    @DisplayName("더 이상 유효하지 않은 토큰은 발송 중에 정리된다")
    void dropStaleToken() {
        given(fcmClient.isEnabled()).willReturn(true);
        given(fcmClient.send(eq("token-c"), anyString(), anyString(), any())).willReturn(false);
        pushService.register("token-c", 4L, "ANDROID");

        pushService.sendToUser(4L, "제목", "내용", Map.of());

        assertThat(deviceTokenRepository.findByToken("token-c")).isEmpty();
    }

    @Test
    @DisplayName("시스템 알림(대상 없음)은 발송하지 않는다")
    void skipSystemNotification() {
        given(fcmClient.isEnabled()).willReturn(true);

        pushService.sendToUser(null, "제목", "내용", Map.of());

        verify(fcmClient, never()).send(anyString(), anyString(), anyString(), any());
    }
}
