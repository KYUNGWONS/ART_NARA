package com.example.artnara.domain.certificate.repository;

import com.example.artnara.domain.certificate.entity.Ownership;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OwnershipRepository extends JpaRepository<Ownership, Long> {

    /** 소유권 목록은 반드시 소유자로 스코프한다(남의 소유권 노출 방지). 환불로 회수된 건 뺀다. */
    List<Ownership> findByOwnerIdAndRevokedFalseOrderByIdDesc(Long ownerId);

    /** 환불 회수용 — 인증서 번호로 찾는다. */
    List<Ownership> findByCertificateNo(String certificateNo);
}
