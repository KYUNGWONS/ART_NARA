package com.example.artnara.domain.artist.controller;

import com.example.artnara.domain.artist.dto.ArtistDto;
import com.example.artnara.domain.artist.service.ArtistService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Artist", description = "ART NARA 작가 포트폴리오 API")
@RestController
@RequestMapping("/api/artists")
@RequiredArgsConstructor
public class ArtistController {

    private final ArtistService artistService;

    @SecurityRequirements
    @GetMapping("/{artistName}")
    @Operation(summary = "작가 포트폴리오 조회",
            description = "작가의 소개, 활동 통계, 등록 작품 목록을 조회합니다.")
    public BaseResponse<ArtistDto.Response> portfolio(@PathVariable String artistName) {
        return BaseResponse.success("작가 포트폴리오 조회", artistService.getPortfolio(artistName));
    }
}
