package com.example.unitrip.global.exception;

import com.example.unitrip.global.common.BaseResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(GlobalException.class)
    public ResponseEntity<BaseResponse<Void>> handleMyException(GlobalException ex) {
        log.warn("Business exception: code={}, msg={}", ex.getResultCode().getCode(), ex.resolveMessage());

        return ResponseEntity
                .status(ex.getResultCode().getStatus())
                .body(BaseResponse.error(ex.getResultCode(), ex.resolveMessage()));
    }

    //추후 잡아야 할 예외 추가
}