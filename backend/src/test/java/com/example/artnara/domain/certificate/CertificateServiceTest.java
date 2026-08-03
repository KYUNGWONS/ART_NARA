package com.example.artnara.domain.certificate;

import com.example.artnara.domain.certificate.dto.CertificateDto;
import com.example.artnara.domain.certificate.service.CertificateService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import com.example.artnara.support.IntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@IntegrationTest
class CertificateServiceTest {

    @Autowired
    CertificateService certificateService;

    /** 시드 소유권 2건의 주인 (ArtnaraDataInitializer 의 컬렉터 Andrew) */
    private static final long SEED_OWNER_ID = 3L;
    private static final long OTHER_USER_ID = 6L;

    @Test
    @DisplayName("디지털 소유권 목록은 내 것만 조회된다")
    void listOwnerships() {
        assertThat(certificateService.listOwnerships(SEED_OWNER_ID).ownerships()).hasSize(2);
    }

    @Test
    @DisplayName("남의 소유권은 내 목록에 보이지 않는다")
    void listOwnershipsScopedToOwner() {
        assertThat(certificateService.listOwnerships(OTHER_USER_ID).ownerships()).isEmpty();
    }

    @Test
    @DisplayName("소유권 등록 시 목록 최신순으로 추가된다")
    void register() {
        certificateService.register(new CertificateDto.IssueRequest(
                "ARTNARA-2026-9999", "새 작품", "나", "2026-07-31",
                2026, "40.0 x 40.0cm", "캔버스에 아크릴"), SEED_OWNER_ID, "Andrew");
        var ownerships = certificateService.listOwnerships(SEED_OWNER_ID).ownerships();
        assertThat(ownerships).hasSize(3);
        assertThat(ownerships.get(0).certificateNo()).isEqualTo("ARTNARA-2026-9999");
    }

    @Test
    @DisplayName("소유권 등록 시 QR 인증서도 발급되어 스캔된다")
    void registerIssuesScannableCertificate() {
        certificateService.register(new CertificateDto.IssueRequest(
                "ARTNARA-2026-7777", "새 작품", "나", "2026-07-31",
                2026, "40.0 x 40.0cm", "캔버스에 아크릴"), SEED_OWNER_ID, "Andrew");

        CertificateDto.Certificate certificate = certificateService.scan(
                new CertificateDto.ScanRequest("ARTNARA-QR-7777"));

        assertThat(certificate.artworkTitle()).isEqualTo("새 작품");
        assertThat(certificate.verified()).isTrue();
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
