package com.example.unitrip.domain.chat.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@Schema(description = "약속 수락/거절 요청 (WebSocket /app/chat/appointment/respond)")
public class AppointmentRespondRequest {

    @Schema(description = "응답할 약속 ID", example = "1")
    private Long appointmentId;

    @Schema(description = "채팅방 ID", example = "1")
    private Long roomId;

    @Schema(description = "수락 여부 (true: 수락, false: 거절)", example = "true")
    private boolean accepted;
}