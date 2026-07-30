package com.example.artnara.domain.chat.exception;

import com.example.artnara.global.common.ResultCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter
@RequiredArgsConstructor
public enum ChatErrorCode implements ResultCode {

    ROOM_NOT_FOUND("CHAT_001", "채팅방을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    APPOINTMENT_NOT_FOUND("CHAT_002", "약속을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    ROOM_NOT_WAITING("CHAT_003", "이미 참여자가 있는 채팅방입니다.", HttpStatus.BAD_REQUEST),
    CANNOT_JOIN_OWN_ROOM("CHAT_004", "본인이 만든 채팅방에는 참여할 수 없습니다.", HttpStatus.BAD_REQUEST);

    private final String code;
    private final String message;
    private final HttpStatusCode status;
}