package com.example.unitrip.domain.chat.dto;

import com.example.unitrip.domain.chat.entity.Appointment;
import com.example.unitrip.domain.chat.entity.AppointmentStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
@Schema(description = "약속 응답")
public class AppointmentResponse {

    @Schema(description = "약속 ID", example = "1")
    private Long id;

    @Schema(description = "채팅방 ID", example = "1")
    private Long roomId;

    @Schema(description = "약속 요청자 ID", example = "1")
    private Long requesterId;

    @Schema(description = "약속 응답자 ID", example = "2")
    private Long responderId;

    @Schema(description = "약속 상태 (PENDING: 대기, ACCEPTED: 수락, REJECTED: 거절)", example = "PENDING")
    private AppointmentStatus status;

    @Schema(description = "약속 시간", example = "2026-03-20T14:00:00")
    private LocalDateTime appointmentTime;

    @Schema(description = "약속 장소", example = "서울역 1번 출구")
    private String location;

    @Schema(description = "약속 생성 시간", example = "2026-03-16T12:00:00")
    private LocalDateTime createdAt;

    public static AppointmentResponse from(Appointment appointment) {
        return AppointmentResponse.builder()
                .id(appointment.getId())
                .roomId(appointment.getChatRoom().getId())
                .requesterId(appointment.getRequesterId())
                .responderId(appointment.getResponderId())
                .status(appointment.getStatus())
                .appointmentTime(appointment.getAppointmentTime())
                .location(appointment.getLocation())
                .createdAt(appointment.getCreatedAt())
                .build();
    }
}