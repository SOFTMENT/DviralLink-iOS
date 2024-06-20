package com.vironit.dropit.service;

import com.vironit.dropit.dto.PostDto;
import com.vironit.dropit.dto.PostGroupWrapper;
import com.vironit.dropit.dto.PostInputDto;
import com.vironit.dropit.dto.UserDto;

import java.util.List;

public interface PostService {

    PostDto findById(long id);

    List<PostGroupWrapper> findAll();

    PostDto create(PostInputDto dto);

    void delete(long id, UserDto principal);

    void deleteOldPosts();
}