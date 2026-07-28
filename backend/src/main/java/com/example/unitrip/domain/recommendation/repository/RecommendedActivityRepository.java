package com.example.unitrip.domain.recommendation.repository;

import com.example.unitrip.domain.recommendation.entity.RecommendedActivity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RecommendedActivityRepository extends JpaRepository<RecommendedActivity, Long> {
    List<RecommendedActivity> findAllByPlaceId(Long placeId);
}
