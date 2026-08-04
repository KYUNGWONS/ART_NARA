package com.example.artnara.domain.certificate.service;

import com.example.artnara.domain.certificate.dto.CertificateDto;
import com.example.artnara.domain.certificate.entity.Certificate;
import com.example.artnara.domain.certificate.entity.Ownership;
import com.example.artnara.domain.certificate.repository.CertificateRepository;
import com.example.artnara.domain.certificate.repository.OwnershipRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class CertificateService {

    private static final String CERT_NOTE = "ART NARA 가 소유권 이력을 보증하는 작품입니다.";

    private final OwnershipRepository ownershipRepository;
    private final CertificateRepository certificateRepository;

    /** 로그인 사용자 본인의 소유권만 내려준다. */
    @Transactional(readOnly = true)
    public CertificateDto.ListResponse listOwnerships(Long ownerId) {
        return new CertificateDto.ListResponse(
                ownershipRepository.findByOwnerIdOrderByIdDesc(ownerId).stream()
                        .map(ownership -> new CertificateDto.Ownership(
                                ownership.getCertificateNo(), ownership.getArtworkTitle(),
                                ownership.getArtistName(), ownership.getAcquiredDate(),
                                ownership.isQrIssued()))
                        .toList());
    }

    /**
     * 거래 완료 시 디지털 소유권을 구매자 계정으로 자동 이전하고,
     * 같은 인증 번호로 QR 소유권 인증서도 발급한다.
     * QR 코드는 "ARTNARA-QR-{인증번호 끝자리}" 형식.
     */
    public void register(CertificateDto.IssueRequest request, Long ownerId, String ownerName) {
        ownershipRepository.save(Ownership.builder()
                .ownerId(ownerId)
                .certificateNo(request.certificateNo())
                .artworkTitle(request.artworkTitle())
                .artistName(request.artistName())
                .acquiredDate(request.acquiredDate())
                .qrIssued(true)
                .build());
        certificateRepository.save(Certificate.builder()
                .qrCode(qrCodeOf(request.certificateNo()))
                .certificateNo(request.certificateNo())
                .artworkTitle(request.artworkTitle())
                .artistName(request.artistName())
                .ownerName(ownerName)
                .issuedDate(request.acquiredDate())
                .yearCreated(request.yearCreated())
                .sizeInfo(request.sizeInfo())
                .medium(request.medium())
                .verified(true)
                .note(CERT_NOTE)
                .build());
    }

    @Transactional(readOnly = true)
    public CertificateDto.Certificate scan(CertificateDto.ScanRequest request) {
        if (request.qrCode() == null || request.qrCode().isBlank()) {
            throw new GlobalException(DomainResultCode.CERTIFICATE_QR_REQUIRED);
        }
        Certificate certificate = certificateRepository
                .findByQrCodeIgnoreCase(request.qrCode().trim())
                .orElseThrow(() ->
                        new GlobalException(DomainResultCode.CERTIFICATE_NOT_FOUND));
        return new CertificateDto.Certificate(
                certificate.getCertificateNo(), certificate.getArtworkTitle(),
                certificate.getArtistName(), certificate.getOwnerName(),
                certificate.getIssuedDate(), certificate.getYearCreated(),
                certificate.getSizeInfo(), certificate.getMedium(),
                certificate.isVerified(), certificate.getNote());
    }

    /** ARTNARA-2026-0001 → ARTNARA-QR-0001 */
    public static String qrCodeOf(String certificateNo) {
        int idx = certificateNo.lastIndexOf('-');
        return "ARTNARA-QR-" + certificateNo.substring(idx + 1);
    }
}
