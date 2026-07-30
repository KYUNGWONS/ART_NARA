package com.example.artnara.domain.magazine.repository;

import com.example.artnara.domain.magazine.entity.Magazine;
import com.example.artnara.domain.magazine.entity.MagazineCategory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MagazineRepository extends JpaRepository<Magazine, Long> {
    List<Magazine> findAllByCategory(MagazineCategory category);
}
