package com.example.artnara.domain.brand.service;

import com.example.artnara.domain.brand.dto.BrandIntroDto;
import org.springframework.stereotype.Service;

@Service
public class BrandService {

    public BrandIntroDto getIntro() {
        return new BrandIntroDto(
                "당신의 취향이 작품을 만나는 곳",
                "검증된 작가의 작품을 발견하고, 나만의 컬렉션으로 소장하는 새로운 미술 경험입니다.",
                "",
                "시작하기",
                "건너뛰기"
        );
    }
}
