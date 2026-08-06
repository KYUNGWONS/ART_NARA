package com.example.artnara.domain.push.entity;

import com.example.artnara.global.common.BaseTimeEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 푸시를 보낼 기기(FCM 등록 토큰).
 *
 * 한 사용자가 여러 기기를 쓸 수 있어 (userId, token) 이 아니라 **token 이 고유**하다.
 * 같은 기기를 다른 계정이 쓰면 소유자만 바뀐다(이전 계정으로 푸시가 가면 안 된다).
 */
@Entity
@Table(name = "device_tokens")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class DeviceToken extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 512)
    private String token;

    @Column(nullable = false)
    private Long userId;

    /** ANDROID / IOS — 발송 실패 분석용 */
    @Column(nullable = false, length = 16)
    private String platform;

    public DeviceToken(String token, Long userId, String platform) {
        this.token = token;
        this.userId = userId;
        this.platform = platform;
    }

    public void reassignTo(Long userId, String platform) {
        this.userId = userId;
        this.platform = platform;
    }
}
