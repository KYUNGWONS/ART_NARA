package com.example.artnara.global.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import org.springframework.http.CacheControl;

import java.nio.file.Path;
import java.time.Duration;

/** 업로드된 이미지를 /images/** 경로로 정적 서빙한다. */
@Configuration
public class StaticResourceConfig implements WebMvcConfigurer {

    private final String uploadDir;

    public StaticResourceConfig(@Value("${app.upload-dir:uploads}") String uploadDir) {
        this.uploadDir = uploadDir;
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 업로드 이미지는 파일명이 곧 버전(중복 없는 이름)이라 오래 캐시해도 안전하다.
        // 캐시가 붙으면 같은 이미지를 반복해서 서버가 다시 내려보내지 않아 트래픽이 크게 준다.
        registry.addResourceHandler("/images/**")
                .addResourceLocations(Path.of(uploadDir).toAbsolutePath().toUri().toString())
                .setCacheControl(CacheControl.maxAge(Duration.ofDays(30)).cachePublic());

        // 시드 작품 이미지(classpath 정적 리소스)도 동일 정책.
        registry.addResourceHandler("/artworks/**")
                .addResourceLocations("classpath:/static/artworks/")
                .setCacheControl(CacheControl.maxAge(Duration.ofDays(30)).cachePublic());
    }
}
