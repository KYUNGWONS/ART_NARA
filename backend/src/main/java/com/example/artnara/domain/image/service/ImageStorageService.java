package com.example.artnara.domain.image.service;

import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

@Service
public class ImageStorageService {

    private static final Map<String, String> ALLOWED_TYPES = Map.of(
            "image/jpeg", ".jpg",
            "image/png", ".png",
            "image/webp", ".webp"
    );

    private final Path uploadDir;

    public ImageStorageService(@Value("${app.upload-dir:uploads}") String uploadDir) {
        this.uploadDir = Path.of(uploadDir);
    }

    /** 이미지를 저장하고 정적 서빙 경로(/images/{파일명})를 반환한다. */
    public String store(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new GlobalException(DomainResultCode.IMAGE_FILE_REQUIRED);
        }
        String contentType = file.getContentType() == null
                ? "" : file.getContentType().toLowerCase(Locale.ROOT);
        String extension = ALLOWED_TYPES.get(contentType);
        if (extension == null) {
            throw new GlobalException(DomainResultCode.IMAGE_INVALID_TYPE);
        }
        try {
            Files.createDirectories(uploadDir);
            String filename = UUID.randomUUID() + extension;
            file.transferTo(uploadDir.resolve(filename).toAbsolutePath());
            return "/images/" + filename;
        } catch (IOException e) {
            throw new GlobalException(DomainResultCode.IMAGE_STORE_FAILED, e.getMessage());
        }
    }
}
