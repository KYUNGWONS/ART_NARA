package com.example.artnara.domain.certificate.service;

import com.example.artnara.domain.certificate.dto.CertificateDto;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class CertificateService {

    private final List<CertificateDto.Ownership> ownerships = new ArrayList<>(List.of(
            new CertificateDto.Ownership(
                    "ARTNARA-2026-0001", "봄의 정원", "김예진", "2026-05-12", true),
            new CertificateDto.Ownership(
                    "ARTNARA-2026-0002", "무채색의 위로", "박소현", "2026-06-30", false)
    ));

    private static final Map<String, CertificateDto.Certificate> CERTIFICATES = Map.of(
            "ARTNARA-QR-0001", new CertificateDto.Certificate(
                    "ARTNARA-2026-0001", "봄의 정원", "김예진", "나",
                    "2026-05-12", true,
                    "블록체인 원장에 기록된 정품 인증 작품입니다."),
            "ARTNARA-QR-0002", new CertificateDto.Certificate(
                    "ARTNARA-2026-0002", "무채색의 위로", "박소현", "나",
                    "2026-06-30", true,
                    "블록체인 원장에 기록된 정품 인증 작품입니다.")
    );

    public synchronized CertificateDto.ListResponse listOwnerships() {
        return new CertificateDto.ListResponse(List.copyOf(ownerships));
    }

    /** 거래 완료 시 디지털 소유권을 구매자 계정으로 자동 이전(등록)한다. */
    public synchronized void register(CertificateDto.Ownership ownership) {
        ownerships.add(0, ownership);
    }

    public CertificateDto.Certificate scan(CertificateDto.ScanRequest request) {
        if (request.qrCode() == null || request.qrCode().isBlank()) {
            throw new GlobalException(DomainResultCode.CERTIFICATE_QR_REQUIRED);
        }
        CertificateDto.Certificate certificate =
                CERTIFICATES.get(request.qrCode().trim().toUpperCase());
        if (certificate == null) {
            throw new GlobalException(DomainResultCode.CERTIFICATE_NOT_FOUND);
        }
        return certificate;
    }
}
