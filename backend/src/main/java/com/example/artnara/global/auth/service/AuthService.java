package com.example.artnara.global.auth.service;

import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.global.auth.dto.AuthDto;
import com.example.artnara.global.auth.exception.AuthErrorCode;
import com.example.artnara.global.auth.jwt.JwtProvider;
import com.example.artnara.global.auth.oauth.OAuthProvider;
import com.example.artnara.global.auth.oauth.OAuthTokenVerifier;
import com.example.artnara.global.auth.oauth.OAuthUserInfo;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
public class AuthService {

    private static final String DEFAULT_ROLE = "USER";

    private final UserRepository userRepository;
    private final JwtProvider jwtProvider;
    private final Map<OAuthProvider, OAuthTokenVerifier> verifiers;

    public AuthService(UserRepository userRepository,
                       JwtProvider jwtProvider,
                       List<OAuthTokenVerifier> verifierList) {
        this.userRepository = userRepository;
        this.jwtProvider = jwtProvider;
        this.verifiers = new EnumMap<>(OAuthProvider.class);
        for (OAuthTokenVerifier verifier : verifierList) {
            this.verifiers.put(verifier.getProvider(), verifier);
        }
    }

    /**
     * OAuth 토큰을 검증하고 앱 JWT를 발급한다.
     * OAuth 신원(provider + providerId)으로 유저를 조회하고, 없으면 최소 유저를 생성한다(= 신규 가입).
     * 신규 유저에게도 JWT를 발급해 이후 프로필 설정(POST /api/users)을 인증 상태로 진행하게 한다.
     * 기존회원 여부와 프로필 완료 여부는 저장된 유저 상태로 판단한다.
     */
    @Transactional
    public AuthDto.LoginResponse login(AuthDto.LoginRequest request) {
        if (request.provider() == null) {
            throw new GlobalException(AuthErrorCode.UNSUPPORTED_PROVIDER);
        }

        OAuthTokenVerifier verifier = verifiers.get(request.provider());
        if (verifier == null) {
            throw new GlobalException(AuthErrorCode.UNSUPPORTED_PROVIDER);
        }

        OAuthUserInfo info = verifier.verify(request.accessToken());

        Optional<User> found =
                userRepository.findByProviderAndProviderId(info.provider(), info.providerId());
        boolean isNewUser = found.isEmpty();
        User user = found.orElseGet(() -> userRepository.save(User.ofOAuth(
                info.provider(), info.providerId(),
                info.email(), info.nickname(), info.profileImageUrl())));

        // 관리자가 차단한 회원은 토큰을 발급하지 않는다.
        if (user.isBlocked()) {
            throw new GlobalException(DomainResultCode.USER_BLOCKED);
        }

        String subject = String.valueOf(user.getId());
        String accessToken = jwtProvider.generateAccessToken(subject, DEFAULT_ROLE);
        String refreshToken = jwtProvider.generateRefreshToken(subject, DEFAULT_ROLE);

        log.info("OAuth 로그인: provider={}, providerId={}, userId={}, isNewUser={}",
                info.provider(), info.providerId(), user.getId(), isNewUser);

        return new AuthDto.LoginResponse(
                accessToken, refreshToken, isNewUser, user.getUserType(), user.isProfileCompleted());
    }

    /**
     * refresh token 으로 새 토큰 쌍을 발급한다(회전 발급 — 이전 refresh 는 클라이언트가 버린다).
     * 서명·만료를 검증하고, 그 사이 탈퇴한 사용자면 거절한다.
     */
    @Transactional(readOnly = true)
    public AuthDto.RefreshResponse refresh(AuthDto.RefreshRequest request) {
        String token = request == null ? null : request.refreshToken();
        if (token == null || token.isBlank()
                || !jwtProvider.validateSignature(token) || jwtProvider.isExpired(token)) {
            throw new GlobalException(AuthErrorCode.INVALID_REFRESH_TOKEN);
        }

        Long userId;
        try {
            userId = Long.parseLong(jwtProvider.getClaims(token).getSubject());
        } catch (NumberFormatException e) {
            throw new GlobalException(AuthErrorCode.INVALID_REFRESH_TOKEN);
        }
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new GlobalException(AuthErrorCode.INVALID_REFRESH_TOKEN));
        // 차단 중이면 재발급도 막아 이미 발급된 토큰이 만료되는 즉시 접근이 끊긴다.
        if (user.isBlocked()) {
            throw new GlobalException(DomainResultCode.USER_BLOCKED);
        }

        String subject = String.valueOf(user.getId());
        return new AuthDto.RefreshResponse(
                jwtProvider.generateAccessToken(subject, DEFAULT_ROLE),
                jwtProvider.generateRefreshToken(subject, DEFAULT_ROLE),
                user.getUserType(), user.isProfileCompleted());
    }
}
