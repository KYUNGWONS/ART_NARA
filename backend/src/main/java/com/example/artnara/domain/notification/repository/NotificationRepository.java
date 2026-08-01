package com.example.artnara.domain.notification.repository;

import com.example.artnara.domain.notification.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface NotificationRepository extends JpaRepository<Notification, Long> {

    /** 내 알림 + 시스템 알림(userId null) */
    @Query("SELECT n FROM Notification n WHERE n.userId IS NULL OR n.userId = :userId ORDER BY n.id DESC")
    List<Notification> findVisibleTo(@Param("userId") Long userId);

    @Query("SELECT COUNT(n) FROM Notification n WHERE (n.userId IS NULL OR n.userId = :userId) AND n.read = false")
    long countUnreadFor(@Param("userId") Long userId);

    @Query("SELECT n FROM Notification n WHERE n.id = :id AND (n.userId IS NULL OR n.userId = :userId)")
    Optional<Notification> findVisibleById(@Param("id") Long id, @Param("userId") Long userId);
}
