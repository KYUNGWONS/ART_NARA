package com.example.unitrip.domain.chat.controller;

import com.example.unitrip.domain.chat.dto.*;
import com.example.unitrip.domain.chat.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * STOMP WebSocket 채팅 컨트롤러
 *
 * [연결]
 *   ws://host/ws  (SockJS fallback 지원)
 *
 * [채팅방 입장]
 *   Client → /app/chat/enter
 *   payload: { "roomId": 1, "userId": 1 }
 *   Server → /user/queue/chat/history  (본인에게만 히스토리 전송)
 *
 * [메시지 전송]
 *   Client → /app/chat/send
 *   payload: { "roomId": 1, "senderId": 1, "content": "안녕", "messageType": "TEXT" }
 *   Server → /topic/chat/{roomId}
 *
 * [읽음 처리]
 *   Client → /app/chat/read/{roomId}
 *   payload: { "userId": 1 }
 *   Server → /topic/chat/{roomId}/read
 *
 * [채팅방 퇴장]
 *   Client → /app/chat/leave
 *   payload: { "roomId": 1, "userId": 1 }
 *   Server → /topic/chat/{roomId}/leave
 *
 * [약속 요청]
 *   Client → /app/chat/appointment/request
 *   payload: AppointmentRequest
 *   Server → /topic/chat/{roomId}/appointment
 *
 * [약속 수락/거절]
 *   Client → /app/chat/appointment/respond
 *   payload: { "appointmentId": 1, "roomId": 1, "accepted": true }
 *   Server → /topic/chat/{roomId}/appointment
 */
@Controller
@RequiredArgsConstructor
public class WebSocketChatController {

    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;


    @MessageMapping("/chat/enter")
    public void enter(@Payload ChatEnterRequest request) {
        List<ChatMessageResponse> history = chatService.getMessages(request.getRoomId());
        // 입장한 본인에게만 히스토리 전송
        messagingTemplate.convertAndSendToUser(
                String.valueOf(request.getUserId()),
                "/queue/chat/history",
                history
        );
    }

    @MessageMapping("/chat/send")
    public void sendMessage(@Payload ChatMessageRequest request) {
        ChatMessageResponse response = chatService.sendMessage(request);
        messagingTemplate.convertAndSend("/topic/chat/" + request.getRoomId(), response);
    }

    @MessageMapping("/chat/read/{roomId}")
    public void markAsRead(
            @DestinationVariable Long roomId,
            @Payload Map<String, Long> payload) {
        Long userId = payload.get("userId");
        List<Long> readMessageIds = chatService.markMessagesAsRead(roomId, userId);

        Map<String, Object> response = new HashMap<>();
        response.put("userId", userId);
        response.put("messageIds", readMessageIds);

        messagingTemplate.convertAndSend("/topic/chat/" + roomId + "/read", (Object) response);
    }

    @MessageMapping("/chat/leave")
    public void leave(@Payload ChatLeaveRequest request) {
        chatService.leaveRoom(request.getRoomId(), request.getUserId());
        messagingTemplate.convertAndSend(
                "/topic/chat/" + request.getRoomId() + "/leave",
                request.getUserId()
        );
    }

    @MessageMapping("/chat/appointment/request")
    public void requestAppointment(@Payload AppointmentRequest request) {
        AppointmentResponse response = chatService.requestAppointment(request);
        messagingTemplate.convertAndSend(
                "/topic/chat/" + request.getRoomId() + "/appointment",
                response
        );
    }

    @MessageMapping("/chat/appointment/respond")
    public void respondToAppointment(@Payload AppointmentRespondRequest request) {
        AppointmentResponse response = chatService.respondToAppointment(request);
        messagingTemplate.convertAndSend(
                "/topic/chat/" + request.getRoomId() + "/appointment",
                response
        );
    }
}
