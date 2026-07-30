package com.example.artnara.domain.booking;

import com.example.artnara.domain.booking.dto.BookingDto;
import com.example.artnara.domain.booking.entity.Booking;
import com.example.artnara.domain.booking.entity.BookingStatus;
import com.example.artnara.domain.booking.repository.BookingRepository;
import com.example.artnara.domain.booking.service.BookingService;
import com.example.artnara.domain.content.entity.Content;
import com.example.artnara.domain.content.entity.Theme;
import com.example.artnara.domain.content.repository.ContentRepository;
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

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;

@ExtendWith(MockitoExtension.class)
class BookingServiceTest {

    @Mock BookingRepository bookingRepository;
    @Mock ContentRepository contentRepository;
    @Mock UserRepository userRepository;
    @InjectMocks BookingService bookingService;

    private User createUser(Long id, String email, String nickname) {
        User user = User.builder().email(email).nickname(nickname)
                .userType(UserType.KOREAN_STUDENT).build();
        ReflectionTestUtils.setField(user, "id", id);
        return user;
    }

    private Content createContent(Long id, User author) {
        Content content = Content.builder().author(author).title("활동")
                .theme(Theme.PLACE).pricePerHour(10000).build();
        ReflectionTestUtils.setField(content, "id", id);
        return content;
    }

    private Booking createBooking(Long id, Content content, User guest, User mate) {
        Booking booking = Booking.builder()
                .content(content).guest(guest).mate(mate)
                .date(LocalDate.of(2026, 5, 1))
                .startTime(LocalTime.of(10, 0)).endTime(LocalTime.of(18, 0))
                .totalPrice(30000).build();
        ReflectionTestUtils.setField(booking, "id", id);
        return booking;
    }

    @Test
    @DisplayName("예약 생성 성공")
    void createSuccess() {
        User mate = createUser(1L, "m@t.com", "mate");
        User guest = createUser(2L, "g@t.com", "guest");
        Content content = createContent(10L, mate);

        given(contentRepository.findById(10L)).willReturn(Optional.of(content));
        given(userRepository.findById(2L)).willReturn(Optional.of(guest));
        given(bookingRepository.existsByGuestIdAndContentIdAndDateAndStatusNot(
                eq(2L), eq(10L), any(), any())).willReturn(false);

        Booking saved = createBooking(100L, content, guest, mate);
        given(bookingRepository.save(any(Booking.class))).willReturn(saved);

        var req = new BookingDto.CreateRequest(10L, 2L, LocalDate.of(2026, 5, 1),
                LocalTime.of(10, 0), LocalTime.of(18, 0), 30000);
        BookingDto.Response res = bookingService.create(req);

        assertThat(res.status()).isEqualTo(BookingStatus.PENDING_PAYMENT);
        assertThat(res.guestId()).isEqualTo(2L);
    }

