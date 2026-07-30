package com.example.artnara.domain.wishlist.repository;

import com.example.artnara.domain.wishlist.entity.WishlistFolder;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface WishlistFolderRepository extends JpaRepository<WishlistFolder, Long> {
    List<WishlistFolder> findAllByOwnerId(Long ownerId);
}
