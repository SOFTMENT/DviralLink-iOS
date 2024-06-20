package com.vironit.dropit.dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.Accessors;

import com.fasterxml.jackson.annotation.JsonFormat;

@Data
@AllArgsConstructor
@Accessors(chain = true)
public class PostDto {

	private long id;

	private String link;

	@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm")
	private LocalDateTime creationTime;

	private String picture;

	private String songName;

	private UserDto author;

	private int commentsNumber;
}