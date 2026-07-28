package com.example.unitrip.domain.notification.service;

import com.example.unitrip.domain.notification.dto.NotificationDto;
import com.example.unitrip.domain.notification.entity.Notification;
import com.example.unitrip.domain.notification.repository.NotificationRepository;
import com.example.unitrip.domain.user.repository.UserRepository;
import com.example.unitrip.global.common.DomainResultCode;
import com.example.unitrip.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    @Transactional
    public NotificationDto.Response create(NotificationDto.CreateRequest req) {
        var user = userRepository.findById(req.userId())
                .orElseThrow(() -> new GlobalException(DomainResultCode.USER_NOT_FOUND));
        Notification saved = notificationRepository.save(
                Notification.builder().user(user).type(req.type())
                        .title(req.title()).body(req.body()).build());
        return NotificationDto.Response.from(saved);
    }

    public List<NotificationDto.Response> list(Long userId) {
        return notificationRepository.findAllByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(NotificationDto.Response::from).toList();
    }

    public long unreadCount(Long userId) {
        return notificationRepository.countByUserIdAndReadFalse(userId);
    }

    @Transactional
    public void markRead(Long id) {
        notificationRepository.findById(id)
                .orElseThrow(() -> new GlobalException(DomainResultCode.NOTIFICATION_NOT_FOUND))
                .markRead();
    }

    @Transactional
    public void delete(Long id) {
        notificationRepository.deleteById(id);
    }
}
