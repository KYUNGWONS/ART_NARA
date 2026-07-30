package com.example.artnara.domain.user.service;

import com.example.artnara.domain.user.dto.UserDto;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.domain.verification.entity.VerificationStatus;
import com.example.artnara.domain.verification.entity.VerificationType;
import com.example.artnara.domain.verification.repository.VerificationRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;
    private final VerificationRepository verificationRepository;

    /**
     * 프로필 설정(회원가입 완료). 로그인 시 생성된, 인증된 유저의 프로필을 채우고 profileCompleted를 true로 전환한다.
     */
    @Transactional
    public UserDto.Response completeProfile(Long userId, UserDto.CreateRequest req) {
        User user = find(userId);
        user.completeProfile(req.nickname(), req.displayName(), req.age(), req.userType(),
                req.profileImageUrl(), req.region(), req.aboutMe(),
                req.travelStyle(), req.interests(), req.languages());
        return UserDto.Response.from(user, isUniversityVerified(user.getId()));
    }

    public UserDto.Response get(Long id) {
        User user = find(id);
        return UserDto.Response.from(user, isUniversityVerified(user.getId()));
    }

    @Transactional
    public UserDto.Response update(Long id, UserDto.UpdateRequest req) {
        User user = find(id);
        user.updateProfile(req.nickname(), req.displayName(), req.region(), req.aboutMe(),
                req.travelStyle(), req.interests(), req.languages());
        return UserDto.Response.from(user, isUniversityVerified(user.getId()));
    }

    // 프로필 '대학교 인증' 표시값: 승인된 UNIVERSITY 인증 보유 시 true(인증), 없으면 false(미인증)
    private boolean isUniversityVerified(Long userId) {
        return verificationRepository.existsByUserIdAndTypeAndStatus(
                userId, VerificationType.UNIVERSITY, VerificationStatus.APPROVED);
    }

    @Transactional
    public void setMatchingEnabled(Long id, boolean enabled) {
        find(id).setMatchingEnabled(enabled);
    }

    @Transactional
    public void delete(Long id) {
        userRepository.delete(find(id));
    }

    private User find(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new GlobalException(DomainResultCode.USER_NOT_FOUND));
    }
}
