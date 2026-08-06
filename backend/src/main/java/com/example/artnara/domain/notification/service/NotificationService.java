package com.example.artnara.domain.notification.service;

import com.example.artnara.domain.notification.dto.NotificationDto;
import com.example.artnara.domain.notification.entity.Notification;
import com.example.artnara.domain.notification.entity.NotificationType;
import com.example.artnara.domain.notification.repository.NotificationRepository;
import com.example.artnara.domain.push.service.PushService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class NotificationService {

    /** 알림 목록은 최근 것만 의미가 있어 한 번에 내려주는 건수를 제한한다. */
    private static final int MAX_ITEMS = 100;

    private final NotificationRepository notificationRepository;
    private final PushService pushService;

    public NotificationDto.ListResponse list(Long userId) {
        return new NotificationDto.ListResponse(
                notificationRepository.findVisibleTo(userId, PageRequest.of(0, MAX_ITEMS)).stream()
                        .map(NotificationDto.Item::from)
                        .toList(),
                notificationRepository.countUnreadFor(userId));
    }

    @Transactional
    public void markAsRead(Long id, Long userId) {
        notificationRepository.findVisibleById(id, userId)
                .orElseThrow(() -> new GlobalException(DomainResultCode.NOTIFICATION_NOT_FOUND))
                .markAsRead();
    }

    @Transactional
    public void markAllAsRead(Long userId) {
        notificationRepository.findVisibleTo(userId, Pageable.unpaged())
                .forEach(Notification::markAsRead);
    }

    /** 도메인 서비스에서 호출하는 발행 헬퍼. userId 가 null 이면 시스템 알림. */
    @Transactional
    public void publish(NotificationType type, String title, String message, Long targetId) {
        publishTo(null, type, title, message, targetId);
    }

    @Transactional
    public void publishTo(Long userId, NotificationType type, String title, String message, Long targetId) {
        notificationRepository.save(Notification.builder()
                .userId(userId)
                .type(type)
                .title(title)
                .message(message)
                .targetId(targetId)
                .build());
        // 앱이 꺼져 있어도 닿도록 푸시를 곁들인다. 시스템 알림(userId=null)은 대상이 없어 건너뛴다.
        pushService.sendToUser(userId, title, message, java.util.Map.of(
                "type", type.name(),
                "targetId", targetId == null ? "" : targetId.toString()));
    }
}
