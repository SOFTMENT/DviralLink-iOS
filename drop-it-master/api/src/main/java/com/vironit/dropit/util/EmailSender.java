package com.vironit.dropit.util;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@EnableAsync
public class EmailSender {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String FROM_EMAIL;

    private static final String REGISTRATION_CONFIRMATION_SUBJECT = "Registration confirmation";
    private static final String REGISTRATION_CONFIRMATION_MESSAGE = "Please follow the link below to complete the registration process. Please note that the link will expire in 24 hours.";
    private static final String RETRIEVING_SUBJECT = "Password retrieving";
    private static final String RETRIEVING_MESSAGE = "Please follow the link below to reset your password. Please note that the link is valid for 24 hours only.";

    @Async
    public void sendRegistrationMail(String recipient, String link) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(FROM_EMAIL);
        message.setTo(recipient);
        message.setSubject(REGISTRATION_CONFIRMATION_SUBJECT);
        message.setText(REGISTRATION_CONFIRMATION_MESSAGE + "\n" + link);
        mailSender.send(message);
    }

    @Async
    public void sendPasswordResetMessage(String recipient, String link) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(FROM_EMAIL);
        message.setTo(recipient);
        message.setSubject(RETRIEVING_SUBJECT);
        message.setText(RETRIEVING_MESSAGE + "\n" + link);
        mailSender.send(message);
    }
}