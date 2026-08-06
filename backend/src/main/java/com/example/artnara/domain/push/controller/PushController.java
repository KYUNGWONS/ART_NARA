package com.example.artnara.domain.push.controller;

import com.example.artnara.domain.push.service.PushService;
import com.example.artnara.global.auth.CurrentUser;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

@Tag(name = "Push", description = "푸시 알림 기기 등록 API")
@RestController
@RequestMapping("/api/devices")
@RequiredArgsConstructor
public class PushController {

    private final PushService pushService;
    private final CurrentUser currentUser;

    public record RegisterRequest(String token, String platform) {}

    @PostMapping
    @Operation(summary = "푸시 기기 등록",
            description = "앱이 발급받은 FCM 등록 토큰을 저장합니다. 소유자는 로그인 신원으로 정합니다.")
    public BaseResponse<Void> register(@RequestBody RegisterRequest request, Principal principal) {
        pushService.register(request.token(), currentUser.idOf(principal), request.platform());
        return BaseResponse.success("기기 등록 완료", null);
    }

    @DeleteMapping
    @Operation(summary = "푸시 기기 해제", description = "로그아웃 시 이 기기로 더 이상 푸시가 가지 않게 합니다.")
    public BaseResponse<Void> unregister(@RequestBody RegisterRequest request) {
        pushService.unregister(request.token());
        return BaseResponse.success("기기 해제 완료", null);
    }
}
