package com.example.artnara.domain.brand.controller;

import com.example.artnara.domain.brand.dto.BrandIntroDto;
import com.example.artnara.domain.brand.dto.BrandValueDto;
import com.example.artnara.domain.brand.service.BrandService;
import com.example.artnara.domain.brand.service.BrandValueService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Brand", description = "ART NARA 브랜드 소개 API")
@RestController
@RequestMapping("/api/brand")
@RequiredArgsConstructor
public class BrandController {

    private final BrandService brandService;
    private final BrandValueService brandValueService;

    @GetMapping("/intro")
    @Operation(summary = "브랜드 소개 조회", description = "앱 첫 진입에 필요한 브랜드 소개 콘텐츠를 조회합니다.")
    public BaseResponse<BrandIntroDto> intro() {
        return BaseResponse.success("브랜드 소개 조회", brandService.getIntro());
    }

    @GetMapping("/value")
    @Operation(summary = "서비스 가치 소개 조회", description = "ART NARA의 신뢰 체계와 서비스 가치를 조회합니다.")
    public BaseResponse<BrandValueDto> value() {
        return BaseResponse.success("서비스 가치 소개 조회", brandValueService.getValue());
    }
}
