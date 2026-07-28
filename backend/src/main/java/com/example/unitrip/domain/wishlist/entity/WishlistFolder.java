package com.example.unitrip.domain.wishlist.entity;

import com.example.unitrip.domain.user.entity.User;
import com.example.unitrip.global.common.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "wishlist_folders")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class WishlistFolder extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "owner_id")
    private User owner;

    @Column(nullable = false)
    private String name;

    @Builder
    public WishlistFolder(User owner, String name) {
        this.owner = owner;
        this.name = name;
    }

    public void rename(String name) {
        if (name != null) this.name = name;
    }
}
