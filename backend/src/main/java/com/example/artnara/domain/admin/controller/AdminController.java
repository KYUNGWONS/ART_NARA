package com.example.artnara.domain.admin.controller;

import com.example.artnara.domain.admin.dto.AdminDto;
import com.example.artnara.domain.admin.service.AdminAuthService;
import com.example.artnara.domain.admin.service.AdminService;
import com.example.artnara.global.common.BaseResponse;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

/**
 * 관리자 API. `/api/admin/login` 외 전 경로는 ROLE_ADMIN 토큰이 필요하다
 * (SecurityConfig 에서 강제 — 앱 사용자 토큰으로는 접근 불가).
 */
@Tag(name = "Admin", description = "ART NARA 관리자 API")
@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminAuthService adminAuthService;
    private final AdminService adminService;

    @PostMapping("/login")
    @Operation(summary = "관리자 로그인", description = "아이디·비밀번호로 관리자 토큰을 발급합니다.")
    public BaseResponse<AdminDto.LoginResponse> login(
            @RequestBody AdminDto.LoginRequest request) {
        return BaseResponse.success("관리자 로그인", adminAuthService.login(request));
    }

    @PatchMapping("/password")
    @Operation(summary = "관리자 비밀번호 변경")
    public BaseResponse<Void> changePassword(
            @RequestBody AdminDto.ChangePasswordRequest request, Principal principal) {
        adminAuthService.changePassword(adminIdOf(principal), request);
        return BaseResponse.success("비밀번호 변경", null);
    }

    @GetMapping("/dashboard")
    @Operation(summary = "대시보드", description = "매출·주문·회원·작품 요약과 최근 매출 추이입니다.")
    public BaseResponse<AdminDto.Dashboard> dashboard() {
        return BaseResponse.success("대시보드", adminService.dashboard());
    }

    @GetMapping("/members")
    @Operation(summary = "회원 목록", description = "닉네임·이메일로 검색할 수 있습니다.")
    public BaseResponse<AdminDto.MemberList> members(
            @RequestParam(required = false) String query) {
        return BaseResponse.success("회원 목록", adminService.members(query));
    }

    @PostMapping("/members/{userId}/block")
    @Operation(summary = "회원 차단", description = "차단된 회원은 로그인할 수 없습니다.")
    public BaseResponse<Void> block(@PathVariable Long userId,
                                    @RequestBody(required = false) AdminDto.BlockRequest request) {
        adminService.blockMember(userId, request == null ? null : request.reason());
        return BaseResponse.success("회원 차단", null);
    }

    @PostMapping("/members/{userId}/unblock")
    @Operation(summary = "회원 차단 해제")
    public BaseResponse<Void> unblock(@PathVariable Long userId) {
        adminService.unblockMember(userId);
        return BaseResponse.success("회원 차단 해제", null);
    }

    @GetMapping("/orders")
    @Operation(summary = "주문 목록", description = "작품명·구매자·작가로 검색할 수 있습니다.")
    public BaseResponse<AdminDto.OrderList> orders(
            @RequestParam(required = false) String query) {
        return BaseResponse.success("주문 목록", adminService.orders(query));
    }

    @PostMapping("/orders/{orderId}/refund")
    @Operation(summary = "주문 환불",
            description = "주문을 환불 처리하고 작품 판매 잠금을 풀어 다시 판매할 수 있게 합니다.")
    public BaseResponse<Void> refund(@PathVariable Long orderId,
                                     @RequestBody(required = false) AdminDto.RefundRequest request) {
        adminService.refund(orderId, request == null ? null : request.reason());
        return BaseResponse.success("주문 환불", null);
    }

    /** 관리자 토큰의 sub 는 admin_accounts.id 다. */
    private Long adminIdOf(Principal principal) {
        if (principal == null) {
            throw new GlobalException(DomainResultCode.AUTH_REQUIRED);
        }
        try {
            return Long.valueOf(principal.getName());
        } catch (NumberFormatException e) {
            throw new GlobalException(DomainResultCode.ADMIN_FORBIDDEN);
        }
    }
}
