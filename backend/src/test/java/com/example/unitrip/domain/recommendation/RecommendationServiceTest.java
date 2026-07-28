package com.example.unitrip.domain.recommendation;

import com.example.unitrip.domain.content.entity.Theme;
import com.example.unitrip.domain.recommendation.dto.RecommendationDto;
import com.example.unitrip.domain.recommendation.entity.RecommendedActivity;
import com.example.unitrip.domain.recommendation.entity.RecommendedPlace;
import com.example.unitrip.domain.recommendation.repository.RecommendedActivityRepository;
import com.example.unitrip.domain.recommendation.repository.RecommendedPlaceRepository;
import com.example.unitrip.domain.recommendation.service.RecommendationService;
import com.example.unitrip.domain.user.entity.Sido;
import com.example.unitrip.domain.user.entity.TravelStyle;
import com.example.unitrip.domain.user.entity.User;
import com.example.unitrip.domain.user.entity.UserType;
import com.example.unitrip.domain.user.repository.UserRepository;
import com.example.unitrip.global.common.DomainResultCode;
import com.example.unitrip.global.exception.GlobalException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.never;

@ExtendWith(MockitoExtension.class)
class RecommendationServiceTest {

    @Mock RecommendedPlaceRepository recommendedPlaceRepository;
    @Mock RecommendedActivityRepository recommendedActivityRepository;
    @Mock UserRepository userRepository;
    @InjectMocks RecommendationService recommendationService;

    private User createUser(Sido region, TravelStyle travelStyle) {
        User user = User.builder().email("a@t.com").nickname("a").userType(UserType.KOREAN_STUDENT)
                .region(region).travelStyle(travelStyle).build();
        ReflectionTestUtils.setField(user, "id", 1L);
        return user;
    }

    private RecommendedPlace createPlace(Long id, Sido sido, Theme theme, TravelStyle travelStyle) {
        RecommendedPlace place = RecommendedPlace.builder()
                .sido(sido).theme(theme).name("place-" + id).imageUrl("img.jpg").travelStyle(travelStyle).build();
        ReflectionTestUtils.setField(place, "id", id);
        return place;
    }

    private RecommendedActivity createActivity(Long id, TravelStyle travelStyle) {
        RecommendedActivity activity = RecommendedActivity.builder()
                .name("activity-" + id).imageUrl("img.jpg").travelStyle(travelStyle).build();
        ReflectionTestUtils.setField(activity, "id", id);
        return activity;
    }

