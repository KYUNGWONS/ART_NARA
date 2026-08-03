package com.example.artnara.domain.sale.repository;

import com.example.artnara.domain.sale.entity.Sale;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SaleRepository extends JpaRepository<Sale, Long> {

    /** 내 판매 목록은 반드시 판매자로 스코프한다(남의 판매 등록 노출 방지). */
    List<Sale> findBySellerIdOrderByIdDesc(Long sellerId);
}
