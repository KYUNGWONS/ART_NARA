package com.example.artnara.domain.map.service;

import com.example.artnara.domain.content.dto.ContentDto;
import com.example.artnara.domain.content.service.ContentService;
import com.example.artnara.domain.map.dto.MapDto;
import com.example.artnara.domain.recommendation.entity.RecommendedContent;
import com.example.artnara.domain.recommendation.repository.RecommendedContentActivityRepository;
import com.example.artnara.domain.recommendation.repository.RecommendedContentRepository;
import com.example.artnara.domain.user.entity.District;
import com.example.artnara.domain.user.entity.Sido;
import com.example.artnara.domain.user.repository.DistrictRepository;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.EnumMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MapService {

    // 시/도 대표 좌표·한글 라벨·소개문·특징 태그. Sido는 행정구역 enum이라 이 정보들을 갖지 않으므로 여기서 보강한다.
    private record SidoInfo(String label, double latitude, double longitude, String description, List<String> tags) {}

    private static final Map<Sido, SidoInfo> SIDO_INFO = new EnumMap<>(Sido.class);
    static {
        SIDO_INFO.put(Sido.SEOUL, new SidoInfo("서울", 37.5665, 126.9780,
                "대한민국의 수도이자 정치·경제·문화의 중심지.", List.of("강남", "홍대", "한강", "K-POP")));
        SIDO_INFO.put(Sido.BUSAN, new SidoInfo("부산", 35.1796, 129.0756,
                "대한민국 제2의 도시이자 대표적인 해양 관광 도시.", List.of("해운대", "감천문화마을", "해산물", "야경")));
        SIDO_INFO.put(Sido.DAEGU, new SidoInfo("대구", 35.8714, 128.6014,
                "내륙 분지에 자리한 섬유·패션 산업의 중심지.", List.of("동성로", "근대골목", "팔공산", "야시장")));
        SIDO_INFO.put(Sido.INCHEON, new SidoInfo("인천", 37.4563, 126.7052,
                "국제공항과 항구를 낀 수도권의 관문 도시.", List.of("차이나타운", "월미도", "개항누리길", "공항")));
        SIDO_INFO.put(Sido.GWANGJU, new SidoInfo("광주", 35.1595, 126.8526,
                "예향(藝鄕)이라 불리는 호남 지역의 중심 도시.", List.of("예술의거리", "무등산", "양림동", "5·18")));
        SIDO_INFO.put(Sido.DAEJEON, new SidoInfo("대전", 36.3504, 127.3845,
                "과학과 행정 기능이 모인 중부권 교통의 요지.", List.of("성심당", "엑스포", "유성온천", "대청호")));
        SIDO_INFO.put(Sido.ULSAN, new SidoInfo("울산", 35.5384, 129.3114,
                "국내 대표 산업도시이자 자동차·조선 산업의 중심지.", List.of("태화강", "간절곶", "고래", "조선소")));
        SIDO_INFO.put(Sido.SEJONG, new SidoInfo("세종", 36.4801, 127.2890,
                "행정중심복합도시로 조성된 대한민국의 행정수도.", List.of("정부청사", "호수공원", "국립세종수목원", "신도시")));
        SIDO_INFO.put(Sido.GYEONGGI, new SidoInfo("경기", 37.4138, 127.5183,
                "서울을 둘러싼 대한민국 최대 인구의 광역자치도.", List.of("에버랜드", "수원화성", "DMZ", "파주출판단지")));
        SIDO_INFO.put(Sido.GANGWON, new SidoInfo("강원", 37.8228, 128.1555,
                "산과 바다를 함께 즐길 수 있는 자연관광의 중심지.", List.of("설악산", "강릉커피거리", "스키", "동해바다")));
        SIDO_INFO.put(Sido.CHUNGBUK, new SidoInfo("충북", 36.6357, 127.4913,
                "내륙에 위치한 충청권 산업·교통의 중심지.", List.of("청남대", "속리산", "단양팔경", "직지")));
        SIDO_INFO.put(Sido.CHUNGNAM, new SidoInfo("충남", 36.5184, 126.8000,
                "서해안을 낀 충청권의 농업·산업 중심지.", List.of("태안해변", "공주백제", "아산온천", "해미읍성")));
        SIDO_INFO.put(Sido.JEONBUK, new SidoInfo("전북", 35.7175, 127.1530,
                "한옥마을과 맛의 고장으로 유명한 호남 내륙 지역.", List.of("한옥마을", "비빔밥", "포토스팟", "전통문화")));
        SIDO_INFO.put(Sido.JEONNAM, new SidoInfo("전남", 34.8161, 126.4629,
                "다도해와 갯벌을 품은 남서해안의 자연 관광지.", List.of("순천만", "여수밤바다", "담양대나무숲", "보성녹차밭")));
        SIDO_INFO.put(Sido.GYEONGBUK, new SidoInfo("경북", 36.4919, 128.8889,
                "역사 유적이 풍부한 영남 내륙의 문화 중심지.", List.of("경주불국사", "안동하회마을", "독도", "첨성대")));
        SIDO_INFO.put(Sido.GYEONGNAM, new SidoInfo("경남", 35.4606, 128.2132,
                "남해안을 낀 영남권의 산업·관광 중심지.", List.of("통영", "진주성", "거제바다", "벚꽃")));
        SIDO_INFO.put(Sido.JEJU, new SidoInfo("제주", 33.4996, 126.5312,
                "화산섬 특유의 자연경관을 자랑하는 대표 관광섬.", List.of("한라산", "흑돼지", "해변카페", "오름")));
    }

    private final DistrictRepository districtRepository;
    private final UserRepository userRepository;
    private final ContentService contentService;
    private final RecommendedContentRepository recommendedContentRepository;
    private final RecommendedContentActivityRepository recommendedContentActivityRepository;

    // 시/도 단위 지도: 전국 17개 시/도의 대표 좌표 + 매칭 활성화된 메이트 수
    public List<MapDto.SidoResponse> getSidoMap() {
        return SIDO_INFO.entrySet().stream()
                .map(entry -> {
                    Sido sido = entry.getKey();
                    SidoInfo info = entry.getValue();
                    long mateCount = userRepository.countByDistrict_SidoAndMatchingEnabledTrue(sido);
                    return new MapDto.SidoResponse(sido, info.label(), info.latitude(), info.longitude(), mateCount);
                })
                .toList();
    }

    // 구 단위 지도: 선택한 시/도에 속한 구 목록 + 구별 메이트 수
    public List<MapDto.DistrictResponse> getDistricts(Sido sido) {
        return districtRepository.findAllBySido(sido).stream()
                .map(d -> new MapDto.DistrictResponse(
                        d.getId(), d.getName(), d.getSido(), d.getLatitude(), d.getLongitude(),
                        userRepository.countByDistrictAndMatchingEnabledTrue(d)))
                .toList();
    }

    // 구 상세: 지도 핀 클릭 시 표시할 메이트 수
    public MapDto.DistrictMateResponse getDistrictMates(Long districtId) {
        District district = findDistrict(districtId);
        long mateCount = userRepository.countByDistrictAndMatchingEnabledTrue(district);
        return new MapDto.DistrictMateResponse(district.getId(), district.getName(), mateCount);
    }

    // 컨텐츠 둘러보기: 그 구의 추천 활동·콘텐츠 목록 + 소속 시(Sido) 설명·태그
    public MapDto.DistrictContentsResponse getDistrictContents(Long districtId) {
        District district = findDistrict(districtId);
        SidoInfo info = SIDO_INFO.get(district.getSido());
        List<ContentDto.Response> contents = contentService.listByDistrict(districtId);
        List<MapDto.RecommendedContentResponse> recommendedContents =
                recommendedContentRepository.findAllByDistrict_Id(districtId)
                        .stream().map(MapDto.RecommendedContentResponse::from).toList();
        return new MapDto.DistrictContentsResponse(
                district.getId(), district.getName(), district.getSido(),
                info.label(), info.description(), info.tags(), contents, recommendedContents);
    }

    // 추천 컨텐츠 카드 상세: "이런 걸 해보세요" 목록 + "콘텐츠 아이디어" 태그
    public MapDto.RecommendedContentDetailResponse getRecommendedContentDetail(Long recommendedContentId) {
        RecommendedContent content = recommendedContentRepository.findById(recommendedContentId)
                .orElseThrow(() -> new GlobalException(DomainResultCode.RECOMMENDED_CONTENT_NOT_FOUND));
        List<MapDto.RecommendedContentActivityResponse> activities =
                recommendedContentActivityRepository.findAllByRecommendedContentId(recommendedContentId)
                        .stream().map(MapDto.RecommendedContentActivityResponse::from).toList();
        return new MapDto.RecommendedContentDetailResponse(
                content.getId(), content.getName(), content.getImageUrl(), content.getSuggestions(),
                content.getLocation(), content.getRating(), content.getContentIdeas(), activities);
    }

    private District findDistrict(Long id) {
        return districtRepository.findById(id)
                .orElseThrow(() -> new GlobalException(DomainResultCode.DISTRICT_NOT_FOUND));
    }
}
