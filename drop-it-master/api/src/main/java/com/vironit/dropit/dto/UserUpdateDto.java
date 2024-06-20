package com.vironit.dropit.dto;

import lombok.Data;
import lombok.experimental.Accessors;

import javax.validation.constraints.Size;

@Data
@Accessors(chain = true)
public class UserUpdateDto {

    private String name;

    @Size(max = 200)
    private String aboutUser;

    private String instagramAccount;

    private String twitterAccount;
}