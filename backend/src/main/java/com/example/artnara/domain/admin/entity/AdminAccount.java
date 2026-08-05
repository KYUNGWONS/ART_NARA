package com.example.artnara.domain.admin.entity;

import com.example.artnara.global.common.BaseTimeEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 관리자 계정. 앱 사용자(User)와 완전히 분리된 테이블이라
 * 관리자 로그인이 앱 회원 데이터에 영향을 주지 않는다.
 *
 * 비밀번호는 BCrypt 해시로만 저장한다(평문 금지).
 */
@Getter
@Entity
@Table(name = "admin_accounts")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AdminAccount extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false)
    private String passwordHash;

    /** 초기 비밀번호(ADMIN)를 그대로 쓰는 동안 true — 화면에서 변경을 유도한다. */
    @Column(nullable = false)
    private boolean mustChangePassword;

    @Builder
    public AdminAccount(String username, String passwordHash, boolean mustChangePassword) {
        this.username = username;
        this.passwordHash = passwordHash;
        this.mustChangePassword = mustChangePassword;
    }

    public void changePassword(String newHash) {
        this.passwordHash = newHash;
        this.mustChangePassword = false;
    }
}
