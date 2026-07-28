package com.example.unitrip.global.auth.service;

import com.example.unitrip.domain.user.entity.User;
import com.example.unitrip.domain.user.repository.UserRepository;
import com.example.unitrip.global.auth.dto.AuthDto;
import com.example.unitrip.global.auth.exception.AuthErrorCode;
import com.example.unitrip.global.auth.jwt.JwtProvider;
import com.example.unitrip.global.auth.oauth.OAuthProvider;
import com.example.unitrip.global.auth.oauth.OAuthTokenVerifier;
import com.example.unitrip.global.auth.oauth.OAuthUserInfo;
import com.example.unitrip.global.exception.GlobalException;
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

        String subject = String.valueOf(user.getId());
        String accessToken = jwtProvider.generateAccessToken(subject, DEFAULT_ROLE);
        String refreshToken = jwtProvider.generateRefreshToken(subject, DEFAULT_ROLE);

        log.info("OAuth 로그인: provider={}, providerId={}, userId={}, isNewUser={}",
                info.provider(), info.providerId(), user.getId(), isNewUser);

        return new AuthDto.LoginResponse(
                accessToken, refreshToken, isNewUser, user.getUserType(), user.isProfileCompleted());
    }
}
