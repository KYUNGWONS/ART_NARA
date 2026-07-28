package com.example.unitrip.domain.content;

import com.example.unitrip.domain.content.dto.ContentDto;
import com.example.unitrip.domain.content.entity.Content;
import com.example.unitrip.domain.content.entity.Theme;
import com.example.unitrip.domain.content.repository.ContentRepository;
import com.example.unitrip.domain.content.service.ContentService;
import com.example.unitrip.domain.user.entity.User;
import com.example.unitrip.domain.user.entity.UserType;
import com.example.unitrip.domain.user.repository.DistrictRepository;
import com.example.unitrip.domain.user.repository.UserRepository;
import com.example.unitrip.global.common.DomainResultCode;
import com.example.unitrip.global.exception.GlobalException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class ContentServiceTest {

    @Mock ContentRepository contentRepository;
    @Mock UserRepository userRepository;
    @Mock DistrictRepository districtRepository;
    @InjectMocks ContentService contentService;

    private User createUser() {
        User u = User.builder().email("a@t.com").nickname("a").userType(UserType.KOREAN_STUDENT).build();
        ReflectionTestUtils.setField(u, "id", 1L);
        return u;
    }

    private Content createContent(User author) {
        Content c = Content.builder().author(author).title("활동").theme(Theme.ACTIVITY).pricePerHour(1000).build();
        ReflectionTestUtils.setField(c, "id", 10L);
        return c;
    }

    @Test
    @DisplayName("콘텐츠 생성 성공")
    void create() {
        User author = createUser();
        Content content = createContent(author);
        given(userRepository.findById(1L)).willReturn(Optional.of(author));
        given(contentRepository.save(any(Content.class))).willReturn(content);

        var req = new ContentDto.CreateRequest("활동", "짧은 소개", "desc", Theme.ACTIVITY,
                null, null, null, null, null, null, null, null, null, null, 1000);
        ContentDto.Response res = contentService.create(1L, req);

        assertThat(res.title()).isEqualTo("활동");
        assertThat(res.authorId()).isEqualTo(1L);
    }

    @Test
    @DisplayName("콘텐츠 조회 성공")
    void get() {
        Content content = createContent(createUser());
        given(contentRepository.findById(10L)).willReturn(Optional.of(content));
        assertThat(contentService.get(10L).id()).isEqualTo(10L);
    }

    @Test
    @DisplayName("없는 콘텐츠 조회 시 예외")
    void getNotFound() {
        given(contentRepository.findById(99L)).willReturn(Optional.empty());
        assertThatThrownBy(() -> contentService.get(99L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.CONTENT_NOT_FOUND);
    }

    @Test
    @DisplayName("공개 콘텐츠 목록 조회")
    void listVisible() {
        Content c = createContent(createUser());
        given(contentRepository.findAllByVisibleTrue()).willReturn(List.of(c));
        assertThat(contentService.listVisible()).hasSize(1);
    }

    @Test
    @DisplayName("작성자별 콘텐츠 조회")
    void listByAuthor() {
        Content c = createContent(createUser());
        given(contentRepository.findAllByAuthorId(1L)).willReturn(List.of(c));
        assertThat(contentService.listByAuthor(1L)).hasSize(1);
    }

    @Test
    @DisplayName("테마별 콘텐츠 조회")
    void listByTheme() {
        Content c = createContent(createUser());
        given(contentRepository.findAllByThemeAndVisibleTrue(Theme.ACTIVITY)).willReturn(List.of(c));
        assertThat(contentService.listByTheme(Theme.ACTIVITY)).hasSize(1);
    }

    @Test
    @DisplayName("구(district)별 콘텐츠 조회")
    void listByDistrict() {
        Content c = createContent(createUser());
        given(contentRepository.findAllByDistrict_IdAndVisibleTrue(9L)).willReturn(List.of(c));
        assertThat(contentService.listByDistrict(9L)).hasSize(1);
    }

    @Test
    @DisplayName("콘텐츠 수정")
    void update() {
        Content content = createContent(createUser());
        given(contentRepository.findById(10L)).willReturn(Optional.of(content));

        var req = new ContentDto.UpdateRequest("new title", null, null, null,
                null, null, null, null, null, null, null, null, null, null, null);
        ContentDto.Response res = contentService.update(10L, req);
        assertThat(res.title()).isEqualTo("new title");
    }

    @Test
    @DisplayName("공개 설정 변경")
    void setVisible() {
        Content content = createContent(createUser());
        given(contentRepository.findById(10L)).willReturn(Optional.of(content));
        contentService.setVisible(10L, false);
        assertThat(content.isVisible()).isFalse();
    }

    @Test
    @DisplayName("콘텐츠 삭제")
    void delete() {
        Content content = createContent(createUser());
        given(contentRepository.findById(10L)).willReturn(Optional.of(content));
        contentService.delete(10L);
        verify(contentRepository).delete(content);
    }
}
