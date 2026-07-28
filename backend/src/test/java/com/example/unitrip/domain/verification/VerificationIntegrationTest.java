package com.example.unitrip.domain.verification;

import com.example.unitrip.domain.user.entity.User;
import com.example.unitrip.domain.user.entity.UserType;
import com.example.unitrip.domain.user.repository.UserRepository;
import com.example.unitrip.domain.verification.dto.VerificationDto;
import com.example.unitrip.domain.verification.entity.VerificationType;
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
class VerificationIntegrationTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper om;
    @Autowired UserRepository userRepository;

    @Test
    @DisplayName("인증 제출 → 승인 → 상태 APPROVED")
    void submitAndApprove() throws Exception {
        User user = userRepository.save(User.builder()
                .email("v@t.com").nickname("v").userType(UserType.KOREAN_STUDENT).build());

        var req = new VerificationDto.SubmitRequest(
                user.getId(), VerificationType.UNIVERSITY, "https://cdn/doc.jpg");

        var result = mockMvc.perform(post("/api/verifications").with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(om.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("PENDING"))
                .andReturn();
        long id = om.readTree(result.getResponse().getContentAsString())
                .path("data").path("id").asLong();

        mockMvc.perform(post("/api/verifications/{id}/approve", id).with(csrf()))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/verifications").param("userId", user.getId().toString()))
                .andExpect(jsonPath("$.data[0].status").value("APPROVED"));
    }
}
