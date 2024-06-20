package com.vironit.dropit.dto;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;

import lombok.Data;
import lombok.experimental.Accessors;

import com.vironit.dropit.constraint.AvailableEmail;
import com.vironit.dropit.constraint.PasswordsEquals;

@Data
@Accessors(chain = true)
@PasswordsEquals(field = "password", equalsTo = "confirmPassword")
public class SignUpForm {

    @NotBlank(message = "Please enter an email.")
    @Email(message = "Please enter a valid email address.")
    @AvailableEmail
    private String email;

    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*()\\\\-_=+{}|?>.<,:;~`’])[A-Za-z\\d!@#$%^&*()\\\\-_=+{}|?>.<,:;~`’]{8,30}$", message = "Please enter the password that meets the requirements.")
    @NotBlank(message = "Please enter a password.")
    private String password;

    @NotBlank(message = "Please enter a password for {err.required}.")
    private String confirmPassword;
}