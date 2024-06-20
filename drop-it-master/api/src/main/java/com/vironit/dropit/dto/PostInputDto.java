package com.vironit.dropit.dto;

import com.vironit.dropit.constraint.Link;
import lombok.Data;
import lombok.experimental.Accessors;

@Data
@Accessors(chain = true)
public class PostInputDto {

    @Link
    private String link;

    private long authorId;
}
