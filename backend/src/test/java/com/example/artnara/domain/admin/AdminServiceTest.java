package com.example.artnara.domain.admin;

import com.example.artnara.domain.admin.dto.AdminDto;
import com.example.artnara.domain.admin.service.AdminAuthService;
import com.example.artnara.domain.admin.service.AdminService;
import com.example.artnara.domain.artwork.service.ArtworkService;
import com.example.artnara.domain.order.dto.OrderDto;
import com.example.artnara.domain.order.service.OrderService;
import com.example.artnara.global.auth.oauth.OAuthProvider;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import com.example.artnara.support.IntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@IntegrationTest
class AdminServiceTest {

    private static final String BUYER = "Andrew";

    @Autowired AdminService adminService;
    @Autowired AdminAuthService adminAuthService;
    @Autowired OrderService orderService;
    @Autowired ArtworkService artworkService;
    @Autowired UserRepository userRepository;

    /** test 프로필은 test.sql 을 실행하지 않으므로 회원은 테스트가 직접 만든다. */
    private User buyer() {
        return userRepository.findFirstByNickname(BUYER).orElseGet(() ->
                userRepository.save(User.ofOAuth(
                        OAuthProvider.KAKAO, "admin-test-buyer",
                        "andrew@test.com", BUYER, null)));
    }

    /** 즉시 판매 작품(id 1~4)만 결제할 수 있다 — 5~8 은 경매다. */
    private OrderDto.Response buy(long artworkId) {
        User user = buyer();
        return orderService.create(
                new OrderDto.CreateRequest(artworkId, "CARD"), user.getId(), user.getNickname());
    }

    @Test
    @DisplayName("기본 관리자(ADMIN/ADMIN)로 로그인하면 비밀번호 변경 안내가 함께 온다")
    void loginWithDefaultAccount() {
        adminAuthService.ensureDefaultAdmin("ADMIN", "ADMIN");

        AdminDto.LoginResponse response =
                adminAuthService.login(new AdminDto.LoginRequest("ADMIN", "ADMIN"));

        assertThat(response.accessToken()).isNotBlank();
        assertThat(response.username()).isEqualTo("ADMIN");
        assertThat(response.mustChangePassword()).isTrue();
    }

