package com.vironit.dropit.repository;

import com.vironit.dropit.model.Post;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;

public interface PostRepository extends JpaRepository<Post, Long> {

    void deleteByCreationTimeBefore(LocalDateTime time);
}