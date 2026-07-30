package com.example.artnara.domain.artwork.scheduler;

import com.example.artnara.domain.artwork.service.ArtworkService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/** 마감 시각이 지난 경매를 1분마다 자동 마감한다. */
@Slf4j
@Component
@RequiredArgsConstructor
public class AuctionScheduler {

    private final ArtworkService artworkService;

    @Scheduled(fixedDelay = 60_000)
    public void closeExpiredAuctions() {
        int closed = artworkService.closeExpiredAuctions();
        if (closed > 0) {
            log.info("경매 자동 마감: {}건", closed);
        }
    }
}
