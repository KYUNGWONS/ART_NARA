package com.example.artnara.domain.content;

import com.example.artnara.domain.content.dto.ContentDto;
import com.example.artnara.domain.content.entity.Language;
import com.example.artnara.domain.content.entity.Theme;
import com.example.artnara.domain.content.entity.TimeSlot;
import com.example.artnara.domain.user.entity.Sido;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.entity.UserType;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.support.IntegrationTest;
import tools.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.DayOfWeek;
import java.util.List;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@IntegrationTest
class ContentIntegrationTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper om;
    @Autowired UserRepository userRepository;

    @Test
    @DisplayName("콘텐츠 등록 및 테마별 조회")
    void createAndListByTheme() throws Exception {
        User author = userRepository.save(User.builder()
                .email("chan@test.com").nickname("chan").age(25)
                .userType(UserType.KOREAN_STUDENT).build());

        var req = new ContentDto.CreateRequest(
                "한강 따릉이", "한강에서 즐기는 라이딩", "한강에서 자전거 타기",
                Theme.ACTIVITY, Sido.SEOUL, "여의도", null,
                List.of(Language.KOREAN, Language.ENGLISH), null,
                List.of(new ContentDto.KnotRequest("여의도 한강공원", "따릉이", 90)),
                List.of(DayOfWeek.TUESDAY, DayOfWeek.FRIDAY),
                List.of(TimeSlot.LUNCH_TO_DINNER),
                "여의나루역 1번 출구", 4, 12000);

        // 작성자는 JWT 신원에서 결정되므로, 요청 principal 이름을 저장된 작성자 ID로 지정한다.
        mockMvc.perform(post("/api/contents").with(csrf()).with(user(String.valueOf(author.getId())))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(om.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.title").value("한강 따릉이"))
                .andExpect(jsonPath("$.data.authorNickname").value("chan"));

        mockMvc.perform(get("/api/contents").param("theme", "ACTIVITY"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].theme").value("ACTIVITY"));
    }
}
