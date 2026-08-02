package com.example.artnara.global.auth.exception;

import com.example.artnara.global.common.ResultCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter
@RequiredArgsConstructor
public enum AuthErrorCode implements ResultCode {

    UNSUPPORTED_PROVIDER("AUTH_001", "지원하지 않는 로그인 제공자입니다.", HttpStatus.BAD_REQUEST),
    OAUTH_VERIFICATION_FAILED("AUTH_002", "OAuth 토큰 검증에 실패했습니다.", HttpStatus.UNAUTHORIZED),
    OAUTH_EMAIL_NOT_FOUND("AUTH_003", "제공자로부터 이메일 정보를 가져올 수 없습니다.", HttpStatus.BAD_REQUEST),
    INVALID_REFRESH_TOKEN("AUTH_004", "리프레시 토큰이 유효하지 않습니다. 다시 로그인해주세요.", HttpStatus.UNAUTHORIZED);

    private final String code;
    private final String message;
    private final HttpStatusCode status;
}
