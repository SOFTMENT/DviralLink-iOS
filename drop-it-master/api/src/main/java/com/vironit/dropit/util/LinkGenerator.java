package com.vironit.dropit.util;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

@Component
public class LinkGenerator {

    private static final String SIGN_UP_LINK = "%s/sign-up/%s";
    private static final String RESET_PASSWORD_LINK = "%s/confirm-reset-password/%s";

    public String generateSignUpLink(String token) {
        return String.format(SIGN_UP_LINK, ServletUriComponentsBuilder.fromCurrentContextPath().build().toUriString(), token);
    }

    public String generateResetPasswordLink(String token) {
        return String.format(RESET_PASSWORD_LINK, ServletUriComponentsBuilder.fromCurrentContextPath().build().toUriString(), token);
    }
}