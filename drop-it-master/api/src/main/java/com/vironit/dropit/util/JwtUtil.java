package com.vironit.dropit.util;

import com.vironit.dropit.dto.UserDto;
import io.fusionauth.jwt.Signer;
import io.fusionauth.jwt.Verifier;
import io.fusionauth.jwt.domain.JWT;
import io.fusionauth.jwt.hmac.HMACSigner;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.json.JacksonJsonParser;
import org.springframework.stereotype.Component;

import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.util.Base64;

@Component
@RequiredArgsConstructor
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secret;

    private static final String ROLE_CLAIM = "role";
    private static final String ID_CLAIM = "id";

    private final Verifier verifier;
    private final JacksonJsonParser parser;

    public String getEmailFromAppleToken(String token) {
        Base64.Decoder decoder = Base64.getDecoder();
        String payload = new String(decoder.decode(token.split("\\.")[1]));
        return (String) parser.parseMap(payload).get("email");
    }

    public String getClaimFromToken(String token, String claim) {
        JWT jwt = JWT.getDecoder().decode(token, verifier);
        return jwt.getString(claim);
    }

    public boolean validateToken(String token, UserDto userDto) {
        final String email = getClaimFromToken(token, "sub");
        return email.equals(userDto.getEmail()) && !JWT.getDecoder().decode(token, verifier).isExpired();
    }

    public String generateToken(UserDto userDto) {
        Signer signer = HMACSigner.newSHA512Signer(secret);
        JWT jwt = new JWT()
                .addClaim(ROLE_CLAIM, userDto.getRole().getName())
                .addClaim(ID_CLAIM, userDto.getId())
                .setIssuedAt(ZonedDateTime.now(ZoneOffset.UTC))
                .setSubject(userDto.getEmail())
                .setExpiration(ZonedDateTime.now(ZoneOffset.UTC).plusYears(100));
        return JWT.getEncoder().encode(jwt, signer);
    }
}