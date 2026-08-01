package com.example.artnara.domain.certificate.dto;

import java.util.List;

public class CertificateDto {

    public record Ownership(
            String certificateNo,
            String artworkTitle,
            String artistName,
            String acquiredDate,
            boolean qrIssued
    ) {}

    /** 인증서 발급 요청 — 소유권 정보 + 인증서에 새길 작품 사양 */
    public record IssueRequest(
            String certificateNo,
            String artworkTitle,
            String artistName,
            String acquiredDate,
            Integer yearCreated,
            String sizeInfo,
            String medium
    ) {}

    public record ListResponse(List<Ownership> ownerships) {}

    public record ScanRequest(String qrCode) {}

    public record Certificate(
            String certificateNo,
            String artworkTitle,
            String artistName,
            String ownerName,
            String issuedDate,
            Integer yearCreated,
            String sizeInfo,
            String medium,
            boolean verified,
            String note
    ) {}
}
