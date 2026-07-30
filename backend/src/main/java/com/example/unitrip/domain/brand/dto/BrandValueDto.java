package com.example.unitrip.domain.brand.dto;

import java.util.List;

public record BrandValueDto(
        String title,
        String description,
        String imageUrl,
        List<Reason> reasons,
        List<String> trustTags,
        String primaryActionLabel,
        String secondaryActionLabel
) {
    public record Reason(String title, String description) {}
}
