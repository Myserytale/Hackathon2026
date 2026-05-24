package com.digitalromania.farm.services;

import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class OtpService {

    private static final long OTP_TTL_SECONDS = 600;

    private final Map<String, OtpEntry> storage = new ConcurrentHashMap<>();
    private final SecureRandom secureRandom = new SecureRandom();

    public String generateAndStore(String username) {
        String code = String.format("%06d", secureRandom.nextInt(1_000_000));
        storage.put(username, new OtpEntry(code, Instant.now().plusSeconds(OTP_TTL_SECONDS)));
        return code;
    }

    public boolean verify(String username, String code) {
        OtpEntry entry = storage.get(username);
        if (entry == null) {
            return false;
        }
        if (Instant.now().isAfter(entry.expiresAt())) {
            storage.remove(username);
            return false;
        }
        if (!entry.code().equals(code)) {
            return false;
        }
        storage.remove(username);
        return true;
    }

    public void invalidate(String username) {
        storage.remove(username);
    }

    private record OtpEntry(String code, Instant expiresAt) {
    }
}
