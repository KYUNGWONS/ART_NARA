package com.example.artnara.domain.review.controller;

import com.example.artnara.domain.review.dto.ReviewDto;
import com.example.artnara.domain.review.service.ReviewService;
import com.example.artnara.global.auth.CurrentUser;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;

@Tag(name = "Review", description = "ART NARA 작품 리뷰 API")
@RestController
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;
    private final CurrentUser currentUser;

    @PostMapping("/api/artworks/{artworkId}/reviews")
    @Operation(summary = "리뷰 작성",
            description = "구매한 작품에 별점과 후기를 남깁니다. 작성자는 JWT 신원에서 결정되며, "
                    + "결제 기록이 있어야 하고 작품당 한 번만 쓸 수 있습니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "작성 성공"),
            @ApiResponse(responseCode = "400", description = "별점/내용이 올바르지 않음"),
            @ApiResponse(responseCode = "403", description = "구매하지 않은 작품"),
            @ApiResponse(responseCode = "409", description = "이미 리뷰를 작성함")
    })
    public BaseResponse<ReviewDto.Item> create(
            @Parameter(description = "작품 ID", example = "1") @PathVariable Long artworkId,
            @RequestBody ReviewDto.CreateRequest request,
            Principal principal) {
        return BaseResponse.success("리뷰 작성", reviewService.create(
                artworkId, request, currentUser.idOf(principal), currentUser.nicknameOf(principal)));
    }

    @GetMapping("/api/artists/{artistName}/reviews")
    @Operation(summary = "작가 리뷰 목록",
            description = "작가가 받은 리뷰를 최신순으로 조회합니다(최대 100건). 평균 평점도 함께 내려줍니다.")
    @ApiResponses({@ApiResponse(responseCode = "200", description = "조회 성공")})
    public BaseResponse<ReviewDto.ListResponse> listByArtist(
            @Parameter(description = "작가 활동명", example = "김예진") @PathVariable String artistName) {
        return BaseResponse.success("작가 리뷰 목록", reviewService.listByArtist(artistName));
    }
}
