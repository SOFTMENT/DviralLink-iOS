package com.vironit.dropit.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.vironit.dropit.model.User;

public interface UserRepository extends JpaRepository<User, Long> {

	Optional<User> findByEmailAndConfirmed(String email, boolean confirmed);

	Optional<User> findByEmailAndPassword(String email, String password);

	boolean existsByEmail(String email);
}