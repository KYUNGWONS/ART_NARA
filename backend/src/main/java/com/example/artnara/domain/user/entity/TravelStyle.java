package com.example.artnara.domain.user.entity;

import jakarta.persistence.Embeddable;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Embeddable
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class TravelStyle {
    private Integer planning; // 계획 스타일: 즉흥적 ↔ 철저한 계획
    private Integer vibe;     // 분위기: 차분한 ↔ 에너지 넘침
    private Integer role;     // 역할: 따라가는 편 ↔ 리드하는 편
    private Integer dynamic;  // 활동량: 소수정예 ↔ 많은 친구
}
