package com.example.unitrip.domain.chat.dto;

import com.example.unitrip.domain.chat.entity.MessageType;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@Schema(description = "채팅 메시지 전송 요청 (WebSocket /app/chat/send)")
public class ChatMessageRequest {

    @Schema(description = "채팅방 ID", example = "1")
    private Long roomId;

    @Schema(description = "메시지 보내는 사용자 ID", example = "1")
    private Long senderId;

    @Schema(description = "메시지 내용", example = "안녕하세요!")
    private String content;

    @Schema(description = "메시지 타입", example = "TEXT")
    private MessageType messageType;
}