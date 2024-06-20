package com.vironit.dropit.dto.converter;

import org.springframework.stereotype.Component;

import com.vironit.dropit.dto.CommentDto;
import com.vironit.dropit.model.Comment;

@Component
public class CommentConverter {

    public CommentDto toDto(Comment comment) {
        String name = comment.getAuthor().getName();
        String userName = name == null || name.isBlank() ? comment.getAuthor().getEmail() : comment.getAuthor().getName();
        return new CommentDto()
                .setId(comment.getId())
                .setCreationTime(comment.getCreationTime())
                .setText(comment.getText())
                .setUserId(comment.getAuthor().getId())
                .setUserName(userName);
    }
}