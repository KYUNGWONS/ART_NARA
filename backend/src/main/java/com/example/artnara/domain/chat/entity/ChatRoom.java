package com.example.artnara.domain.chat.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "chat_rooms")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Builder
@AllArgsConstructor
public class ChatRoom {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 방 만든 사람 (한국인이든 외국인이든 무관)
    @Column(nullable = false)
    private Long creatorId;

    // 참여한 사람 - 참여 전까지 null
    private Long joinerId;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ChatRoomStatus status = ChatRoomStatus.WAITING;

    @Builder.Default
    @Column(nullable = false)
    private boolean creatorLeft = false;

    @Builder.Default
    @Column(nullable = false)
    private boolean joinerLeft = false;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @Builder.Default
    @OneToMany(mappedBy = "chatRoom", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ChatMessage> messages = new ArrayList<>();

    @Builder.Default
    @OneToMany(mappedBy = "chatRoom", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Appointment> appointments = new ArrayList<>();

    // 상대방 참여
    public void join(Long joinerId) {
        this.joinerId = joinerId;
        this.status = ChatRoomStatus.ACTIVE;
    }

    public void leave(Long userId) {
        if (userId.equals(creatorId)) {
            this.creatorLeft = true;
        } else if (userId.equals(joinerId)) {
            this.joinerLeft = true;
        }
        if (creatorLeft && joinerLeft) {
            this.status = ChatRoomStatus.CLOSED;
        }
    }

    public Long getOpponentId(Long myUserId) {
        return myUserId.equals(creatorId) ? joinerId : creatorId;
    }
}