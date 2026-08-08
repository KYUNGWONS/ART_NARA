package com.example.artnara.domain.order.controller;

import com.example.artnara.domain.order.dto.OrderDto;
import com.example.artnara.domain.order.service.OrderService;
import com.example.artnara.global.auth.CurrentUser;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

@Tag(name = "Order", description = "ART NARA 작품 구매/결제 API")
@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;
    private final CurrentUser currentUser;

    @PostMapping
    @Operation(summary = "작품 예약",
            description = "작품을 예약합니다. 배송이 없는 직거래라 결제는 만나서 수령을 확인한 뒤에 합니다. "
                    + "예약하면 작품이 잠겨 다른 사람이 살 수 없습니다.")
    public BaseResponse<OrderDto.Response> reserve(@RequestBody OrderDto.CreateRequest request,
                                                   Principal principal) {
        // 구매자·소유권자는 로그인 신원에서 정한다.
        return BaseResponse.success("작품 예약 완료", orderService.reserve(
                request, currentUser.idOf(principal), currentUser.nicknameOf(principal)));
    }

    @PostMapping("/{orderId}/handover")
    @Operation(summary = "수령 확인",
            description = "만나서 작품을 주고받았음을 확인합니다. 판매자는 '전달했어요', 구매자는 '받았어요' 로 "
                    + "기록되며, 양쪽이 모두 확인해야 결제할 수 있습니다.")
    public BaseResponse<OrderDto.Response> confirmHandover(@PathVariable Long orderId,
                                                           Principal principal) {
        return BaseResponse.success("수령 확인", orderService.confirmHandover(
                orderId, currentUser.idOf(principal), currentUser.nicknameOf(principal)));
    }

    @PostMapping("/{orderId}/pay")
    @Operation(summary = "결제",
            description = "양쪽 수령 확인이 끝난 예약을 결제합니다. 구매자만 호출할 수 있고, "
                    + "결제가 확정되면 작품이 판매 완료로 잠기고 디지털 소유권·인증서가 발급됩니다.")
    public BaseResponse<OrderDto.Response> pay(@PathVariable Long orderId,
                                               @RequestBody OrderDto.PayRequest request,
                                               Principal principal) {
        return BaseResponse.success("결제 완료", orderService.pay(
                orderId, request, currentUser.idOf(principal),
                currentUser.nicknameOf(principal)));
    }

    @PostMapping("/{orderId}/cancel")
    @Operation(summary = "예약 취소",
            description = "결제 전 예약을 취소합니다. 거래 당사자(판매자·구매자) 모두 취소할 수 있고 "
                    + "작품은 다시 판매 중으로 돌아갑니다.")
    public BaseResponse<Void> cancel(@PathVariable Long orderId, Principal principal) {
        orderService.cancel(orderId, currentUser.idOf(principal),
                currentUser.nicknameOf(principal));
        return BaseResponse.success("예약 취소", null);
    }

    @GetMapping
    @Operation(summary = "주문 내역 조회", description = "내가 구매(예약)한 내역을 최신순으로 조회합니다.")
    public BaseResponse<OrderDto.ListResponse> list(Principal principal) {
        return BaseResponse.success("주문 내역 조회",
                orderService.list(currentUser.idOf(principal)));
    }

    @GetMapping("/selling")
    @Operation(summary = "내 작품 거래 조회",
            description = "내 작품에 걸린 예약·거래를 조회합니다. 판매자가 '전달했어요' 를 누르는 화면에서 씁니다.")
    public BaseResponse<OrderDto.ListResponse> listSelling(Principal principal) {
        return BaseResponse.success("판매 거래 조회",
                orderService.listSelling(currentUser.nicknameOf(principal)));
    }
}
