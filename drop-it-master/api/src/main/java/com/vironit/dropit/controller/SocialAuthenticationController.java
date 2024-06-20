package com.vironit.dropit.controller;

import com.vironit.dropit.dto.JwtResponse;
import com.vironit.dropit.dto.SocialLoginDto;
import com.vironit.dropit.dto.UserDto;
import com.vironit.dropit.service.UserService;
import com.vironit.dropit.util.JwtUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import lombok.AllArgsConstructor;
import org.springframework.boot.json.JacksonJsonParser;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@RestController
@AllArgsConstructor
public class SocialAuthenticationController {

    private final JwtUtil jwtUtil;
    private final RestTemplate restTemplate;
    private final JacksonJsonParser parser;
    private final UserService userService;

    private static final String GOOGLE_API_USERINFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo";

    @Operation(summary = "Sign in with google or appleId.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully signed in.",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(implementation = JwtResponse.class))})
    })
    @PostMapping("/social-login")
    public JwtResponse login(@RequestBody SocialLoginDto dto) {
        String email = null;
        switch (dto.getAuthenticationProvider()) {
            case APPLE:
                email = getAppleEmail(dto.getToken());
                break;
            case GOOGLE:
                email = getGoogleEmail(dto.getToken());
                break;
        }
        UserDto userDto = userService.findOrSaveSocialNetworkUser(email, dto.getAuthenticationProvider());
        return new JwtResponse(jwtUtil.generateToken(userDto));
    }

    private String getGoogleEmail(String token) {
        Map<String, Object> response = parser.parseMap(restTemplate.getForObject(GOOGLE_API_USERINFO_URL + "?access_token=" + token, String.class));
        return (String) response.get("email");
    }

    private String getAppleEmail(String token) {
        return jwtUtil.getEmailFromAppleToken(token);
    }
}