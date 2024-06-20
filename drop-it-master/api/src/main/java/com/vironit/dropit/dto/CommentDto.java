package com.vironit.dropit.dto;

import java.time.LocalDateTime;

import lombok.Data;
import lombok.experimental.Accessors;

import com.fasterxml.jackson.annotation.JsonFormat;

@Data
@Accessors(chain = true)
public class CommentDto {

    private long id;

    private long userId;

    private String userName;

    private String text;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm")
    private LocalDateTime creationTime;
}