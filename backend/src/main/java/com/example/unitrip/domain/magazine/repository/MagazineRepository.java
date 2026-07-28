package com.example.unitrip.domain.magazine.repository;

import com.example.unitrip.domain.magazine.entity.Magazine;
import com.example.unitrip.domain.magazine.entity.MagazineCategory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MagazineRepository extends JpaRepository<Magazine, Long> {
    List<Magazine> findAllByCategory(MagazineCategory category);
}
