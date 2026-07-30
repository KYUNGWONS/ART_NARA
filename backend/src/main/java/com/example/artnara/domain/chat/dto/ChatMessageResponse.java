package com.example.artnara.domain.chat.dto;

import com.example.artnara.domain.chat.entity.ChatMessage;
import com.example.artnara.domain.chat.entity.MessageType;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
@Schema(description = "채팅 메시지 응답")
public class ChatMessageResponse {

    @Schema(description = "메시지 ID", example = "1")
    private Long id;

    @Schema(description = "채팅방 ID", example = "1")
    private Long roomId;

    @Schema(description = "보낸 사용자 ID", example = "1")
    private Long senderId;

    @Schema(description = "메시지 내용", example = "안녕하세요!")
    private String content;

    @Schema(description = "메시지 타입", example = "TEXT")
    private MessageType messageType;

    @Schema(description = "읽음 여부", example = "false")
    private boolean read;

    @Schema(description = "메시지 생성 시간", example = "2026-03-16T12:00:00")
    private LocalDateTime createdAt;

    public static ChatMessageResponse from(ChatMessage message) {
        return ChatMessageResponse.builder()
                .id(message.getId())
                .roomId(message.getChatRoom().getId())
                .senderId(message.getSenderId())
                .content(message.getContent())
                .messageType(message.getMessageType())
                .read(message.isRead())
                .createdAt(message.getCreatedAt())
                .build();
    }
}