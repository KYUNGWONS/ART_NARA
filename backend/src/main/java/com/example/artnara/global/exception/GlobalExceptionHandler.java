package com.example.artnara.global.exception;

import com.example.artnara.global.common.BaseResponse;
import com.example.artnara.global.common.DomainResultCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

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
     * 쿼리 파라미터가 빠졌거나 타입이 안 맞는 요청(`?latitude=abc`, 필수값 누락 등).
     * 본문·경로·메서드와 같은 이유로 클라이언트 잘못이므로 400 으로 돌려준다 —
     * 500 으로 나가면 서버 장애로 오인해 원인을 엉뚱한 데서 찾게 된다.
     */
    @ExceptionHandler({MissingServletRequestParameterException.class,
            MethodArgumentTypeMismatchException.class})
    public ResponseEntity<BaseResponse<Void>> handleInvalidParam(Exception ex) {
        String detail = ex instanceof MissingServletRequestParameterException missing
                ? "필수 파라미터가 없습니다: " + missing.getParameterName()
                : "파라미터 형식이 올바르지 않습니다: "
                        + ((MethodArgumentTypeMismatchException) ex).getName();
        log.warn("잘못된 요청 파라미터: {}", detail);
        return ResponseEntity
                .status(DomainResultCode.REQUEST_PARAM_INVALID.getStatus())
                .body(BaseResponse.error(DomainResultCode.REQUEST_PARAM_INVALID, detail));
    }

    /**
     * 없는 경로 요청. 오타난 API 를 부르면 "서버 오류(500)" 로 보여 원인을 엉뚱한 데서 찾게 되고,
     * 스택까지 로그에 쌓인다. 클라이언트 잘못이므로 404 로 돌려주고 로그는 한 줄만 남긴다.
     */
    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<BaseResponse<Void>> handleNotFound(NoResourceFoundException ex) {
        log.warn("존재하지 않는 경로 요청: {}", ex.getResourcePath());

        return ResponseEntity
                .status(DomainResultCode.ENDPOINT_NOT_FOUND.getStatus())
                .body(BaseResponse.error(DomainResultCode.ENDPOINT_NOT_FOUND,
                        DomainResultCode.ENDPOINT_NOT_FOUND.getMessage()));
    }

    /**
     * 잘못된 HTTP 메서드(예: POST 전용 API 를 GET 으로 호출).
     * 이것도 클라이언트 잘못이라 500 이 아니라 405 로 알려줘야 원인을 바로 찾는다.
     */
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<BaseResponse<Void>> handleMethodNotAllowed(
            HttpRequestMethodNotSupportedException ex) {
        log.warn("허용되지 않은 메서드: {}", ex.getMethod());

        return ResponseEntity
                .status(DomainResultCode.METHOD_NOT_ALLOWED.getStatus())
                .body(BaseResponse.error(DomainResultCode.METHOD_NOT_ALLOWED,
                        DomainResultCode.METHOD_NOT_ALLOWED.getMessage()));
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