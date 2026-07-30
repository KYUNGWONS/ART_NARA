package com.example.artnara.domain.sale.service;

import com.example.artnara.domain.sale.dto.SaleDto;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class SaleService {

    private final List<SaleDto.Response> sales = new ArrayList<>();
    private final AtomicLong idSequence = new AtomicLong(0);

    public synchronized SaleDto.Response create(SaleDto.CreateRequest request) {
        validate(request);
        SaleDto.Response sale = new SaleDto.Response(
                idSequence.incrementAndGet(),
                request.title().trim(),
                request.description() == null ? "" : request.description().trim(),
                request.medium() == null ? "" : request.medium().trim(),
                request.size() == null ? "" : request.size().trim(),
                request.year(),
                request.buyNowPrice(),
                request.auctionEnabled(),
                request.auctionEnabled() ? request.auctionStartPrice() : null,
                request.auctionEnabled() ? request.auctionEndDate() : null,
                request.imageUrl() == null ? "" : request.imageUrl().trim(),
                "검수 대기");
        sales.add(0, sale);
        return sale;
    }

    public synchronized SaleDto.ListResponse list() {
        return new SaleDto.ListResponse(List.copyOf(sales));
    }

    private void validate(SaleDto.CreateRequest request) {
        if (request.title() == null || request.title().isBlank()) {
            throw new GlobalException(DomainResultCode.SALE_TITLE_REQUIRED);
        }
        if (request.buyNowPrice() == null || request.buyNowPrice() <= 0) {
            throw new GlobalException(DomainResultCode.SALE_INVALID_PRICE);
        }
        if (request.auctionEnabled()) {
            if (request.auctionStartPrice() == null || request.auctionStartPrice() <= 0) {
                throw new GlobalException(DomainResultCode.SALE_INVALID_AUCTION,
                        "경매 최저가를 입력해주세요.");
            }
            if (request.auctionStartPrice() > request.buyNowPrice()) {
                throw new GlobalException(DomainResultCode.SALE_INVALID_AUCTION,
                        "경매 최저가는 즉시 판매가보다 높을 수 없습니다.");
            }
            if (request.auctionEndDate() == null || !request.auctionEndDate().isAfter(LocalDate.now())) {
                throw new GlobalException(DomainResultCode.SALE_INVALID_AUCTION,
                        "경매 마감일은 내일 이후여야 합니다.");
            }
        }
    }
}
