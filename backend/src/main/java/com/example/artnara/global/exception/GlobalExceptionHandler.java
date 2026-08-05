package com.example.artnara.global.exception;

import com.example.artnara.global.common.BaseResponse;
import com.example.artnara.global.common.DomainResultCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
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

    /**
     * 본문 역직렬화 실패(알 수 없는 enum 값, 깨진 JSON 등). 잡지 않으면 서블릿이 /error 로 넘겨
     * 원인을 알 수 없는 응답이 나가므로, 어떤 필드가 문제인지 메시지로 돌려준다.
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<BaseResponse<Void>> handleNotReadable(HttpMessageNotReadableException ex) {
        log.warn("Request body not readable: {}", ex.getMessage());

        Throwable cause = ex.getMostSpecificCause();
        return ResponseEntity
                .status(DomainResultCode.REQUEST_BODY_INVALID.getStatus())
                .body(BaseResponse.error(DomainResultCode.REQUEST_BODY_INVALID, cause.getMessage()));
    }

    /**
     * 예상 못 한 예외. 잡지 않으면 서블릿 기본 500 이 나가면서 스택이 어디에도 남지 않아
     * 원인 추적이 불가능하다. 여기서 로그로 남기고 공통 응답 형식으로 돌려준다.
     * (클라이언트에는 내부 메시지를 노출하지 않는다.)
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<BaseResponse<Void>> handleUnexpected(Exception ex) {
        log.error("Unexpected exception", ex);

        return ResponseEntity
                .status(DomainResultCode.INTERNAL_ERROR.getStatus())
                .body(BaseResponse.error(DomainResultCode.INTERNAL_ERROR,
                        DomainResultCode.INTERNAL_ERROR.getMessage()));
    }
}