package com.vironit.dropit.service;

import com.vironit.dropit.dto.SignUpForm;
import com.vironit.dropit.dto.UpdatePasswordDto;
import com.vironit.dropit.dto.UserDto;
import com.vironit.dropit.dto.UserUpdateDto;
import com.vironit.dropit.model.AuthenticationProvider;

public interface UserService {
    UserDto findById(long id);

    UserDto findByEmail(String email);

    UserDto authenticate(String email, String password);

    UserDto update(UserUpdateDto dto, long id);

    void signUp(SignUpForm signUpForm);

    void confirmRegistration(String key);

    UserDto findOrSaveSocialNetworkUser(String email, AuthenticationProvider authenticationProvider);

    void deleteExpiredKeys();

    void sendResetPasswordMessage(String email);

    void resetPassword(String key);

    void updatePassword(UpdatePasswordDto dto);

    void incrementViews(long id);

    int getViewsById(long id);
}