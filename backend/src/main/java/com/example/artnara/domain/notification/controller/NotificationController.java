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

import java.security.Principal;

@Tag(name = "Notification", description = "알림 API")
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    @Operation(summary = "알림 목록",
            description = "내 알림과 시스템 알림을 최신순으로 조회합니다. 대상은 JWT 신원에서 결정됩니다.")
    @ApiResponses({@ApiResponse(responseCode = "200", description = "조회 성공")})
    public BaseResponse<NotificationDto.ListResponse> list(Principal principal) {
        return BaseResponse.success("알림 목록 조회", notificationService.list(userId(principal)));
    }

    @PatchMapping("/{id}/read")
    @Operation(summary = "알림 읽음 처리")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "읽음 처리 성공"),
            @ApiResponse(responseCode = "404", description = "알림을 찾을 수 없음")
    })
    public BaseResponse<Void> read(
            @Parameter(description = "알림 ID", example = "1") @PathVariable Long id,
            Principal principal) {
        notificationService.markAsRead(id, userId(principal));
        return BaseResponse.success("알림 읽음 처리", null);
    }

    @PatchMapping("/read-all")
    @Operation(summary = "알림 모두 읽음 처리")
    @ApiResponses({@ApiResponse(responseCode = "200", description = "읽음 처리 성공")})
    public BaseResponse<Void> readAll(Principal principal) {
        notificationService.markAllAsRead(userId(principal));
        return BaseResponse.success("알림 모두 읽음 처리", null);
    }

    private Long userId(Principal principal) {
        return Long.parseLong(principal.getName());
    }
}
