package com.example.artnara.domain.certificate.repository;

import com.example.artnara.domain.certificate.entity.Certificate;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CertificateRepository extends JpaRepository<Certificate, Long> {

    Optional<Certificate> findByQrCodeIgnoreCase(String qrCode);

    /** 환불 회수용 — 발급 번호로 찾는다. */
    Optional<Certificate> findByCertificateNo(String certificateNo);
}
