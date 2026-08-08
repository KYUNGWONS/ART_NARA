package com.example.artnara.global.config;

import tools.jackson.databind.ObjectMapper;
import com.example.artnara.support.IntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

@IntegrationTest
@DisplayName("응답 시각 직렬화")
class TimeZoneConfigTest {

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("시각에는 한국 시간대 오프셋이 붙어 나간다 — 기기 시간대가 달라도 같은 순간을 가리키도록")
    void writesSeoulOffset() {
        String json = objectMapper.writeValueAsString(
                new Holder(LocalDateTime.of(2026, 8, 9, 1, 54, 22)));

        assertThat(json).contains("2026-08-09T01:54:22+09:00");
    }

    private record Holder(LocalDateTime createdAt) {}
}
