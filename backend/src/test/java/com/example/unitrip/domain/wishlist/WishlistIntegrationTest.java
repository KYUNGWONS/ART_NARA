package com.example.unitrip.domain.wishlist;

import com.example.unitrip.domain.content.entity.Content;
import com.example.unitrip.domain.content.entity.Theme;
import com.example.unitrip.domain.content.repository.ContentRepository;
import com.example.unitrip.domain.user.entity.User;
import com.example.unitrip.domain.user.entity.UserType;
import com.example.unitrip.domain.user.repository.UserRepository;
import com.example.unitrip.domain.wishlist.dto.WishlistDto;
import com.example.unitrip.support.IntegrationTest;
import tools.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@IntegrationTest
class WishlistIntegrationTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper om;
    @Autowired UserRepository userRepository;
    @Autowired ContentRepository contentRepository;

    @Test
    @DisplayName("폴더 생성 후 아이템 추가 및 조회")
    void folderAndItem() throws Exception {
        User owner = userRepository.save(User.builder()
                .email("o@t.com").nickname("o").userType(UserType.FOREIGN_TOURIST).build());
        Content content = contentRepository.save(Content.builder()
                .author(owner).title("한옥마을").theme(Theme.PLACE).build());

        var folderReq = new WishlistDto.CreateFolderRequest(owner.getId(), "서울");
        var folderResult = mockMvc.perform(post("/api/wishlist/folders").with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(om.writeValueAsString(folderReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.name").value("서울"))
                .andReturn();
        long folderId = om.readTree(folderResult.getResponse().getContentAsString())
                .path("data").path("id").asLong();

        var itemReq = new WishlistDto.AddItemRequest(folderId, content.getId(), "좋아요");
        mockMvc.perform(post("/api/wishlist/items").with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(om.writeValueAsString(itemReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.contentTitle").value("한옥마을"));

        mockMvc.perform(get("/api/wishlist/folders/{id}/items", folderId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].memo").value("좋아요"));
    }
}
