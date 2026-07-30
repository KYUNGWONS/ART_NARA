package com.example.artnara.domain.user.dto;

import com.example.artnara.domain.user.entity.Sido;
import com.example.artnara.domain.user.entity.TravelStyle;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.entity.UserType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

public class UserDto {

    // 프로필 설정(회원가입 완료) 요청. 신원(email 등)은 JWT에서 가져오므로 body로 받지 않는다.
    @Schema(name = "UserCreateRequest")
    public record CreateRequest(
            String nickname,
            String displayName,
            Integer age,
            UserType userType,
            String profileImageUrl,
            Sido region,
            String aboutMe,
            List<String> interests,
            List<String> languages,
            TravelStyle travelStyle
    ) {}

    @Schema(name = "UserUpdateRequest")
    public record UpdateRequest(
            String nickname,
            String displayName,
            Sido region,
            String aboutMe,
            List<String> interests,
            List<String> languages,
            TravelStyle travelStyle
    ) {}

    @Schema(name = "UserResponse")
    public record Response(
            Long id,
            String email,
            String nickname,
            String displayName,
            Integer age,
            UserType userType,
            boolean universityVerified,
            boolean profileCompleted,
            String profileImageUrl,
            Sido region,
            String aboutMe,
            List<String> interests,
            List<String> languages,
            TravelStyle travelStyle,
            boolean matchingEnabled
    ) {
        // universityVerified: 프로필의 '대학교 인증'(미인증/인증) 표시값. User 엔티티에 없어 서비스에서 계산해 주입한다.
        public static Response from(User u, boolean universityVerified) {
            return new Response(
                    u.getId(), u.getEmail(), u.getNickname(), u.getDisplayName(), u.getAge(),
                    u.getUserType(), universityVerified, u.isProfileCompleted(), u.getProfileImageUrl(),
                    u.getRegion(), u.getAboutMe(), u.getInterests(), u.getLanguages(), u.getTravelStyle(),
                    u.isMatchingEnabled()
            );
        }
    }
}
