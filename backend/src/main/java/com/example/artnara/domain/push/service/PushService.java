package com.example.artnara.domain.push.service;

import com.example.artnara.domain.push.entity.DeviceToken;
import com.example.artnara.domain.push.repository.DeviceTokenRepository;
import com.example.artnara.global.push.FcmClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

/**
 * 기기 등록과 푸시 발송.
 *
 * 발송은 **앱 내 알림을 저장한 뒤 곁들이는 것**이라, 실패해도 예외를 밖으로 내보내지 않는다
 * (푸시가 안 갔다고 결제·입찰 트랜잭션이 되돌아가면 안 된다).
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class PushService {

    private final DeviceTokenRepository deviceTokenRepository;
    private final FcmClient fcmClient;

    /** 앱이 로그인 후 보내는 등록 토큰을 저장한다. 같은 기기를 다른 계정이 쓰면 소유자만 바뀐다. */
    public void register(String token, Long userId, String platform) {
        String resolvedPlatform = platform == null || platform.isBlank()
                ? "ANDROID" : platform.trim().toUpperCase();
        deviceTokenRepository.findByToken(token)
                .ifPresentOrElse(
                        existing -> existing.reassignTo(userId, resolvedPlatform),
                        () -> deviceTokenRepository.save(
                                new DeviceToken(token, userId, resolvedPlatform)));
    }

    /** 로그아웃·앱 삭제 시 호출. 없는 토큰이어도 조용히 넘어간다. */
    public void unregister(String token) {
        deviceTokenRepository.deleteByToken(token);
    }

    /**
     * 사용자의 모든 기기로 보낸다. 대상이 없으면 아무 일도 하지 않는다.
     * 더 이상 유효하지 않은 토큰은 이 자리에서 정리한다.
     */
    public void sendToUser(Long userId, String title, String body, Map<String, String> data) {
        if (userId == null || !fcmClient.isEnabled()) return;
        List<DeviceToken> devices = deviceTokenRepository.findByUserId(userId);
        for (DeviceToken device : devices) {
            try {
                if (!fcmClient.send(device.getToken(), title, body, data)) {
                    deviceTokenRepository.delete(device);
                }
            } catch (RuntimeException e) {
                log.warn("푸시 발송 중 오류 userId={}", userId, e);
            }
        }
    }
}
