package com.example.artnara.domain.recommendation.repository;

import com.example.artnara.domain.recommendation.entity.RecommendedActivity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RecommendedActivityRepository extends JpaRepository<RecommendedActivity, Long> {
    List<RecommendedActivity> findAllByPlaceId(Long placeId);
}
