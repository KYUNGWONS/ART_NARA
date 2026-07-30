package com.example.artnara.global.config;

import com.example.artnara.domain.artwork.entity.Artwork;
import com.example.artnara.domain.artwork.entity.ArtworkBid;
import com.example.artnara.domain.artwork.repository.ArtworkBidRepository;
import com.example.artnara.domain.artwork.repository.ArtworkRepository;
import com.example.artnara.domain.certificate.entity.Ownership;
import com.example.artnara.domain.certificate.repository.OwnershipRepository;
import com.example.artnara.domain.commission.entity.Commission;
import com.example.artnara.domain.commission.entity.CommissionOffer;
import com.example.artnara.domain.commission.repository.CommissionOfferRepository;
import com.example.artnara.domain.commission.repository.CommissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

/**
 * ART NARA 데모 시드 데이터.
 * SQL 시드(test.sql)와 달리 test 프로필에서도 동작해야 하는 아트나라 도메인 데이터는 여기서 넣는다.
 * 작품 id 1~8 순서는 ArtworkService 의 위치 mock(LOCATIONS)과 맞춰져 있으므로 유지할 것.
 */
@Component
@Order(1)
@RequiredArgsConstructor
public class ArtnaraDataInitializer implements CommandLineRunner {

    private static final int BID_STEP = 10000;

    private final ArtworkRepository artworkRepository;
    private final ArtworkBidRepository artworkBidRepository;
    private final CommissionRepository commissionRepository;
    private final CommissionOfferRepository commissionOfferRepository;
    private final OwnershipRepository ownershipRepository;

    @Override
    @Transactional
    public void run(String... args) {
        if (artworkRepository.count() > 0) {
            return;
        }
        seedCommissions();
        seedOwnerships();
        seedArtwork("봄의 정원", "김예진", "자연의 빛을 기록하는 작가",
                "따스한 봄 햇살 아래 피어난 정원의 색을 캔버스에 옮겼습니다. 유화 특유의 두터운 질감으로 꽃잎의 생동감을 살렸습니다.",
                "캔버스에 유화", "53.0 x 45.5cm (10호)", 2026, 320000, false, null);
        seedArtwork("무채색의 위로", "박소현", "고요한 순간을 그립니다",
                "말 없는 위로가 필요한 날, 무채색의 결로 마음의 온도를 담아낸 작품입니다.",
                "종이에 목탄", "42.0 x 29.7cm (A3)", 2025, 180000, false, null);
        seedArtwork("빛과 그림자 사이", "이수민", "일상의 감정을 색으로 표현합니다",
                "창가에 스며드는 오후의 빛과 그림자의 경계를 관찰하며 그린 연작 중 세 번째 작품입니다.",
                "캔버스에 아크릴", "72.7 x 60.6cm (20호)", 2026, 450000, false, null);
        seedArtwork("고요한 파도", "최준혁", "바다의 시간을 수집하는 작가",
                "새벽 바다의 잔잔한 파도를 푸른 색층으로 쌓아 올렸습니다.",
                "캔버스에 유화", "65.1 x 50.0cm (15호)", 2025, 260000, false, null);
        seedArtwork("붉은 기억", "한지원", "기억의 잔상을 붉은 색채로 남깁니다",
                "지나간 기억의 온도를 붉은 색층으로 표현한 졸업 전시 출품작입니다.",
                "캔버스에 유화", "90.9 x 72.7cm (30호)", 2026, 780000, true, "02:14:33");
        seedArtwork("도시의 새벽", "오민서", "도시의 표정을 기록합니다",
                "아무도 깨지 않은 새벽 도시의 푸른 공기를 담았습니다.",
                "캔버스에 아크릴", "72.7 x 53.0cm (20호)", 2026, 340000, true, "05:47:10");
        seedArtwork("흐린 날의 숲", "정다은", "숲의 사계를 그리는 작가",
                "비 오기 직전 흐린 날 숲의 습기와 냄새까지 담고자 했습니다.",
                "종이에 수채", "56.0 x 38.0cm", 2025, 520000, true, "00:58:22");
        seedArtwork("기억의 조각", "윤재호", "조각난 기억을 화면 위에 재조립합니다",
                "콜라주 기법으로 기억의 파편들을 하나의 화면에 재구성한 작품입니다.",
                "혼합 매체", "60.6 x 60.6cm", 2026, 190000, true, "09:30:05");
    }

    private void seedArtwork(String title, String artistName, String artistIntroduction,
                             String description, String medium, String sizeInfo, int yearCreated,
                             int price, boolean auction, String remainingTime) {
        Artwork artwork = artworkRepository.save(Artwork.builder()
                .title(title)
                .artistName(artistName)
                .artistIntroduction(artistIntroduction)
                .description(description)
                .medium(medium)
                .sizeInfo(sizeInfo)
                .yearCreated(yearCreated)
                .price(price)
                .auction(auction)
                .currentBid(auction ? price : null)
                .imageUrl("")
                .remainingTime(remainingTime)
                .build());
        if (auction) {
            seedBid(artwork.getId(), "김*진", price - BID_STEP * 2, "1시간 전");
            seedBid(artwork.getId(), "이*수", price - BID_STEP, "40분 전");
            seedBid(artwork.getId(), "박*현", price, "12분 전");
        }
    }

    private void seedCommissions() {
        Commission sample = commissionRepository.save(Commission.builder()
                .title("거실에 걸 바다 풍경화 의뢰")
                .description("3m 폭 거실 벽에 어울리는 잔잔한 바다 풍경을 원해요. 파란색 계열이면 좋겠습니다.")
                .category("회화")
                .budget(500000)
                .desiredDate(LocalDate.now().plusDays(30))
                .referenceImageUrl("")
                .notifiedArtistCount(42)
                .build());
        commissionOfferRepository.save(CommissionOffer.builder()
                .commissionId(sample.getId()).artistName("김*진").amount(450000)
                .message("유화로 30호 작업 가능합니다.").offerTime("2시간 전").build());
        commissionOfferRepository.save(CommissionOffer.builder()
                .commissionId(sample.getId()).artistName("박*현").amount(400000)
                .message("아크릴로 2주 내 완성 가능해요.").offerTime("1시간 전").build());
    }

    private void seedOwnerships() {
        ownershipRepository.save(Ownership.builder()
                .certificateNo("ARTNARA-2026-0001").artworkTitle("봄의 정원")
                .artistName("김예진").acquiredDate("2026-05-12").qrIssued(true).build());
        ownershipRepository.save(Ownership.builder()
                .certificateNo("ARTNARA-2026-0002").artworkTitle("무채색의 위로")
                .artistName("박소현").acquiredDate("2026-06-30").qrIssued(false).build());
    }

    private void seedBid(Long artworkId, String bidderName, int amount, String bidTime) {
        artworkBidRepository.save(ArtworkBid.builder()
                .artworkId(artworkId)
                .bidderName(bidderName)
                .amount(amount)
                .bidTime(bidTime)
                .build());
    }
}
