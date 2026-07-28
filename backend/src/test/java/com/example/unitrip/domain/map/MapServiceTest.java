package com.example.unitrip.domain.map;

import com.example.unitrip.domain.content.dto.ContentDto;
import com.example.unitrip.domain.content.service.ContentService;
import com.example.unitrip.domain.map.dto.MapDto;
import com.example.unitrip.domain.map.service.MapService;
import com.example.unitrip.domain.recommendation.entity.RecommendedContent;
import com.example.unitrip.domain.recommendation.entity.RecommendedContentActivity;
import com.example.unitrip.domain.recommendation.repository.RecommendedContentActivityRepository;
import com.example.unitrip.domain.recommendation.repository.RecommendedContentRepository;
import com.example.unitrip.domain.user.entity.District;
import com.example.unitrip.domain.user.entity.Sido;
import com.example.unitrip.domain.user.repository.DistrictRepository;
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

@ExtendWith(MockitoExtension.class)
class MapServiceTest {

    @Mock DistrictRepository districtRepository;
    @Mock UserRepository userRepository;
    @Mock ContentService contentService;
    @Mock RecommendedContentRepository recommendedContentRepository;
    @Mock RecommendedContentActivityRepository recommendedContentActivityRepository;
    @InjectMocks MapService mapService;

    private District createDistrict(Long id, Sido sido, String name) {
        District district = District.builder().sido(sido).name(name).latitude(35.0).longitude(129.0).build();
        ReflectionTestUtils.setField(district, "id", id);
        return district;
    }

    @Test
    @DisplayName("시/도 단위 지도는 17개 시/도 전부를 좌표·메이트 수와 함께 반환")
    void getSidoMap_returnsAllSidoWithMateCount() {
        given(userRepository.countByDistrict_SidoAndMatchingEnabledTrue(any())).willReturn(0L);
        given(userRepository.countByDistrict_SidoAndMatchingEnabledTrue(Sido.BUSAN)).willReturn(2L);

        List<MapDto.SidoResponse> result = mapService.getSidoMap();

        assertThat(result).hasSize(Sido.values().length);
        MapDto.SidoResponse busan = result.stream().filter(r -> r.sido() == Sido.BUSAN).findFirst().orElseThrow();
        assertThat(busan.label()).isEqualTo("부산");
        assertThat(busan.mateCount()).isEqualTo(2L);
    }

