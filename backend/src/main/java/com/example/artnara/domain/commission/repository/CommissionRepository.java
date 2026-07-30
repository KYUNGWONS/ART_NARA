package com.example.artnara.domain.commission.repository;

import com.example.artnara.domain.commission.entity.Commission;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CommissionRepository extends JpaRepository<Commission, Long> {

    List<Commission> findAllByOrderByIdDesc();
}
