package com.example.artnara.domain.artwork.controller;

import com.example.artnara.domain.artwork.dto.ArtworkDetailDto;
import com.example.artnara.domain.artwork.dto.NearbyArtworkDto;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.global.common.BaseResponse;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

@Tag(name = "Artwork", description = "ART NARA 작품 상세/입찰 API")
@RestController
@RequestMapping("/api/artworks")
@RequiredArgsConstructor
public class ArtworkController {

    private final ArtworkService artworkService;

    @GetMapping("/nearby")
    @Operation(summary = "집 주변 작품 매칭", description = "기준 좌표에서 가까운 순으로 판매 중인 작품을 조회합니다.")
    public BaseResponse<NearbyArtworkDto> nearby(
            @RequestParam double latitude,
            @RequestParam double longitude) {
        return BaseResponse.success("집 주변 작품 매칭", artworkService.getNearby(latitude, longitude));
    }

    @GetMapping("/liked")
    @Operation(summary = "내 관심 작품 목록",
            description = "하트를 누른 작품을 최근 순으로 조회합니다. 로그인(JWT)이 필요합니다.")
    public BaseResponse<java.util.List<ArtworkDetailDto>> liked(Principal principal) {
        if (principal == null) {
            throw new GlobalException(DomainResultCode.AUTH_REQUIRED);
        }
        return BaseResponse.success("내 관심 작품 목록",
                artworkService.listLiked(Long.parseLong(principal.getName())));
    }

    @GetMapping("/{artworkId}")
    @Operation(summary = "작품 상세 조회", description = "작품 정보, 작가 소개, 경매 작품이면 입찰 내역까지 조회합니다.")
    public BaseResponse<ArtworkDetailDto> detail(@PathVariable Long artworkId) {
        return BaseResponse.success("작품 상세 조회", artworkService.getDetail(artworkId));
    }

    @PostMapping("/{artworkId}/close")
    @Operation(summary = "경매 마감 처리", description = "경매를 마감하고 최고 입찰자를 낙찰자로 확정합니다. (프로토타입: 수동 마감)")
    public BaseResponse<ArtworkDetailDto> closeAuction(@PathVariable Long artworkId) {
        return BaseResponse.success("경매 마감 처리", artworkService.closeAuction(artworkId));
    }

    @PostMapping("/{artworkId}/like")
    @Operation(summary = "관심 작품 토글",
            description = "하트를 눌러 관심 작품에 등록/해제합니다. 로그인(JWT)이 필요하며, 응답 data 는 토글 후 상태입니다.")
    public BaseResponse<Boolean> toggleLike(@PathVariable Long artworkId, Principal principal) {
        if (principal == null) {
            throw new GlobalException(DomainResultCode.AUTH_REQUIRED);
        }
        return BaseResponse.success("관심 작품 토글",
                artworkService.toggleLike(artworkId, Long.parseLong(principal.getName())));
    }

    @PostMapping("/{artworkId}/bids")
    @Operation(summary = "작품 입찰", description = "경매 작품에 입찰합니다. 입찰가는 현재가보다 최소 입찰 단위 이상 높아야 합니다.")
    public BaseResponse<ArtworkDetailDto> bid(
            @PathVariable Long artworkId,
            @RequestBody ArtworkDetailDto.BidRequest request) {
        return BaseResponse.success("작품 입찰", artworkService.placeBid(artworkId, request));
    }
}
