package com.example.unitrip.domain.chat.dto;

import com.example.unitrip.domain.chat.entity.ChatRoom;
import com.example.unitrip.domain.chat.entity.ChatRoomStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
@Schema(description = "채팅방 응답")
public class ChatRoomResponse {

    @Schema(description = "채팅방 ID", example = "1")
    private Long roomId;

    @Schema(description = "방 생성자 ID", example = "1")
    private Long creatorId;

    @Schema(description = "참여자 ID (대기 중이면 null)", example = "2")
    private Long joinerId;

    @Schema(description = "나 기준 상대방 ID (대기 중이면 null)", example = "2")
    private Long opponentId;

    @Schema(description = "채팅방 상태 (WAITING: 대기, ACTIVE: 진행 중, CLOSED: 종료)", example = "ACTIVE")
    private ChatRoomStatus status;

    @Schema(description = "방 생성자 퇴장 여부", example = "false")
    private boolean creatorLeft;

    @Schema(description = "참여자 퇴장 여부", example = "false")
    private boolean joinerLeft;

    @Schema(description = "채팅방 생성 시간", example = "2026-03-16T12:00:00")
    private LocalDateTime createdAt;

    public static ChatRoomResponse of(ChatRoom room, Long myUserId) {
        return ChatRoomResponse.builder()
                .roomId(room.getId())
                .creatorId(room.getCreatorId())
                .joinerId(room.getJoinerId())
                .opponentId(room.getOpponentId(myUserId))
                .status(room.getStatus())
                .creatorLeft(room.isCreatorLeft())
                .joinerLeft(room.isJoinerLeft())
                .createdAt(room.getCreatedAt())
                .build();
    }
}
