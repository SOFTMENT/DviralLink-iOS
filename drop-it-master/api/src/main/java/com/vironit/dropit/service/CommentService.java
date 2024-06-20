package com.vironit.dropit.service;

import java.util.List;

import com.vironit.dropit.dto.CommentDto;
import com.vironit.dropit.dto.CommentInputDto;
import com.vironit.dropit.dto.UserDto;

public interface CommentService {

    List<CommentDto> findByPostId(long postId);

    CommentDto create(CommentInputDto dto, long postId);

    void delete(long id, UserDto principal);
}