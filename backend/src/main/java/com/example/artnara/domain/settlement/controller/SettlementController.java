package com.example.artnara.domain.settlement.controller;

import com.example.artnara.domain.settlement.dto.SettlementDto;
import com.example.artnara.domain.settlement.service.SettlementService;
import com.example.artnara.global.auth.CurrentUser;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

@Tag(name = "Settlement", description = "작가 판매 정산 API")
@RestController
@RequestMapping("/api/settlements")
@RequiredArgsConstructor
public class SettlementController {

    private final SettlementService settlementService;
    private final CurrentUser currentUser;

    @GetMapping
    @Operation(summary = "내 판매 정산 조회",
            description = "로그인한 작가의 판매 금액·수수료·정산 예정액과 건별 내역을 조회합니다. "
                    + "환불된 주문은 합계에서 빠집니다.")
    public BaseResponse<SettlementDto> mySettlement(Principal principal) {
        // 정산 대상은 JWT 신원(활동명)으로만 정한다 — 파라미터로 남의 정산을 볼 수 없다.
        return BaseResponse.success("판매 정산 조회",
                settlementService.forArtist(currentUser.nicknameOf(principal)));
    }
}
