package com.example.artnara.domain.notification.entity;

public enum NotificationType {
    /** 제작 의뢰가 등록되어 작가들에게 전달됨 */
    COMMISSION_CREATED,
    /** 제작 의뢰에 작가 제안이 도착함 */
    COMMISSION_OFFER,
    /** 경매가 마감됨(낙찰/유찰) */
    AUCTION_CLOSED,
    /** 결제 완료 및 소유권 인증서 발급 */
    ORDER_COMPLETED,
    /** 관리자 환불 처리 — 구매자에게 알린다 */
    ORDER_REFUNDED,
    /** 작품 문의 채팅에 새 메시지 도착 */
    CHAT_MESSAGE
}
