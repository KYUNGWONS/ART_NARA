package com.example.artnara.global.auth;

import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.security.Principal;

/**
 * 요청 주체(로그인 사용자)를 꺼내는 헬퍼.
 *
 * 컨트롤러마다 `Long.parseLong(principal.getName())` 을 반복하지 않도록 한 곳에 모으고,
 * 인증이 없거나 사용자가 사라진 경우를 같은 방식으로 처리한다.
 */
@Component
@RequiredArgsConstructor
public class CurrentUser {

    private final UserRepository userRepository;

    public Long idOf(Principal principal) {
        if (principal == null) {
            throw new GlobalException(DomainResultCode.AUTH_REQUIRED);
        }
        try {
            return Long.parseLong(principal.getName());
        } catch (NumberFormatException e) {
            throw new GlobalException(DomainResultCode.AUTH_REQUIRED);
        }
    }

    /** 거래 주체 표기에 쓰는 활동명(닉네임). */
    public String nicknameOf(Principal principal) {
        return userRepository.findById(idOf(principal))
                .map(User::getNickname)
                .orElseThrow(() -> new GlobalException(DomainResultCode.USER_NOT_FOUND));
    }
}
