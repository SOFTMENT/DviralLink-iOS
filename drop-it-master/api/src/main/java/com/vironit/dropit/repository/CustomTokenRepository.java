package com.vironit.dropit.repository;

import com.vironit.dropit.model.Token;

import java.util.List;

public interface CustomTokenRepository {

    List<Token> findExpiredTokens();
}