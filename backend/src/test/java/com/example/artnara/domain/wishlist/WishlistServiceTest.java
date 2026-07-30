package com.example.artnara.domain.wishlist;

import com.example.artnara.domain.content.entity.Content;
import com.example.artnara.domain.content.entity.Theme;
import com.example.artnara.domain.content.repository.ContentRepository;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.entity.UserType;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.domain.wishlist.dto.WishlistDto;
import com.example.artnara.domain.wishlist.entity.WishlistFolder;
import com.example.artnara.domain.wishlist.entity.WishlistItem;
import com.example.artnara.domain.wishlist.repository.WishlistFolderRepository;
import com.example.artnara.domain.wishlist.repository.WishlistItemRepository;
import com.example.artnara.domain.wishlist.service.WishlistService;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class WishlistServiceTest {

    @Mock WishlistFolderRepository folderRepository;
    @Mock WishlistItemRepository itemRepository;
    @Mock UserRepository userRepository;
    @Mock ContentRepository contentRepository;
    @InjectMocks WishlistService wishlistService;

    private User createUser() {
        User u = User.builder().email("o@t.com").nickname("o").userType(UserType.FOREIGN_TOURIST).build();
        ReflectionTestUtils.setField(u, "id", 1L);
        return u;
    }

    private WishlistFolder createFolder(User owner) {
        WishlistFolder f = WishlistFolder.builder().owner(owner).name("서울").build();
        ReflectionTestUtils.setField(f, "id", 10L);
        return f;
    }

    private Content createContent(User author) {
        Content c = Content.builder().author(author).title("한옥마을").theme(Theme.PLACE).build();
        ReflectionTestUtils.setField(c, "id", 20L);
        return c;
    }

    @Test
    @DisplayName("폴더 생성")
    void createFolder() {
        User user = createUser();
        WishlistFolder folder = createFolder(user);
        given(userRepository.findById(1L)).willReturn(Optional.of(user));
        given(folderRepository.save(any(WishlistFolder.class))).willReturn(folder);

        var req = new WishlistDto.CreateFolderRequest(1L, "서울");
        WishlistDto.FolderResponse res = wishlistService.createFolder(req);
        assertThat(res.name()).isEqualTo("서울");
        assertThat(res.itemCount()).isEqualTo(0);
    }

    @Test
    @DisplayName("폴더 목록 조회")
    void listFolders() {
        User user = createUser();
        WishlistFolder folder = createFolder(user);
        given(folderRepository.findAllByOwnerId(1L)).willReturn(List.of(folder));
        given(itemRepository.countByFolderId(10L)).willReturn(3L);

        List<WishlistDto.FolderResponse> res = wishlistService.listFolders(1L);
        assertThat(res).hasSize(1);
        assertThat(res.get(0).itemCount()).isEqualTo(3);
    }

    @Test
    @DisplayName("폴더 이름 변경")
    void renameFolder() {
        User user = createUser();
        WishlistFolder folder = createFolder(user);
        given(folderRepository.findById(10L)).willReturn(Optional.of(folder));
        given(itemRepository.countByFolderId(10L)).willReturn(0L);

        var req = new WishlistDto.RenameFolderRequest("부산");
        WishlistDto.FolderResponse res = wishlistService.renameFolder(10L, req);
        assertThat(res.name()).isEqualTo("부산");
    }

    @Test
    @DisplayName("폴더 삭제")
    void deleteFolder() {
        WishlistFolder folder = createFolder(createUser());
        given(folderRepository.findById(10L)).willReturn(Optional.of(folder));
        wishlistService.deleteFolder(10L);
        verify(folderRepository).delete(folder);
    }

    @Test
    @DisplayName("아이템 추가")
    void addItem() {
        User user = createUser();
        WishlistFolder folder = createFolder(user);
        Content content = createContent(user);
        WishlistItem item = WishlistItem.builder()
                .folder(folder).content(content).memo("좋아요").build();
        ReflectionTestUtils.setField(item, "id", 30L);

        given(folderRepository.findById(10L)).willReturn(Optional.of(folder));
        given(contentRepository.findById(20L)).willReturn(Optional.of(content));
        given(itemRepository.save(any(WishlistItem.class))).willReturn(item);

        var req = new WishlistDto.AddItemRequest(10L, 20L, "좋아요");
        WishlistDto.ItemResponse res = wishlistService.addItem(req);
        assertThat(res.contentTitle()).isEqualTo("한옥마을");
        assertThat(res.memo()).isEqualTo("좋아요");
    }

    @Test
    @DisplayName("아이템 목록 조회")
    void listItems() {
        User user = createUser();
        WishlistFolder folder = createFolder(user);
        Content content = createContent(user);
        WishlistItem item = WishlistItem.builder().folder(folder).content(content).memo("m").build();
        ReflectionTestUtils.setField(item, "id", 30L);
        given(itemRepository.findAllByFolderId(10L)).willReturn(List.of(item));

        assertThat(wishlistService.listItems(10L)).hasSize(1);
    }

    @Test
    @DisplayName("아이템 메모 수정")
    void updateItem() {
        User user = createUser();
        WishlistFolder folder = createFolder(user);
        Content content = createContent(user);
        WishlistItem item = WishlistItem.builder().folder(folder).content(content).memo("old").build();
        ReflectionTestUtils.setField(item, "id", 30L);
        given(itemRepository.findById(30L)).willReturn(Optional.of(item));

        var req = new WishlistDto.UpdateItemRequest("new");
        WishlistDto.ItemResponse res = wishlistService.updateItem(30L, req);
        assertThat(res.memo()).isEqualTo("new");
    }

    @Test
    @DisplayName("없는 폴더 조회 시 예외")
    void folderNotFound() {
        given(folderRepository.findById(99L)).willReturn(Optional.empty());
        assertThatThrownBy(() -> wishlistService.renameFolder(99L, new WishlistDto.RenameFolderRequest("x")))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.WISHLIST_NOT_FOUND);
    }

    @Test
    @DisplayName("없는 아이템 조회 시 예외")
    void itemNotFound() {
        given(itemRepository.findById(99L)).willReturn(Optional.empty());
        assertThatThrownBy(() -> wishlistService.updateItem(99L, new WishlistDto.UpdateItemRequest("x")))
                .isInstanceOf(GlobalException.class)
                .extracting(e -> ((GlobalException) e).getResultCode())
                .isEqualTo(DomainResultCode.WISHLIST_NOT_FOUND);
    }
}
