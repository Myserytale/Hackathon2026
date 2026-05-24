package com.digitalromania.farm.services;

public interface EmailService {
    void sendOtpEmail(String toEmail, String recipientName, String code);
    void sendDossierStatusEmail(String toEmail, String recipientName, String status, String documentUrl);
}
