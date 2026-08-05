package com.example.artnara.domain.admin.repository;

import com.example.artnara.domain.admin.entity.AdminAccount;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AdminAccountRepository extends JpaRepository<AdminAccount, Long> {

    Optional<AdminAccount> findByUsername(String username);
}
