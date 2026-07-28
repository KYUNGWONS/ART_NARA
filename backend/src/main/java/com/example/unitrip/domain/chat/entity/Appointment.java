package com.example.unitrip.domain.chat.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "appointments")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Builder
@AllArgsConstructor
public class Appointment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chat_room_id", nullable = false)
    private ChatRoom chatRoom;

    @Column(nullable = false)
    private Long requesterId;

    @Column(nullable = false)
    private Long responderId;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AppointmentStatus status = AppointmentStatus.PENDING;

    private LocalDateTime appointmentTime;

    private String location;

    @CreationTimestamp
    private LocalDateTime createdAt;

    public void accept() {
        this.status = AppointmentStatus.ACCEPTED;
    }

    public void reject() {
        this.status = AppointmentStatus.REJECTED;
    }
}