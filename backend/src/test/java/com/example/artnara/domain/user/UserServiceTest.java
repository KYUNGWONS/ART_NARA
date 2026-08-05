package com.example.artnara.domain.user;

import com.example.artnara.domain.user.dto.UserDto;
import com.example.artnara.domain.user.entity.Sido;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.entity.UserType;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.domain.user.service.UserService;
import com.example.artnara.domain.verification.entity.VerificationStatus;
import com.example.artnara.domain.verification.entity.VerificationType;
import com.example.artnara.domain.verification.repository.VerificationRepository;
import com.example.artnara.global.auth.oauth.OAuthProvider;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock UserRepository userRepository;
    @Mock VerificationRepository verificationRepository;
    @InjectMocks UserService userService;

    private User createUser() {
        User user = User.builder()
                .email("test@test.com").nickname("nick").displayName("재하정").age(25)
                .userType(UserType.KOREAN_STUDENT).region(Sido.SEOUL)
                .aboutMe("hi").interests(List.of("회화")).build();
        ReflectionTestUtils.setField(user, "id", 1L);
        return user;
    }

    @Test
    @DisplayName("프로필 설정(회원가입 완료) - 인증된 유저 프로필을 채우고 profileCompleted=true")
    void completeProfile() {
        // 로그인 시 생성된 최소 유저 (프로필 미완료)
        User user = User.ofOAuth(OAuthProvider.KAKAO, "kakao-1", "test@test.com", null, null);
        ReflectionTestUtils.setField(user, "id", 1L);
        given(userRepository.findById(1L)).willReturn(Optional.of(user));

        var req = new UserDto.CreateRequest("nick", "재하정", 25,
                UserType.KOREAN_STUDENT, "https://img/p.png", Sido.SEOUL, "hi", List.of("회화"));
        UserDto.Response res = userService.completeProfile(1L, req);

        assertThat(res.email()).isEqualTo("test@test.com");
        assertThat(res.nickname()).isEqualTo("nick");
        assertThat(res.displayName()).isEqualTo("재하정");
        assertThat(res.userType()).isEqualTo(UserType.KOREAN_STUDENT);
        assertThat(res.profileCompleted()).isTrue();
    }

    @Test
    @DisplayName("없는 유저의 프로필 설정 시 예외")
    void completeProfileNotFound() {
        given(userRepository.findById(99L)).willReturn(Optional.empty());

        var req = new UserDto.CreateRequest("nick", "재하정", 25,
                UserType.KOREAN_STUDENT, "https://img/p.png", Sido.SEOUL, "hi", List.of("회화"));

        assertThatThrownBy(() -> userService.completeProfile(99L, req))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.USER_NOT_FOUND);
    }

    @Test
    @DisplayName("사용자 조회 성공")
    void get() {
        given(userRepository.findById(1L)).willReturn(Optional.of(createUser()));
        UserDto.Response res = userService.get(1L);
        assertThat(res.id()).isEqualTo(1L);
    }

    @Test
    @DisplayName("조회 시 승인된 대학교 인증이 있으면 universityVerified=true")
    void getUniversityVerified() {
        given(userRepository.findById(1L)).willReturn(Optional.of(createUser()));
        given(verificationRepository.existsByUserIdAndTypeAndStatus(
                1L, VerificationType.UNIVERSITY, VerificationStatus.APPROVED)).willReturn(true);

        UserDto.Response res = userService.get(1L);

        assertThat(res.universityVerified()).isTrue();
    }

    @Test
    @DisplayName("승인된 대학교 인증이 없으면 universityVerified=false(미인증)")
    void getUniversityUnverified() {
        given(userRepository.findById(1L)).willReturn(Optional.of(createUser()));

        UserDto.Response res = userService.get(1L);

        assertThat(res.universityVerified()).isFalse();
    }

    @Test
    @DisplayName("없는 사용자 조회 시 예외")
    void getNotFound() {
        given(userRepository.findById(99L)).willReturn(Optional.empty());
        assertThatThrownBy(() -> userService.get(99L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.USER_NOT_FOUND);
    }

    @Test
    @DisplayName("사용자 프로필 수정")
    void update() {
        User user = createUser();
        given(userRepository.findById(1L)).willReturn(Optional.of(user));

        var req = new UserDto.UpdateRequest("newNick", null, null, null, null, null);
        UserDto.Response res = userService.update(1L, req);

        assertThat(res.nickname()).isEqualTo("newNick");
    }

    @Test
    @DisplayName("사용자 역할 전환")
    void updateUserType() {
        User user = createUser();
        given(userRepository.findById(1L)).willReturn(Optional.of(user));

        var req = new UserDto.UpdateRequest(null, null, null, null, null,
                UserType.FOREIGN_TOURIST);
        UserDto.Response res = userService.update(1L, req);

        assertThat(res.userType()).isEqualTo(UserType.FOREIGN_TOURIST);
    }

    @Test
    @DisplayName("사용자 삭제")
    void delete() {
        User user = createUser();
        given(userRepository.findById(1L)).willReturn(Optional.of(user));

        userService.delete(1L);
        verify(userRepository).delete(user);
    }
}
