package com.example.artnara.domain.festival;

import com.example.artnara.domain.festival.dto.FestivalDto;
import com.example.artnara.domain.festival.entity.Festival;
import com.example.artnara.domain.festival.repository.FestivalRepository;
import com.example.artnara.domain.festival.service.FestivalService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class FestivalServiceTest {

    @Mock FestivalRepository festivalRepository;
    @InjectMocks FestivalService festivalService;

    private Festival createFestival() {
        Festival f = Festival.builder().name("축제").region("서울")
                .description("설명").startDate(LocalDate.of(2026, 10, 1))
                .endDate(LocalDate.of(2026, 10, 5)).build();
        ReflectionTestUtils.setField(f, "id", 1L);
        return f;
    }

    @Test
    @DisplayName("페스티벌 생성")
    void create() {
        Festival f = createFestival();
        given(festivalRepository.save(any(Festival.class))).willReturn(f);
        var req = new FestivalDto.CreateRequest("축제", "서울", "설명", null,
                LocalDate.of(2026, 10, 1), LocalDate.of(2026, 10, 5));
        assertThat(festivalService.create(req).name()).isEqualTo("축제");
    }

    @Test
    @DisplayName("전체 목록 조회")
    void listAll() {
        given(festivalRepository.findAll()).willReturn(List.of(createFestival()));
        assertThat(festivalService.list(null)).hasSize(1);
    }

    @Test
    @DisplayName("지역별 목록 조회")
    void listByRegion() {
        given(festivalRepository.findAllByRegion("서울")).willReturn(List.of(createFestival()));
        assertThat(festivalService.list("서울")).hasSize(1);
    }

    @Test
    @DisplayName("조회 성공")
    void get() {
        given(festivalRepository.findById(1L)).willReturn(Optional.of(createFestival()));
        assertThat(festivalService.get(1L).id()).isEqualTo(1L);
    }

    @Test
    @DisplayName("없는 페스티벌 조회 시 예외")
    void getNotFound() {
        given(festivalRepository.findById(99L)).willReturn(Optional.empty());
        assertThatThrownBy(() -> festivalService.get(99L))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.FESTIVAL_NOT_FOUND);
    }

    @Test
    @DisplayName("페스티벌 수정")
    void update() {
        Festival f = createFestival();
        given(festivalRepository.findById(1L)).willReturn(Optional.of(f));
        var req = new FestivalDto.UpdateRequest("새 축제", null, null, null, null, null);
        assertThat(festivalService.update(1L, req).name()).isEqualTo("새 축제");
    }

    @Test
    @DisplayName("페스티벌 삭제")
    void delete() {
        Festival f = createFestival();
        given(festivalRepository.findById(1L)).willReturn(Optional.of(f));
        festivalService.delete(1L);
        verify(festivalRepository).delete(f);
    }
}
