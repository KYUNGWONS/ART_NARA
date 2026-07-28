package com.example.unitrip.global.common;

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
    RECOMMENDED_CONTENT_NOT_FOUND("RECOMMENDED_CONTENT_404", "추천 컨텐츠를 찾을 수 없습니다.", HttpStatus.NOT_FOUND);

    private final String code;
    private final String message;
    private final HttpStatusCode status;
}