    @Test
    @DisplayName("비밀번호가 틀리면 401")
    void loginWithWrongPassword() {
        adminAuthService.ensureDefaultAdmin("ADMIN", "ADMIN");

        assertThatThrownBy(() ->
                adminAuthService.login(new AdminDto.LoginRequest("ADMIN", "WRONG")))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ADMIN_LOGIN_FAILED);
    }

    @Test
    @DisplayName("없는 아이디도 같은 401 로 답한다(계정 존재 여부를 알리지 않는다)")
    void loginWithUnknownAccount() {
        assertThatThrownBy(() ->
                adminAuthService.login(new AdminDto.LoginRequest("NOBODY", "ADMIN")))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ADMIN_LOGIN_FAILED);
    }

    @Test
    @DisplayName("비밀번호를 바꾸면 새 비밀번호로만 로그인된다")
    void changePassword() {
        adminAuthService.ensureDefaultAdmin("ADMIN", "ADMIN");
        Long adminId = Long.valueOf(
                adminAuthService.login(new AdminDto.LoginRequest("ADMIN", "ADMIN"))
                        .accessToken().isBlank() ? "0" : "1");
        // 토큰 파싱 대신 로그인으로 얻은 계정을 바로 쓴다 — id 는 시드상 1
        adminAuthService.changePassword(adminId,
                new AdminDto.ChangePasswordRequest("ADMIN", "newpass"));

        assertThat(adminAuthService.login(new AdminDto.LoginRequest("ADMIN", "newpass"))
                .mustChangePassword()).isFalse();
        assertThatThrownBy(() ->
                adminAuthService.login(new AdminDto.LoginRequest("ADMIN", "ADMIN")))
                .isInstanceOf(GlobalException.class);
    }

    @Test
    @DisplayName("현재 비밀번호가 틀리면 변경되지 않는다")
    void changePasswordWithWrongCurrent() {
        adminAuthService.ensureDefaultAdmin("ADMIN", "ADMIN");

        assertThatThrownBy(() -> adminAuthService.changePassword(1L,
                new AdminDto.ChangePasswordRequest("WRONG", "newpass")))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ADMIN_PASSWORD_MISMATCH);
    }

    @Test
    @DisplayName("너무 짧은 비밀번호는 거절한다")
    void changePasswordTooShort() {
        adminAuthService.ensureDefaultAdmin("ADMIN", "ADMIN");

        assertThatThrownBy(() -> adminAuthService.changePassword(1L,
                new AdminDto.ChangePasswordRequest("ADMIN", "ab")))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ADMIN_PASSWORD_TOO_SHORT);
    }

    @Test
    @DisplayName("대시보드는 결제액을 매출로 집계한다")
    void dashboardCountsRevenue() {
        AdminDto.Dashboard before = adminService.dashboard();
        OrderDto.Response order = buy(1L);

        AdminDto.Dashboard after = adminService.dashboard();

        assertThat(after.totalRevenue()).isEqualTo(before.totalRevenue() + order.amount());
        assertThat(after.orderCount()).isEqualTo(before.orderCount() + 1);
        assertThat(after.recentSales()).isNotEmpty();
    }

    @Test
    @DisplayName("환불하면 매출에서 빠지고 환불액으로 잡힌다")
    void refundMovesRevenue() {
        OrderDto.Response order = buy(2L);
        AdminDto.Dashboard paid = adminService.dashboard();

        adminService.refund(order.orderId(), "고객 변심");

        AdminDto.Dashboard refunded = adminService.dashboard();
        assertThat(refunded.totalRevenue()).isEqualTo(paid.totalRevenue() - order.amount());
        assertThat(refunded.refundedAmount()).isEqualTo(paid.refundedAmount() + order.amount());
        assertThat(refunded.refundCount()).isEqualTo(paid.refundCount() + 1);
    }

    @Test
    @DisplayName("환불하면 작품이 다시 판매 가능해진다")
    void refundUnlocksArtwork() {
        OrderDto.Response order = buy(3L);
        assertThat(artworkService.getDetail(3L).sold()).isTrue();

        adminService.refund(order.orderId(), "파손");

        assertThat(artworkService.getDetail(3L).sold()).isFalse();
    }

    @Test
    @DisplayName("같은 주문을 두 번 환불할 수 없다")
    void refundTwice() {
        OrderDto.Response order = buy(4L);
        adminService.refund(order.orderId(), "고객 변심");

        assertThatThrownBy(() -> adminService.refund(order.orderId(), "또"))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.ORDER_ALREADY_REFUNDED);
    }

    @Test
    @DisplayName("회원을 차단하고 해제할 수 있다")
    void blockAndUnblock() {
        Long userId = buyer().getId();
        adminService.blockMember(userId, "부적절한 거래");

        AdminDto.MemberRow blocked = memberOf(userId);
        assertThat(blocked.blocked()).isTrue();
        assertThat(blocked.blockedReason()).isEqualTo("부적절한 거래");

        adminService.unblockMember(userId);
        assertThat(memberOf(userId).blocked()).isFalse();
    }

    @Test
    @DisplayName("회원 목록은 닉네임으로 검색된다")
    void searchMembers() {
        buyer();

        AdminDto.MemberList result = adminService.members("andrew");

        assertThat(result.members()).isNotEmpty();
        assertThat(result.members())
                .allMatch(member -> member.nickname().toLowerCase().contains("andrew"));
    }

    @Test
    @DisplayName("회원 행에 구매 건수·금액이 집계된다")
    void memberSpending() {
        OrderDto.Response order = buy(1L);

        AdminDto.MemberRow row = memberOf(buyer().getId());
        assertThat(row.orderCount()).isGreaterThanOrEqualTo(1);
        assertThat(row.spentAmount()).isGreaterThanOrEqualTo(order.amount());
    }

    private AdminDto.MemberRow memberOf(long userId) {
        return adminService.members(null).members().stream()
                .filter(member -> member.id() == userId)
                .findFirst()
                .orElseThrow();
    }
}
