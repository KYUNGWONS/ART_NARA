package com.example.artnara.domain.chat.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@Schema(description = "약속 생성 요청 (WebSocket /app/chat/appointment/request)")
public class AppointmentRequest {

    @Schema(description = "약속을 생성할 채팅방 ID", example = "1")
    private Long roomId;

    @Schema(description = "약속을 요청하는 사용자 ID", example = "1")
    private Long requesterId;

    @Schema(description = "약속 응답 대상 사용자 ID", example = "2")
    private Long responderId;

    @Schema(description = "약속 시간", example = "2026-03-20T14:00:00")
    private LocalDateTime appointmentTime;

    @Schema(description = "약속 장소", example = "서울역 1번 출구")
    private String location;
}