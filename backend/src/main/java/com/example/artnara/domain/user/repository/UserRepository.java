package com.example.artnara.domain.user.repository;

import com.example.artnara.domain.user.entity.District;
import com.example.artnara.domain.user.entity.Sido;
import com.example.artnara.domain.user.entity.User;
import com.example.artnara.global.auth.oauth.OAuthProvider;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    Optional<User> findByProviderAndProviderId(OAuthProvider provider, String providerId);
    long countByDistrictAndMatchingEnabledTrue(District district);
    long countByDistrict_SidoAndMatchingEnabledTrue(Sido sido);
}
