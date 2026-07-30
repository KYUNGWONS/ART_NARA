package com.example.artnara.domain.festival.service;

import com.example.artnara.domain.festival.dto.FestivalDto;
import com.example.artnara.domain.festival.entity.Festival;
import com.example.artnara.domain.festival.repository.FestivalRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FestivalService {

    private final FestivalRepository festivalRepository;

    @Transactional
    public FestivalDto.Response create(FestivalDto.CreateRequest req) {
        Festival saved = festivalRepository.save(Festival.builder()
                .name(req.name()).region(req.region()).description(req.description())
                .coverImageUrl(req.coverImageUrl())
                .startDate(req.startDate()).endDate(req.endDate()).build());
        return FestivalDto.Response.from(saved);
    }

    public List<FestivalDto.Response> list(String region) {
        var list = (region == null) ? festivalRepository.findAll()
                : festivalRepository.findAllByRegion(region);
        return list.stream().map(FestivalDto.Response::from).toList();
    }

    public FestivalDto.Response get(Long id) {
        return FestivalDto.Response.from(find(id));
    }

    @Transactional
    public FestivalDto.Response update(Long id, FestivalDto.UpdateRequest req) {
        Festival f = find(id);
        f.update(req.name(), req.region(), req.description(), req.coverImageUrl(),
                req.startDate(), req.endDate());
        return FestivalDto.Response.from(f);
    }

    @Transactional
    public void delete(Long id) {
        festivalRepository.delete(find(id));
    }

    private Festival find(Long id) {
        return festivalRepository.findById(id)
                .orElseThrow(() -> new GlobalException(DomainResultCode.FESTIVAL_NOT_FOUND));
    }
}
