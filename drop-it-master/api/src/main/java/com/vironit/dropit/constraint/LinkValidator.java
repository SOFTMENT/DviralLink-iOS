package com.vironit.dropit.constraint;

import lombok.AllArgsConstructor;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;
import java.util.List;

@AllArgsConstructor
public class LinkValidator implements ConstraintValidator<Link, String> {

    private static final String LINK_REGEX = "https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)";
    private static final String MESSAGE = "Please share the links to music sources only. Please add links from YouTube, Spotify, Tidal, Instagram, Facebook, SoundCloud, Apple Music.";

    private final LinkProperties linkProperties;

    @Override
    public boolean isValid(String link, ConstraintValidatorContext constraintValidatorContext) {
        boolean isValid = false;
        if (link.matches(LINK_REGEX)) {
            List<String> sources = linkProperties.getSources();
            isValid = sources.stream().anyMatch(link::startsWith);
            if (!isValid) {
                constraintValidatorContext.disableDefaultConstraintViolation();
                constraintValidatorContext.buildConstraintViolationWithTemplate(MESSAGE).addConstraintViolation();
            }
        }
        return isValid;
    }
}