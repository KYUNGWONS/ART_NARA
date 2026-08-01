package com.example.artnara.domain.chat.dto;

import com.example.artnara.domain.chat.entity.ChatMessage;
import com.example.artnara.domain.chat.entity.ChatRoom;
import com.example.artnara.domain.chat.entity.ChatRoomStatus;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.entity.UserType;
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

    @Schema(description = "상대방 닉네임 (대기 중이면 null)", example = "김예진")
    private String opponentNickname;

    @Schema(description = "상대방 프로필 이미지", example = "https://cdn.artnara.com/profile/yejin.jpg")
    private String opponentProfileImageUrl;

    @Schema(description = "상대방 역할 (KOREAN_STUDENT: 작가, FOREIGN_TOURIST: 컬렉터)", example = "KOREAN_STUDENT")
    private UserType opponentUserType;

    @Schema(description = "마지막 메시지 내용", example = "작품 실물로 볼 수 있을까요?")
    private String lastMessage;

    @Schema(description = "마지막 메시지 시각", example = "2026-03-16T12:30:00")
    private LocalDateTime lastMessageAt;

    public static ChatRoomResponse of(ChatRoom room, Long myUserId) {
        return of(room, myUserId, null, null);
    }

    /**
     * 목록 화면용. 상대 프로필과 마지막 메시지를 함께 채운다(둘 다 nullable).
     */
    public static ChatRoomResponse of(ChatRoom room, Long myUserId, User opponent, ChatMessage lastMessage) {
        return ChatRoomResponse.builder()
                .roomId(room.getId())
                .creatorId(room.getCreatorId())
                .joinerId(room.getJoinerId())
                .opponentId(room.getOpponentId(myUserId))
                .status(room.getStatus())
                .creatorLeft(room.isCreatorLeft())
                .joinerLeft(room.isJoinerLeft())
                .createdAt(room.getCreatedAt())
                .opponentNickname(opponent != null ? opponent.getNickname() : null)
                .opponentProfileImageUrl(opponent != null ? opponent.getProfileImageUrl() : null)
                .opponentUserType(opponent != null ? opponent.getUserType() : null)
                .lastMessage(lastMessage != null ? lastMessage.getContent() : null)
                .lastMessageAt(lastMessage != null ? lastMessage.getCreatedAt() : null)
                .build();
    }
}
