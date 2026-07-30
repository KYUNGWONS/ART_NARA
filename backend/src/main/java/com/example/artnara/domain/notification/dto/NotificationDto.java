package com.example.artnara.domain.notification.dto;

import com.example.artnara.domain.notification.entity.Notification;
import com.example.artnara.domain.notification.entity.NotificationType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

public class NotificationDto {

    @Schema(name = "NotificationCreateRequest")
    public record CreateRequest(Long userId, NotificationType type, String title, String body) {}

    @Schema(name = "NotificationResponse")
    public record Response(Long id, Long userId, NotificationType type,
                           String title, String body, boolean read, LocalDateTime createdAt) {
        public static Response from(Notification n) {
            return new Response(n.getId(), n.getUser().getId(), n.getType(),
                    n.getTitle(), n.getBody(), n.isRead(), n.getCreatedAt());
        }
    }
}
