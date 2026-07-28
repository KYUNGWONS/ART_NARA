package com.example.unitrip.domain.wishlist.entity;

import com.example.unitrip.domain.content.entity.Content;
import com.example.unitrip.global.common.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "wishlist_items")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class WishlistItem extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "folder_id")
    private WishlistFolder folder;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "content_id")
    private Content content;

    @Column(length = 500)
    private String memo;

    @Builder
    public WishlistItem(WishlistFolder folder, Content content, String memo) {
        this.folder = folder;
        this.content = content;
        this.memo = memo;
    }

    public void updateMemo(String memo) {
        this.memo = memo;
    }
}
