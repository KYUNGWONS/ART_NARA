package com.example.artnara.domain.recommendation.service;

import com.example.artnara.domain.content.entity.Theme;
import com.example.artnara.domain.recommendation.dto.RecommendationDto;
import com.example.artnara.domain.recommendation.entity.RecommendedActivity;
import com.example.artnara.domain.recommendation.entity.RecommendedPlace;
import com.example.artnara.domain.recommendation.repository.RecommendedActivityRepository;
import com.example.artnara.domain.recommendation.repository.RecommendedPlaceRepository;
import com.example.artnara.domain.user.entity.TravelStyle;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RecommendationService {

    // TravelStyle 각 축의 가정 범위(-100~100)에서 나올 수 있는 최대 유클리드 거리
    private static final double AXIS_RANGE = 200.0;
    private static final double MAX_DISTANCE = Math.sqrt(4 * AXIS_RANGE * AXIS_RANGE);
    private static final int NEUTRAL_SCORE = 50;

    private final RecommendedPlaceRepository recommendedPlaceRepository;
    private final RecommendedActivityRepository recommendedActivityRepository;
    private final UserRepository userRepository;

    public List<RecommendationDto.PlaceResponse> recommendPlaces(Long userId, Theme theme) {
        User user = findUser(userId);
        if (user.getRegion() == null) return List.of();

        List<RecommendedPlace> places = theme != null
                ? recommendedPlaceRepository.findAllBySidoAndTheme(user.getRegion(), theme)
                : recommendedPlaceRepository.findAllBySido(user.getRegion());

        return places.stream()
                .map(p -> RecommendationDto.PlaceResponse.of(p, matchScore(user.getTravelStyle(), p.getTravelStyle())))
                .sorted(Comparator.comparingInt(RecommendationDto.PlaceResponse::matchScore).reversed())
                .toList();
    }

    public List<RecommendationDto.ActivityResponse> recommendActivities(Long userId, Long placeId) {
        User user = findUser(userId);
        findPlace(placeId);

        return recommendedActivityRepository.findAllByPlaceId(placeId).stream()
                .map(a -> RecommendationDto.ActivityResponse.of(a, matchScore(user.getTravelStyle(), a.getTravelStyle())))
                .sorted(Comparator.comparingInt(RecommendationDto.ActivityResponse::matchScore).reversed())
                .toList();
    }

    /**
     * 두 TravelStyle 벡터 간 유클리드 거리를 0~100 매칭 점수로 변환한다.
     * 어느 한쪽이라도 travelStyle이 없으면(프로필 미완성 등) 중립 점수를 반환한다.
     */
    static int matchScore(TravelStyle a, TravelStyle b) {
        if (a == null || b == null) return NEUTRAL_SCORE;
        double distance = Math.sqrt(
                square(a.getPlanning() - b.getPlanning())
                        + square(a.getVibe() - b.getVibe())
                        + square(a.getRole() - b.getRole())
                        + square(a.getDynamic() - b.getDynamic())
        );
        double normalized = Math.min(distance / MAX_DISTANCE, 1.0);
        return (int) Math.round(100 - normalized * 100);
    }

    private static double square(int diff) {
        return (double) diff * diff;
    }

    private User findUser(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new GlobalException(DomainResultCode.USER_NOT_FOUND));
    }

    private RecommendedPlace findPlace(Long id) {
        return recommendedPlaceRepository.findById(id)
                .orElseThrow(() -> new GlobalException(DomainResultCode.RECOMMENDED_PLACE_NOT_FOUND));
    }
}
