package com.example.artnara.domain.image.controller;

import com.example.artnara.domain.image.service.ImageStorageService;
import com.example.artnara.global.common.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@Tag(name = "Image", description = "ART NARA 이미지 업로드 API")
@RestController
@RequestMapping("/api/images")
@RequiredArgsConstructor
public class ImageController {

    private final ImageStorageService imageStorageService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "이미지 업로드",
            description = "작품/의뢰 사진을 업로드합니다. jpg·png·webp 만 허용하며 업로드된 이미지는 /images/{파일명} 으로 서빙됩니다.")
    public BaseResponse<Map<String, String>> upload(@RequestPart("file") MultipartFile file) {
        return BaseResponse.success("이미지 업로드", Map.of("url", imageStorageService.store(file)));
    }
}
