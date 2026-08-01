package com.example.artnara.domain.chat.service;

import com.example.artnara.domain.chat.dto.*;
import com.example.artnara.domain.chat.entity.*;
import com.example.artnara.domain.chat.exception.ChatErrorCode;
import com.example.artnara.domain.chat.repository.*;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.notification.entity.NotificationType;
import com.example.artnara.domain.notification.service.NotificationService;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ChatService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final AppointmentRepository appointmentRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    // 방 생성 (자기 ID만으로 생성, 상대 대기)
    @Transactional
    public ChatRoomResponse createRoom(Long creatorId) {
        ChatRoom room = chatRoomRepository.save(
                ChatRoom.builder()
                        .creatorId(creatorId)
                        .build()
        );
        return ChatRoomResponse.of(room, creatorId);
    }

    // 대기 중인 방 목록
    public List<ChatRoomResponse> getWaitingRooms(Long myUserId) {
        return chatRoomRepository.findByStatus(ChatRoomStatus.WAITING)
                .stream()
                .filter(room -> !room.getCreatorId().equals(myUserId)) // 내가 만든 방 제외
                .map(room -> ChatRoomResponse.of(room, myUserId))
                .toList();
    }

    /**
     * 작품 문의용 1:1 방 열기. 이미 두 사람 사이의 방이 있으면 그 방을 돌려준다.
     * 상대는 닉네임(작품의 작가명)으로 찾는다.
     */
    @Transactional
    public ChatRoomResponse openDirectRoom(Long myUserId, String opponentNickname) {
        User opponent = userRepository.findFirstByNickname(opponentNickname)
                .orElseThrow(() -> new GlobalException(DomainResultCode.USER_NOT_FOUND));
        if (opponent.getId().equals(myUserId)) {
            throw new GlobalException(ChatErrorCode.CANNOT_JOIN_OWN_ROOM);
        }
        ChatRoom room = chatRoomRepository.findBetween(myUserId, opponent.getId()).stream()
                .findFirst()
                .orElseGet(() -> chatRoomRepository.save(ChatRoom.builder()
                        .creatorId(myUserId)
                        .build()));
        if (room.getJoinerId() == null) {
            room.join(opponent.getId());
        }
        ChatMessage lastMessage = chatMessageRepository
                .findFirstByChatRoomIdOrderByCreatedAtDesc(room.getId())
                .orElse(null);
        return ChatRoomResponse.of(room, myUserId, opponent, lastMessage);
    }

    // 방 참여
    @Transactional
    public ChatRoomResponse joinRoom(Long roomId, Long joinerId) {
        ChatRoom room = chatRoomRepository.findById(roomId)
                .orElseThrow(() -> new GlobalException(ChatErrorCode.ROOM_NOT_FOUND));

        if (room.getStatus() != ChatRoomStatus.WAITING) {
            throw new GlobalException(ChatErrorCode.ROOM_NOT_WAITING);
        }
        if (room.getCreatorId().equals(joinerId)) {
            throw new GlobalException(ChatErrorCode.CANNOT_JOIN_OWN_ROOM);
        }

        room.join(joinerId);
        return ChatRoomResponse.of(room, joinerId);
    }

    // 내 채팅방 목록. 목록 화면에서 바로 그릴 수 있도록 상대 프로필과 마지막 메시지를 함께 채운다.
    public List<ChatRoomResponse> getMyChatRooms(Long userId) {
        return chatRoomRepository.findAllByUserId(userId)
                .stream()
                .map(room -> {
                    Long opponentId = room.getOpponentId(userId);
                    User opponent = opponentId != null
                            ? userRepository.findById(opponentId).orElse(null)
                            : null;
                    ChatMessage lastMessage = chatMessageRepository
                            .findFirstByChatRoomIdOrderByCreatedAtDesc(room.getId())
                            .orElse(null);
                    long unread = chatMessageRepository
                            .countByChatRoomIdAndSenderIdNotAndReadFalse(room.getId(), userId);
                    return ChatRoomResponse.of(room, userId, opponent, lastMessage, unread);
                })
                .toList();
    }

    /** 대화 내역 조회(본인이 참여한 방만). REST 진입 시 사용한다. */
    public List<ChatMessageResponse> getMessagesForParticipant(Long roomId, Long userId) {
        ChatRoom room = chatRoomRepository.findById(roomId)
                .orElseThrow(() -> new GlobalException(ChatErrorCode.ROOM_NOT_FOUND));
        boolean participant = userId.equals(room.getCreatorId()) || userId.equals(room.getJoinerId());
        if (!participant) {
            throw new GlobalException(ChatErrorCode.NOT_ROOM_PARTICIPANT);
        }
        return getMessages(roomId);
    }

    // 메시지 목록 조회
    public List<ChatMessageResponse> getMessages(Long roomId) {
        return chatMessageRepository.findByChatRoomIdOrderByCreatedAtAsc(roomId)
                .stream()
                .map(ChatMessageResponse::from)
                .toList();
    }

    // 메시지 전송
    @Transactional
    public ChatMessageResponse sendMessage(ChatMessageRequest request) {
        ChatRoom room = chatRoomRepository.findById(request.getRoomId())
                .orElseThrow(() -> new GlobalException(ChatErrorCode.ROOM_NOT_FOUND));

        ChatMessage message = ChatMessage.builder()
                .chatRoom(room)
                .senderId(request.getSenderId())
                .content(request.getContent())
                .messageType(request.getMessageType())
                .build();

        ChatMessage saved = chatMessageRepository.save(message);

        // 채팅 탭이 없는 구조라(디자인 6탭) 새 메시지는 알림으로도 알려준다.
        Long receiverId = room.getOpponentId(request.getSenderId());
        if (receiverId != null) {
            String sender = userRepository.findById(request.getSenderId())
                    .map(User::getNickname)
                    .orElse("상대방");
            notificationService.publishTo(receiverId, NotificationType.CHAT_MESSAGE,
                    sender + "님의 메시지",
                    saved.getContent().length() > 60
                            ? saved.getContent().substring(0, 60) + "…"
                            : saved.getContent(),
                    room.getId());
        }

        return ChatMessageResponse.from(saved);
    }

    // 읽음 처리
    @Transactional
    public List<Long> markMessagesAsRead(Long roomId, Long userId) {
        List<Long> unreadIds = chatMessageRepository.findUnreadMessageIds(roomId, userId);
        if (!unreadIds.isEmpty()) {
            chatMessageRepository.markAsRead(roomId, userId);
        }
        return unreadIds;
    }

    // 퇴장
    @Transactional
    public void leaveRoom(Long roomId, Long userId) {
        ChatRoom room = chatRoomRepository.findById(roomId)
                .orElseThrow(() -> new GlobalException(ChatErrorCode.ROOM_NOT_FOUND));
        room.leave(userId);
    }

    // 약속 요청
    @Transactional
    public AppointmentResponse requestAppointment(AppointmentRequest request) {
        ChatRoom room = chatRoomRepository.findById(request.getRoomId())
                .orElseThrow(() -> new GlobalException(ChatErrorCode.ROOM_NOT_FOUND));

        Appointment appointment = Appointment.builder()
                .chatRoom(room)
                .requesterId(request.getRequesterId())
                .responderId(request.getResponderId())
                .appointmentTime(request.getAppointmentTime())
                .location(request.getLocation())
                .build();

        appointment = appointmentRepository.save(appointment);

        ChatMessage msg = ChatMessage.builder()
                .chatRoom(room)
                .senderId(request.getRequesterId())
                .content("[약속 요청] 약속 잡기를 원합니다.")
                .messageType(MessageType.APPOINTMENT)
                .build();
        chatMessageRepository.save(msg);

        return AppointmentResponse.from(appointment);
    }

    // 약속 수락/거절
    @Transactional
    public AppointmentResponse respondToAppointment(AppointmentRespondRequest request) {
        Appointment appointment = appointmentRepository.findById(request.getAppointmentId())
                .orElseThrow(() -> new GlobalException(ChatErrorCode.APPOINTMENT_NOT_FOUND));

        if (request.isAccepted()) appointment.accept();
        else appointment.reject();

        return AppointmentResponse.from(appointment);
    }

    // 대기 중인 약속 목록
    public List<AppointmentResponse> getPendingAppointments(Long userId) {
        return appointmentRepository.findByResponderIdAndStatus(userId, AppointmentStatus.PENDING)
                .stream()
                .map(AppointmentResponse::from)
                .toList();
    }
}
