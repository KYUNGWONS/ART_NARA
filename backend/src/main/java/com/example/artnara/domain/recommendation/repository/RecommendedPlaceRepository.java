package com.example.artnara.domain.recommendation.repository;

import com.example.artnara.domain.content.entity.Theme;
import com.example.artnara.domain.recommendation.entity.RecommendedPlace;
import com.example.artnara.domain.user.entity.Sido;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RecommendedPlaceRepository extends JpaRepository<RecommendedPlace, Long> {
    List<RecommendedPlace> findAllBySido(Sido sido);
    List<RecommendedPlace> findAllBySidoAndTheme(Sido sido, Theme theme);
}
