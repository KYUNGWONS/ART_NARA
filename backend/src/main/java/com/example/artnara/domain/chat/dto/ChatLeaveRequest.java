package com.example.artnara.domain.chat.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@Schema(description = "채팅방 퇴장 요청 (WebSocket /app/chat/leave)")
public class ChatLeaveRequest {

    @Schema(description = "퇴장할 채팅방 ID", example = "1")
    private Long roomId;

    @Schema(description = "퇴장하는 사용자 ID", example = "1")
    private Long userId;
}