package com.example.unitrip.domain.booking.dto;

import com.example.unitrip.domain.booking.entity.Booking;
import com.example.unitrip.domain.booking.entity.BookingStatus;
import com.example.unitrip.domain.user.entity.User;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

public class BookingDto {

    private static final DateTimeFormatter HH_MM = DateTimeFormatter.ofPattern("HH:mm");

    @Schema(name = "BookingCreateRequest")
    public record CreateRequest(
            Long contentId,
            Long guestId,
            LocalDate date,
            LocalTime startTime,
            LocalTime endTime,
            Integer totalPrice
    ) {}

    @Schema(name = "BookingResponse")
    public record Response(
            Long id,
            Long contentId,
            String contentTitle,
            Long guestId,
            Long mateId,
            String mateNickname,
            LocalDate date,
            LocalTime startTime,
            LocalTime endTime,
            Integer totalPrice,
            BookingStatus status
    ) {
        public static Response from(Booking b) {
            return new Response(
                    b.getId(), b.getContent().getId(), b.getContent().getTitle(),
                    b.getGuest().getId(), b.getMate().getId(), b.getMate().getNickname(),
                    b.getDate(), b.getStartTime(), b.getEndTime(),
                    b.getTotalPrice(), b.getStatus()
            );
        }
    }

    /**
     * 홈 달력용 약속 아이템. mateName/mateUserId는 '로그인 유저(viewer) 기준 상대방'이다.
     * viewer가 guest면 상대는 mate, viewer가 mate면 상대는 guest.
     */
    public record AppointmentResponse(
            Long appointmentId,
            LocalDate date,
            String mateName,
            Long mateUserId,
            String place,
            String contentTitle,
            String startTime,
            String endTime,
            String status
    ) {
        public static AppointmentResponse from(Booking b, Long viewerId) {
            User counterpart = b.getGuest().getId().equals(viewerId) ? b.getMate() : b.getGuest();
            return new AppointmentResponse(
                    b.getId(),
                    b.getDate(),
                    counterpart.getNickname(),
                    counterpart.getId(),
                    b.getContent().getMeetingPoint(),
                    b.getContent().getTitle(),
                    formatTime(b.getStartTime()),
                    formatTime(b.getEndTime()),
                    toStatus(b.getStatus())
            );
        }

        private static String formatTime(LocalTime t) {
            return t == null ? null : t.format(HH_MM);
        }

        // 결제 대기(PENDING_PAYMENT)도 달력에선 예정된 약속이므로 PENDING으로 노출
        private static String toStatus(BookingStatus s) {
            return s == BookingStatus.PENDING_PAYMENT ? "PENDING" : s.name();
        }
    }
}
