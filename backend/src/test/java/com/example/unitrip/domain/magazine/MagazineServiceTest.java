package com.example.unitrip.domain.magazine;

import com.example.unitrip.domain.magazine.dto.MagazineDto;
import com.example.unitrip.domain.magazine.entity.Magazine;
import com.example.unitrip.domain.magazine.entity.MagazineCategory;
import com.example.unitrip.domain.magazine.repository.MagazineRepository;
import com.example.unitrip.domain.magazine.service.MagazineService;
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
class MagazineServiceTest {

    @Mock MagazineRepository magazineRepository;
    @InjectMocks MagazineService magazineService;

    private Magazine createMagazine() {
        Magazine m = Magazine.builder().title("매거진").summary("요약")
                .content("본문").category(MagazineCategory.KNOT_GUIDE).build();
        ReflectionTestUtils.setField(m, "id", 1L);
        return m;
    }

    @Test
    @DisplayName("매거진 생성")
    void create() {
        Magazine m = createMagazine();
        given(magazineRepository.save(any(Magazine.class))).willReturn(m);
        var req = new MagazineDto.CreateRequest("매거진", "요약", "본문", null, MagazineCategory.KNOT_GUIDE);
        assertThat(magazineService.create(req).title()).isEqualTo("매거진");
    }

    @Test
    @DisplayName("전체 목록 조회")
    void listAll() {
        given(magazineRepository.findAll()).willReturn(List.of(createMagazine()));
        assertThat(magazineService.list(null)).hasSize(1);
    }

    @Test
    @DisplayName("카테고리별 조회")
    void listByCategory() {
        given(magazineRepository.findAllByCategory(MagazineCategory.KNOT_GUIDE))
                .willReturn(List.of(createMagazine()));
        assertThat(magazineService.list(MagazineCategory.KNOT_GUIDE)).hasSize(1);
    }

    @Test
    @DisplayName("조회 성공")
    void get() {
        given(magazineRepository.findById(1L)).willReturn(Optional.of(createMagazine()));
        assertThat(magazineService.get(1L).id()).isEqualTo(1L);
    }

    @Test
    @DisplayName("없는 매거진 조회 시 예외")
    void getNotFound() {
        given(magazineRepository.findById(99L)).willReturn(Optional.empty());
        assertThatThrownBy(() -> magazineService.get(99L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.MAGAZINE_NOT_FOUND);
    }

    @Test
    @DisplayName("매거진 수정")
    void update() {
        Magazine m = createMagazine();
        given(magazineRepository.findById(1L)).willReturn(Optional.of(m));
        var req = new MagazineDto.UpdateRequest("새 제목", null, null, null, null);
        assertThat(magazineService.update(1L, req).title()).isEqualTo("새 제목");
    }

    @Test
    @DisplayName("매거진 삭제")
    void delete() {
        Magazine m = createMagazine();
        given(magazineRepository.findById(1L)).willReturn(Optional.of(m));
        magazineService.delete(1L);
        verify(magazineRepository).delete(m);
    }
}
