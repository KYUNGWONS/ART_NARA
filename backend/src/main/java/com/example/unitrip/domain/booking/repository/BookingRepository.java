package com.example.unitrip.domain.booking.repository;

import com.example.unitrip.domain.booking.entity.Booking;
import com.example.unitrip.domain.booking.entity.BookingStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface BookingRepository extends JpaRepository<Booking, Long> {
    List<Booking> findAllByGuestId(Long guestId);
    List<Booking> findAllByMateId(Long mateId);
    boolean existsByGuestIdAndContentIdAndDateAndStatusNot(
            Long guestId, Long contentId, LocalDate date, BookingStatus status);

    // 홈 달력용: 로그인 유저가 guest이든 mate이든 본인이 관련된 약속을 기간(from~to)으로 조회
    @Query("""
            select b from Booking b
            where (b.guest.id = :userId or b.mate.id = :userId)
              and b.date between :from and :to
            order by b.date asc, b.startTime asc
            """)
    List<Booking> findMineBetween(@Param("userId") Long userId,
                                  @Param("from") LocalDate from,
                                  @Param("to") LocalDate to);
}
