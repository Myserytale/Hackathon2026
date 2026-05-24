package com.digitalromania.farm.services;

import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

@Service
@Profile("test")
public class TestEmailService implements EmailService {

    public static String lastOtp;
    public static String lastRecipientEmail;

    @Override
    public void sendOtpEmail(String toEmail, String recipientName, String code) {
        lastRecipientEmail = toEmail;
        lastOtp = code;
    }
}
