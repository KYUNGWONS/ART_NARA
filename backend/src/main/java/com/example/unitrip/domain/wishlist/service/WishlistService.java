package com.example.unitrip.domain.wishlist.service;

import com.example.unitrip.domain.content.repository.ContentRepository;
import com.example.unitrip.domain.user.repository.UserRepository;
import com.example.unitrip.domain.wishlist.dto.WishlistDto;
import com.example.unitrip.domain.wishlist.entity.WishlistFolder;
import com.example.unitrip.domain.wishlist.entity.WishlistItem;
import com.example.unitrip.domain.wishlist.repository.WishlistFolderRepository;
import com.example.unitrip.domain.wishlist.repository.WishlistItemRepository;
import com.example.unitrip.global.common.DomainResultCode;
import com.example.unitrip.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class WishlistService {

    private final WishlistFolderRepository folderRepository;
    private final WishlistItemRepository itemRepository;
    private final UserRepository userRepository;
    private final ContentRepository contentRepository;

    @Transactional
    public WishlistDto.FolderResponse createFolder(WishlistDto.CreateFolderRequest req) {
        var owner = userRepository.findById(req.ownerId())
                .orElseThrow(() -> new GlobalException(DomainResultCode.USER_NOT_FOUND));
        WishlistFolder saved = folderRepository.save(
                WishlistFolder.builder().owner(owner).name(req.name()).build());
        return WishlistDto.FolderResponse.from(saved, 0);
    }

    public List<WishlistDto.FolderResponse> listFolders(Long ownerId) {
        return folderRepository.findAllByOwnerId(ownerId).stream()
                .map(f -> WishlistDto.FolderResponse.from(f, itemRepository.countByFolderId(f.getId())))
                .toList();
    }

    @Transactional
    public WishlistDto.FolderResponse renameFolder(Long id, WishlistDto.RenameFolderRequest req) {
        WishlistFolder f = findFolder(id);
        f.rename(req.name());
        return WishlistDto.FolderResponse.from(f, itemRepository.countByFolderId(id));
    }

    @Transactional
    public void deleteFolder(Long id) {
        folderRepository.delete(findFolder(id));
    }

    @Transactional
    public WishlistDto.ItemResponse addItem(WishlistDto.AddItemRequest req) {
        WishlistFolder folder = findFolder(req.folderId());
        var content = contentRepository.findById(req.contentId())
                .orElseThrow(() -> new GlobalException(DomainResultCode.CONTENT_NOT_FOUND));
        WishlistItem saved = itemRepository.save(
                WishlistItem.builder().folder(folder).content(content).memo(req.memo()).build());
        return WishlistDto.ItemResponse.from(saved);
    }

    public List<WishlistDto.ItemResponse> listItems(Long folderId) {
        return itemRepository.findAllByFolderId(folderId).stream()
                .map(WishlistDto.ItemResponse::from).toList();
    }

    @Transactional
    public WishlistDto.ItemResponse updateItem(Long id, WishlistDto.UpdateItemRequest req) {
        WishlistItem item = itemRepository.findById(id)
                .orElseThrow(() -> new GlobalException(DomainResultCode.WISHLIST_NOT_FOUND));
        item.updateMemo(req.memo());
        return WishlistDto.ItemResponse.from(item);
    }

    @Transactional
    public void deleteItem(Long id) {
        itemRepository.deleteById(id);
    }

    private WishlistFolder findFolder(Long id) {
        return folderRepository.findById(id)
                .orElseThrow(() -> new GlobalException(DomainResultCode.WISHLIST_NOT_FOUND));
    }
}
