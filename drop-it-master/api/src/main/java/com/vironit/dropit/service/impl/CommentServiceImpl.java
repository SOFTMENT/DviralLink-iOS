package com.vironit.dropit.service.impl;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import lombok.RequiredArgsConstructor;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import com.vironit.dropit.dto.CommentDto;
import com.vironit.dropit.dto.CommentInputDto;
import com.vironit.dropit.dto.UserDto;
import com.vironit.dropit.dto.converter.CommentConverter;
import com.vironit.dropit.exception.BadRequestException;
import com.vironit.dropit.exception.NotFoundEntityException;
import com.vironit.dropit.model.Comment;
import com.vironit.dropit.model.Post;
import com.vironit.dropit.model.User;
import com.vironit.dropit.repository.CommentRepository;
import com.vironit.dropit.repository.PostRepository;
import com.vironit.dropit.repository.UserRepository;
import com.vironit.dropit.service.CommentService;

@Service
@RequiredArgsConstructor
public class CommentServiceImpl implements CommentService {

    private final CommentRepository commentRepository;
    private final UserRepository userRepository;
    private final PostRepository postRepository;
    private final CommentConverter converter;

    public List<CommentDto> findByPostId(long postId) {
        return commentRepository.findByPostId(postId).stream().map(converter::toDto).collect(Collectors.toList());
    }

    @Transactional(isolation = Isolation.REPEATABLE_READ)
    public CommentDto create(CommentInputDto dto, long postId) {
        User author = userRepository.findById(dto.getAuthorId()).orElseThrow(() -> new BadRequestException("No user with id = " + dto.getAuthorId()));
        Post post = postRepository.findById(postId).orElseThrow(() -> new BadRequestException("No post with id = " + postId));
        Comment comment = new Comment()
                .setAuthor(author)
                .setPost(post)
                .setText(dto.getText())
                .setCreationTime(LocalDateTime.now());
        return converter.toDto(commentRepository.save(comment));
    }

    public void delete(long id, UserDto principal) {
        Comment comment = commentRepository.findById(id).orElseThrow(() -> new NotFoundEntityException("No comment with id = " + id));
        if (principal.getId() == comment.getAuthor().getId() || comment.getPost().getAuthor().getId() == principal.getId()
                || principal.isAdmin()) {
            commentRepository.deleteById(id);
        } else {
            throw new AccessDeniedException("You can't delete other user's comments.");
        }
    }
}