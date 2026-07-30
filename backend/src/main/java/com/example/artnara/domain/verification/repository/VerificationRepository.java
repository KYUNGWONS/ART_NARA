package com.example.artnara.domain.verification.repository;

import com.example.artnara.domain.verification.entity.Verification;
import com.example.artnara.domain.verification.entity.VerificationStatus;
import com.example.artnara.domain.verification.entity.VerificationType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VerificationRepository extends JpaRepository<Verification, Long> {
    List<Verification> findAllByUserId(Long userId);

    // 프로필 '대학교 인증' 표시용: 해당 유형의 승인된 인증 보유 여부
    boolean existsByUserIdAndTypeAndStatus(Long userId, VerificationType type, VerificationStatus status);
}