    @Test
    @DisplayName("동일한 여행스타일 벡터는 매칭 점수 100")
    void recommendPlaces_identicalVector_scoresHundred() {
        TravelStyle style = new TravelStyle(10, 20, 30, 40);
        User user = createUser(Sido.SEOUL, style);
        RecommendedPlace place = createPlace(1L, Sido.SEOUL, Theme.PLACE, new TravelStyle(10, 20, 30, 40));

        given(userRepository.findById(1L)).willReturn(Optional.of(user));
        given(recommendedPlaceRepository.findAllBySido(Sido.SEOUL)).willReturn(List.of(place));

        List<RecommendationDto.PlaceResponse> result = recommendationService.recommendPlaces(1L, null);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).matchScore()).isEqualTo(100);
    }

    @Test
    @DisplayName("정반대 여행스타일 벡터는 매칭 점수 0에 가까움")
    void recommendPlaces_oppositeVector_scoresNearZero() {
        User user = createUser(Sido.SEOUL, new TravelStyle(-100, -100, -100, -100));
        RecommendedPlace place = createPlace(1L, Sido.SEOUL, Theme.PLACE, new TravelStyle(100, 100, 100, 100));

        given(userRepository.findById(1L)).willReturn(Optional.of(user));
        given(recommendedPlaceRepository.findAllBySido(Sido.SEOUL)).willReturn(List.of(place));

        List<RecommendationDto.PlaceResponse> result = recommendationService.recommendPlaces(1L, null);

        assertThat(result.get(0).matchScore()).isZero();
    }

    @Test
    @DisplayName("매칭 점수 내림차순으로 정렬되어 반환")
    void recommendPlaces_sortedByScoreDescending() {
        TravelStyle userStyle = new TravelStyle(0, 0, 0, 0);
        User user = createUser(Sido.SEOUL, userStyle);
        RecommendedPlace closePlace = createPlace(1L, Sido.SEOUL, Theme.PLACE, new TravelStyle(10, 10, 10, 10));
        RecommendedPlace farPlace = createPlace(2L, Sido.SEOUL, Theme.PLACE, new TravelStyle(100, 100, 100, 100));

        given(userRepository.findById(1L)).willReturn(Optional.of(user));
        given(recommendedPlaceRepository.findAllBySido(Sido.SEOUL)).willReturn(List.of(farPlace, closePlace));

        List<RecommendationDto.PlaceResponse> result = recommendationService.recommendPlaces(1L, null);

        assertThat(result).extracting(RecommendationDto.PlaceResponse::id).containsExactly(1L, 2L);
    }

    @Test
    @DisplayName("테마가 주어지면 지역+테마로 필터링")
    void recommendPlaces_withTheme_filtersByTheme() {
        User user = createUser(Sido.SEOUL, new TravelStyle(0, 0, 0, 0));
        given(userRepository.findById(1L)).willReturn(Optional.of(user));
        given(recommendedPlaceRepository.findAllBySidoAndTheme(Sido.SEOUL, Theme.ACTIVITY)).willReturn(List.of());

        recommendationService.recommendPlaces(1L, Theme.ACTIVITY);

        verify(recommendedPlaceRepository).findAllBySidoAndTheme(Sido.SEOUL, Theme.ACTIVITY);
        verify(recommendedPlaceRepository, never()).findAllBySido(any());
    }

    @Test
    @DisplayName("거주지역이 없으면 빈 목록 반환")
    void recommendPlaces_noRegion_returnsEmpty() {
        User user = createUser(null, new TravelStyle(0, 0, 0, 0));
        given(userRepository.findById(1L)).willReturn(Optional.of(user));

        List<RecommendationDto.PlaceResponse> result = recommendationService.recommendPlaces(1L, null);

        assertThat(result).isEmpty();
        verify(recommendedPlaceRepository, never()).findAllBySido(any());
    }

    @Test
    @DisplayName("여행스타일이 없으면 중립 점수(50) 반환")
    void recommendPlaces_noTravelStyle_returnsNeutralScore() {
        User user = createUser(Sido.SEOUL, null);
        RecommendedPlace place = createPlace(1L, Sido.SEOUL, Theme.PLACE, new TravelStyle(10, 20, 30, 40));

        given(userRepository.findById(1L)).willReturn(Optional.of(user));
        given(recommendedPlaceRepository.findAllBySido(Sido.SEOUL)).willReturn(List.of(place));

        List<RecommendationDto.PlaceResponse> result = recommendationService.recommendPlaces(1L, null);

        assertThat(result.get(0).matchScore()).isEqualTo(50);
    }

    @Test
    @DisplayName("장소별 추천 활동을 매칭 점수 내림차순으로 반환")
    void recommendActivities_sortedByScoreDescending() {
        TravelStyle userStyle = new TravelStyle(0, 0, 0, 0);
        User user = createUser(Sido.SEOUL, userStyle);
        RecommendedPlace place = createPlace(1L, Sido.SEOUL, Theme.PLACE, new TravelStyle(0, 0, 0, 0));
        RecommendedActivity closeActivity = createActivity(10L, new TravelStyle(5, 5, 5, 5));
        RecommendedActivity farActivity = createActivity(20L, new TravelStyle(100, 100, 100, 100));

        given(userRepository.findById(1L)).willReturn(Optional.of(user));
        given(recommendedPlaceRepository.findById(1L)).willReturn(Optional.of(place));
        given(recommendedActivityRepository.findAllByPlaceId(1L)).willReturn(List.of(farActivity, closeActivity));

        List<RecommendationDto.ActivityResponse> result = recommendationService.recommendActivities(1L, 1L);

        assertThat(result).extracting(RecommendationDto.ActivityResponse::id).containsExactly(10L, 20L);
    }

    @Test
    @DisplayName("존재하지 않는 장소로 활동 추천 조회 시 예외")
    void recommendActivities_placeNotFound_throws() {
        User user = createUser(Sido.SEOUL, new TravelStyle(0, 0, 0, 0));
        given(userRepository.findById(1L)).willReturn(Optional.of(user));
        given(recommendedPlaceRepository.findById(99L)).willReturn(Optional.empty());

        assertThatThrownBy(() -> recommendationService.recommendActivities(1L, 99L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.RECOMMENDED_PLACE_NOT_FOUND);
    }
}
