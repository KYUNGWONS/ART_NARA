package com.example.artnara.domain.artist.service;

import com.example.artnara.domain.artist.dto.ArtistDto;
import com.example.artnara.domain.artwork.entity.Artwork;
import com.example.artnara.domain.artwork.repository.ArtworkRepository;
import com.example.artnara.domain.order.repository.ArtOrderRepository;
import com.example.artnara.domain.user.entity.Sido;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.domain.user.repository.UserRepository;
import com.example.artnara.global.common.DomainResultCode;
import com.example.artnara.global.exception.GlobalException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ArtistService {

    /** 작가 포트폴리오 조회 — 작품 저장소를 작가명 기준으로 묶어 프로필을 구성한다. */
    public ArtistDto.Response getPortfolio(String artistName) {
        List<Artwork> artworks =
                artworkRepository.findByArtistNameOrderByIdDesc(artistName.trim());
        if (artworks.isEmpty()) {
            throw new GlobalException(DomainResultCode.ARTIST_NOT_FOUND);
        }
        // 판매 수는 실제 주문에서 센다. 지역은 같은 활동명으로 가입한 사용자 프로필에서 가져온다.
        long salesCount = artOrderRepository.countByArtistName(artistName.trim());
        String location = userRepository.findFirstByNickname(artistName.trim())
                .map(User::getRegion)
                .map(Sido::getLabel)
                .orElse(null);

        return new ArtistDto.Response(
                artworks.get(0).getArtistName(),
                artworks.get(0).getArtistIntroduction(),
                location,
                artworks.size(),
                salesCount,
                // 리뷰 도메인이 없어 평점·리뷰 수는 내려주지 않는다(화면에서 '-' 로 표시).
                null,
                null,
                artworks.stream()
                        .map(artwork -> new ArtistDto.ArtworkSummary(
                                artwork.getId(), artwork.getTitle(), artwork.getImageUrl(),
                                artwork.isAuction() && artwork.getCurrentBid() != null
                                        ? artwork.getCurrentBid() : artwork.getPrice(),
                                artwork.isAuction()))
                        .toList());
    }

    private final ArtworkRepository artworkRepository;
    private final ArtOrderRepository artOrderRepository;
    private final UserRepository userRepository;
}
