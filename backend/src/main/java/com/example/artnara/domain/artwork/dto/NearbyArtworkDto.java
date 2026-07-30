package com.example.artnara.domain.artwork.dto;

import java.util.List;

public record NearbyArtworkDto(List<Item> artworks) {

    public record Item(
            Long id,
            String title,
            String artistName,
            int price,
            boolean auction,
            double latitude,
            double longitude,
            String address,
            double distanceKm
    ) {}
}
