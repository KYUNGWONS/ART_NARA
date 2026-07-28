package com.example.unitrip.domain.magazine;

import com.example.unitrip.domain.magazine.dto.MagazineDto;
import com.example.unitrip.domain.magazine.entity.MagazineCategory;
import com.example.unitrip.support.IntegrationTest;
import tools.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@IntegrationTest
class MagazineIntegrationTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper om;

    @Test
    @DisplayName("매거진 생성 후 카테고리 필터 조회")
    void createAndFilter() throws Exception {
        var req = new MagazineDto.CreateRequest(
                "Seoul Hidden Gems", "best views", "content body",
                null, MagazineCategory.KNOT_GUIDE);

        mockMvc.perform(post("/api/magazines").with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(om.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.category").value("KNOT_GUIDE"));

        mockMvc.perform(get("/api/magazines").param("category", "KNOT_GUIDE"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].title").value("Seoul Hidden Gems"));
    }
}
