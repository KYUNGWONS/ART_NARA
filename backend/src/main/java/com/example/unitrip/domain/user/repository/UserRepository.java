package com.example.unitrip.domain.user.repository;

import com.example.unitrip.domain.user.entity.District;
import com.example.unitrip.domain.user.entity.Sido;
import com.example.unitrip.domain.user.entity.User;
import com.example.unitrip.global.auth.oauth.OAuthProvider;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    Optional<User> findByProviderAndProviderId(OAuthProvider provider, String providerId);
    long countByDistrictAndMatchingEnabledTrue(District district);
    long countByDistrict_SidoAndMatchingEnabledTrue(Sido sido);
}
