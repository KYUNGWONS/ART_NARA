package com.example.artnara.domain.notification.controller;

import com.example.artnara.domain.notification.dto.NotificationDto;
import com.example.artnara.domain.notification.service.NotificationService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Notification", description = "알림 API")
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @PostMapping
    @Operation(summary = "알림 생성", description = "사용자에게 새로운 알림을 생성합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "알림 생성 성공"),
            @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음")
    })
    public BaseResponse<NotificationDto.Response> create(@RequestBody NotificationDto.CreateRequest req) {
        return BaseResponse.success("알림 생성", notificationService.create(req));
    }

    @GetMapping
    @Operation(summary = "알림 목록 조회", description = "사용자의 알림 목록을 최신순으로 조회합니다.")
    @ApiResponse(responseCode = "200", description = "알림 목록 조회 성공")
    public BaseResponse<List<NotificationDto.Response>> list(
            @Parameter(description = "사용자 ID", example = "1") @RequestParam Long userId) {
        return BaseResponse.success("알림 목록", notificationService.list(userId));
    }

    @GetMapping("/unread-count")
    @Operation(summary = "미읽음 알림 개수 조회", description = "사용자의 읽지 않은 알림 개수를 조회합니다.")
    @ApiResponse(responseCode = "200", description = "미읽음 개수 조회 성공")
    public BaseResponse<Long> unreadCount(
            @Parameter(description = "사용자 ID", example = "1") @RequestParam Long userId) {
        return BaseResponse.success("미확인 개수", notificationService.unreadCount(userId));
    }

    @PatchMapping("/{id}/read")
    @Operation(summary = "알림 읽음 처리", description = "알림을 읽음 상태로 변경합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "읽음 처리 성공"),
            @ApiResponse(responseCode = "404", description = "알림을 찾을 수 없음")
    })
    public BaseResponse<Void> markRead(
            @Parameter(description = "알림 ID", example = "1") @PathVariable Long id) {
        notificationService.markRead(id);
        return BaseResponse.success("읽음 처리", null);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "알림 삭제", description = "알림을 삭제합니다.")
    @ApiResponse(responseCode = "200", description = "알림 삭제 성공")
    public BaseResponse<Void> delete(
            @Parameter(description = "알림 ID", example = "1") @PathVariable Long id) {
        notificationService.delete(id);
        return BaseResponse.success("알림 삭제", null);
    }
}
