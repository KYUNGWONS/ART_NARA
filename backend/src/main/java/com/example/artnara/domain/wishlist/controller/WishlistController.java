package com.example.artnara.domain.wishlist.controller;

import com.example.artnara.domain.wishlist.dto.WishlistDto;
import com.example.artnara.domain.wishlist.service.WishlistService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Wishlist", description = "위시리스트 API")
@RestController
@RequestMapping("/api/wishlist")
@RequiredArgsConstructor
public class WishlistController {

    private final WishlistService wishlistService;

    @PostMapping("/folders")
    @Operation(summary = "위시리스트 폴더 생성", description = "새로운 위시리스트 폴더를 생성합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "폴더 생성 성공"),
            @ApiResponse(responseCode = "404", description = "소유자를 찾을 수 없음")
    })
    public BaseResponse<WishlistDto.FolderResponse> createFolder(@RequestBody WishlistDto.CreateFolderRequest req) {
        return BaseResponse.success("폴더 생성", wishlistService.createFolder(req));
    }

    @GetMapping("/folders")
    @Operation(summary = "폴더 목록 조회", description = "소유자의 위시리스트 폴더 목록과 각 폴더의 항목 수를 조회합니다.")
    @ApiResponse(responseCode = "200", description = "폴더 목록 조회 성공")
    public BaseResponse<List<WishlistDto.FolderResponse>> listFolders(
            @Parameter(description = "소유자 ID", example = "1") @RequestParam Long ownerId) {
        return BaseResponse.success("폴더 목록", wishlistService.listFolders(ownerId));
    }

    @PatchMapping("/folders/{id}")
    @Operation(summary = "폴더 이름 변경", description = "위시리스트 폴더의 이름을 변경합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "폴더 이름 변경 성공"),
            @ApiResponse(responseCode = "404", description = "폴더를 찾을 수 없음")
    })
    public BaseResponse<WishlistDto.FolderResponse> renameFolder(
            @Parameter(description = "폴더 ID", example = "1") @PathVariable Long id,
            @RequestBody WishlistDto.RenameFolderRequest req) {
        return BaseResponse.success("폴더 이름 변경", wishlistService.renameFolder(id, req));
    }

    @DeleteMapping("/folders/{id}")
    @Operation(summary = "폴더 삭제", description = "위시리스트 폴더를 삭제합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "폴더 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "폴더를 찾을 수 없음")
    })
    public BaseResponse<Void> deleteFolder(
            @Parameter(description = "폴더 ID", example = "1") @PathVariable Long id) {
        wishlistService.deleteFolder(id);
        return BaseResponse.success("폴더 삭제", null);
    }

    @PostMapping("/items")
    @Operation(summary = "위시 항목 추가", description = "폴더에 콘텐츠를 위시 항목으로 추가합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "항목 추가 성공"),
            @ApiResponse(responseCode = "404", description = "폴더 또는 콘텐츠를 찾을 수 없음")
    })
    public BaseResponse<WishlistDto.ItemResponse> addItem(@RequestBody WishlistDto.AddItemRequest req) {
        return BaseResponse.success("위시 항목 추가", wishlistService.addItem(req));
    }

    @GetMapping("/folders/{folderId}/items")
    @Operation(summary = "폴더 내 항목 목록 조회", description = "특정 폴더의 위시 항목 목록을 조회합니다.")
    @ApiResponse(responseCode = "200", description = "항목 목록 조회 성공")
    public BaseResponse<List<WishlistDto.ItemResponse>> listItems(
            @Parameter(description = "폴더 ID", example = "1") @PathVariable Long folderId) {
        return BaseResponse.success("항목 목록", wishlistService.listItems(folderId));
    }

    @PatchMapping("/items/{id}")
    @Operation(summary = "위시 항목 메모 수정", description = "위시 항목의 메모를 수정합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "항목 수정 성공"),
            @ApiResponse(responseCode = "404", description = "항목을 찾을 수 없음")
    })
    public BaseResponse<WishlistDto.ItemResponse> updateItem(
            @Parameter(description = "항목 ID", example = "1") @PathVariable Long id,
            @RequestBody WishlistDto.UpdateItemRequest req) {
        return BaseResponse.success("항목 수정", wishlistService.updateItem(id, req));
    }

    @DeleteMapping("/items/{id}")
    @Operation(summary = "위시 항목 삭제", description = "위시 항목을 삭제합니다.")
    @ApiResponse(responseCode = "200", description = "항목 삭제 성공")
    public BaseResponse<Void> deleteItem(
            @Parameter(description = "항목 ID", example = "1") @PathVariable Long id) {
        wishlistService.deleteItem(id);
        return BaseResponse.success("항목 삭제", null);
    }
}
