package com.example.unitrip.domain.festival.repository;

import com.example.unitrip.domain.festival.entity.Festival;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FestivalRepository extends JpaRepository<Festival, Long> {
    List<Festival> findAllByRegion(String region);
}
