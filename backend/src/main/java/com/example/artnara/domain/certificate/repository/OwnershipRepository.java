package com.example.artnara.domain.certificate.repository;

import com.example.artnara.domain.certificate.entity.Ownership;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OwnershipRepository extends JpaRepository<Ownership, Long> {

    List<Ownership> findAllByOrderByIdDesc();
}
