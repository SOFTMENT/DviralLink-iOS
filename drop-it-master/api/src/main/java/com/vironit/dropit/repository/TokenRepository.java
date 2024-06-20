package com.vironit.dropit.repository;

import com.vironit.dropit.model.Token;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TokenRepository extends JpaRepository<Token, String>, CustomTokenRepository {

}