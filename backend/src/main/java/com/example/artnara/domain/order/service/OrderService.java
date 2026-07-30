package com.example.artnara.domain.order.service;

import com.example.artnara.domain.artwork.dto.ArtworkDetailDto;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.domain.certificate.dto.CertificateDto;
import com.example.artnara.domain.certificate.service.CertificateService;
import com.example.artnara.domain.order.dto.OrderDto;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.atomic.AtomicLong;

@Service
@RequiredArgsConstructor
public class OrderService {

    /** 배송 중개비 (전문 포장 + 배송, 사업계획서 기준 1~2만원) */
    private static final int DELIVERY_FEE = 15000;

    private static final Set<String> PAYMENT_METHODS =
            Set.of("CARD", "KAKAO_PAY", "NAVER_PAY", "TOSS");

    private final ArtworkService artworkService;
    private final CertificateService certificateService;

    private final List<OrderDto.Response> orders = new ArrayList<>();
    private final Set<Long> soldArtworkIds = new HashSet<>();
    private final AtomicLong idSequence = new AtomicLong(0);
    private final AtomicLong certificateSequence = new AtomicLong(100);

    public synchronized OrderDto.Response create(OrderDto.CreateRequest request) {
        validate(request);
        ArtworkDetailDto artwork = artworkService.getDetail(request.artworkId());
        if (artwork.auction()) {
            throw new GlobalException(DomainResultCode.ORDER_AUCTION_NOT_BUYABLE);
        }
        if (soldArtworkIds.contains(artwork.id())) {
            throw new GlobalException(DomainResultCode.ORDER_ALREADY_SOLD);
        }

        // mock PG 승인 → 결제 완료 처리
        String certificateNo = "ARTNARA-2026-" + certificateSequence.incrementAndGet();
        String today = LocalDate.now().toString();

        OrderDto.Response order = new OrderDto.Response(
                idSequence.incrementAndGet(),
                artwork.id(), artwork.title(), artwork.artistName(),
                artwork.price(), DELIVERY_FEE, artwork.price() + DELIVERY_FEE,
                request.paymentMethod(),
                request.receiverName().trim(),
                request.deliveryAddress().trim(),
                "결제 완료", certificateNo, today);

        soldArtworkIds.add(artwork.id());
        orders.add(0, order);

        // 거래 완료 → 디지털 소유권 자동 이전
        certificateService.register(new CertificateDto.Ownership(
                certificateNo, artwork.title(), artwork.artistName(), today, false));

        return order;
    }

    public synchronized OrderDto.ListResponse list() {
        return new OrderDto.ListResponse(List.copyOf(orders));
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
