package com.example.artnara.domain.entity;

import com.example.artnara.domain.booking.entity.Booking;
import com.example.artnara.domain.booking.entity.BookingStatus;
import com.example.artnara.domain.chat.entity.*;
import com.example.artnara.domain.content.entity.Content;
import com.example.artnara.domain.content.entity.Language;
import com.example.artnara.domain.content.entity.Theme;
import com.example.artnara.domain.content.entity.TimeSlot;
import com.example.artnara.domain.festival.entity.Festival;
import com.example.artnara.domain.magazine.entity.Magazine;
import com.example.artnara.domain.magazine.entity.MagazineCategory;
import com.example.artnara.domain.notification.entity.Notification;
import com.example.artnara.domain.notification.entity.NotificationType;
import com.example.artnara.domain.user.entity.Sido;
import com.example.artnara.domain.user.entity.TravelStyle;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.entity.UserType;
import com.example.artnara.domain.verification.entity.Verification;
import com.example.artnara.domain.verification.entity.VerificationStatus;
import com.example.artnara.domain.verification.entity.VerificationType;
import com.example.artnara.domain.wishlist.entity.WishlistFolder;
import com.example.artnara.domain.wishlist.entity.WishlistItem;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
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

            user.updateProfile("new", null, null, null, null, null, null);

            assertThat(user.getNickname()).isEqualTo("new");
            assertThat(user.getRegion()).isEqualTo(Sido.SEOUL);
            assertThat(user.getAboutMe()).isEqualTo("hi");
        }

        @Test
        @DisplayName("프로필 전체 업데이트")
        void updateProfileFull() {
            User user = User.builder()
                    .email("a@test.com").nickname("old").userType(UserType.KOREAN_STUDENT).build();

            TravelStyle style = new TravelStyle(10, 20, 30, 40);
            user.updateProfile("new", "재하정", Sido.BUSAN, "bye", style, List.of("music"), List.of("한국어"));

            assertThat(user.getNickname()).isEqualTo("new");
            assertThat(user.getDisplayName()).isEqualTo("재하정");
            assertThat(user.getRegion()).isEqualTo(Sido.BUSAN);
            assertThat(user.getAboutMe()).isEqualTo("bye");
            assertThat(user.getTravelStyle()).isEqualTo(style);
            assertThat(user.getInterests()).containsExactly("music");
            assertThat(user.getLanguages()).containsExactly("한국어");
        }

        @Test
        @DisplayName("매칭 활성화/비활성화")
        void setMatchingEnabled() {
            User user = User.builder()
                    .email("a@test.com").nickname("n").userType(UserType.FOREIGN_TOURIST).build();

            assertThat(user.isMatchingEnabled()).isTrue();
            user.setMatchingEnabled(false);
            assertThat(user.isMatchingEnabled()).isFalse();
        }
    }

    // ── Booking ───────────────────────────────────────────

    @Nested
    @DisplayName("Booking 엔티티")
    class BookingTest {

        private Booking createBooking() {
            User author = User.builder()
                    .email("m@t.com").nickname("mate").userType(UserType.KOREAN_STUDENT).build();
            Content content = Content.builder()
                    .author(author).title("t").theme(Theme.PLACE).pricePerHour(1000).build();
            User guest = User.builder()
                    .email("g@t.com").nickname("guest").userType(UserType.FOREIGN_TOURIST).build();
            return Booking.builder()
                    .content(content).guest(guest).mate(author)
                    .date(LocalDate.of(2026, 5, 1))
                    .startTime(LocalTime.of(10, 0)).endTime(LocalTime.of(18, 0))
                    .totalPrice(30000).build();
        }

        @Test
        @DisplayName("생성 시 기본 상태는 PENDING_PAYMENT")
        void defaultStatus() {
            assertThat(createBooking().getStatus()).isEqualTo(BookingStatus.PENDING_PAYMENT);
        }

        @Test
        @DisplayName("confirm → CONFIRMED")
        void confirm() {
            Booking b = createBooking();
            b.confirm();
            assertThat(b.getStatus()).isEqualTo(BookingStatus.CONFIRMED);
        }

        @Test
        @DisplayName("cancel → CANCELLED")
        void cancel() {
            Booking b = createBooking();
            b.cancel();
            assertThat(b.getStatus()).isEqualTo(BookingStatus.CANCELLED);
        }

        @Test
        @DisplayName("complete → COMPLETED")
        void complete() {
            Booking b = createBooking();
            b.complete();
            assertThat(b.getStatus()).isEqualTo(BookingStatus.COMPLETED);
        }
    }

    // ── Content ───────────────────────────────────────────

    @Nested
    @DisplayName("Content 엔티티")
    class ContentTest {

        @Test
        @DisplayName("기본 visible은 true")
        void defaultVisible() {
            User author = User.builder()
                    .email("a@t.com").nickname("a").userType(UserType.KOREAN_STUDENT).build();
            Content c = Content.builder()
                    .author(author).title("t").theme(Theme.ACTIVITY).build();
            assertThat(c.isVisible()).isTrue();
        }

        @Test
        @DisplayName("setVisible로 공개/비공개 전환")
        void setVisible() {
            User author = User.builder()
                    .email("a@t.com").nickname("a").userType(UserType.KOREAN_STUDENT).build();
            Content c = Content.builder()
                    .author(author).title("t").theme(Theme.ACTIVITY).build();
            c.setVisible(false);
            assertThat(c.isVisible()).isFalse();
        }

        @Test
        @DisplayName("부분 업데이트 - null이 아닌 필드만 변경")
        void updatePartial() {
            User author = User.builder()
                    .email("a@t.com").nickname("a").userType(UserType.KOREAN_STUDENT).build();
            Content c = Content.builder()
                    .author(author).title("old").theme(Theme.PLACE)
                    .description("desc").pricePerHour(1000).build();

            c.update("new", null, null, Theme.ACTIVITY, null, null, null, null, null, null, null, null, null, null);

            assertThat(c.getTitle()).isEqualTo("new");
            assertThat(c.getDescription()).isEqualTo("desc");
            assertThat(c.getTheme()).isEqualTo(Theme.ACTIVITY);
            assertThat(c.getPricePerHour()).isEqualTo(1000);
        }

        @Test
        @DisplayName("전체 업데이트")
        void updateFull() {
            User author = User.builder()
                    .email("a@t.com").nickname("a").userType(UserType.KOREAN_STUDENT).build();
            Content c = Content.builder()
                    .author(author).title("old").theme(Theme.PLACE).build();

            c.update("new", "한 줄 소개", "new desc", Theme.PERFORMANCE, Sido.SEOUL, "합정", null,
                    List.of(Language.KOREAN), List.of("img.jpg"),
                    List.of(DayOfWeek.MONDAY), List.of(TimeSlot.DINNER_TO_NIGHT),
                    "합정역 1번 출구", 4, 5000);

            assertThat(c.getTitle()).isEqualTo("new");
            assertThat(c.getDescription()).isEqualTo("new desc");
            assertThat(c.getTheme()).isEqualTo(Theme.PERFORMANCE);
            assertThat(c.getSido()).isEqualTo(Sido.SEOUL);
            assertThat(c.getNeighborhood()).isEqualTo("합정");
            assertThat(c.getMeetingPoint()).isEqualTo("합정역 1번 출구");
            assertThat(c.getAvailableDays()).containsExactly(DayOfWeek.MONDAY);
            assertThat(c.getAvailableTimeSlots()).containsExactly(TimeSlot.DINNER_TO_NIGHT);
            assertThat(c.getPricePerHour()).isEqualTo(5000);
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

    // ── Festival ──────────────────────────────────────────

    @Nested
    @DisplayName("Festival 엔티티")
    class FestivalTest {

        @Test
        @DisplayName("부분 업데이트")
        void updatePartial() {
            Festival f = Festival.builder()
                    .name("축제").region("서울").description("설명").build();
            f.update("새 축제", null, null, null, null, null);
            assertThat(f.getName()).isEqualTo("새 축제");
            assertThat(f.getRegion()).isEqualTo("서울");
            assertThat(f.getDescription()).isEqualTo("설명");
        }

        @Test
        @DisplayName("전체 업데이트")
        void updateFull() {
            Festival f = Festival.builder().name("old").region("old").build();
            f.update("new", "부산", "desc", "img.jpg",
                    LocalDate.of(2026, 10, 1), LocalDate.of(2026, 10, 5));
            assertThat(f.getName()).isEqualTo("new");
            assertThat(f.getRegion()).isEqualTo("부산");
            assertThat(f.getDescription()).isEqualTo("desc");
            assertThat(f.getCoverImageUrl()).isEqualTo("img.jpg");
            assertThat(f.getStartDate()).isEqualTo(LocalDate.of(2026, 10, 1));
            assertThat(f.getEndDate()).isEqualTo(LocalDate.of(2026, 10, 5));
        }
    }

    // ── Magazine ──────────────────────────────────────────

    @Nested
    @DisplayName("Magazine 엔티티")
    class MagazineTest {

        @Test
        @DisplayName("부분 업데이트")
        void updatePartial() {
            Magazine m = Magazine.builder()
                    .title("old").summary("sum").category(MagazineCategory.KNOT_GUIDE).build();
            m.update("new", null, null, null, null);
            assertThat(m.getTitle()).isEqualTo("new");
            assertThat(m.getSummary()).isEqualTo("sum");
            assertThat(m.getCategory()).isEqualTo(MagazineCategory.KNOT_GUIDE);
        }

        @Test
        @DisplayName("전체 업데이트")
        void updateFull() {
            Magazine m = Magazine.builder()
                    .title("old").category(MagazineCategory.KNOT_GUIDE).build();
            m.update("new", "summary", "content", "img.jpg", MagazineCategory.QNA_TIPS);
            assertThat(m.getTitle()).isEqualTo("new");
            assertThat(m.getSummary()).isEqualTo("summary");
            assertThat(m.getContent()).isEqualTo("content");
            assertThat(m.getCoverImageUrl()).isEqualTo("img.jpg");
            assertThat(m.getCategory()).isEqualTo(MagazineCategory.QNA_TIPS);
        }
    }

    // ── Notification ──────────────────────────────────────

    @Nested
    @DisplayName("Notification 엔티티")
    class NotificationTest {

        @Test
        @DisplayName("기본 read false, markRead → true")
        void markRead() {
            User user = User.builder()
                    .email("u@t.com").nickname("u").userType(UserType.KOREAN_STUDENT).build();
            Notification n = Notification.builder()
                    .user(user).type(NotificationType.BOOKING_CONFIRMED)
                    .title("예약 확정").body("body").build();
            assertThat(n.isRead()).isFalse();
            n.markRead();
            assertThat(n.isRead()).isTrue();
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

    // ── WishlistFolder ────────────────────────────────────

    @Nested
    @DisplayName("WishlistFolder 엔티티")
    class WishlistFolderTest {

        @Test
        @DisplayName("rename - null이면 변경 안 함")
        void renameNull() {
            User owner = User.builder()
                    .email("o@t.com").nickname("o").userType(UserType.FOREIGN_TOURIST).build();
            WishlistFolder f = WishlistFolder.builder().owner(owner).name("old").build();
            f.rename(null);
            assertThat(f.getName()).isEqualTo("old");
        }

        @Test
        @DisplayName("rename - 이름 변경")
        void rename() {
            User owner = User.builder()
                    .email("o@t.com").nickname("o").userType(UserType.FOREIGN_TOURIST).build();
            WishlistFolder f = WishlistFolder.builder().owner(owner).name("old").build();
            f.rename("new");
            assertThat(f.getName()).isEqualTo("new");
        }
    }

    // ── WishlistItem ──────────────────────────────────────

    @Nested
    @DisplayName("WishlistItem 엔티티")
    class WishlistItemTest {

        @Test
        @DisplayName("메모 업데이트")
        void updateMemo() {
            User owner = User.builder()
                    .email("o@t.com").nickname("o").userType(UserType.FOREIGN_TOURIST).build();
            Content content = Content.builder()
                    .author(owner).title("t").theme(Theme.PLACE).build();
            WishlistFolder folder = WishlistFolder.builder().owner(owner).name("f").build();
            WishlistItem item = WishlistItem.builder()
                    .folder(folder).content(content).memo("old").build();

            item.updateMemo("new memo");
            assertThat(item.getMemo()).isEqualTo("new memo");
        }
    }
}
