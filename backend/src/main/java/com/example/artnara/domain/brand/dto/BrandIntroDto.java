package com.example.artnara.domain.brand.dto;

public record BrandIntroDto(
        String title,
        String description,
        String imageUrl,
        String primaryActionLabel,
        String secondaryActionLabel
) {}
