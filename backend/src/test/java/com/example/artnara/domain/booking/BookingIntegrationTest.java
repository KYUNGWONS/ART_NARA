package com.example.artnara.domain.booking;

import com.example.artnara.domain.booking.dto.BookingDto;
import com.example.artnara.domain.content.entity.Content;
import com.example.artnara.domain.content.entity.Theme;
import com.example.artnara.domain.content.repository.ContentRepository;
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

import java.time.LocalDate;
import java.time.LocalTime;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@IntegrationTest
class BookingIntegrationTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper om;
    @Autowired UserRepository userRepository;
    @Autowired ContentRepository contentRepository;

    @Test
    @DisplayName("예약 생성 성공 → 중복 예약 시 409")
    void createThenDuplicate() throws Exception {
        User mate = userRepository.save(User.builder()
                .email("mate@t.com").nickname("chan").userType(UserType.KOREAN_STUDENT).build());
        User guest = userRepository.save(User.builder()
                .email("g@t.com").nickname("andy").userType(UserType.FOREIGN_TOURIST).build());
        Content content = contentRepository.save(Content.builder()
                .author(mate).title("서촌 산책").theme(Theme.PLACE).pricePerHour(20000).build());

        var req = new BookingDto.CreateRequest(
                content.getId(), guest.getId(), LocalDate.of(2026, 5, 1),
                LocalTime.of(11, 0), LocalTime.of(18, 0), 35000);

        mockMvc.perform(post("/api/bookings").with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(om.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("PENDING_PAYMENT"));

        mockMvc.perform(post("/api/bookings").with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(om.writeValueAsString(req)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("BOOKING_409"));
    }
}
