package com.example.unitrip.domain.wishlist.repository;

import com.example.unitrip.domain.wishlist.entity.WishlistItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface WishlistItemRepository extends JpaRepository<WishlistItem, Long> {
    List<WishlistItem> findAllByFolderId(Long folderId);
    long countByFolderId(Long folderId);
}
