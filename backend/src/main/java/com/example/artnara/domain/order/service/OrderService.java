package com.example.artnara.domain.order.service;

import com.example.artnara.domain.artwork.dto.ArtworkDetailDto;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.domain.certificate.dto.CertificateDto;
import com.example.artnara.domain.certificate.service.CertificateService;
import com.example.artnara.domain.order.dto.OrderDto;
import com.example.artnara.domain.order.entity.ArtOrder;
import com.example.artnara.domain.order.repository.ArtOrderRepository;
import com.example.artnara.domain.notification.entity.NotificationType;
import com.example.artnara.domain.notification.service.NotificationService;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import com.example.artnara.global.payment.TossPaymentClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Set;

/**
 * 작품 주문 — **직거래 흐름**이다.
 *
 * 배송이 없는 서비스라 결제를 만난 뒤로 미룬다:
 * 예약 → (만나서 전달) → 판매자·구매자 각각 수령 확인 → 결제 → 소유권 발급.
 * 예약만으로 작품이 잠기므로 남이 중복 구매하지 못하고, 어느 한쪽 주장만으로는
 * 결제가 열리지 않는다.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class OrderService {

    private static final Set<String> PAYMENT_METHODS =
            Set.of("CARD", "KAKAO_PAY", "NAVER_PAY", "TOSS");

    /** 결제 전에는 수단을 모른다. NOT NULL 컬럼이라 자리만 채워둔다. */
    private static final String PAYMENT_PENDING = "미정";

    private final ArtOrderRepository artOrderRepository;
    private final ArtworkService artworkService;
    private final CertificateService certificateService;
    private final NotificationService notificationService;
    private final UserRepository userRepository;
    private final TossPaymentClient tossPaymentClient;

    /**
     * 작품을 예약한다. 결제는 하지 않고 작품만 잠근다 — 만나서 확인한 뒤에 결제한다.
     */
    public OrderDto.Response reserve(OrderDto.CreateRequest request,
                                     Long buyerId, String buyerName) {
        if (request.artworkId() == null) {
            throw new GlobalException(DomainResultCode.ARTWORK_NOT_FOUND);
        }
        ArtworkDetailDto artwork = artworkService.getDetail(request.artworkId());
        int amount = artwork.price();

        // 자기 작품을 자기가 사면 판매 이력·정산이 실제 거래처럼 부풀려진다.
        if (buyerName != null && buyerName.equals(artwork.artistName())) {
            throw new GlobalException(DomainResultCode.ORDER_OWN_ARTWORK);
        }

        if (artwork.auction()) {
            // 경매 작품은 마감 후 낙찰자만 낙찰가로 살 수 있다.
            if (!artwork.auctionClosed()) {
                throw new GlobalException(DomainResultCode.ORDER_AUCTION_NOT_BUYABLE);
            }
            if (artwork.winnerName() == null) {
                throw new GlobalException(DomainResultCode.ORDER_AUCTION_NO_WINNER);
            }
            if (!buyerName.equals(artwork.winnerName())) {
                throw new GlobalException(DomainResultCode.ORDER_NOT_WINNER);
            }
            amount = artwork.currentBid();
        }
        if (artwork.sold()) {
            throw new GlobalException(DomainResultCode.ORDER_ALREADY_SOLD);
        }
        // 살아 있는 예약(취소·환불되지 않은 것)이 있으면 다른 사람이 끼어들 수 없다.
        if (artOrderRepository.existsByArtworkIdAndCancelledFalseAndRefundedFalse(artwork.id())) {
            throw new GlobalException(DomainResultCode.ORDER_ALREADY_RESERVED);
        }

        artworkService.markReserved(artwork.id());

        ArtOrder order = artOrderRepository.save(ArtOrder.builder()
                .artworkId(artwork.id())
                .artworkTitle(artwork.title())
                .artistName(artwork.artistName())
                .amount(amount)
                .paymentMethod(PAYMENT_PENDING)
                .status("예약 중")
                .certificateNo("")
                .orderedDate(LocalDate.now().toString())
                .buyerId(buyerId)
                .buyerName(buyerName)
                .build());

        notifySeller(artwork.artistName(), NotificationType.ORDER_RESERVED,
                "작품이 예약되었어요",
                "'" + artwork.title() + "' 을(를) " + buyerName + "님이 예약했습니다. "
                        + "만나서 전달한 뒤 '전달했어요' 를 눌러주세요.",
                order.getId());

        return toDto(order, true);
    }

    /**
     * 수령을 확인한다. 판매자면 '전달했어요', 구매자면 '받았어요' 로 기록된다.
     * 양쪽이 모두 확인하면 구매자에게 결제 차례를 알린다.
     */
    public OrderDto.Response confirmHandover(Long orderId, Long userId, String userName) {
        ArtOrder order = find(orderId);
        boolean isBuyer = isBuyer(order, userId);
        boolean isSeller = order.getArtistName().equals(userName);
        if (!isBuyer && !isSeller) {
            throw new GlobalException(DomainResultCode.ORDER_NOT_PARTICIPANT);
        }
        if (order.isCancelled()) throw new GlobalException(DomainResultCode.ORDER_CANCELLED);
        if (order.isPaid()) throw new GlobalException(DomainResultCode.ORDER_ALREADY_PAID);

        if (isBuyer) {
            order.confirmByBuyer();
        } else {
            order.confirmBySeller();
        }

        if (order.isHandoverConfirmed()) {
            notificationService.publishTo(order.getBuyerId(),
                    NotificationType.ORDER_PAYMENT_DUE,
                    "결제를 진행해주세요",
                    "'" + order.getArtworkTitle() + "' 수령 확인이 끝났습니다. "
                            + "결제하면 디지털 소유권이 발급됩니다.",
                    order.getId());
        } else if (isBuyer) {
            notifySeller(order.getArtistName(), NotificationType.ORDER_HANDOVER,
                    "구매자가 수령을 확인했어요",
                    "'" + order.getArtworkTitle() + "' 을(를) 구매자가 받았다고 확인했습니다.",
                    order.getId());
        } else {
            notificationService.publishTo(order.getBuyerId(),
                    NotificationType.ORDER_HANDOVER,
                    "작가가 전달을 확인했어요",
                    "'" + order.getArtworkTitle() + "' 을(를) 받으셨다면 '받았어요' 를 눌러주세요.",
                    order.getId());
        }
        return toDto(order, isSeller);
    }

    /**
     * 결제한다. **양쪽 수령 확인이 끝난 예약에서 구매자만** 호출할 수 있다.
     * 결제가 확정되면 작품이 판매 완료로 잠기고 디지털 소유권·인증서가 발급된다.
     */
    public OrderDto.Response pay(Long orderId, OrderDto.PayRequest request,
                                 Long buyerId, String buyerName) {
        ArtOrder order = find(orderId);
        if (!isBuyer(order, buyerId)) {
            throw new GlobalException(DomainResultCode.ORDER_BUYER_ONLY);
        }
        if (order.isCancelled()) throw new GlobalException(DomainResultCode.ORDER_CANCELLED);
        if (order.isPaid()) throw new GlobalException(DomainResultCode.ORDER_ALREADY_PAID);
        if (!order.isHandoverConfirmed()) {
            throw new GlobalException(DomainResultCode.ORDER_HANDOVER_REQUIRED);
        }
        if (request == null || request.paymentMethod() == null
                || !PAYMENT_METHODS.contains(request.paymentMethod())) {
            throw new GlobalException(DomainResultCode.ORDER_INVALID_PAYMENT_METHOD);
        }

        // 실 PG(토스)를 거쳤으면 서버에서 승인한다. 클라이언트가 보낸 금액은 믿지 않고,
        // 토스가 확정한 금액과 주문 금액을 대조한다.
        String paymentKey = blankToNull(request.paymentKey());
        if (paymentKey != null) {
            if (!tossPaymentClient.isEnabled()) {
                throw new GlobalException(DomainResultCode.PAYMENT_FAILED,
                        "결제 서버가 설정되지 않았습니다.");
            }
            String tossOrderId = blankToNull(request.tossOrderId());
            if (tossOrderId == null) {
                throw new GlobalException(DomainResultCode.PAYMENT_FAILED, "주문번호가 없습니다.");
            }
            int approved = tossPaymentClient.confirm(paymentKey, tossOrderId, order.getAmount());
            if (approved != order.getAmount()) {
                throw new GlobalException(DomainResultCode.PAYMENT_AMOUNT_MISMATCH);
            }
            order.linkPayment(paymentKey);
        }

        artworkService.markSold(order.getArtworkId());
        order.markPaid(request.paymentMethod());

        String certificateNo = "ARTNARA-2026-" + (100 + order.getId());
        order.issueCertificate(certificateNo);

        String today = LocalDate.now().toString();
        ArtworkDetailDto artwork = artworkService.getDetail(order.getArtworkId());
        certificateService.register(new CertificateDto.IssueRequest(
                certificateNo, order.getArtworkTitle(), order.getArtistName(), today,
                artwork.year(), artwork.size(), artwork.medium()), buyerId, buyerName);

        notificationService.publishTo(buyerId, NotificationType.ORDER_COMPLETED,
                "결제가 완료되었어요",
                "'" + order.getArtworkTitle() + "' 결제가 완료되어 디지털 소유권과 "
                        + "소유권 인증서(" + certificateNo + ")가 발급되었습니다.",
                order.getId());

        notifySeller(order.getArtistName(), NotificationType.ORDER_COMPLETED,
                "작품이 판매되었어요",
                "'" + order.getArtworkTitle() + "' 이(가) "
                        + String.format("%,d", order.getAmount()) + "원에 판매되었습니다.",
                order.getId());

        return toDto(order, false);
    }

    /** 만나기 전에 예약을 무른다. 당사자 아무나 취소할 수 있고 작품 잠금이 풀린다. */
    public void cancel(Long orderId, Long userId, String userName) {
        ArtOrder order = find(orderId);
        boolean isBuyer = isBuyer(order, userId);
        boolean isSeller = order.getArtistName().equals(userName);
        if (!isBuyer && !isSeller) {
            throw new GlobalException(DomainResultCode.ORDER_NOT_PARTICIPANT);
        }
        if (order.isPaid()) throw new GlobalException(DomainResultCode.ORDER_ALREADY_PAID);
        if (order.isCancelled()) return; // 여러 번 눌러도 결과가 같다

        order.cancel();
        artworkService.releaseReservation(order.getArtworkId());

        if (isBuyer) {
            notifySeller(order.getArtistName(), NotificationType.ORDER_CANCELLED,
                    "예약이 취소되었어요",
                    "'" + order.getArtworkTitle() + "' 예약이 취소되어 다시 판매 중입니다.",
                    order.getId());
        } else {
            notificationService.publishTo(order.getBuyerId(),
                    NotificationType.ORDER_CANCELLED,
                    "예약이 취소되었어요",
                    "'" + order.getArtworkTitle() + "' 예약이 판매자에 의해 취소되었습니다.",
                    order.getId());
        }
    }

    /** 주문 내역은 로그인한 구매자 본인 것만 내려준다. */
    @Transactional(readOnly = true)
    public OrderDto.ListResponse list(Long buyerId) {
        return new OrderDto.ListResponse(
                artOrderRepository.findByBuyerIdOrderByIdDesc(buyerId).stream()
                        .map(order -> toDto(order, false))
                        .toList());
    }

    /** 내 작품에 걸린 거래(판매자 입장). '전달했어요' 를 누르려면 이 목록이 필요하다. */
    @Transactional(readOnly = true)
    public OrderDto.ListResponse listSelling(String artistName) {
        return new OrderDto.ListResponse(
                artOrderRepository.findByArtistNameOrderByIdDesc(artistName).stream()
                        .map(order -> toDto(order, true))
                        .toList());
    }

    private ArtOrder find(Long orderId) {
        return artOrderRepository.findById(orderId)
                .orElseThrow(() -> new GlobalException(DomainResultCode.ORDER_NOT_FOUND));
    }

    private boolean isBuyer(ArtOrder order, Long userId) {
        return userId != null && userId.equals(order.getBuyerId());
    }

    /** 작품의 작가와 같은 활동명으로 가입한 사용자에게 알린다(없으면 조용히 건너뛴다). */
    private void notifySeller(String artistName, NotificationType type,
                              String title, String message, Long targetId) {
        userRepository.findFirstByNickname(artistName).ifPresent(artist ->
                notificationService.publishTo(artist.getId(), type, title, message, targetId));
    }

    private OrderDto.Response toDto(ArtOrder order, boolean viewerIsSeller) {
        return new OrderDto.Response(
                order.getId(), order.getArtworkId(), order.getArtworkTitle(),
                order.getArtistName(), order.getAmount(), order.getPaymentMethod(),
                order.getStatus(), order.getCertificateNo(), order.getOrderedDate(),
                order.isRefunded(), order.isSellerConfirmed(), order.isBuyerConfirmed(),
                order.isPaid(), order.isCancelled(), viewerIsSeller, order.getBuyerName());
    }

    private static String blankToNull(String value) {
        return (value == null || value.isBlank()) ? null : value.trim();
    }
}
