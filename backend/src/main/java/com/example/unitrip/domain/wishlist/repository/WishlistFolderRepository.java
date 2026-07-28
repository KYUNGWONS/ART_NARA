package com.example.unitrip.domain.wishlist.repository;

import com.example.unitrip.domain.wishlist.entity.WishlistFolder;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface WishlistFolderRepository extends JpaRepository<WishlistFolder, Long> {
    List<WishlistFolder> findAllByOwnerId(Long ownerId);
}
