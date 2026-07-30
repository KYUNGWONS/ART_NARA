package com.example.artnara.domain.certificate;

import com.example.artnara.domain.certificate.dto.CertificateDto;
import com.example.artnara.domain.certificate.service.CertificateService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class CertificateServiceTest {

    private final CertificateService certificateService = new CertificateService();

    @Test
    @DisplayName("디지털 소유권 목록 조회")
    void listOwnerships() {
        assertThat(certificateService.listOwnerships().ownerships()).hasSize(2);
    }

    @Test
    @DisplayName("QR 스캔 성공 시 인증서를 반환한다 (대소문자 무시)")
    void scan() {
        CertificateDto.Certificate certificate = certificateService.scan(
                new CertificateDto.ScanRequest("artnara-qr-0001"));
        assertThat(certificate.artworkTitle()).isEqualTo("봄의 정원");
        assertThat(certificate.verified()).isTrue();
    }

    @Test
    @DisplayName("등록되지 않은 QR 코드 스캔 시 404")
    void scanUnknownCode() {
        assertThatThrownBy(() -> certificateService.scan(
                new CertificateDto.ScanRequest("UNKNOWN-QR")))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.CERTIFICATE_NOT_FOUND);
    }

    @Test
    @DisplayName("빈 QR 코드 스캔 시 400")
    void scanBlankCode() {
        assertThatThrownBy(() -> certificateService.scan(
                new CertificateDto.ScanRequest(" ")))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.CERTIFICATE_QR_REQUIRED);
    }
}
