package com.example.artnara.domain.commission.repository;

import com.example.artnara.domain.commission.entity.CommissionOffer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CommissionOfferRepository extends JpaRepository<CommissionOffer, Long> {

    List<CommissionOffer> findByCommissionIdOrderByAmountAsc(Long commissionId);

    Optional<CommissionOffer> findFirstByCommissionIdOrderByAmountAsc(Long commissionId);
}
