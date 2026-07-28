package com.example.unitrip.domain.user;

import com.example.unitrip.domain.user.dto.UserDto;
import com.example.unitrip.domain.user.entity.Sido;
import com.example.unitrip.domain.user.entity.TravelStyle;
import com.example.unitrip.domain.user.entity.User;
import com.example.unitrip.domain.user.entity.UserType;
import com.example.unitrip.domain.user.repository.UserRepository;
import com.example.unitrip.global.auth.oauth.OAuthProvider;
import com.example.unitrip.support.IntegrationTest;
import tools.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@IntegrationTest
class UserIntegrationTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper om;
    @Autowired UserRepository userRepository;

    @Test
    @DisplayName("로그인으로 생성된 유저가 프로필 설정 후 조회 가능")
    void completeProfileAndGet() throws Exception {
        // 로그인 시점에 생성된 최소 유저 (프로필 미완료)
        User user = userRepository.save(
                User.ofOAuth(OAuthProvider.GOOGLE, "google-1", "andrew@test.com", null, null));
        long id = user.getId();

        var req = new UserDto.CreateRequest(
                "andrew", "Andrew K", 24, UserType.FOREIGN_TOURIST,
                "https://img/andrew.png", Sido.SEOUL, "hi", List.of("food", "culture"),
                List.of("English", "한국어"), new TravelStyle(40, -40, 20, 30));

        // 인증된 본인(userId=id)으로 프로필 설정
        mockMvc.perform(post("/api/users")
                        .with(user(String.valueOf(id)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(om.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.email").value("andrew@test.com"))
                .andExpect(jsonPath("$.data.userType").value("FOREIGN_TOURIST"))
                .andExpect(jsonPath("$.data.profileCompleted").value(true));

        mockMvc.perform(get("/api/users/me")
                        .with(user(String.valueOf(id))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.nickname").value("andrew"));
    }

    @Test
    @DisplayName("없는 사용자 조회 시 404")
    void notFound() throws Exception {
        mockMvc.perform(get("/api/users/me")
                        .with(user("9999")))
                .andExpect(status().isNotFound());
    }
}
