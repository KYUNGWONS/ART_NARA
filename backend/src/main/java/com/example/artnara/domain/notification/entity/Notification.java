package com.example.artnara.domain.notification.entity;

import com.example.artnara.global.common.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 알림. 하단 내비 '알림' 탭에서 조회한다.
 *
 * 프로토타입 도메인(작품·의뢰·주문)은 아직 사용자 스코프가 없어, 그 흐름에서 만들어지는 알림은
 * userId 없이(=시스템 알림) 저장하고 모든 사용자에게 노출한다. 사용자 스코프가 생기면
 * 생성 시점에 userId 를 채우면 그대로 개인 알림이 된다.
 */
@Getter
@Entity
@Table(name = "notifications")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Notification extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** 수신자. null 이면 시스템 알림(전체 노출) */
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NotificationType type;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, length = 500)
    private String message;

    /** 알림을 눌렀을 때 이동할 대상 id (작품·의뢰·주문 등, 타입별 해석) */
    private Long targetId;

    @Column(name = "is_read", nullable = false)
    private boolean read = false;

    @Builder
    public Notification(Long userId, NotificationType type, String title, String message, Long targetId) {
        this.userId = userId;
        this.type = type;
        this.title = title;
        this.message = message;
        this.targetId = targetId;
    }

    public void markAsRead() {
        this.read = true;
    }
}
