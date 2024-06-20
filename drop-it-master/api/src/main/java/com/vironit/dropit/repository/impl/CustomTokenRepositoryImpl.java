package com.vironit.dropit.repository.impl;

import com.vironit.dropit.model.Token;
import com.vironit.dropit.repository.CustomTokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Root;
import java.time.LocalDateTime;
import java.util.List;

@Repository
@RequiredArgsConstructor
public class CustomTokenRepositoryImpl implements CustomTokenRepository {

    @PersistenceContext
    private final EntityManager entityManager;

    @Override
    public List<Token> findExpiredTokens() {
        CriteriaBuilder criteriaBuilder = entityManager.getCriteriaBuilder();
        CriteriaQuery<Token> criteriaQuery = criteriaBuilder.createQuery(Token.class);
        Root<Token> root = criteriaQuery.from(Token.class);
        criteriaQuery.where(criteriaBuilder.lessThan(root.get("expirationTime"), LocalDateTime.now()));
        return entityManager.createQuery(criteriaQuery).getResultList();
    }
}