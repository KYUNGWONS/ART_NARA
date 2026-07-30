package com.example.artnara.domain.verification.entity;

import com.example.artnara.domain.user.entity.User;
import com.example.artnara.global.common.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "verifications")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Verification extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private VerificationType type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private VerificationStatus status;

    private String documentUrl;

    @Column(length = 500)
    private String rejectReason;

    @Builder
    public Verification(User user, VerificationType type, String documentUrl) {
        this.user = user;
        this.type = type;
        this.documentUrl = documentUrl;
        this.status = VerificationStatus.PENDING;
    }

    public void approve() {
        this.status = VerificationStatus.APPROVED;
        this.rejectReason = null;
    }

    public void reject(String reason) {
        this.status = VerificationStatus.REJECTED;
        this.rejectReason = reason;
    }
}
