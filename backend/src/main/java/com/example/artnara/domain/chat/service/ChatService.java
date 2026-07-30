package com.example.artnara.domain.chat.service;

import com.example.artnara.domain.chat.dto.*;
import com.example.artnara.domain.chat.entity.*;
import com.example.artnara.domain.chat.exception.ChatErrorCode;
import com.example.artnara.domain.chat.repository.*;
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

    // 내 채팅방 목록
    public List<ChatRoomResponse> getMyChatRooms(Long userId) {
        return chatRoomRepository.findAllByUserId(userId)
                .stream()
                .map(room -> ChatRoomResponse.of(room, userId))
                .toList();
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

        return ChatMessageResponse.from(chatMessageRepository.save(message));
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
