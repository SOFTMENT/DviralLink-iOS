package com.vironit.dropit.util;

import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.context.annotation.Primary;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@Primary
public class ShaPasswordEncoder implements PasswordEncoder {

    @Override
    public String encode(CharSequence charSequence) {
        String password = charSequence.toString();
        for (int i = 0; i < 1024; i++) {
            password = DigestUtils.sha256Hex(password);
        }
        return password;
    }

    @Override
    public boolean matches(CharSequence charSequence, String s) {
        return encode(charSequence).equals(s);
    }
}