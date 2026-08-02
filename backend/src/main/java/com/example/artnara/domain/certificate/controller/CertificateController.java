package com.example.artnara.domain.certificate.controller;

import com.example.artnara.domain.certificate.dto.CertificateDto;
import com.example.artnara.domain.certificate.service.CertificateService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Certificate", description = "ART NARA 정품 인증·디지털 소유권 API")
@RestController
@RequestMapping("/api/certificates")
@RequiredArgsConstructor
public class CertificateController {

    private final CertificateService certificateService;

    @GetMapping
    @Operation(summary = "디지털 소유권 목록 조회", description = "구매 완료 후 발급된 내 디지털 소유권 목록을 조회합니다.")
    public BaseResponse<CertificateDto.ListResponse> list() {
        return BaseResponse.success("디지털 소유권 목록 조회", certificateService.listOwnerships());
    }

    @PostMapping("/scan")
    @Operation(summary = "정품 인증 QR 스캔", description = "작품 뒤에 부착된 QR 코드를 스캔하면 디지털 인증서를 조회합니다.")
    public BaseResponse<CertificateDto.Certificate> scan(
            @RequestBody CertificateDto.ScanRequest request) {
        return BaseResponse.success("정품 인증 조회", certificateService.scan(request));
    }
}
