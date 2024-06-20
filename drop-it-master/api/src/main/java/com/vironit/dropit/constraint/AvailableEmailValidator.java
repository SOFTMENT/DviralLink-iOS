package com.vironit.dropit.constraint;

import com.vironit.dropit.repository.UserRepository;
import lombok.RequiredArgsConstructor;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;

@RequiredArgsConstructor
public class AvailableEmailValidator implements ConstraintValidator<AvailableEmail, String> {

    private final UserRepository repository;

    @Override
    public boolean isValid(String login, ConstraintValidatorContext constraintValidatorContext) {
        return !repository.existsByEmail(login);
    }
}