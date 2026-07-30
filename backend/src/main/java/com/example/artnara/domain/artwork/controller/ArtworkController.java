package com.example.artnara.domain.artwork.controller;

import com.example.artnara.domain.artwork.dto.ArtworkDetailDto;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Artwork", description = "ART NARA 작품 상세/입찰 API")
@RestController
@RequestMapping("/api/artworks")
@RequiredArgsConstructor
public class ArtworkController {

    private final ArtworkService artworkService;

    @GetMapping("/{artworkId}")
    @Operation(summary = "작품 상세 조회", description = "작품 정보, 작가 소개, 경매 작품이면 입찰 내역까지 조회합니다.")
    public BaseResponse<ArtworkDetailDto> detail(@PathVariable Long artworkId) {
        return BaseResponse.success("작품 상세 조회", artworkService.getDetail(artworkId));
    }

    @PostMapping("/{artworkId}/bids")
    @Operation(summary = "작품 입찰", description = "경매 작품에 입찰합니다. 입찰가는 현재가보다 최소 입찰 단위 이상 높아야 합니다.")
    public BaseResponse<ArtworkDetailDto> bid(
            @PathVariable Long artworkId,
            @RequestBody ArtworkDetailDto.BidRequest request) {
        return BaseResponse.success("작품 입찰", artworkService.placeBid(artworkId, request));
    }
}
