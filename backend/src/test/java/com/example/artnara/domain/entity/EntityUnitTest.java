package com.example.artnara.domain.entity;

import com.example.artnara.domain.chat.entity.*;
import com.example.artnara.domain.user.entity.Sido;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.entity.UserType;
import com.example.artnara.domain.verification.entity.Verification;
import com.example.artnara.domain.verification.entity.VerificationStatus;
import com.example.artnara.domain.verification.entity.VerificationType;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class EntityUnitTest {

    // ── User ──────────────────────────────────────────────

    @Nested
    @DisplayName("User 엔티티")
    class UserTest {

        @Test
        @DisplayName("프로필 부분 업데이트 - null이 아닌 필드만 변경")
        void updateProfilePartial() {
            User user = User.builder()
                    .email("a@test.com").nickname("old").userType(UserType.KOREAN_STUDENT)
                    .region(Sido.SEOUL).aboutMe("hi").build();

            user.updateProfile("new", null, null, null, null, null);

            assertThat(user.getNickname()).isEqualTo("new");
            assertThat(user.getRegion()).isEqualTo(Sido.SEOUL);
            assertThat(user.getAboutMe()).isEqualTo("hi");
            // 역할을 안 보내면 기존 역할이 유지된다
            assertThat(user.getUserType()).isEqualTo(UserType.KOREAN_STUDENT);
        }

        @Test
        @DisplayName("역할 전환 - 작가에서 컬렉터로")
        void updateProfileSwitchesRole() {
            User user = User.builder()
                    .email("a@test.com").nickname("경원").userType(UserType.KOREAN_STUDENT)
                    .build();

            user.updateProfile(null, null, null, null, null, UserType.FOREIGN_TOURIST);

            assertThat(user.getUserType()).isEqualTo(UserType.FOREIGN_TOURIST);
            assertThat(user.getNickname()).isEqualTo("경원");
        }

        @Test
        @DisplayName("프로필 전체 업데이트")
        void updateProfileFull() {
            User user = User.builder()
                    .email("a@test.com").nickname("old").userType(UserType.KOREAN_STUDENT).build();

            user.updateProfile("new", "재하정", Sido.BUSAN, "bye", List.of("회화"), null);

            assertThat(user.getNickname()).isEqualTo("new");
            assertThat(user.getDisplayName()).isEqualTo("재하정");
            assertThat(user.getRegion()).isEqualTo(Sido.BUSAN);
            assertThat(user.getAboutMe()).isEqualTo("bye");
            assertThat(user.getInterests()).containsExactly("회화");
        }
    }

    // ── ChatRoom ──────────────────────────────────────────

    @Nested
    @DisplayName("ChatRoom 엔티티")
    class ChatRoomTest {

        @Test
        @DisplayName("생성 시 기본 상태 WAITING")
        void defaultStatus() {
            ChatRoom room = ChatRoom.builder().creatorId(1L).build();
            assertThat(room.getStatus()).isEqualTo(ChatRoomStatus.WAITING);
            assertThat(room.isCreatorLeft()).isFalse();
            assertThat(room.isJoinerLeft()).isFalse();
        }

        @Test
        @DisplayName("join → ACTIVE, joinerId 설정")
        void join() {
            ChatRoom room = ChatRoom.builder().creatorId(1L).build();
            room.join(2L);
            assertThat(room.getJoinerId()).isEqualTo(2L);
            assertThat(room.getStatus()).isEqualTo(ChatRoomStatus.ACTIVE);
        }

        @Test
        @DisplayName("creator leave → creatorLeft true, 아직 ACTIVE")
        void leaveCreator() {
            ChatRoom room = ChatRoom.builder().creatorId(1L).build();
            room.join(2L);
            room.leave(1L);
            assertThat(room.isCreatorLeft()).isTrue();
            assertThat(room.isJoinerLeft()).isFalse();
            assertThat(room.getStatus()).isEqualTo(ChatRoomStatus.ACTIVE);
        }

        @Test
        @DisplayName("양쪽 다 leave → CLOSED")
        void leaveBoth() {
            ChatRoom room = ChatRoom.builder().creatorId(1L).build();
            room.join(2L);
            room.leave(1L);
            room.leave(2L);
            assertThat(room.getStatus()).isEqualTo(ChatRoomStatus.CLOSED);
        }

        @Test
        @DisplayName("getOpponentId - creator 기준")
        void opponentForCreator() {
            ChatRoom room = ChatRoom.builder().creatorId(1L).build();
            room.join(2L);
            assertThat(room.getOpponentId(1L)).isEqualTo(2L);
        }

        @Test
        @DisplayName("getOpponentId - joiner 기준")
        void opponentForJoiner() {
            ChatRoom room = ChatRoom.builder().creatorId(1L).build();
            room.join(2L);
            assertThat(room.getOpponentId(2L)).isEqualTo(1L);
        }
    }

    // ── ChatMessage ───────────────────────────────────────

    @Nested
    @DisplayName("ChatMessage 엔티티")
    class ChatMessageTest {

        @Test
        @DisplayName("기본 read는 false, markAsRead → true")
        void markAsRead() {
            ChatRoom room = ChatRoom.builder().creatorId(1L).build();
            ChatMessage msg = ChatMessage.builder()
                    .chatRoom(room).senderId(1L).content("hi")
                    .messageType(MessageType.TEXT).build();

            assertThat(msg.isRead()).isFalse();
            msg.markAsRead();
            assertThat(msg.isRead()).isTrue();
        }
    }

    // ── Appointment ───────────────────────────────────────

    @Nested
    @DisplayName("Appointment 엔티티")
    class AppointmentTest {

        @Test
        @DisplayName("기본 상태 PENDING")
        void defaultStatus() {
            ChatRoom room = ChatRoom.builder().creatorId(1L).build();
            Appointment apt = Appointment.builder()
                    .chatRoom(room).requesterId(1L).responderId(2L)
                    .appointmentTime(LocalDateTime.of(2026, 5, 1, 14, 0))
                    .location("서울역").build();
            assertThat(apt.getStatus()).isEqualTo(AppointmentStatus.PENDING);
        }

        @Test
        @DisplayName("accept → ACCEPTED")
        void accept() {
            ChatRoom room = ChatRoom.builder().creatorId(1L).build();
            Appointment apt = Appointment.builder()
                    .chatRoom(room).requesterId(1L).responderId(2L).build();
            apt.accept();
            assertThat(apt.getStatus()).isEqualTo(AppointmentStatus.ACCEPTED);
        }

        @Test
        @DisplayName("reject → REJECTED")
        void reject() {
            ChatRoom room = ChatRoom.builder().creatorId(1L).build();
            Appointment apt = Appointment.builder()
                    .chatRoom(room).requesterId(1L).responderId(2L).build();
            apt.reject();
            assertThat(apt.getStatus()).isEqualTo(AppointmentStatus.REJECTED);
        }
    }

    // ── Verification ──────────────────────────────────────

    @Nested
    @DisplayName("Verification 엔티티")
    class VerificationTest {

        private Verification createVerification() {
            User user = User.builder()
                    .email("u@t.com").nickname("u").userType(UserType.KOREAN_STUDENT).build();
            return Verification.builder()
                    .user(user).type(VerificationType.UNIVERSITY)
                    .documentUrl("https://doc.jpg").build();
        }

        @Test
        @DisplayName("기본 상태 PENDING")
        void defaultStatus() {
            assertThat(createVerification().getStatus()).isEqualTo(VerificationStatus.PENDING);
        }

        @Test
        @DisplayName("approve → APPROVED, rejectReason null")
        void approve() {
            Verification v = createVerification();
            v.approve();
            assertThat(v.getStatus()).isEqualTo(VerificationStatus.APPROVED);
            assertThat(v.getRejectReason()).isNull();
        }

        @Test
        @DisplayName("reject → REJECTED, rejectReason 설정")
        void reject() {
            Verification v = createVerification();
            v.reject("서류 불명확");
            assertThat(v.getStatus()).isEqualTo(VerificationStatus.REJECTED);
            assertThat(v.getRejectReason()).isEqualTo("서류 불명확");
        }

        @Test
        @DisplayName("reject 후 approve → rejectReason null로 초기화")
        void rejectThenApprove() {
            Verification v = createVerification();
            v.reject("불명확");
            v.approve();
            assertThat(v.getStatus()).isEqualTo(VerificationStatus.APPROVED);
            assertThat(v.getRejectReason()).isNull();
        }
    }

}
