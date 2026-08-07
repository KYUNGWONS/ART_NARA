package com.example.artnara.global.common;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter
@RequiredArgsConstructor
public enum DomainResultCode implements ResultCode {

    USER_NOT_FOUND("USER_404", "사용자를 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    USER_EMAIL_DUPLICATE("USER_409", "이미 가입된 이메일입니다.", HttpStatus.CONFLICT),
    CHATROOM_NOT_FOUND("CHATROOM_404", "채팅방을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    VERIFICATION_NOT_FOUND("VERIFICATION_404", "인증 정보를 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    ARTWORK_NOT_FOUND("ARTWORK_404", "작품을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    ARTWORK_NOT_AUCTION("ARTWORK_400", "경매 작품이 아닙니다.", HttpStatus.BAD_REQUEST),
    BID_AMOUNT_TOO_LOW("BID_422", "입찰가가 최소 입찰 금액보다 낮습니다.", HttpStatus.UNPROCESSABLE_ENTITY),
    SALE_TITLE_REQUIRED("SALE_400_TITLE", "작품명을 입력해주세요.", HttpStatus.BAD_REQUEST),
    SALE_INVALID_PRICE("SALE_400_PRICE", "즉시 판매가를 올바르게 입력해주세요.", HttpStatus.BAD_REQUEST),
    SALE_INVALID_AUCTION("SALE_422_AUCTION", "경매 설정이 올바르지 않습니다.", HttpStatus.UNPROCESSABLE_ENTITY),
    COMMISSION_NOT_FOUND("COMMISSION_404", "제작 의뢰를 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    COMMISSION_TITLE_REQUIRED("COMMISSION_400_TITLE", "의뢰 제목을 입력해주세요.", HttpStatus.BAD_REQUEST),
    COMMISSION_CATEGORY_REQUIRED("COMMISSION_400_CATEGORY", "미술품 카테고리를 선택해주세요.", HttpStatus.BAD_REQUEST),
    COMMISSION_INVALID_BUDGET("COMMISSION_400_BUDGET", "예산을 올바르게 입력해주세요.", HttpStatus.BAD_REQUEST),
    OFFER_INVALID_AMOUNT("OFFER_400", "제안 금액을 올바르게 입력해주세요.", HttpStatus.BAD_REQUEST),
    OFFER_AMOUNT_TOO_HIGH("OFFER_422", "역경매 제안가는 현재 최저가보다 낮아야 합니다.", HttpStatus.UNPROCESSABLE_ENTITY),
    CERTIFICATE_QR_REQUIRED("CERTIFICATE_400", "QR 코드를 입력해주세요.", HttpStatus.BAD_REQUEST),
    CERTIFICATE_NOT_FOUND("CERTIFICATE_404", "인증 정보를 찾을 수 없는 QR 코드입니다.", HttpStatus.NOT_FOUND),
    ORDER_INVALID_PAYMENT_METHOD("ORDER_400_PAYMENT", "지원하지 않는 결제 수단입니다.", HttpStatus.BAD_REQUEST),
    PAYMENT_FAILED("PAYMENT_402", "결제에 실패했습니다.", HttpStatus.PAYMENT_REQUIRED),
    PAYMENT_AMOUNT_MISMATCH("PAYMENT_422", "결제 금액이 주문 금액과 다릅니다.", HttpStatus.UNPROCESSABLE_ENTITY),
    ORDER_AUCTION_NOT_BUYABLE("ORDER_400_AUCTION", "경매 작품은 입찰로만 구매할 수 있습니다.", HttpStatus.BAD_REQUEST),
    ORDER_ALREADY_SOLD("ORDER_409", "이미 판매 완료된 작품입니다.", HttpStatus.CONFLICT),
    AUCTION_ALREADY_CLOSED("AUCTION_409", "이미 마감된 경매입니다.", HttpStatus.CONFLICT),
    ORDER_AUCTION_NO_WINNER("ORDER_400_NO_WINNER", "유찰된 경매 작품은 결제할 수 없습니다.", HttpStatus.BAD_REQUEST),
    ORDER_NOT_WINNER("ORDER_403_WINNER", "낙찰자만 결제할 수 있습니다.", HttpStatus.FORBIDDEN),
    IMAGE_FILE_REQUIRED("IMAGE_400", "업로드할 이미지 파일이 없습니다.", HttpStatus.BAD_REQUEST),
    IMAGE_INVALID_TYPE("IMAGE_422", "jpg, png, webp 이미지만 업로드할 수 있습니다.", HttpStatus.UNPROCESSABLE_ENTITY),
    IMAGE_STORE_FAILED("IMAGE_500", "이미지 저장에 실패했습니다.", HttpStatus.INTERNAL_SERVER_ERROR),
    ARTIST_NOT_FOUND("ARTIST_404", "작가를 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    NOTIFICATION_NOT_FOUND("NOTIFICATION_404", "알림을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    REVIEW_INVALID_RATING("REVIEW_400_RATING", "별점은 1~5 사이여야 합니다.", HttpStatus.BAD_REQUEST),
    REVIEW_CONTENT_REQUIRED("REVIEW_400_CONTENT", "리뷰 내용을 입력해주세요.", HttpStatus.BAD_REQUEST),
    REVIEW_NOT_PURCHASED("REVIEW_403", "구매한 작품에만 리뷰를 쓸 수 있습니다.", HttpStatus.FORBIDDEN),
    REVIEW_ALREADY_WRITTEN("REVIEW_409", "이미 리뷰를 작성한 작품입니다.", HttpStatus.CONFLICT),
    ADMIN_LOGIN_FAILED("ADMIN_401", "아이디 또는 비밀번호가 올바르지 않습니다.", HttpStatus.UNAUTHORIZED),
    ADMIN_NOT_FOUND("ADMIN_404", "관리자 계정을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    ADMIN_PASSWORD_MISMATCH("ADMIN_400_PW", "현재 비밀번호가 올바르지 않습니다.", HttpStatus.BAD_REQUEST),
    ADMIN_PASSWORD_TOO_SHORT("ADMIN_400_LEN", "비밀번호는 4자 이상이어야 합니다.", HttpStatus.BAD_REQUEST),
    ADMIN_PASSWORD_SAME("ADMIN_400_SAME", "현재 비밀번호와 다른 값을 입력해주세요.", HttpStatus.BAD_REQUEST),
    ADMIN_FORBIDDEN("ADMIN_403", "관리자 권한이 필요합니다.", HttpStatus.FORBIDDEN),
    ORDER_NOT_FOUND("ORDER_404", "주문을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    ORDER_ALREADY_REFUNDED("ORDER_409_REFUND", "이미 환불된 주문입니다.", HttpStatus.CONFLICT),
    USER_BLOCKED("USER_403_BLOCKED", "이용이 제한된 계정입니다. 고객센터에 문의해주세요.", HttpStatus.FORBIDDEN),
    AUTH_REQUIRED("COMMON_401", "로그인이 필요합니다.", HttpStatus.UNAUTHORIZED),
    REQUEST_BODY_INVALID("COMMON_400_BODY", "요청 본문을 해석할 수 없습니다.", HttpStatus.BAD_REQUEST),
    REQUEST_PARAM_INVALID("COMMON_400_PARAM", "요청 파라미터가 올바르지 않습니다.", HttpStatus.BAD_REQUEST),
    ENDPOINT_NOT_FOUND("COMMON_404", "존재하지 않는 요청 경로입니다.", HttpStatus.NOT_FOUND),
    METHOD_NOT_ALLOWED("COMMON_405", "허용되지 않은 요청 방식입니다.", HttpStatus.METHOD_NOT_ALLOWED),
    INTERNAL_ERROR("COMMON_500", "요청을 처리하지 못했습니다. 잠시 후 다시 시도해주세요.",
            HttpStatus.INTERNAL_SERVER_ERROR);

    private final String code;
    private final String message;
    private final HttpStatusCode status;
}
