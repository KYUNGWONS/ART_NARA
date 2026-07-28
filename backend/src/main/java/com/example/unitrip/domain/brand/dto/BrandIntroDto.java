package com.example.unitrip.domain.brand.dto;

public record BrandIntroDto(
        String title,
        String description,
        String imageUrl,
        String primaryActionLabel,
        String secondaryActionLabel
) {}
