package com.example.unitrip.domain.festival;

import com.example.unitrip.domain.festival.dto.FestivalDto;
import com.example.unitrip.support.IntegrationTest;
import tools.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@IntegrationTest
class FestivalIntegrationTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper om;

    @Test
    @DisplayName("페스티벌 생성 후 지역 필터 조회")
    void createAndFilterByRegion() throws Exception {
        var req = new FestivalDto.CreateRequest(
                "서울 불꽃축제", "서울", "한강에서 열리는 불꽃축제",
                null, LocalDate.of(2026, 10, 5), LocalDate.of(2026, 10, 5));

        mockMvc.perform(post("/api/festivals").with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(om.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.name").value("서울 불꽃축제"));

        mockMvc.perform(get("/api/festivals").param("region", "서울"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].region").value("서울"));
    }
}
