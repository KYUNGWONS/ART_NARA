package com.example.artnara.global.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;

/** 업로드된 이미지를 /images/** 경로로 정적 서빙한다. */
@Configuration
public class StaticResourceConfig implements WebMvcConfigurer {

    private final String uploadDir;

    public StaticResourceConfig(@Value("${app.upload-dir:uploads}") String uploadDir) {
        this.uploadDir = uploadDir;
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/images/**")
                .addResourceLocations(Path.of(uploadDir).toAbsolutePath().toUri().toString());
    }
}
