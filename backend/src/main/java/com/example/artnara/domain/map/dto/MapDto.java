package com.example.artnara.domain.map.dto;

import com.example.artnara.domain.content.dto.ContentDto;
import com.example.artnara.domain.recommendation.entity.RecommendedContent;
import com.example.artnara.domain.recommendation.entity.RecommendedContentActivity;
import com.example.artnara.domain.user.entity.Sido;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

public class MapDto {

    @Schema(name = "MapSidoResponse", description = "시/도 단위 지도 핀(광역 단위 보기)")
    public record SidoResponse(
            @Schema(description = "시/도") Sido sido,
            @Schema(description = "시/도 한글 라벨", example = "서울") String label,
            @Schema(description = "대표 좌표 위도") double latitude,
            @Schema(description = "대표 좌표 경도") double longitude,
            @Schema(description = "이 시/도 내 매칭 활성화된 메이트 수") long mateCount
    ) {}

    @Schema(name = "MapDistrictResponse", description = "구 단위 지도 핀")
    public record DistrictResponse(
            @Schema(description = "구 ID") Long districtId,
            @Schema(description = "구 이름", example = "해운대구") String name,
            @Schema(description = "소속 시/도") Sido sido,
            @Schema(description = "대표 좌표 위도") double latitude,
            @Schema(description = "대표 좌표 경도") double longitude,
            @Schema(description = "이 구 내 매칭 활성화된 메이트 수") long mateCount
    ) {}

    @Schema(name = "MapDistrictMateResponse", description = "지도 핀 클릭 시 표시할 메이트 수 카드")
    public record DistrictMateResponse(
            @Schema(description = "구 ID") Long districtId,
            @Schema(description = "구 이름") String name,
            @Schema(description = "매칭 활성화된 메이트 수") long mateCount
    ) {}

    @Schema(name = "MapRecommendedContentResponse",
            description = "구 컨텐츠 둘러보기 카드 목록 항목. 목록은 가볍게 유지하기 위해 " +
                    "상세 정보(suggestions/contentIdeas/이런 걸 해보세요 목록)는 포함하지 않는다 — " +
                    "카드 클릭 시 GET /api/map/recommended-contents/{id}로 조회한다.")
    public record RecommendedContentResponse(
            @Schema(description = "추천 컨텐츠 ID") Long id,
            @Schema(description = "카드 제목", example = "전주 한옥마을 투어") String name,
            @Schema(description = "카드 이미지 URL") String imageUrl,
            @Schema(description = "위치 상세(구/동 등 자유 텍스트)", example = "완산구 한옥마을") String location,
            @Schema(description = "평점") Double rating
    ) {
        public static RecommendedContentResponse from(RecommendedContent c) {
            return new RecommendedContentResponse(
                    c.getId(), c.getName(), c.getImageUrl(), c.getLocation(), c.getRating());
        }
    }

    @Schema(name = "MapRecommendedContentActivityResponse", description = "추천 컨텐츠 상세의 \"이런 걸 해보세요\" 목록 항목")
    public record RecommendedContentActivityResponse(
            @Schema(description = "항목 ID") Long id,
            @Schema(description = "활동명", example = "한복 대여") String name,
            @Schema(description = "이미지 URL") String imageUrl,
            @Schema(description = "한 줄 설명", example = "전통 한복을 빌려 골목을 누벼보세요") String description
    ) {
        public static RecommendedContentActivityResponse from(RecommendedContentActivity a) {
            return new RecommendedContentActivityResponse(a.getId(), a.getName(), a.getImageUrl(), a.getDescription());
        }
    }

    @Schema(name = "MapRecommendedContentDetailResponse",
            description = "추천 컨텐츠 카드를 클릭했을 때의 상세. 카드 목록(RecommendedContentResponse)에는 없는 " +
                    "suggestions/contentIdeas/activities(\"이런 걸 해보세요\")를 포함한다.")
    public record RecommendedContentDetailResponse(
            @Schema(description = "추천 컨텐츠 ID") Long id,
            @Schema(description = "제목") String name,
            @Schema(description = "이미지 URL") String imageUrl,
            @Schema(description = "한 줄 제안 문구 목록(카테고리 배지가 아닌 액션 문구)",
                    example = "[\"한복 입고 인생샷 남기기\", \"돌담길 골목 산책하기\"]") List<String> suggestions,
            @Schema(description = "위치 상세") String location,
            @Schema(description = "평점") Double rating,
            @Schema(description = "\"콘텐츠 아이디어\" 태그 목록", example = "[\"포토 에세이\", \"숏폼 브이로그\"]") List<String> contentIdeas,
            @Schema(description = "\"이런 걸 해보세요\" 세부 활동 목록") List<RecommendedContentActivityResponse> activities
    ) {}

    @Schema(name = "MapDistrictContentsResponse", description = "\"컨텐츠 둘러보기\" 화면 응답 — 시/도 소개 + 그 구의 콘텐츠·추천 컨텐츠 카드")
    public record DistrictContentsResponse(
            @Schema(description = "구 ID") Long districtId,
            @Schema(description = "구 이름") String districtName,
            @Schema(description = "소속 시/도") Sido sido,
            @Schema(description = "시/도 한글 라벨") String sidoLabel,
            @Schema(description = "시/도 소개문") String sidoDescription,
            @Schema(description = "시/도 특징 태그", example = "[\"한옥마을\", \"비빔밥\", \"포토스팟\", \"전통문화\"]") List<String> sidoTags,
            @Schema(description = "그 구의 공개 콘텐츠(매듭) 목록") List<ContentDto.Response> contents,
            @Schema(description = "그 구에 배정된 추천 컨텐츠 카드 목록(가벼운 카드, 상세는 별도 조회)")
            List<RecommendedContentResponse> recommendedContents
    ) {}
}
