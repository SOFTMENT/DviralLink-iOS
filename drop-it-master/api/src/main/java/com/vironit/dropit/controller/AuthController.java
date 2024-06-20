package com.vironit.dropit.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;

import javax.validation.Valid;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.vironit.dropit.dto.JwtResponse;
import com.vironit.dropit.dto.SignInForm;
import com.vironit.dropit.dto.SignUpForm;
import com.vironit.dropit.dto.UpdatePasswordDto;
import com.vironit.dropit.dto.UserDto;
import com.vironit.dropit.service.UserService;
import com.vironit.dropit.util.JwtUtil;

@RestController
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final UserService service;
    private final JwtUtil jwtTokenUtil;

    private static final String KEY_PATTERN = "\\b[A-Fa-f0-9]{64}\\b";

    @PostMapping("/sign-up")
    @ResponseStatus(HttpStatus.ACCEPTED)
    @Operation(summary = "Sign up with login and password")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "202", description = "Registration form accepted and confirmation email sent."),
            @ApiResponse(responseCode = "400", description = "Inserted email is already taken.")
    })
    public void signUp(@RequestBody @Valid SignUpForm signUpForm) {
        service.signUp(signUpForm);
    }

    @GetMapping("/sign-up/{token}")
    @Operation(summary = "Confirm sign up by unique token")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Registration completed successfully.", content = @Content()),
            @ApiResponse(responseCode = "400", description = "Token is invalid.", content = @Content()),
            @ApiResponse(responseCode = "410", description = "Token has expired.", content = @Content())
    })
    public ResponseEntity<Object> completeSignUp(@PathVariable String token) {
        if (token.matches(KEY_PATTERN)) {
            service.confirmRegistration(token);
            return ResponseEntity.ok("Registration complete!");
        } else {
            return ResponseEntity.badRequest().body("Invalid token.");
        }
    }

    @PostMapping("/sign-in")
    @Operation(summary = "Sign in with email and password")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully authorized user.",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(implementation = JwtResponse.class))}),
            @ApiResponse(responseCode = "401", description = "Incorrect login or password.", content = @Content()),
            @ApiResponse(responseCode = "406", description = "Account is not confirmed via registration process.", content = @Content())
    })
    public JwtResponse createAuthenticationToken(@RequestBody SignInForm form) {
        final UserDto userDto = service.authenticate(form.getEmail(), form.getPassword());
        final String token = jwtTokenUtil.generateToken(userDto);
        return new JwtResponse(token);
    }

    @GetMapping("/reset-password")
    @ResponseStatus(HttpStatus.ACCEPTED)
    @Operation(summary = "Send email to user to reset password")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "202", description = "Accepted and email sent to user.", content = @Content()),
            @ApiResponse(responseCode = "404", description = "No user with given email", content = @Content())
    })
    public void retrievePassword(@Parameter(description = "email of user to reset password") String email) {
        service.sendResetPasswordMessage(email);
    }

    @GetMapping("/confirm-reset-password/{token}")
    @Operation(summary = "Confirm reset password by token given to user via email.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "202", description = "Email reset successfully", content = @Content()),
            @ApiResponse(responseCode = "400", description = "Token is invalid", content = @Content()),
            @ApiResponse(responseCode = "410", description = "Token has expired.", content = @Content())
    })
    public ResponseEntity<Object> resetPassword(@PathVariable String token) {
        if (token.matches(KEY_PATTERN)) {
            service.resetPassword(token);
            return ResponseEntity.ok("Password was reset successfully.");
        } else {
            return ResponseEntity.badRequest().body("Invalid token");
        }
    }

    @PatchMapping("/set-password")
    @Operation(summary = "Reset password")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "202", description = "Successfully updated the password", content = @Content()),
            @ApiResponse(responseCode = "400", description = "No user with given email or password wasn't reset", content = @Content()),
    })
    public void setPassword(@RequestBody UpdatePasswordDto dto) {
        service.updatePassword(dto);
    }
}