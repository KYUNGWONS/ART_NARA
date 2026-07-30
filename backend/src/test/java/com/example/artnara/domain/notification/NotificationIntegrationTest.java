package com.example.artnara.domain.notification;

import com.example.artnara.domain.notification.dto.NotificationDto;
import com.example.artnara.domain.notification.entity.NotificationType;
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

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@IntegrationTest
class NotificationIntegrationTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper om;
    @Autowired UserRepository userRepository;

    @Test
    @DisplayName("알림 생성 후 unread count 1, 읽음 처리 후 0")
    void createThenMarkRead() throws Exception {
        User user = userRepository.save(User.builder()
                .email("n@t.com").nickname("n").userType(UserType.FOREIGN_TOURIST).build());

        var req = new NotificationDto.CreateRequest(
                user.getId(), NotificationType.APPOINTMENT_REMINDER, "약속 2시간 전", "준비하세요");

        var result = mockMvc.perform(post("/api/notifications").with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(om.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andReturn();
        long id = om.readTree(result.getResponse().getContentAsString())
                .path("data").path("id").asLong();

        mockMvc.perform(get("/api/notifications/unread-count").param("userId", user.getId().toString()))
                .andExpect(jsonPath("$.data").value(1));

        mockMvc.perform(patch("/api/notifications/{id}/read", id).with(csrf()))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/notifications/unread-count").param("userId", user.getId().toString()))
                .andExpect(jsonPath("$.data").value(0));
    }
}
