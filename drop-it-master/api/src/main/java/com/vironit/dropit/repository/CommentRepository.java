package com.vironit.dropit.repository;

import com.vironit.dropit.model.Comment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CommentRepository extends JpaRepository<Comment, Long> {

    void deleteAllByPostId(long id);

    List<Comment> findByPostId(long id);
}