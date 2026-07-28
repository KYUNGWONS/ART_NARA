package com.example.unitrip.domain.brand.controller;

import com.example.unitrip.domain.brand.dto.BrandIntroDto;
import com.example.unitrip.domain.brand.service.BrandService;
import com.example.unitrip.global.common.BaseResponse;
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

    @GetMapping("/intro")
    @Operation(summary = "브랜드 소개 조회", description = "앱 첫 진입에 필요한 브랜드 소개 콘텐츠를 조회합니다.")
    public BaseResponse<BrandIntroDto> intro() {
        return BaseResponse.success("브랜드 소개 조회", brandService.getIntro());
    }
}
