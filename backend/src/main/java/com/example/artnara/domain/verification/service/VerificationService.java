package com.example.artnara.domain.verification.service;

import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.domain.verification.dto.VerificationDto;
import com.example.artnara.domain.verification.entity.Verification;
import com.example.artnara.domain.verification.repository.VerificationRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class VerificationService {

    private final VerificationRepository verificationRepository;
    private final UserRepository userRepository;

    @Transactional
    public VerificationDto.Response submit(VerificationDto.SubmitRequest req) {
        var user = userRepository.findById(req.userId())
                .orElseThrow(() -> new GlobalException(DomainResultCode.USER_NOT_FOUND));
        Verification saved = verificationRepository.save(Verification.builder()
                .user(user).type(req.type()).documentUrl(req.documentUrl()).build());
        return VerificationDto.Response.from(saved);
    }

    public List<VerificationDto.Response> listByUser(Long userId) {
        return verificationRepository.findAllByUserId(userId).stream()
                .map(VerificationDto.Response::from).toList();
    }

    @Transactional
    public void approve(Long id) {
        find(id).approve();
    }

    @Transactional
    public void reject(Long id, VerificationDto.RejectRequest req) {
        find(id).reject(req.reason());
    }

    private Verification find(Long id) {
        return verificationRepository.findById(id)
                .orElseThrow(() -> new GlobalException(DomainResultCode.VERIFICATION_NOT_FOUND));
    }
}
