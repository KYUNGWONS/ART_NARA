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
    CONTENT_NOT_FOUND("CONTENT_404", "콘텐츠를 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    CONTENT_KNOT_LIMIT_EXCEEDED("CONTENT_422_KNOT", "매듭은 최대 3개까지 등록할 수 있습니다.", HttpStatus.UNPROCESSABLE_ENTITY),
    CONTENT_IMAGE_LIMIT_EXCEEDED("CONTENT_422_IMAGE", "사진은 최대 5장까지 등록할 수 있습니다.", HttpStatus.UNPROCESSABLE_ENTITY),
    BOOKING_NOT_FOUND("BOOKING_404", "예약을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    BOOKING_DUPLICATE("BOOKING_409", "이미 동일한 활동을 예약하셨습니다.", HttpStatus.CONFLICT),
    BOOKING_CANCEL_WINDOW_CLOSED("BOOKING_422", "취소 가능 시간이 지났습니다.", HttpStatus.UNPROCESSABLE_ENTITY),
    INVALID_DATE_RANGE("COMMON_400", "조회 기간(from~to 또는 month)을 올바르게 지정해야 합니다.", HttpStatus.BAD_REQUEST),
    CHATROOM_NOT_FOUND("CHATROOM_404", "채팅방을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    WISHLIST_NOT_FOUND("WISHLIST_404", "위시리스트를 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    MAGAZINE_NOT_FOUND("MAGAZINE_404", "매거진을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    FESTIVAL_NOT_FOUND("FESTIVAL_404", "페스티벌을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    NOTIFICATION_NOT_FOUND("NOTIFICATION_404", "알림을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    VERIFICATION_NOT_FOUND("VERIFICATION_404", "인증 정보를 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    RECOMMENDED_PLACE_NOT_FOUND("RECOMMENDED_PLACE_404", "추천 장소를 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    DISTRICT_NOT_FOUND("DISTRICT_404", "지역(구)을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    RECOMMENDED_CONTENT_NOT_FOUND("RECOMMENDED_CONTENT_404", "추천 컨텐츠를 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
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
    ORDER_AUCTION_NOT_BUYABLE("ORDER_400_AUCTION", "경매 작품은 입찰로만 구매할 수 있습니다.", HttpStatus.BAD_REQUEST),
    ORDER_ALREADY_SOLD("ORDER_409", "이미 판매 완료된 작품입니다.", HttpStatus.CONFLICT),
    AUCTION_ALREADY_CLOSED("AUCTION_409", "이미 마감된 경매입니다.", HttpStatus.CONFLICT),
    ORDER_AUCTION_NO_WINNER("ORDER_400_NO_WINNER", "유찰된 경매 작품은 결제할 수 없습니다.", HttpStatus.BAD_REQUEST),
    ORDER_NOT_WINNER("ORDER_403_WINNER", "낙찰자만 결제할 수 있습니다.", HttpStatus.FORBIDDEN),
    IMAGE_FILE_REQUIRED("IMAGE_400", "업로드할 이미지 파일이 없습니다.", HttpStatus.BAD_REQUEST),
    IMAGE_INVALID_TYPE("IMAGE_422", "jpg, png, webp 이미지만 업로드할 수 있습니다.", HttpStatus.UNPROCESSABLE_ENTITY),
    IMAGE_STORE_FAILED("IMAGE_500", "이미지 저장에 실패했습니다.", HttpStatus.INTERNAL_SERVER_ERROR),
    ARTIST_NOT_FOUND("ARTIST_404", "작가를 찾을 수 없습니다.", HttpStatus.NOT_FOUND);

    private final String code;
    private final String message;
    private final HttpStatusCode status;
}
