package com.example.artnara.domain.festival.repository;

import com.example.artnara.domain.festival.entity.Festival;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FestivalRepository extends JpaRepository<Festival, Long> {
    List<Festival> findAllByRegion(String region);
}
