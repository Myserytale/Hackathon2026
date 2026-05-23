package com.digitalromania.farm.controllers;

import com.digitalromania.farm.config.JwtUtil;
import com.digitalromania.farm.models.User;
import com.digitalromania.farm.repositories.UserRepository;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Random;

import io.github.bucket4j.Bucket;
import io.github.bucket4j.Bandwidth;
import java.time.Duration;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    private Map<String, String> otpStorage = new ConcurrentHashMap<>();
    public static String LAST_GENERATED_OTP = "123456"; // For testing

    private final Bucket bucket;

    public AuthController() {
        Bandwidth limit = Bandwidth.builder()
                .capacity(5)
                .refillGreedy(5, Duration.ofMinutes(1))
                .build();
        this.bucket = Bucket.builder().addLimit(limit).build();
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AuthRequest request) {
        if (!bucket.tryConsume(1)) {
            return ResponseEntity.status(429).body("Too many login attempts. Please try again later.");
        }

        Optional<User> userOpt = userRepository.findByUsername(request.getUsername());
        
        if (userOpt.isPresent() && passwordEncoder.matches(request.getPassword(), userOpt.get().getPassword())) {
            // ROeID Step 1: Return a temporary 2FA token
            String tempToken = jwtUtil.generate2FaToken(userOpt.get().getUsername());
            
            // Mocking SMS/Email delivery via console
            String code = String.format("%06d", new Random().nextInt(999999));
            otpStorage.put(userOpt.get().getUsername(), code);
            LAST_GENERATED_OTP = code;
            
            System.out.println("\n====== MOCK ROeID NOTIFICATION ======");
            System.out.println("To: " + userOpt.get().getUsername() + " (via Mailtrap/SMS)");
            System.out.println("Your ROeID authentication code is: " + code);
            System.out.println("=====================================\n");
            
            return ResponseEntity.ok(new AuthResponse(tempToken, "2FA code sent via SMS/Email. Call /api/auth/verify-2fa"));
        }
        return ResponseEntity.status(401).body("Invalid credentials");
    }

    @PostMapping("/verify-2fa")
    public ResponseEntity<?> verify2Fa(@RequestBody TwoFaRequest request) {
        String token = request.getTempToken();
        
        try {
            String username = jwtUtil.extractUsername(token);
            if (jwtUtil.validateToken(token, username) && jwtUtil.is2FaToken(token)) {
                String expectedCode = otpStorage.get(username);
                if (expectedCode != null && expectedCode.equals(request.getCode())) {
                    otpStorage.remove(username); // One-time use
                    User user = userRepository.findByUsername(username).orElseThrow();
                    String finalToken = jwtUtil.generateToken(user.getUsername(), user.getRole().name());
                    return ResponseEntity.ok(new AuthResponse(finalToken, "Login successful"));
                } else {
                    return ResponseEntity.status(401).body("Invalid 2FA code");
                }
            }
        } catch (Exception e) {
            return ResponseEntity.status(401).body("Invalid or expired 2FA token");
        }
        
        return ResponseEntity.status(401).body("Unauthorized");
    }
}

@Data
class AuthRequest {
    private String username;
    private String password;
}

@Data
class TwoFaRequest {
    private String tempToken;
    private String code;
}

@Data
class AuthResponse {
    private String token;
    private String message;

    public AuthResponse(String token, String message) {
        this.token = token;
        this.message = message;
    }
}
