package com.example.artnara.domain.notification.dto;

import com.example.artnara.domain.notification.entity.Notification;
import com.example.artnara.domain.notification.entity.NotificationType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.List;

public class NotificationDto {

    @Schema(name = "NotificationItem")
    public record Item(
            Long id,
            NotificationType type,
            String title,
            String message,
            Long targetId,
            boolean read,
            LocalDateTime createdAt
    ) {
        public static Item from(Notification n) {
            return new Item(n.getId(), n.getType(), n.getTitle(), n.getMessage(),
                    n.getTargetId(), n.isRead(), n.getCreatedAt());
        }
    }

    @Schema(name = "NotificationListResponse")
    public record ListResponse(List<Item> notifications, long unreadCount) {}
}
