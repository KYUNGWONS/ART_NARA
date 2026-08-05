package com.example.artnara.domain.admin.service;

import com.example.artnara.domain.admin.dto.AdminDto;
import com.example.artnara.domain.admin.entity.AdminAccount;
import com.example.artnara.domain.admin.repository.AdminAccountRepository;
import com.example.artnara.global.auth.jwt.JwtProvider;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 관리자 인증. 앱 사용자와 토큰 role 로 구분한다(ADMIN vs USER).
 * 관리자 토큰으로 앱 API 를, 앱 토큰으로 관리자 API 를 호출할 수 없다.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class AdminAuthService {

    /** 최소 비밀번호 길이 — 초기값(ADMIN)보다 짧게는 못 바꾸게 한다. */
    private static final int MIN_PASSWORD_LENGTH = 4;

    private final AdminAccountRepository adminAccountRepository;
    private final JwtProvider jwtProvider;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public AdminDto.LoginResponse login(AdminDto.LoginRequest request) {
        String username = request.username() == null ? "" : request.username().trim();
        String password = request.password() == null ? "" : request.password();

        AdminAccount admin = adminAccountRepository.findByUsername(username)
                .orElseThrow(() -> new GlobalException(DomainResultCode.ADMIN_LOGIN_FAILED));
        if (!passwordEncoder.matches(password, admin.getPasswordHash())) {
            // 아이디/비밀번호 어느 쪽이 틀렸는지 알려주지 않는다(계정 존재 여부 노출 방지).
            throw new GlobalException(DomainResultCode.ADMIN_LOGIN_FAILED);
        }
        String token = jwtProvider.generateAccessToken(String.valueOf(admin.getId()), "ADMIN");
        return new AdminDto.LoginResponse(token, admin.getUsername(), admin.isMustChangePassword());
    }

    public void changePassword(Long adminId, AdminDto.ChangePasswordRequest request) {
        AdminAccount admin = adminAccountRepository.findById(adminId)
                .orElseThrow(() -> new GlobalException(DomainResultCode.ADMIN_NOT_FOUND));
        String current = request.currentPassword() == null ? "" : request.currentPassword();
        String next = request.newPassword() == null ? "" : request.newPassword();

        if (!passwordEncoder.matches(current, admin.getPasswordHash())) {
            throw new GlobalException(DomainResultCode.ADMIN_PASSWORD_MISMATCH);
        }
        if (next.length() < MIN_PASSWORD_LENGTH) {
            throw new GlobalException(DomainResultCode.ADMIN_PASSWORD_TOO_SHORT);
        }
        if (passwordEncoder.matches(next, admin.getPasswordHash())) {
            throw new GlobalException(DomainResultCode.ADMIN_PASSWORD_SAME);
        }
        admin.changePassword(passwordEncoder.encode(next));
    }

    /** 부팅 시 기본 관리자(ADMIN/ADMIN)를 없으면 만든다. */
    public void ensureDefaultAdmin(String username, String rawPassword) {
        if (adminAccountRepository.findByUsername(username).isPresent()) return;
        adminAccountRepository.save(AdminAccount.builder()
                .username(username)
                .passwordHash(passwordEncoder.encode(rawPassword))
                .mustChangePassword(true)
                .build());
    }
}
