package com.example.unitrip.global.auth;

import com.example.unitrip.domain.user.entity.User;
import com.example.unitrip.domain.user.entity.UserType;
import com.example.unitrip.domain.user.repository.UserRepository;
import com.example.unitrip.global.auth.dto.AuthDto;
import com.example.unitrip.global.auth.exception.AuthErrorCode;
import com.example.unitrip.global.auth.jwt.JwtProvider;
import com.example.unitrip.global.auth.oauth.OAuthProvider;
import com.example.unitrip.global.auth.oauth.OAuthTokenVerifier;
import com.example.unitrip.global.auth.oauth.OAuthUserInfo;
import com.example.unitrip.global.auth.service.AuthService;
import com.example.unitrip.global.exception.GlobalException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

class AuthServiceTest {

    private UserRepository userRepository;
    private JwtProvider jwtProvider;
    private OAuthTokenVerifier kakaoVerifier;
    private AuthService authService;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        jwtProvider = mock(JwtProvider.class);
        kakaoVerifier = mock(OAuthTokenVerifier.class);
        given(kakaoVerifier.getProvider()).willReturn(OAuthProvider.KAKAO);
        given(jwtProvider.generateAccessToken(any(), any())).willReturn("access-jwt");
        given(jwtProvider.generateRefreshToken(any(), any())).willReturn("refresh-jwt");

        authService = new AuthService(userRepository, jwtProvider, List.of(kakaoVerifier));
    }

    @Test
    @DisplayName("신규 유저는 최소 유저로 생성되고 isNewUser=true, profileCompleted=false, userType=null")
    void loginNewUser() {
        given(kakaoVerifier.verify("oauth-token"))
                .willReturn(new OAuthUserInfo(OAuthProvider.KAKAO, "kakao-1", "new@test.com", "닉", null));
        given(userRepository.findByProviderAndProviderId(OAuthProvider.KAKAO, "kakao-1"))
                .willReturn(Optional.empty());
        given(userRepository.save(any(User.class))).willAnswer(inv -> {
            User u = inv.getArgument(0);
            ReflectionTestUtils.setField(u, "id", 10L);
            return u;
        });

        var res = authService.login(new AuthDto.LoginRequest(OAuthProvider.KAKAO, "oauth-token"));

        assertThat(res.accessToken()).isEqualTo("access-jwt");
        assertThat(res.refreshToken()).isEqualTo("refresh-jwt");
        assertThat(res.isNewUser()).isTrue();
        assertThat(res.profileCompleted()).isFalse();
        assertThat(res.userType()).isNull();
        // JWT subject는 userId
        verify(jwtProvider).generateAccessToken(eq("10"), any());
        verify(userRepository).save(any(User.class));
    }

    @Test
    @DisplayName("기존 유저는 생성하지 않고 isNewUser=false, 저장된 userType/profileCompleted 반환")
    void loginExistingUser() {
        User user = User.builder().provider(OAuthProvider.KAKAO).providerId("kakao-1")
                .email("old@test.com").nickname("닉").userType(UserType.KOREAN_STUDENT).build();
        ReflectionTestUtils.setField(user, "id", 7L);
        ReflectionTestUtils.setField(user, "profileCompleted", true);

        given(kakaoVerifier.verify("oauth-token"))
                .willReturn(new OAuthUserInfo(OAuthProvider.KAKAO, "kakao-1", "old@test.com", "닉", null));
        given(userRepository.findByProviderAndProviderId(OAuthProvider.KAKAO, "kakao-1"))
                .willReturn(Optional.of(user));

        var res = authService.login(new AuthDto.LoginRequest(OAuthProvider.KAKAO, "oauth-token"));

        assertThat(res.isNewUser()).isFalse();
        assertThat(res.profileCompleted()).isTrue();
        assertThat(res.userType()).isEqualTo(UserType.KOREAN_STUDENT);
        verify(jwtProvider).generateAccessToken(eq("7"), any());
        verify(userRepository, never()).save(any());
    }

    @Test
    @DisplayName("등록되지 않은 제공자는 UNSUPPORTED_PROVIDER 예외")
    void loginUnsupportedProvider() {
        assertThatThrownBy(() ->
                authService.login(new AuthDto.LoginRequest(OAuthProvider.GOOGLE, "oauth-token")))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(AuthErrorCode.UNSUPPORTED_PROVIDER);
    }

    @Test
    @DisplayName("provider가 null이면 UNSUPPORTED_PROVIDER 예외")
    void loginNullProvider() {
        assertThatThrownBy(() ->
                authService.login(new AuthDto.LoginRequest(null, "oauth-token")))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(AuthErrorCode.UNSUPPORTED_PROVIDER);
    }
}
