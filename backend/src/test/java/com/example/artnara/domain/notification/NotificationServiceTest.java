package com.example.artnara.domain.notification;

import com.example.artnara.domain.notification.dto.NotificationDto;
import com.example.artnara.domain.notification.entity.Notification;
import com.example.artnara.domain.notification.entity.NotificationType;
import com.example.artnara.domain.notification.repository.NotificationRepository;
import com.example.artnara.domain.notification.service.NotificationService;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.entity.UserType;
import com.example.artnara.domain.user.repository.UserRepository;
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
class NotificationServiceTest {

    @Mock NotificationRepository notificationRepository;
    @Mock UserRepository userRepository;
    @InjectMocks NotificationService notificationService;

    private User createUser() {
        User u = User.builder().email("u@t.com").nickname("u").userType(UserType.KOREAN_STUDENT).build();
        ReflectionTestUtils.setField(u, "id", 1L);
        return u;
    }

    private Notification createNotification(User user) {
        Notification n = Notification.builder().user(user)
                .type(NotificationType.BOOKING_CONFIRMED).title("예약 확정").body("body").build();
        ReflectionTestUtils.setField(n, "id", 10L);
        return n;
    }

    @Test
    @DisplayName("알림 생성")
    void create() {
        User user = createUser();
        Notification noti = createNotification(user);
        given(userRepository.findById(1L)).willReturn(Optional.of(user));
        given(notificationRepository.save(any(Notification.class))).willReturn(noti);

        var req = new NotificationDto.CreateRequest(1L, NotificationType.BOOKING_CONFIRMED, "예약 확정", "body");
        assertThat(notificationService.create(req).title()).isEqualTo("예약 확정");
    }

    @Test
    @DisplayName("알림 목록 조회")
    void list() {
        User user = createUser();
        given(notificationRepository.findAllByUserIdOrderByCreatedAtDesc(1L))
                .willReturn(List.of(createNotification(user)));
        assertThat(notificationService.list(1L)).hasSize(1);
    }

    @Test
    @DisplayName("미읽음 개수 조회")
    void unreadCount() {
        given(notificationRepository.countByUserIdAndReadFalse(1L)).willReturn(3L);
        assertThat(notificationService.unreadCount(1L)).isEqualTo(3L);
    }

    @Test
    @DisplayName("읽음 처리")
    void markRead() {
        User user = createUser();
        Notification noti = createNotification(user);
        given(notificationRepository.findById(10L)).willReturn(Optional.of(noti));

        notificationService.markRead(10L);
        assertThat(noti.isRead()).isTrue();
    }

    @Test
    @DisplayName("없는 알림 읽음 처리 시 예외")
    void markReadNotFound() {
        given(notificationRepository.findById(99L)).willReturn(Optional.empty());
        assertThatThrownBy(() -> notificationService.markRead(99L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.NOTIFICATION_NOT_FOUND);
    }

    @Test
    @DisplayName("알림 삭제")
    void delete() {
        notificationService.delete(10L);
        verify(notificationRepository).deleteById(10L);
    }
}
