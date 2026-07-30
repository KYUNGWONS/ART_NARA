package com.example.artnara.domain.image;

import com.example.artnara.domain.image.service.ImageStorageService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.mock.web.MockMultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ImageStorageServiceTest {

    @TempDir
    Path tempDir;

    private ImageStorageService service() {
        return new ImageStorageService(tempDir.toString());
    }

    @Test
    @DisplayName("이미지 저장 시 /images/ 경로를 반환하고 파일이 생성된다")
    void store() {
        MockMultipartFile file = new MockMultipartFile(
                "file", "artwork.jpg", "image/jpeg", new byte[]{1, 2, 3});

        String url = service().store(file);

        assertThat(url).startsWith("/images/").endsWith(".jpg");
        String filename = url.substring("/images/".length());
        assertThat(Files.exists(tempDir.resolve(filename))).isTrue();
    }

    @Test
    @DisplayName("빈 파일 업로드 시 400")
    void storeEmptyFile() {
        MockMultipartFile empty = new MockMultipartFile(
                "file", "empty.jpg", "image/jpeg", new byte[0]);
        assertThatThrownBy(() -> service().store(empty))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.IMAGE_FILE_REQUIRED);
    }

    @Test
    @DisplayName("허용되지 않은 형식 업로드 시 422")
    void storeInvalidType() {
        MockMultipartFile pdf = new MockMultipartFile(
                "file", "doc.pdf", "application/pdf", new byte[]{1});
        assertThatThrownBy(() -> service().store(pdf))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.IMAGE_INVALID_TYPE);
    }
}
