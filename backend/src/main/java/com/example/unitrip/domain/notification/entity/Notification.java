package com.example.unitrip.domain.notification.entity;

import com.example.unitrip.domain.user.entity.User;
import com.example.unitrip.global.common.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "notifications")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Notification extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NotificationType type;

    @Column(nullable = false)
    private String title;

    @Column(length = 1000)
    private String body;

    @Column(name = "is_read", nullable = false)
    private boolean read = false;

    @Builder
    public Notification(User user, NotificationType type, String title, String body) {
        this.user = user;
        this.type = type;
        this.title = title;
        this.body = body;
    }

    public void markRead() { this.read = true; }
}
