package com.example.artnara.domain.wishlist.dto;

import com.example.artnara.domain.wishlist.entity.WishlistFolder;
import com.example.artnara.domain.wishlist.entity.WishlistItem;

public class WishlistDto {

    public record CreateFolderRequest(Long ownerId, String name) {}
    public record RenameFolderRequest(String name) {}

    public record AddItemRequest(Long folderId, Long contentId, String memo) {}
    public record UpdateItemRequest(String memo) {}

    public record FolderResponse(Long id, Long ownerId, String name, long itemCount) {
        public static FolderResponse from(WishlistFolder f, long itemCount) {
            return new FolderResponse(f.getId(), f.getOwner().getId(), f.getName(), itemCount);
        }
    }

    public record ItemResponse(Long id, Long folderId, Long contentId, String contentTitle, String memo) {
        public static ItemResponse from(WishlistItem i) {
            return new ItemResponse(i.getId(), i.getFolder().getId(),
                    i.getContent().getId(), i.getContent().getTitle(), i.getMemo());
        }
    }
}