    @Test
    @DisplayName("중복 예약 시 예외")
    void createDuplicate() {
        User mate = createUser(1L, "m@t.com", "mate");
        User guest = createUser(2L, "g@t.com", "guest");
        Content content = createContent(10L, mate);

        given(contentRepository.findById(10L)).willReturn(Optional.of(content));
        given(userRepository.findById(2L)).willReturn(Optional.of(guest));
        given(bookingRepository.existsByGuestIdAndContentIdAndDateAndStatusNot(
                eq(2L), eq(10L), any(), any())).willReturn(true);

        var req = new BookingDto.CreateRequest(10L, 2L, LocalDate.of(2026, 5, 1),
                null, null, 30000);

        assertThatThrownBy(() -> bookingService.create(req))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.BOOKING_DUPLICATE);
    }

    @Test
    @DisplayName("예약 조회 성공")
    void get() {
        User mate = createUser(1L, "m@t.com", "mate");
        User guest = createUser(2L, "g@t.com", "guest");
        Content content = createContent(10L, mate);
        Booking booking = createBooking(100L, content, guest, mate);
        given(bookingRepository.findById(100L)).willReturn(Optional.of(booking));

        BookingDto.Response res = bookingService.get(100L);
        assertThat(res.id()).isEqualTo(100L);
    }

    @Test
    @DisplayName("없는 예약 조회 시 예외")
    void getNotFound() {
        given(bookingRepository.findById(99L)).willReturn(Optional.empty());
        assertThatThrownBy(() -> bookingService.get(99L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.BOOKING_NOT_FOUND);
    }

    @Test
    @DisplayName("예약 확정")
    void confirm() {
        User mate = createUser(1L, "m@t.com", "mate");
        User guest = createUser(2L, "g@t.com", "guest");
        Booking booking = createBooking(100L, createContent(10L, mate), guest, mate);
        given(bookingRepository.findById(100L)).willReturn(Optional.of(booking));

        bookingService.confirm(100L);
        assertThat(booking.getStatus()).isEqualTo(BookingStatus.CONFIRMED);
    }

    @Test
    @DisplayName("예약 취소")
    void cancel() {
        User mate = createUser(1L, "m@t.com", "mate");
        User guest = createUser(2L, "g@t.com", "guest");
        Booking booking = createBooking(100L, createContent(10L, mate), guest, mate);
        given(bookingRepository.findById(100L)).willReturn(Optional.of(booking));

        bookingService.cancel(100L);
        assertThat(booking.getStatus()).isEqualTo(BookingStatus.CANCELLED);
    }

    @Test
    @DisplayName("홈 달력 - 상대방은 viewer 기준(mate가 보면 guest, guest가 보면 mate) + 시간/상태 매핑")
    void listMyAppointmentsViewerRelative() {
        User mate = createUser(1L, "m@t.com", "재협");
        User guest = createUser(2L, "g@t.com", "Matthew");
        Content content = Content.builder().author(mate).title("한옥마을 투어")
                .theme(Theme.PLACE).meetingPoint("홍대입구역 2번 출구").pricePerHour(10000).build();
        ReflectionTestUtils.setField(content, "id", 10L);
        Booking b = createBooking(100L, content, guest, mate); // 2026-05-01 10:00~18:00, PENDING_PAYMENT
        given(bookingRepository.findMineBetween(eq(1L), any(), any())).willReturn(List.of(b));
        given(bookingRepository.findMineBetween(eq(2L), any(), any())).willReturn(List.of(b));

        LocalDate from = LocalDate.of(2026, 5, 1);
        LocalDate to = LocalDate.of(2026, 5, 31);

        // viewer = mate(재협) → 상대 = guest(Matthew)
        var asMate = bookingService.listMyAppointments(1L, from, to);
        assertThat(asMate).hasSize(1);
        var item = asMate.get(0);
        assertThat(item.mateName()).isEqualTo("Matthew");
        assertThat(item.mateUserId()).isEqualTo(2L);
        assertThat(item.place()).isEqualTo("홍대입구역 2번 출구");
        assertThat(item.contentTitle()).isEqualTo("한옥마을 투어");
        assertThat(item.startTime()).isEqualTo("10:00");
        assertThat(item.endTime()).isEqualTo("18:00");
        assertThat(item.status()).isEqualTo("PENDING"); // PENDING_PAYMENT → PENDING

        // viewer = guest(Matthew) → 상대 = mate(재협)
        var asGuest = bookingService.listMyAppointments(2L, from, to);
        assertThat(asGuest.get(0).mateName()).isEqualTo("재협");
        assertThat(asGuest.get(0).mateUserId()).isEqualTo(1L);
    }

    @Test
    @DisplayName("게스트별 목록 조회")
    void listByGuest() {
        User mate = createUser(1L, "m@t.com", "mate");
        User guest = createUser(2L, "g@t.com", "guest");
        Booking b = createBooking(100L, createContent(10L, mate), guest, mate);
        given(bookingRepository.findAllByGuestId(2L)).willReturn(List.of(b));

        List<BookingDto.Response> res = bookingService.listByGuest(2L);
        assertThat(res).hasSize(1);
    }
}
