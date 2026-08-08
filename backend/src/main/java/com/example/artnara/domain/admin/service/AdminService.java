package com.example.artnara.domain.admin.service;

import com.example.artnara.domain.admin.dto.AdminDto;
import com.example.artnara.domain.artwork.repository.ArtworkRepository;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.domain.certificate.service.CertificateService;
import com.example.artnara.domain.notification.entity.NotificationType;
import com.example.artnara.domain.notification.service.NotificationService;
import com.example.artnara.domain.order.entity.ArtOrder;
import com.example.artnara.domain.order.repository.ArtOrderRepository;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import com.example.artnara.global.payment.TossPaymentClient;
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
    private final CertificateService certificateService;
    private final NotificationService notificationService;
    private final TossPaymentClient tossPaymentClient;

    @Transactional(readOnly = true)
    public AdminDto.Dashboard dashboard() {
        List<ArtOrder> orders = artOrderRepository.findAll();
        // 매출은 결제까지 끝난 건만 센다 — 예약·수령확인 단계는 아직 돈이 오가지 않았다.
        List<ArtOrder> paid = orders.stream()
                .filter(order -> order.isPaid() && !order.isRefunded())
                .toList();

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
        List<ArtOrder> refunded = orders.stream().filter(ArtOrder::isRefunded).toList();
        long refundedAmount = refunded.stream().mapToLong(ArtOrder::getAmount).sum();

        List<User> users = userRepository.findAll();
        long blocked = users.stream().filter(User::isBlocked).count();
        long soldCount = artworkRepository.findAll().stream()
                .filter(artwork -> artwork.isSold()).count();

        return new AdminDto.Dashboard(
                totalRevenue, todayRevenue, monthRevenue, refundedAmount,
                // 환불 건수는 실제 환불된 주문만 — 예전에는 '결제 안 된 주문 전부' 를 세서
                // 예약·취소까지 환불로 잡혔다(환불 5건인데 13건으로 표시됐다).
                paid.size(), refunded.size(),
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
            if (order.getBuyerId() == null || !order.isPaid() || order.isRefunded()) continue;
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
                        order.getRefundReason(), order.getRefundedAt(),
                        order.isPaid(), order.isCancelled(),
                        order.isSellerConfirmed(), order.isBuyerConfirmed()))
                .toList();
        return new AdminDto.OrderList(rows, rows.size());
    }

    /**
     * 환불 처리 — 실 PG 로 결제된 주문이면 토스 취소를 먼저 호출하고,
     * 성공한 뒤에 주문을 환불 상태로 바꾸고 작품 판매 잠금을 푼다.
     * (PG 취소가 실패하면 예외가 나가 주문 상태는 그대로 남는다 — 장부와 PG 가 어긋나지 않는다.)
     */
    public void refund(Long orderId, String reason) {
        ArtOrder order = artOrderRepository.findById(orderId)
                .orElseThrow(() -> new GlobalException(DomainResultCode.ORDER_NOT_FOUND));
        if (order.isRefunded()) {
            throw new GlobalException(DomainResultCode.ORDER_ALREADY_REFUNDED);
        }
        // 결제 전(예약·수령확인)에는 돌려줄 돈이 없다. 그건 예약 취소로 처리한다.
        if (!order.isPaid()) {
            throw new GlobalException(DomainResultCode.ORDER_HANDOVER_REQUIRED,
                    "아직 결제되지 않은 예약입니다. 예약 취소로 처리해주세요.");
        }
        String resolved = blank(reason) ? "관리자 환불" : reason.trim();
        if (order.getPaymentKey() != null && !order.getPaymentKey().isBlank()) {
            tossPaymentClient.cancel(order.getPaymentKey(), resolved);
        }
        order.refund(resolved, LocalDate.now().toString());
        artworkService.markUnsold(order.getArtworkId());
        // 작품이 다시 팔릴 수 있게 됐으므로 이전 구매자의 소유권·인증서도 회수한다.
        certificateService.revoke(order.getCertificateNo());
        // 구매자는 앱에서 환불 사실을 알 수 있어야 한다(관리자가 처리하므로 본인은 모른다).
        notificationService.publishTo(order.getBuyerId(),
                NotificationType.ORDER_REFUNDED, "환불이 처리되었어요",
                "'" + order.getArtworkTitle() + "' 주문이 환불되었습니다. 디지털 소유권은 회수됩니다.",
                order.getId());
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
