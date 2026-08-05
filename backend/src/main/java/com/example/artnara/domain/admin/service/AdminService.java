package com.example.artnara.domain.admin.service;

import com.example.artnara.domain.admin.dto.AdminDto;
import com.example.artnara.domain.artwork.repository.ArtworkRepository;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.domain.order.entity.ArtOrder;
import com.example.artnara.domain.order.repository.ArtOrderRepository;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * 관리자 조회·조치. 앱 API 와 달리 전체 데이터를 본다(관리자 권한 전제).
 *
 * 매출 집계는 환불된 주문을 제외한다 — 환불액은 따로 보여준다.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class AdminService {

    /** 대시보드 매출 그래프 구간(일) */
    private static final int SALES_DAYS = 14;
    /** 상위 작가 표시 수 */
    private static final int TOP_ARTIST_LIMIT = 5;

    private final ArtOrderRepository artOrderRepository;
    private final UserRepository userRepository;
    private final ArtworkRepository artworkRepository;
    private final ArtworkService artworkService;

    @Transactional(readOnly = true)
    public AdminDto.Dashboard dashboard() {
        List<ArtOrder> orders = artOrderRepository.findAll();
        List<ArtOrder> paid = orders.stream().filter(order -> !order.isRefunded()).toList();

        String today = LocalDate.now().toString();
        String monthPrefix = today.substring(0, 7);

        long totalRevenue = sum(paid);
        long todayRevenue = paid.stream()
                .filter(order -> today.equals(order.getOrderedDate()))
                .mapToLong(ArtOrder::getAmount).sum();
        long monthRevenue = paid.stream()
                .filter(order -> order.getOrderedDate() != null
                        && order.getOrderedDate().startsWith(monthPrefix))
                .mapToLong(ArtOrder::getAmount).sum();
        long refundedAmount = orders.stream()
                .filter(ArtOrder::isRefunded)
                .mapToLong(ArtOrder::getAmount).sum();

        List<User> users = userRepository.findAll();
        long blocked = users.stream().filter(User::isBlocked).count();
        long soldCount = artworkRepository.findAll().stream()
                .filter(artwork -> artwork.isSold()).count();

        return new AdminDto.Dashboard(
                totalRevenue, todayRevenue, monthRevenue, refundedAmount,
                paid.size(), orders.size() - paid.size(),
                users.size(), blocked,
                artworkRepository.count(), soldCount,
                dailySales(paid), topArtists(paid));
    }

    private long sum(List<ArtOrder> orders) {
        return orders.stream().mapToLong(ArtOrder::getAmount).sum();
    }

    /** 최근 SALES_DAYS 일 매출. 거래 없는 날도 0 으로 채워 그래프가 끊기지 않게 한다. */
    private List<AdminDto.DailySales> dailySales(List<ArtOrder> paid) {
        Map<String, long[]> byDate = new LinkedHashMap<>();
        LocalDate start = LocalDate.now().minusDays(SALES_DAYS - 1L);
        for (int i = 0; i < SALES_DAYS; i++) {
            byDate.put(start.plusDays(i).toString(), new long[] {0, 0});
        }
        for (ArtOrder order : paid) {
            long[] slot = byDate.get(order.getOrderedDate());
            if (slot == null) continue; // 구간 밖 주문은 그래프에서 제외
            slot[0] += order.getAmount();
            slot[1] += 1;
        }
        return byDate.entrySet().stream()
                .map(entry -> new AdminDto.DailySales(
                        entry.getKey(), entry.getValue()[0], entry.getValue()[1]))
                .toList();
    }

    private List<AdminDto.TopArtist> topArtists(List<ArtOrder> paid) {
        Map<String, long[]> byArtist = new LinkedHashMap<>();
        for (ArtOrder order : paid) {
            long[] slot = byArtist.computeIfAbsent(
                    order.getArtistName(), key -> new long[] {0, 0});
            slot[0] += order.getAmount();
            slot[1] += 1;
        }
        return byArtist.entrySet().stream()
                .map(entry -> new AdminDto.TopArtist(
                        entry.getKey(), entry.getValue()[0], entry.getValue()[1]))
                .sorted(Comparator.comparingLong(AdminDto.TopArtist::amount).reversed())
                .limit(TOP_ARTIST_LIMIT)
                .toList();
    }

    @Transactional(readOnly = true)
    public AdminDto.MemberList members(String query) {
        String keyword = normalize(query);
        // 주문을 한 번만 돌아 회원별 구매액을 만든다(회원마다 조회하면 N+1).
        Map<Long, long[]> spentByBuyer = new LinkedHashMap<>();
        for (ArtOrder order : artOrderRepository.findAll()) {
            if (order.getBuyerId() == null || order.isRefunded()) continue;
            long[] slot = spentByBuyer.computeIfAbsent(
                    order.getBuyerId(), key -> new long[] {0, 0});
            slot[0] += order.getAmount();
            slot[1] += 1;
        }

        List<AdminDto.MemberRow> rows = userRepository.findAll().stream()
                .filter(user -> keyword.isEmpty()
                        || contains(user.getNickname(), keyword)
                        || contains(user.getEmail(), keyword))
                .sorted(Comparator.comparing(User::getId).reversed())
                .map(user -> {
                    long[] spent = spentByBuyer.getOrDefault(user.getId(), new long[] {0, 0});
                    return new AdminDto.MemberRow(
                            user.getId(), user.getNickname(), user.getEmail(),
                            user.getUserType() == null ? null : user.getUserType().name(),
                            user.getRegion() == null ? null : user.getRegion().getLabel(),
                            user.isBlocked(), user.getBlockedReason(),
                            spent[1], spent[0],
                            user.getCreatedAt() == null
                                    ? null : user.getCreatedAt().toLocalDate().toString());
                })
                .toList();
        return new AdminDto.MemberList(rows, rows.size());
    }

    public void blockMember(Long userId, String reason) {
        find(userId).block(blank(reason) ? "관리자 차단" : reason.trim());
    }

    public void unblockMember(Long userId) {
        find(userId).unblock();
    }

    private User find(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new GlobalException(DomainResultCode.USER_NOT_FOUND));
    }

    @Transactional(readOnly = true)
    public AdminDto.OrderList orders(String query) {
        String keyword = normalize(query);
        List<AdminDto.OrderRow> rows = artOrderRepository.findAll().stream()
                .filter(order -> keyword.isEmpty()
                        || contains(order.getArtworkTitle(), keyword)
                        || contains(order.getBuyerName(), keyword)
                        || contains(order.getArtistName(), keyword))
                .sorted(Comparator.comparing(ArtOrder::getId).reversed())
                .map(order -> new AdminDto.OrderRow(
                        order.getId(), order.getArtworkId(), order.getArtworkTitle(),
                        order.getArtistName(), order.getBuyerName(), order.getAmount(),
                        order.getPaymentMethod(), order.getStatus(), order.getCertificateNo(),
                        order.getOrderedDate(), order.isRefunded(),
                        order.getRefundReason(), order.getRefundedAt()))
                .toList();
        return new AdminDto.OrderList(rows, rows.size());
    }

    /**
     * 환불 처리 — 주문을 환불 상태로 바꾸고 작품 판매 잠금을 풀어 다시 팔 수 있게 한다.
     * mock PG 라 결제 취소 호출은 없다(실 PG 연동 시 이 지점에 취소 API 를 붙인다).
     */
    public void refund(Long orderId, String reason) {
        ArtOrder order = artOrderRepository.findById(orderId)
                .orElseThrow(() -> new GlobalException(DomainResultCode.ORDER_NOT_FOUND));
        if (order.isRefunded()) {
            throw new GlobalException(DomainResultCode.ORDER_ALREADY_REFUNDED);
        }
        order.refund(blank(reason) ? "관리자 환불" : reason.trim(), LocalDate.now().toString());
        artworkService.markUnsold(order.getArtworkId());
    }

    private static String normalize(String value) {
        return value == null ? "" : value.trim().toLowerCase(Locale.ROOT);
    }

    private static boolean contains(String value, String keyword) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(keyword);
    }

    private static boolean blank(String value) {
        return value == null || value.isBlank();
    }
}
