package com.example.artnara.domain.order.service;

import com.example.artnara.domain.artwork.dto.ArtworkDetailDto;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.domain.certificate.dto.CertificateDto;
import com.example.artnara.domain.certificate.service.CertificateService;
import com.example.artnara.domain.order.dto.OrderDto;
import com.example.artnara.domain.order.entity.ArtOrder;
import com.example.artnara.domain.order.repository.ArtOrderRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Set;

@Service
@RequiredArgsConstructor
@Transactional
public class OrderService {

    /** 배송 중개비 (전문 포장 + 배송, 사업계획서 기준 1~2만원) */
    private static final int DELIVERY_FEE = 15000;

    /** 프로토타입 단일 사용자 — ArtworkService.placeBid 가 기록하는 입찰자명과 동일해야 한다. */
    private static final String BUYER_NAME = "나";

    private static final Set<String> PAYMENT_METHODS =
            Set.of("CARD", "KAKAO_PAY", "NAVER_PAY", "TOSS");

    private final ArtOrderRepository artOrderRepository;
    private final ArtworkService artworkService;
    private final CertificateService certificateService;

    public OrderDto.Response create(OrderDto.CreateRequest request) {
        validate(request);
        ArtworkDetailDto artwork = artworkService.getDetail(request.artworkId());
        int amount = artwork.price();
        if (artwork.auction()) {
            // 경매 작품은 마감 후 낙찰자만 낙찰가로 결제할 수 있다.
            if (!artwork.auctionClosed()) {
                throw new GlobalException(DomainResultCode.ORDER_AUCTION_NOT_BUYABLE);
            }
            if (artwork.winnerName() == null) {
                throw new GlobalException(DomainResultCode.ORDER_AUCTION_NO_WINNER);
            }
            if (!BUYER_NAME.equals(artwork.winnerName())) {
                throw new GlobalException(DomainResultCode.ORDER_NOT_WINNER);
            }
            amount = artwork.currentBid();
        }
        if (artOrderRepository.existsByArtworkId(artwork.id())) {
            throw new GlobalException(DomainResultCode.ORDER_ALREADY_SOLD);
        }

        // mock PG 승인 → 결제 완료 처리
        String today = LocalDate.now().toString();
        ArtOrder order = artOrderRepository.save(ArtOrder.builder()
                .artworkId(artwork.id())
                .artworkTitle(artwork.title())
                .artistName(artwork.artistName())
                .price(amount)
                .deliveryFee(DELIVERY_FEE)
                .totalAmount(amount + DELIVERY_FEE)
                .paymentMethod(request.paymentMethod())
                .receiverName(request.receiverName().trim())
                .phone(request.phone())
                .deliveryAddress(request.deliveryAddress().trim())
                .status("결제 완료")
                .certificateNo("ARTNARA-2026-PENDING")
                .orderedDate(today)
                .build());
        String certificateNo = "ARTNARA-2026-" + (100 + order.getId());
        order.issueCertificate(certificateNo);

        // 거래 완료 → 디지털 소유권 자동 이전
        certificateService.register(new CertificateDto.Ownership(
                certificateNo, artwork.title(), artwork.artistName(), today, false));

        return toDto(order);
    }

    @Transactional(readOnly = true)
    public OrderDto.ListResponse list() {
        return new OrderDto.ListResponse(
                artOrderRepository.findAllByOrderByIdDesc().stream()
                        .map(this::toDto)
                        .toList());
    }

    private OrderDto.Response toDto(ArtOrder order) {
        return new OrderDto.Response(
                order.getId(), order.getArtworkId(), order.getArtworkTitle(),
                order.getArtistName(), order.getPrice(), order.getDeliveryFee(),
                order.getTotalAmount(), order.getPaymentMethod(),
                order.getReceiverName(), order.getDeliveryAddress(),
                order.getStatus(), order.getCertificateNo(), order.getOrderedDate());
    }

    private void validate(OrderDto.CreateRequest request) {
        if (request.artworkId() == null) {
            throw new GlobalException(DomainResultCode.ARTWORK_NOT_FOUND);
        }
        if (request.paymentMethod() == null
                || !PAYMENT_METHODS.contains(request.paymentMethod())) {
            throw new GlobalException(DomainResultCode.ORDER_INVALID_PAYMENT_METHOD);
        }
        if (request.receiverName() == null || request.receiverName().isBlank()
                || request.deliveryAddress() == null || request.deliveryAddress().isBlank()) {
            throw new GlobalException(DomainResultCode.ORDER_ADDRESS_REQUIRED);
        }
    }
}
