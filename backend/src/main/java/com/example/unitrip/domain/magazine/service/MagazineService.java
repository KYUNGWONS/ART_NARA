package com.example.unitrip.domain.magazine.service;

import com.example.unitrip.domain.magazine.dto.MagazineDto;
import com.example.unitrip.domain.magazine.entity.Magazine;
import com.example.unitrip.domain.magazine.entity.MagazineCategory;
import com.example.unitrip.domain.magazine.repository.MagazineRepository;
import com.example.unitrip.global.common.DomainResultCode;
import com.example.unitrip.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MagazineService {

    private final MagazineRepository magazineRepository;

    @Transactional
    public MagazineDto.Response create(MagazineDto.CreateRequest req) {
        Magazine saved = magazineRepository.save(Magazine.builder()
                .title(req.title()).summary(req.summary()).content(req.content())
                .coverImageUrl(req.coverImageUrl()).category(req.category()).build());
        return MagazineDto.Response.from(saved);
    }

    public List<MagazineDto.Response> list(MagazineCategory category) {
        var list = (category == null) ? magazineRepository.findAll()
                : magazineRepository.findAllByCategory(category);
        return list.stream().map(MagazineDto.Response::from).toList();
    }

    public MagazineDto.Response get(Long id) {
        return MagazineDto.Response.from(find(id));
    }

    @Transactional
    public MagazineDto.Response update(Long id, MagazineDto.UpdateRequest req) {
        Magazine m = find(id);
        m.update(req.title(), req.summary(), req.content(), req.coverImageUrl(), req.category());
        return MagazineDto.Response.from(m);
    }

    @Transactional
    public void delete(Long id) {
        magazineRepository.delete(find(id));
    }

    private Magazine find(Long id) {
        return magazineRepository.findById(id)
                .orElseThrow(() -> new GlobalException(DomainResultCode.MAGAZINE_NOT_FOUND));
    }
}
