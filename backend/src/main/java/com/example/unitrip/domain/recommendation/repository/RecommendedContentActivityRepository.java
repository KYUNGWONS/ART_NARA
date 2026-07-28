package com.example.unitrip.domain.recommendation.repository;

import com.example.unitrip.domain.recommendation.entity.RecommendedContentActivity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RecommendedContentActivityRepository extends JpaRepository<RecommendedContentActivity, Long> {
    List<RecommendedContentActivity> findAllByRecommendedContentId(Long recommendedContentId);
}
