package com.example.artnara.domain.sale.controller;

import com.example.artnara.domain.sale.dto.SaleDto;
import com.example.artnara.domain.sale.service.SaleService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Sale", description = "ART NARA 작품 판매 등록 API")
@RestController
@RequestMapping("/api/sales")
@RequiredArgsConstructor
public class SaleController {

    private final SaleService saleService;

    @PostMapping
    @Operation(summary = "판매 등록", description = "즉시 판매가와 선택적 경매(최저가·마감일) 정보로 작품 판매를 등록합니다.")
    public BaseResponse<SaleDto.Response> create(@RequestBody SaleDto.CreateRequest request) {
        return BaseResponse.success("판매 등록", saleService.create(request));
    }

    @GetMapping
    @Operation(summary = "판매 목록 조회", description = "등록한 판매 작품 목록을 최신순으로 조회합니다.")
    public BaseResponse<SaleDto.ListResponse> list() {
        return BaseResponse.success("판매 목록 조회", saleService.list());
    }
}
