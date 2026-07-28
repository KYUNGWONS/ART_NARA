package com.example.unitrip.domain.booking.entity;

import com.example.unitrip.domain.content.entity.Content;
import com.example.unitrip.domain.user.entity.User;
import com.example.unitrip.global.common.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@Entity
@Table(name = "bookings")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Booking extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "content_id")
    private Content content;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "guest_id")
    private User guest;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "mate_id")
    private User mate;

    @Column(nullable = false)
    private LocalDate date;

    private LocalTime startTime;
    private LocalTime endTime;

    @Column(nullable = false)
    private Integer totalPrice;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private BookingStatus status;

    @Builder
    public Booking(Content content, User guest, User mate, LocalDate date,
                   LocalTime startTime, LocalTime endTime, Integer totalPrice) {
        this.content = content;
        this.guest = guest;
        this.mate = mate;
        this.date = date;
        this.startTime = startTime;
        this.endTime = endTime;
        this.totalPrice = totalPrice;
        this.status = BookingStatus.PENDING_PAYMENT;
    }

    public void confirm() { this.status = BookingStatus.CONFIRMED; }
    public void cancel() { this.status = BookingStatus.CANCELLED; }
    public void complete() { this.status = BookingStatus.COMPLETED; }
}
