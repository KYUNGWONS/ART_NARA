package com.example.artnara.domain.commission.controller;

import com.example.artnara.domain.commission.dto.CommissionDto;
import com.example.artnara.domain.commission.service.CommissionService;
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

@Tag(name = "Commission", description = "DUST-ART 제작 의뢰(역경매) API")
@RestController
@RequestMapping("/api/commissions")
@RequiredArgsConstructor
public class CommissionController {

    private final CommissionService commissionService;

    @PostMapping
    @Operation(summary = "제작 의뢰 등록",
            description = "요청사항과 예산으로 제작 의뢰를 등록하면 해당 카테고리 매칭 작가 전원에게 알림이 발송됩니다.")
    public BaseResponse<CommissionDto.Response> create(@RequestBody CommissionDto.CreateRequest request) {
        return BaseResponse.success("제작 의뢰 등록", commissionService.create(request));
    }

    @GetMapping
    @Operation(summary = "제작 의뢰 목록 조회", description = "등록한 제작 의뢰와 작가 제안 현황을 최신순으로 조회합니다.")
    public BaseResponse<CommissionDto.ListResponse> list() {
        return BaseResponse.success("제작 의뢰 목록 조회", commissionService.list());
    }

    @PostMapping("/{commissionId}/offers")
    @Operation(summary = "작가 제안 등록", description = "역경매 방식으로 현재 최저가보다 낮은 금액만 제안할 수 있습니다.")
    public BaseResponse<CommissionDto.Response> placeOffer(
            @PathVariable Long commissionId,
            @RequestBody CommissionDto.OfferRequest request) {
        return BaseResponse.success("작가 제안 등록", commissionService.placeOffer(commissionId, request));
    }
}
