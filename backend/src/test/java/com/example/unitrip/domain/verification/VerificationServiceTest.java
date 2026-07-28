package com.example.unitrip.domain.verification;

import com.example.unitrip.domain.user.entity.User;
import com.example.unitrip.domain.user.entity.UserType;
import com.example.unitrip.domain.user.repository.UserRepository;
import com.example.unitrip.domain.verification.dto.VerificationDto;
import com.example.unitrip.domain.verification.entity.Verification;
import com.example.unitrip.domain.verification.entity.VerificationStatus;
import com.example.unitrip.domain.verification.entity.VerificationType;
import com.example.unitrip.domain.verification.repository.VerificationRepository;
import com.example.unitrip.domain.verification.service.VerificationService;
import com.example.unitrip.global.common.DomainResultCode;
import com.example.unitrip.global.exception.GlobalException;
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

@ExtendWith(MockitoExtension.class)
class VerificationServiceTest {

    @Mock VerificationRepository verificationRepository;
    @Mock UserRepository userRepository;
    @InjectMocks VerificationService verificationService;

    private User createUser() {
        User u = User.builder().email("u@t.com").nickname("u").userType(UserType.KOREAN_STUDENT).build();
        ReflectionTestUtils.setField(u, "id", 1L);
        return u;
    }

    private Verification createVerification(User user) {
        Verification v = Verification.builder().user(user)
                .type(VerificationType.UNIVERSITY).documentUrl("https://doc.jpg").build();
        ReflectionTestUtils.setField(v, "id", 10L);
        return v;
    }

    @Test
    @DisplayName("인증 제출")
    void submit() {
        User user = createUser();
        Verification v = createVerification(user);
        given(userRepository.findById(1L)).willReturn(Optional.of(user));
        given(verificationRepository.save(any(Verification.class))).willReturn(v);

        var req = new VerificationDto.SubmitRequest(1L, VerificationType.UNIVERSITY, "https://doc.jpg");
        VerificationDto.Response res = verificationService.submit(req);
        assertThat(res.status()).isEqualTo(VerificationStatus.PENDING);
    }

    @Test
    @DisplayName("사용자별 인증 목록 조회")
    void listByUser() {
        User user = createUser();
        given(verificationRepository.findAllByUserId(1L)).willReturn(List.of(createVerification(user)));
        assertThat(verificationService.listByUser(1L)).hasSize(1);
    }

    @Test
    @DisplayName("인증 승인")
    void approve() {
        User user = createUser();
        Verification v = createVerification(user);
        given(verificationRepository.findById(10L)).willReturn(Optional.of(v));

        verificationService.approve(10L);
        assertThat(v.getStatus()).isEqualTo(VerificationStatus.APPROVED);
    }

    @Test
    @DisplayName("인증 반려")
    void reject() {
        User user = createUser();
        Verification v = createVerification(user);
        given(verificationRepository.findById(10L)).willReturn(Optional.of(v));

        verificationService.reject(10L, new VerificationDto.RejectRequest("불명확"));
        assertThat(v.getStatus()).isEqualTo(VerificationStatus.REJECTED);
        assertThat(v.getRejectReason()).isEqualTo("불명확");
    }

    @Test
    @DisplayName("없는 인증 조회 시 예외")
    void notFound() {
        given(verificationRepository.findById(99L)).willReturn(Optional.empty());
        assertThatThrownBy(() -> verificationService.approve(99L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.VERIFICATION_NOT_FOUND);
    }
}
