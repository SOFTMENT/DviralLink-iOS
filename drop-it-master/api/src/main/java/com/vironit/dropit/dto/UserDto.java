package com.vironit.dropit.dto;

import com.vironit.dropit.model.Role;
import lombok.Data;
import lombok.experimental.Accessors;

@Data
@Accessors(chain = true)
public class UserDto {

    private long id;
    private String email;
    private String name;
    private String aboutUser;
    private String instagramAccount;
    private String twitterAccount;
    private Role role;

    public boolean isAdmin() {
        return role.getName().equals("ADMIN");
    }
}