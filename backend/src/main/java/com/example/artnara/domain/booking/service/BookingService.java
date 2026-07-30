package com.example.artnara.domain.booking.service;

import com.example.artnara.domain.booking.dto.BookingDto;
import com.example.artnara.domain.booking.entity.Booking;
import com.example.artnara.domain.booking.entity.BookingStatus;
import com.example.artnara.domain.booking.repository.BookingRepository;
import com.example.artnara.domain.content.entity.Content;
import com.example.artnara.domain.content.repository.ContentRepository;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BookingService {

    private final BookingRepository bookingRepository;
    private final ContentRepository contentRepository;
    private final UserRepository userRepository;

    @Transactional
    public BookingDto.Response create(BookingDto.CreateRequest req) {
        Content content = contentRepository.findById(req.contentId())
                .orElseThrow(() -> new GlobalException(DomainResultCode.CONTENT_NOT_FOUND));
        User guest = userRepository.findById(req.guestId())
                .orElseThrow(() -> new GlobalException(DomainResultCode.USER_NOT_FOUND));

        if (bookingRepository.existsByGuestIdAndContentIdAndDateAndStatusNot(
                req.guestId(), req.contentId(), req.date(), BookingStatus.CANCELLED)) {
            throw new GlobalException(DomainResultCode.BOOKING_DUPLICATE);
        }

        Booking booking = Booking.builder()
                .content(content)
                .guest(guest)
                .mate(content.getAuthor())
                .date(req.date())
                .startTime(req.startTime())
                .endTime(req.endTime())
                .totalPrice(req.totalPrice())
                .build();
        return BookingDto.Response.from(bookingRepository.save(booking));
    }

    public BookingDto.Response get(Long id) {
        return BookingDto.Response.from(find(id));
    }

    public List<BookingDto.Response> listByGuest(Long guestId) {
        return bookingRepository.findAllByGuestId(guestId).stream()
                .map(BookingDto.Response::from).toList();
    }

    public List<BookingDto.Response> listByMate(Long mateId) {
        return bookingRepository.findAllByMateId(mateId).stream()
                .map(BookingDto.Response::from).toList();
    }

    /**
     * 홈 달력용: 로그인 유저 본인이 관련된(guest 또는 mate) 약속을 기간(from~to)으로 조회한다.
     * 각 항목의 상대방(mateName/mateUserId)은 viewer=userId 기준으로 계산된다.
     */
    public List<BookingDto.AppointmentResponse> listMyAppointments(Long userId, LocalDate from, LocalDate to) {
        return bookingRepository.findMineBetween(userId, from, to).stream()
                .map(b -> BookingDto.AppointmentResponse.from(b, userId)).toList();
    }


    @Transactional
    public void confirm(Long id) { find(id).confirm(); }

    @Transactional
    public void cancel(Long id) { find(id).cancel(); }

    @Transactional
    public void complete(Long id) { find(id).complete(); }

    private Booking find(Long id) {
        return bookingRepository.findById(id)
                .orElseThrow(() -> new GlobalException(DomainResultCode.BOOKING_NOT_FOUND));
    }
}
