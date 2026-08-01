package com.example.artnara.domain.order.controller;

import com.example.artnara.domain.order.dto.OrderDto;
import com.example.artnara.domain.order.service.OrderService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Order", description = "DUST-ART 작품 구매/결제 API")
@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    @Operation(summary = "작품 구매(결제)",
            description = "결제 수단을 선택해 작품을 결제합니다. 결제 완료 시 디지털 소유권이 자동 발급됩니다.")
    public BaseResponse<OrderDto.Response> create(@RequestBody OrderDto.CreateRequest request) {
        return BaseResponse.success("작품 결제 완료", orderService.create(request));
    }

    @GetMapping
    @Operation(summary = "주문 내역 조회", description = "내 주문 내역을 최신순으로 조회합니다.")
    public BaseResponse<OrderDto.ListResponse> list() {
        return BaseResponse.success("주문 내역 조회", orderService.list());
    }
}
