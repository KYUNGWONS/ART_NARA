package com.example.artnara.domain.chat;

import com.example.artnara.domain.chat.dto.*;
import com.example.artnara.domain.chat.entity.*;
import com.example.artnara.domain.chat.exception.ChatErrorCode;
import com.example.artnara.domain.chat.repository.AppointmentRepository;
import com.example.artnara.domain.chat.repository.ChatMessageRepository;
import com.example.artnara.domain.chat.repository.ChatRoomRepository;
import com.example.artnara.domain.chat.service.ChatService;
import com.example.artnara.global.exception.GlobalException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class ChatServiceTest {

    @Mock ChatRoomRepository chatRoomRepository;
    @Mock ChatMessageRepository chatMessageRepository;
    @Mock AppointmentRepository appointmentRepository;
    @InjectMocks ChatService chatService;

    private ChatRoom createRoom(Long id) {
        ChatRoom room = ChatRoom.builder().creatorId(1L).build();
        ReflectionTestUtils.setField(room, "id", id);
        return room;
    }

    @Test
    @DisplayName("채팅방 생성")
    void createRoom() {
        ChatRoom room = createRoom(10L);
        given(chatRoomRepository.save(any(ChatRoom.class))).willReturn(room);

        ChatRoomResponse res = chatService.createRoom(1L);
        assertThat(res.getRoomId()).isEqualTo(10L);
        assertThat(res.getStatus()).isEqualTo(ChatRoomStatus.WAITING);
    }

    @Test
    @DisplayName("대기 중인 채팅방 목록 - 본인 방 제외")
    void getWaitingRooms() {
        ChatRoom myRoom = createRoom(1L);
        ChatRoom otherRoom = ChatRoom.builder().creatorId(2L).build();
        ReflectionTestUtils.setField(otherRoom, "id", 2L);

        given(chatRoomRepository.findByStatus(ChatRoomStatus.WAITING))
                .willReturn(List.of(myRoom, otherRoom));

        List<ChatRoomResponse> res = chatService.getWaitingRooms(1L);
        assertThat(res).hasSize(1);
        assertThat(res.get(0).getCreatorId()).isEqualTo(2L);
    }

    @Test
    @DisplayName("채팅방 참여 성공")
    void joinRoom() {
        ChatRoom room = createRoom(10L);
        given(chatRoomRepository.findById(10L)).willReturn(Optional.of(room));

        ChatRoomResponse res = chatService.joinRoom(10L, 2L);
        assertThat(res.getStatus()).isEqualTo(ChatRoomStatus.ACTIVE);
        assertThat(res.getJoinerId()).isEqualTo(2L);
    }

    @Test
    @DisplayName("이미 활성화된 방 참여 시 예외")
    void joinRoomNotWaiting() {
        ChatRoom room = createRoom(10L);
        room.join(2L); // ACTIVE로 변경
        given(chatRoomRepository.findById(10L)).willReturn(Optional.of(room));

        assertThatThrownBy(() -> chatService.joinRoom(10L, 3L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(ChatErrorCode.ROOM_NOT_WAITING);
    }

    @Test
    @DisplayName("본인이 만든 방 참여 시 예외")
    void joinOwnRoom() {
        ChatRoom room = createRoom(10L);
        given(chatRoomRepository.findById(10L)).willReturn(Optional.of(room));

        assertThatThrownBy(() -> chatService.joinRoom(10L, 1L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(ChatErrorCode.CANNOT_JOIN_OWN_ROOM);
    }

    @Test
    @DisplayName("내 채팅방 목록 조회")
    void getMyChatRooms() {
        ChatRoom room = createRoom(10L);
        given(chatRoomRepository.findAllByUserId(1L)).willReturn(List.of(room));

        List<ChatRoomResponse> res = chatService.getMyChatRooms(1L);
        assertThat(res).hasSize(1);
    }

    @Test
    @DisplayName("메시지 목록 조회")
    void getMessages() {
        ChatRoom room = createRoom(10L);
        ChatMessage msg = ChatMessage.builder()
                .chatRoom(room).senderId(1L).content("hi").messageType(MessageType.TEXT).build();
        ReflectionTestUtils.setField(msg, "id", 100L);
        given(chatMessageRepository.findByChatRoomIdOrderByCreatedAtAsc(10L)).willReturn(List.of(msg));

        List<ChatMessageResponse> res = chatService.getMessages(10L);
        assertThat(res).hasSize(1);
        assertThat(res.get(0).getContent()).isEqualTo("hi");
    }

    @Test
    @DisplayName("메시지 전송")
    void sendMessage() {
        ChatRoom room = createRoom(10L);
        given(chatRoomRepository.findById(10L)).willReturn(Optional.of(room));

        ChatMessage saved = ChatMessage.builder()
                .chatRoom(room).senderId(1L).content("hello").messageType(MessageType.TEXT).build();
        ReflectionTestUtils.setField(saved, "id", 100L);
        given(chatMessageRepository.save(any(ChatMessage.class))).willReturn(saved);

        ChatMessageRequest request = new ChatMessageRequest();
        ReflectionTestUtils.setField(request, "roomId", 10L);
        ReflectionTestUtils.setField(request, "senderId", 1L);
        ReflectionTestUtils.setField(request, "content", "hello");
        ReflectionTestUtils.setField(request, "messageType", MessageType.TEXT);

        ChatMessageResponse res = chatService.sendMessage(request);
        assertThat(res.getContent()).isEqualTo("hello");
    }

    @Test
    @DisplayName("읽음 처리")
    void markMessagesAsRead() {
        given(chatMessageRepository.findUnreadMessageIds(10L, 1L)).willReturn(List.of(100L, 101L));

        List<Long> result = chatService.markMessagesAsRead(10L, 1L);
        assertThat(result).containsExactly(100L, 101L);
        verify(chatMessageRepository).markAsRead(10L, 1L);
    }

    @Test
    @DisplayName("읽을 메시지가 없으면 markAsRead 호출 안 함")
    void markMessagesAsReadEmpty() {
        given(chatMessageRepository.findUnreadMessageIds(10L, 1L)).willReturn(List.of());

        List<Long> result = chatService.markMessagesAsRead(10L, 1L);
        assertThat(result).isEmpty();
    }

    @Test
    @DisplayName("채팅방 퇴장")
    void leaveRoom() {
        ChatRoom room = createRoom(10L);
        room.join(2L);
        given(chatRoomRepository.findById(10L)).willReturn(Optional.of(room));

        chatService.leaveRoom(10L, 1L);
        assertThat(room.isCreatorLeft()).isTrue();
    }

    @Test
    @DisplayName("약속 요청")
    void requestAppointment() {
        ChatRoom room = createRoom(10L);
        given(chatRoomRepository.findById(10L)).willReturn(Optional.of(room));

        Appointment apt = Appointment.builder()
                .chatRoom(room).requesterId(1L).responderId(2L)
                .appointmentTime(LocalDateTime.of(2026, 5, 1, 14, 0))
                .location("서울역").build();
        ReflectionTestUtils.setField(apt, "id", 50L);
        given(appointmentRepository.save(any(Appointment.class))).willReturn(apt);
        given(chatMessageRepository.save(any(ChatMessage.class))).willReturn(
                ChatMessage.builder().chatRoom(room).senderId(1L)
                        .content("msg").messageType(MessageType.APPOINTMENT).build());

        AppointmentRequest request = new AppointmentRequest();
        ReflectionTestUtils.setField(request, "roomId", 10L);
        ReflectionTestUtils.setField(request, "requesterId", 1L);
        ReflectionTestUtils.setField(request, "responderId", 2L);
        ReflectionTestUtils.setField(request, "appointmentTime", LocalDateTime.of(2026, 5, 1, 14, 0));
        ReflectionTestUtils.setField(request, "location", "서울역");

        AppointmentResponse res = chatService.requestAppointment(request);
        assertThat(res.getStatus()).isEqualTo(AppointmentStatus.PENDING);
        assertThat(res.getLocation()).isEqualTo("서울역");
    }

    @Test
    @DisplayName("약속 수락")
    void respondAccept() {
        ChatRoom room = createRoom(10L);
        Appointment apt = Appointment.builder()
                .chatRoom(room).requesterId(1L).responderId(2L).build();
        ReflectionTestUtils.setField(apt, "id", 50L);
        given(appointmentRepository.findById(50L)).willReturn(Optional.of(apt));

        AppointmentRespondRequest request = new AppointmentRespondRequest();
        ReflectionTestUtils.setField(request, "appointmentId", 50L);
        ReflectionTestUtils.setField(request, "roomId", 10L);
        ReflectionTestUtils.setField(request, "accepted", true);

        AppointmentResponse res = chatService.respondToAppointment(request);
        assertThat(res.getStatus()).isEqualTo(AppointmentStatus.ACCEPTED);
    }

    @Test
    @DisplayName("약속 거절")
    void respondReject() {
        ChatRoom room = createRoom(10L);
        Appointment apt = Appointment.builder()
                .chatRoom(room).requesterId(1L).responderId(2L).build();
        ReflectionTestUtils.setField(apt, "id", 50L);
        given(appointmentRepository.findById(50L)).willReturn(Optional.of(apt));

        AppointmentRespondRequest request = new AppointmentRespondRequest();
        ReflectionTestUtils.setField(request, "appointmentId", 50L);
        ReflectionTestUtils.setField(request, "roomId", 10L);
        ReflectionTestUtils.setField(request, "accepted", false);

        AppointmentResponse res = chatService.respondToAppointment(request);
        assertThat(res.getStatus()).isEqualTo(AppointmentStatus.REJECTED);
    }

    @Test
    @DisplayName("없는 약속 응답 시 예외")
    void respondNotFound() {
        given(appointmentRepository.findById(99L)).willReturn(Optional.empty());

        AppointmentRespondRequest request = new AppointmentRespondRequest();
        ReflectionTestUtils.setField(request, "appointmentId", 99L);
        ReflectionTestUtils.setField(request, "roomId", 10L);
        ReflectionTestUtils.setField(request, "accepted", true);

        assertThatThrownBy(() -> chatService.respondToAppointment(request))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(ChatErrorCode.APPOINTMENT_NOT_FOUND);
    }

    @Test
    @DisplayName("대기 중인 약속 목록 조회")
    void getPendingAppointments() {
        ChatRoom room = createRoom(10L);
        Appointment apt = Appointment.builder()
                .chatRoom(room).requesterId(1L).responderId(2L).build();
        ReflectionTestUtils.setField(apt, "id", 50L);
        given(appointmentRepository.findByResponderIdAndStatus(2L, AppointmentStatus.PENDING))
                .willReturn(List.of(apt));

        List<AppointmentResponse> res = chatService.getPendingAppointments(2L);
        assertThat(res).hasSize(1);
    }

    @Test
    @DisplayName("없는 채팅방 참여 시 예외")
    void joinRoomNotFound() {
        given(chatRoomRepository.findById(99L)).willReturn(Optional.empty());
        assertThatThrownBy(() -> chatService.joinRoom(99L, 1L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(ChatErrorCode.ROOM_NOT_FOUND);
    }
}
