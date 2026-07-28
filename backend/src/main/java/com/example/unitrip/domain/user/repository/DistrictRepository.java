package com.example.unitrip.domain.user.repository;

import com.example.unitrip.domain.user.entity.District;
import com.example.unitrip.domain.user.entity.Sido;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DistrictRepository extends JpaRepository<District, Long> {
    List<District> findAllBySido(Sido sido);
}
