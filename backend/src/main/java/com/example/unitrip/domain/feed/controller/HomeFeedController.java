package com.example.unitrip.domain.feed.controller;

import com.example.unitrip.domain.feed.dto.HomeFeedDto;
import com.example.unitrip.domain.feed.service.HomeFeedService;
import com.example.unitrip.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
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
            @RequestParam(required = false, defaultValue = "") String query) {
        return BaseResponse.success("홈 피드 조회", homeFeedService.getHomeFeed(query));
    }
}
