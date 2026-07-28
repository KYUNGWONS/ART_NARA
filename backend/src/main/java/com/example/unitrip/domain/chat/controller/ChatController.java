package com.example.unitrip.domain.chat.controller;

import com.example.unitrip.domain.chat.dto.AppointmentResponse;
import com.example.unitrip.domain.chat.dto.ChatRoomResponse;
import com.example.unitrip.domain.chat.service.ChatService;
import com.example.unitrip.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
@Tag(name = "Chat", description = "채팅 REST API — 채팅방 생성·참여·조회 및 약속 관리")
public class ChatController {

    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;

    @PostMapping("/rooms")
    @Operation(
            summary = "채팅방 생성",
            description = "내 ID만으로 방을 생성합니다. 생성된 방은 WAITING 상태이며, 상대방은 대기방 목록에서 참여할 수 있습니다.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "채팅방 생성 성공")
            }
    )
    public ResponseEntity<BaseResponse<ChatRoomResponse>> createRoom(
            @Parameter(description = "방을 생성하는 사용자 ID", example = "1", required = true)
            @RequestParam Long userId) {
        return ResponseEntity.ok(BaseResponse.success("채팅방 생성 완료", chatService.createRoom(userId)));
    }

    @GetMapping("/rooms/waiting")
    @Operation(
            summary = "대기 중인 채팅방 목록",
            description = "현재 참여 가능한 WAITING 상태의 채팅방 목록을 조회합니다. 본인이 만든 방은 제외됩니다.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "대기방 목록 조회 성공")
            }
    )
    public ResponseEntity<BaseResponse<List<ChatRoomResponse>>> getWaitingRooms(
            @Parameter(description = "조회하는 사용자 ID (본인이 만든 방 제외 필터링용)", example = "1", required = true)
            @RequestParam Long userId) {
        return ResponseEntity.ok(BaseResponse.success("대기방 목록 조회 성공", chatService.getWaitingRooms(userId)));
    }

    @PostMapping("/rooms/{roomId}/join")
    @Operation(
            summary = "채팅방 참여",
            description = "WAITING 상태인 채팅방에 참여합니다. 참여 성공 시 방 상태가 ACTIVE로 변경되고, WebSocket(/topic/chat/{roomId}/join)으로 방장에게 실시간 알림이 전송됩니다.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "채팅방 참여 성공")
            }
    )
    public ResponseEntity<BaseResponse<ChatRoomResponse>> joinRoom(
            @Parameter(description = "참여할 채팅방 ID", example = "1", required = true)
            @PathVariable Long roomId,
            @Parameter(description = "참여하는 사용자 ID", example = "2", required = true)
            @RequestParam Long userId) {
        ChatRoomResponse response = chatService.joinRoom(roomId, userId);
        // 방장에게 실시간으로 상대방 참여 알림
        messagingTemplate.convertAndSend("/topic/chat/" + roomId + "/join", response);
        return ResponseEntity.ok(BaseResponse.success("채팅방 참여 완료", response));
    }

    @GetMapping("/rooms/my")
    @Operation(
            summary = "내 채팅방 목록",
            description = "내가 생성했거나 참여한 모든 채팅방 목록을 조회합니다. (WAITING, ACTIVE, CLOSED 모두 포함)",
            responses = {
                    @ApiResponse(responseCode = "200", description = "내 채팅방 목록 조회 성공")
            }
    )
    public ResponseEntity<BaseResponse<List<ChatRoomResponse>>> getMyChatRooms(
            @Parameter(description = "조회하는 사용자 ID", example = "1", required = true)
            @RequestParam Long userId) {
        return ResponseEntity.ok(BaseResponse.success("채팅방 목록 조회 성공", chatService.getMyChatRooms(userId)));
    }

    @GetMapping("/appointments/pending")
    @Operation(
            summary = "대기 중인 약속 목록 조회",
            description = "내가 응답해야 하는 PENDING 상태의 약속 요청 목록을 조회합니다.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "대기 중인 약속 목록 조회 성공")
            }
    )
    public ResponseEntity<BaseResponse<List<AppointmentResponse>>> getPendingAppointments(
            @Parameter(description = "조회하는 사용자 ID", example = "1", required = true)
            @RequestParam Long userId) {
        return ResponseEntity.ok(BaseResponse.success("대기 중인 약속 조회 성공", chatService.getPendingAppointments(userId)));
    }
}