    @Test
    @DisplayName("구 단위 지도는 해당 시/도의 구 목록을 메이트 수와 함께 반환")
    void getDistricts_returnsDistrictsWithMateCount() {
        District haeundae = createDistrict(9L, Sido.BUSAN, "해운대구");
        given(districtRepository.findAllBySido(Sido.BUSAN)).willReturn(List.of(haeundae));
        given(userRepository.countByDistrictAndMatchingEnabledTrue(haeundae)).willReturn(4L);

        List<MapDto.DistrictResponse> result = mapService.getDistricts(Sido.BUSAN);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).name()).isEqualTo("해운대구");
        assertThat(result.get(0).mateCount()).isEqualTo(4L);
    }

    @Test
    @DisplayName("구 메이트 수 조회 성공")
    void getDistrictMates_success() {
        District haeundae = createDistrict(9L, Sido.BUSAN, "해운대구");
        given(districtRepository.findById(9L)).willReturn(Optional.of(haeundae));
        given(userRepository.countByDistrictAndMatchingEnabledTrue(haeundae)).willReturn(4L);

        MapDto.DistrictMateResponse result = mapService.getDistrictMates(9L);

        assertThat(result.districtId()).isEqualTo(9L);
        assertThat(result.name()).isEqualTo("해운대구");
        assertThat(result.mateCount()).isEqualTo(4L);
    }

    @Test
    @DisplayName("존재하지 않는 구의 메이트 수 조회 시 예외")
    void getDistrictMates_notFound_throws() {
        given(districtRepository.findById(999L)).willReturn(Optional.empty());

        assertThatThrownBy(() -> mapService.getDistrictMates(999L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.DISTRICT_NOT_FOUND);
    }

    @Test
    @DisplayName("구 컨텐츠 둘러보기는 그 구의 콘텐츠 목록과 소속 시 설명·태그를 함께 반환")
    void getDistrictContents_returnsContentsWithSidoDescription() {
        District haeundae = createDistrict(9L, Sido.BUSAN, "해운대구");
        given(districtRepository.findById(9L)).willReturn(Optional.of(haeundae));
        given(contentService.listByDistrict(9L)).willReturn(List.<ContentDto.Response>of());
        given(recommendedContentRepository.findAllByDistrict_Id(9L)).willReturn(List.of());

        MapDto.DistrictContentsResponse result = mapService.getDistrictContents(9L);

        assertThat(result.districtName()).isEqualTo("해운대구");
        assertThat(result.sido()).isEqualTo(Sido.BUSAN);
        assertThat(result.sidoLabel()).isEqualTo("부산");
        assertThat(result.sidoDescription()).isNotBlank();
        assertThat(result.sidoTags()).isNotEmpty();
        assertThat(result.contents()).isEmpty();
        assertThat(result.recommendedContents()).isEmpty();
    }

    @Test
    @DisplayName("구 컨텐츠 둘러보기는 그 구에 배정된 추천 컨텐츠를 카드 형태로 반환")
    void getDistrictContents_returnsRecommendedContentCards() {
        District wansan = createDistrict(26L, Sido.JEONBUK, "완산구");
        given(districtRepository.findById(26L)).willReturn(Optional.of(wansan));
        given(contentService.listByDistrict(26L)).willReturn(List.of());
        RecommendedContent content = RecommendedContent.builder()
                .district(wansan).name("전주 한옥마을 투어").imageUrl("img.jpg")
                .location("완산구 한옥마을").rating(4.9).build();
        ReflectionTestUtils.setField(content, "id", 1L);
        given(recommendedContentRepository.findAllByDistrict_Id(26L)).willReturn(List.of(content));

        MapDto.DistrictContentsResponse result = mapService.getDistrictContents(26L);

        assertThat(result.recommendedContents()).hasSize(1);
        MapDto.RecommendedContentResponse card = result.recommendedContents().get(0);
        assertThat(card.name()).isEqualTo("전주 한옥마을 투어");
        assertThat(card.location()).isEqualTo("완산구 한옥마을");
        assertThat(card.rating()).isEqualTo(4.9);
    }

    @Test
    @DisplayName("추천 컨텐츠 상세 조회는 제안 문구·콘텐츠 아이디어·이런 걸 해보세요 목록을 함께 반환")
    void getRecommendedContentDetail_returnsFullDetail() {
        District wansan = createDistrict(26L, Sido.JEONBUK, "완산구");
        RecommendedContent content = RecommendedContent.builder()
                .district(wansan).name("전주 한옥마을 투어").imageUrl("img.jpg")
                .suggestions(List.of("한복 입고 인생샷 남기기")).location("완산구 한옥마을").rating(4.9)
                .contentIdeas(List.of("포토 에세이")).build();
        ReflectionTestUtils.setField(content, "id", 1L);
        given(recommendedContentRepository.findById(1L)).willReturn(Optional.of(content));

        RecommendedContentActivity activity = RecommendedContentActivity.builder()
                .recommendedContent(content).name("한복 대여").imageUrl("img.jpg")
                .description("전통 한복을 빌려 골목을 누벼보세요").build();
        ReflectionTestUtils.setField(activity, "id", 1L);
        given(recommendedContentActivityRepository.findAllByRecommendedContentId(1L)).willReturn(List.of(activity));

        MapDto.RecommendedContentDetailResponse result = mapService.getRecommendedContentDetail(1L);

        assertThat(result.suggestions()).containsExactly("한복 입고 인생샷 남기기");
        assertThat(result.contentIdeas()).containsExactly("포토 에세이");
        assertThat(result.activities()).hasSize(1);
        assertThat(result.activities().get(0).name()).isEqualTo("한복 대여");
    }

    @Test
    @DisplayName("존재하지 않는 추천 컨텐츠 상세 조회 시 예외")
    void getRecommendedContentDetail_notFound_throws() {
        given(recommendedContentRepository.findById(999L)).willReturn(Optional.empty());

        assertThatThrownBy(() -> mapService.getRecommendedContentDetail(999L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.RECOMMENDED_CONTENT_NOT_FOUND);
    }
}
