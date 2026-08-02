package com.example.artnara.domain.feed.controller;

import com.example.artnara.domain.feed.dto.HomeFeedDto;
import com.example.artnara.domain.feed.service.HomeFeedService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;

import java.security.Principal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Home Feed", description = "ART NARA 홈 피드 API")
@RestController
@RequestMapping("/api/feed")
@RequiredArgsConstructor
public class HomeFeedController {

    private final HomeFeedService homeFeedService;

    @GetMapping("/home")
    @Operation(summary = "홈 피드 조회", description = "검색어가 있으면 작품명과 작가명으로 홈 피드를 필터링합니다.")
    public BaseResponse<HomeFeedDto> home(
            @RequestParam(required = false, defaultValue = "") String query,
            @RequestParam(required = false) String category,
            Principal principal) {
        // 로그인 상태면 관심 작품(하트) 표시를 함께 채운다. 비로그인이면 principal 이 null.
        Long userId = principal == null ? null : Long.parseLong(principal.getName());
        return BaseResponse.success("홈 피드 조회", homeFeedService.getHomeFeed(query, category, userId));
    }
}
