package com.vironit.dropit.dto;

import com.vironit.dropit.model.AuthenticationProvider;
import lombok.Data;

@Data
public class SocialLoginDto {

    private String token;

    private AuthenticationProvider authenticationProvider;
}