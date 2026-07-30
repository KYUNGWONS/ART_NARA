package com.example.artnara.domain.recommendation.repository;

import com.example.artnara.domain.recommendation.entity.RecommendedContent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RecommendedContentRepository extends JpaRepository<RecommendedContent, Long> {
    List<RecommendedContent> findAllByDistrict_Id(Long districtId);
}
