package com.vironit.dropit.dto;

import lombok.Data;
import lombok.experimental.Accessors;

import javax.validation.constraints.NotBlank;

@Data
@Accessors(chain = true)
public class SignInForm {

    @NotBlank(message = "Please enter your email address.")
    private String email;

    @NotBlank(message = "Please enter your password.")
    private String password;
}