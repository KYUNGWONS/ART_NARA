package com.example.artnara.domain.artwork.service;

import com.example.artnara.domain.artwork.dto.AuctionUpdateDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

/**
 * 경매 현황을 구독자에게 밀어준다.
 *
 * 발행이 실패해도 입찰·마감 자체는 성공한 거래이므로 예외를 밖으로 내보내지 않는다
 * (알림 실패가 트랜잭션을 되돌리면 안 된다).
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AuctionBroadcaster {

    private final SimpMessagingTemplate messagingTemplate;

    public void publish(AuctionUpdateDto update) {
        try {
            messagingTemplate.convertAndSend("/topic/auction/" + update.artworkId(), update);
        } catch (RuntimeException e) {
            log.warn("경매 현황 발행 실패 artworkId={}", update.artworkId(), e);
        }
    }
}
