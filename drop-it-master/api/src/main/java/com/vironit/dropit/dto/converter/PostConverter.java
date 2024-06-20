package com.vironit.dropit.dto.converter;

import lombok.RequiredArgsConstructor;

import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Component;

import com.vironit.dropit.dto.PostDto;
import com.vironit.dropit.dto.UserDto;
import com.vironit.dropit.model.Post;

@Component
@RequiredArgsConstructor
public class PostConverter {

    private final ModelMapper modelMapper;

    public PostDto toDto(Post post) {
        int commentsNumber = post.getComments() != null ? post.getComments().size() : 0;
        return new PostDto(post.getId(),
                post.getLink(),
                post.getCreationTime(),
                post.getPicture(),
                post.getSongName(),
                modelMapper.map(post.getAuthor(), UserDto.class),
                commentsNumber);
    }
}