package com.example.artnara.domain.certificate.repository;

import com.example.artnara.domain.certificate.entity.Ownership;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OwnershipRepository extends JpaRepository<Ownership, Long> {

    /** 소유권 목록은 반드시 소유자로 스코프한다(남의 소유권 노출 방지). */
    List<Ownership> findByOwnerIdOrderByIdDesc(Long ownerId);
}
