package com.example.artnara.domain.user.entity;

import com.example.artnara.global.auth.oauth.OAuthProvider;
import com.example.artnara.global.common.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Getter
@Entity
@Table(name = "users",
        uniqueConstraints = @UniqueConstraint(columnNames = {"provider", "providerId"}))
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // OAuth 제공자 신원 (안정적인 식별자). 로그인 시점에 저장된다.
    @Enumerated(EnumType.STRING)
    private OAuthProvider provider;

    private String providerId;

    // OAuth 제공자가 이메일을 제공하지 않을 수 있어 nullable
    private String email;

    @Column(nullable = false)
    private String nickname;

    private String displayName;

    private Integer age;

    // 프로필 설정 전에는 null. 프로필 설정(회원가입 완료) 시 지정된다.
    @Enumerated(EnumType.STRING)
    private UserType userType;

    // 프로필 설정 완료 여부. 로그인 응답의 profileCompleted에 사용된다.
    @Column(nullable = false)
    private boolean profileCompleted = false;

    private String profileImageUrl;

    @Enumerated(EnumType.STRING)
    private Sido region;

    @Column(length = 1000)
    private String aboutMe;

    /** 작가는 주요 장르, 컬렉터는 관심 장르 (회화·조각·디지털 …) */
    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "user_interests", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "interest")
    private List<String> interests = new ArrayList<>();

    @Builder
    public User(OAuthProvider provider, String providerId,
                String email, String nickname, String displayName, Integer age, UserType userType,
                String profileImageUrl, Sido region, String aboutMe, List<String> interests) {
        this.provider = provider;
        this.providerId = providerId;
        this.email = email;
        this.nickname = nickname;
        this.displayName = displayName;
        this.age = age;
        this.userType = userType;
        this.profileImageUrl = profileImageUrl;
        this.region = region;
        this.aboutMe = aboutMe;
        if (interests != null) this.interests = interests;
    }

    /**
     * OAuth 최초 로그인 시 생성되는 최소 유저. userType/프로필은 아직 비어 있고 profileCompleted=false.
     */
    public static User ofOAuth(OAuthProvider provider, String providerId,
                               String email, String nickname, String profileImageUrl) {
        User user = new User();
        user.provider = provider;
        user.providerId = providerId;
        user.email = email;
        user.nickname = (nickname != null && !nickname.isBlank()) ? nickname : defaultNickname(email);
        user.profileImageUrl = profileImageUrl;
        user.profileCompleted = false;
        return user;
    }

    private static String defaultNickname(String email) {
        if (email != null && email.contains("@")) {
            return email.substring(0, email.indexOf('@'));
        }
        return "user";
    }

    /** 부분 수정. null 인 항목은 기존 값을 유지한다(역할 포함). */
    public void updateProfile(String nickname, String displayName, Sido region, String aboutMe,
                              List<String> interests, UserType userType) {
        if (nickname != null) this.nickname = nickname;
        if (displayName != null) this.displayName = displayName;
        if (region != null) this.region = region;
        if (aboutMe != null) this.aboutMe = aboutMe;
        if (interests != null) this.interests = interests;
        if (userType != null) this.userType = userType;
    }

    /**
     * 프로필 설정(회원가입 완료). userType 지정과 함께 profileCompleted를 true로 전환한다.
     */
    public void completeProfile(String nickname, String displayName, Integer age, UserType userType,
                                String profileImageUrl, Sido region, String aboutMe,
                                List<String> interests) {
        if (nickname != null) this.nickname = nickname;
        if (displayName != null) this.displayName = displayName;
        if (age != null) this.age = age;
        if (userType != null) this.userType = userType;
        if (profileImageUrl != null) this.profileImageUrl = profileImageUrl;
        if (region != null) this.region = region;
        if (aboutMe != null) this.aboutMe = aboutMe;
        if (interests != null) this.interests = interests;
        this.profileCompleted = true;
    }
}
