package com.vironit.dropit.dto;

import com.vironit.dropit.constraint.PasswordsEquals;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;

@Data
@PasswordsEquals(field = "password", equalsTo = "confirmPassword")
public class UpdatePasswordDto {

    private String email;

    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,30}$", message = "Please enter the password that meets the requirements.")
    @NotBlank(message = "Please enter a password.")
    private String password;

    @NotBlank(message = "Please enter a password.")
    private String confirmPassword;
}