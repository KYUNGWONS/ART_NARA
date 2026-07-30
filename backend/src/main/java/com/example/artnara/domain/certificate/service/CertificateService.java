package com.example.artnara.domain.certificate.service;

import com.example.artnara.domain.certificate.dto.CertificateDto;
import com.example.artnara.domain.certificate.entity.Ownership;
import com.example.artnara.domain.certificate.repository.OwnershipRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional
public class CertificateService {

    // QR 코드 → 디지털 인증서 mock (실서비스에서는 블록체인 원장 조회로 대체)
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

    private final OwnershipRepository ownershipRepository;

    @Transactional(readOnly = true)
    public CertificateDto.ListResponse listOwnerships() {
        return new CertificateDto.ListResponse(
                ownershipRepository.findAllByOrderByIdDesc().stream()
                        .map(ownership -> new CertificateDto.Ownership(
                                ownership.getCertificateNo(), ownership.getArtworkTitle(),
                                ownership.getArtistName(), ownership.getAcquiredDate(),
                                ownership.isQrIssued()))
                        .toList());
    }

    /** 거래 완료 시 디지털 소유권을 구매자 계정으로 자동 이전(등록)한다. */
    public void register(CertificateDto.Ownership ownership) {
        ownershipRepository.save(Ownership.builder()
                .certificateNo(ownership.certificateNo())
                .artworkTitle(ownership.artworkTitle())
                .artistName(ownership.artistName())
                .acquiredDate(ownership.acquiredDate())
                .qrIssued(ownership.qrIssued())
                .build());
    }

    @Transactional(readOnly = true)
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
