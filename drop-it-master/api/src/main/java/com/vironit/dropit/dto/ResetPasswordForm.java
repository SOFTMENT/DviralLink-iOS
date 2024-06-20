package com.vironit.dropit.dto;

import com.vironit.dropit.constraint.PasswordsEquals;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;

@Data
@PasswordsEquals(field = "newPassword", equalsTo = "confirmPassword")
public class ResetPasswordForm {

    private String token;

    @NotBlank(message = "Please enter a password.")
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,30}$", message = "Please enter the password that meets the requirements.")
    private String newPassword;

    @NotBlank(message = "Please enter a password.")
    private String confirmPassword;
}