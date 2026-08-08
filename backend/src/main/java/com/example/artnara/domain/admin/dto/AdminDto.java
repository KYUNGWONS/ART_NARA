package com.example.artnara.domain.admin.dto;

import java.util.List;

public class AdminDto {

    public record LoginRequest(String username, String password) {}

    public record LoginResponse(String accessToken, String username,
                                boolean mustChangePassword) {}

    public record ChangePasswordRequest(String currentPassword, String newPassword) {}

    /** 대시보드 요약 — 매출·거래·회원 한눈에 */
    public record Dashboard(
            long totalRevenue,
            long todayRevenue,
            long monthRevenue,
            long refundedAmount,
            long orderCount,
            long refundCount,
            long memberCount,
            long blockedMemberCount,
            long artworkCount,
            long soldArtworkCount,
            List<DailySales> recentSales,
            List<TopArtist> topArtists
    ) {}

    /** 일자별 매출(최근 N일) */
    public record DailySales(String date, long amount, long count) {}

    /** 판매액 상위 작가 */
    public record TopArtist(String artistName, long amount, long count) {}

    public record MemberRow(
            Long id,
            String nickname,
            String email,
            String userType,
            String region,
            boolean blocked,
            String blockedReason,
            long orderCount,
            long spentAmount,
            String joinedAt
    ) {}

    public record MemberList(List<MemberRow> members, long total) {}

    public record BlockRequest(String reason) {}

    public record OrderRow(
            Long id,
            Long artworkId,
            String artworkTitle,
            String artistName,
            String buyerName,
            int amount,
            String paymentMethod,
            String status,
            String certificateNo,
            String orderedDate,
            boolean refunded,
            String refundReason,
            String refundedAt,
            /** 직거래 단계 — 환불은 결제(paid)된 건에만 의미가 있다. */
            boolean paid,
            boolean cancelled,
            boolean sellerConfirmed,
            boolean buyerConfirmed
    ) {}

    public record OrderList(List<OrderRow> orders, long total) {}

    public record RefundRequest(String reason) {}
}
