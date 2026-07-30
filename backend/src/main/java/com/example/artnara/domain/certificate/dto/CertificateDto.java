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

    public record ListResponse(List<Ownership> ownerships) {}

    public record ScanRequest(String qrCode) {}

    public record Certificate(
            String certificateNo,
            String artworkTitle,
            String artistName,
            String ownerName,
            String issuedDate,
            boolean verified,
            String note
    ) {}
}
