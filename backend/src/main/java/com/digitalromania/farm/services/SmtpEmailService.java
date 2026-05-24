package com.digitalromania.farm.services;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@Profile("!test")
public class SmtpEmailService implements EmailService {

    private static final Logger log = LoggerFactory.getLogger(SmtpEmailService.class);

    private final JavaMailSender mailSender;
    private final String fromAddress;

    public SmtpEmailService(
            JavaMailSender mailSender,
            @Value("${app.mail.from:ROeID <noreply@roeid.ro>}") String fromAddress
    ) {
        this.mailSender = mailSender;
        this.fromAddress = fromAddress;
    }

    @Override
    public void sendOtpEmail(String toEmail, String recipientName, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromAddress);
        message.setTo(toEmail);
        message.setSubject("ROeID — cod de autentificare");
        message.setText("""
                Bună ziua, %s,

                Codul dvs. de autentificare ROeID este: %s

                Codul expiră în 10 minute. Nu împărtășiți acest cod cu nimeni.

                — Echipa ROeID
                """.formatted(recipientName, code));

        mailSender.send(message);
        log.info("2FA code emailed to {}", toEmail);
    }
}
