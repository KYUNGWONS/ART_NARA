package com.example.artnara.domain.booking;

import com.example.artnara.domain.booking.entity.Booking;
import com.example.artnara.domain.booking.repository.BookingRepository;
import com.example.artnara.domain.content.entity.Content;
import com.example.artnara.domain.content.entity.Theme;
import com.example.artnara.domain.content.repository.ContentRepository;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.entity.UserType;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.support.IntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.time.LocalTime;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@IntegrationTest
class AppointmentIntegrationTest {

    @Autowired MockMvc mockMvc;
    @Autowired UserRepository userRepository;
    @Autowired ContentRepository contentRepository;
    @Autowired BookingRepository bookingRepository;

    private record Fixture(User mate, User guest, Content content) {}

    private Fixture setUp() {
        User mate = userRepository.save(User.builder()
                .email("mate@t.com").nickname("재협").userType(UserType.KOREAN_STUDENT).build());
        User guest = userRepository.save(User.builder()
                .email("g@t.com").nickname("Matthew").userType(UserType.FOREIGN_TOURIST).build());
        User other = userRepository.save(User.builder()
                .email("o@t.com").nickname("남").userType(UserType.FOREIGN_TOURIST).build());
        Content content = contentRepository.save(Content.builder()
                .author(mate).title("한옥마을 투어").theme(Theme.PLACE)
                .meetingPoint("홍대입구역 2번 출구").pricePerHour(20000).build());

        // 내 약속 (7월, 범위 내)
        bookingRepository.save(Booking.builder().content(content).guest(guest).mate(mate)
                .date(LocalDate.of(2026, 7, 8))
                .startTime(LocalTime.of(14, 0)).endTime(LocalTime.of(17, 0)).totalPrice(20000).build());
        // 내 약속이지만 범위 밖 (8월)
        bookingRepository.save(Booking.builder().content(content).guest(guest).mate(mate)
                .date(LocalDate.of(2026, 8, 3))
                .startTime(LocalTime.of(14, 0)).endTime(LocalTime.of(17, 0)).totalPrice(20000).build());
        // 나와 무관한 약속 (guest/mate 모두 other)
        bookingRepository.save(Booking.builder().content(content).guest(other).mate(other)
                .date(LocalDate.of(2026, 7, 10))
                .startTime(LocalTime.of(10, 0)).endTime(LocalTime.of(12, 0)).totalPrice(20000).build());
        return new Fixture(mate, guest, content);
    }

    @Test
    @DisplayName("month=2026-07 → 본인 7월 약속만, 상대방은 로그인(mate=재협) 기준 guest(Matthew)")
    void listByMonth() throws Exception {
        Fixture f = setUp();

        mockMvc.perform(get("/api/appointments").param("month", "2026-07")
                        .with(user(String.valueOf(f.mate().getId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("SUCCESS"))
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[0].date").value("2026-07-08"))
                .andExpect(jsonPath("$.data[0].mateName").value("Matthew"))
                .andExpect(jsonPath("$.data[0].mateUserId").value(f.guest().getId()))
                .andExpect(jsonPath("$.data[0].place").value("홍대입구역 2번 출구"))
                .andExpect(jsonPath("$.data[0].contentTitle").value("한옥마을 투어"))
                .andExpect(jsonPath("$.data[0].startTime").value("14:00"))
                .andExpect(jsonPath("$.data[0].endTime").value("17:00"))
                .andExpect(jsonPath("$.data[0].status").value("PENDING"));
    }

    @Test
    @DisplayName("guest로 로그인해 월 조회하면 상대는 mate(재협)")
    void listByMonthAsGuest() throws Exception {
        Fixture f = setUp();

        mockMvc.perform(get("/api/appointments").param("month", "2026-07")
                        .with(user(String.valueOf(f.guest().getId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[0].mateName").value("재협"))
                .andExpect(jsonPath("$.data[0].mateUserId").value(f.mate().getId()));
    }

    @Test
    @DisplayName("해당 기간에 약속 없으면 빈 배열")
    void emptyWhenNoAppointments() throws Exception {
        Fixture f = setUp();

        mockMvc.perform(get("/api/appointments").param("month", "2026-01")
                        .with(user(String.valueOf(f.mate().getId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(0));
    }

    @Test
    @DisplayName("from/to/month 모두 없으면 400")
    void badRequestWhenNoRange() throws Exception {
        Fixture f = setUp();

        mockMvc.perform(get("/api/appointments")
                        .with(user(String.valueOf(f.mate().getId()))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("COMMON_400"));
    }
}
