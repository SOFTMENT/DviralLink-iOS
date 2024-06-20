package com.vironit.dropit.dto;

import lombok.Data;

@Data
public class CommentInputDto {

	private String text;

	private long authorId;
}