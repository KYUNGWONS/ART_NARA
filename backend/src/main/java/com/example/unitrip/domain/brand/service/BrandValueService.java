package com.example.unitrip.domain.brand.service;

import com.example.unitrip.domain.brand.dto.BrandValueDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BrandValueService {

    public BrandValueDto getValue() {
        return new BrandValueDto(
                "믿을 수 있는 작품 거래의 시작",
                "작가의 이야기가 담긴 작품을 검증된 방식으로 발견하고 소장하세요.",
                "",
                List.of(
                        new BrandValueDto.Reason(
                                "작가의 이야기와 큐레이션",
                                "모든 작품에는 작가의 창작 배경과 서사가 담겨 있습니다. 전문 큐레이터가 엄선한 작품만 피드에 노출됩니다."),
                        new BrandValueDto.Reason(
                                "검수된 거래와 정품 인증",
                                "등록된 모든 작품은 전문가 검수를 통과하며 고유 인증 QR이 부착됩니다."),
                        new BrandValueDto.Reason(
                                "디지털 소유권으로 소장하다",
                                "거래 완료 후 작품의 소유권이 구매자 계정에 자동으로 이전되어 영구 보관됩니다.")
                ),
                List.of("작가 인증", "정품 QR", "에스크로 결제", "소유권 이전"),
                "내 취향으로 작품 찾기",
                "건너뛰기"
        );
    }
}
