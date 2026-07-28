package com.example.unitrip.domain.content.repository;

import com.example.unitrip.domain.content.entity.Content;
import com.example.unitrip.domain.content.entity.Theme;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ContentRepository extends JpaRepository<Content, Long> {
    List<Content> findAllByVisibleTrue();
    List<Content> findAllByAuthorId(Long authorId);
    List<Content> findAllByThemeAndVisibleTrue(Theme theme);
    List<Content> findAllByDistrict_IdAndVisibleTrue(Long districtId);
}
