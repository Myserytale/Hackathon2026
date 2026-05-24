package com.digitalromania.farm.controllers;

import com.digitalromania.farm.config.JwtUtil;
import com.digitalromania.farm.models.Role;
import com.digitalromania.farm.models.User;
import com.digitalromania.farm.repositories.UserRepository;
import com.digitalromania.farm.services.EmailService;
import com.digitalromania.farm.services.OtpService;
import com.digitalromania.farm.services.ValidationUtils;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.MailException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

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

    @Autowired
    private OtpService otpService;

    @Autowired
    private EmailService emailService;

    private final Bucket bucket;

    public AuthController() {
        Bandwidth limit = Bandwidth.builder()
                .capacity(5)
                .refillGreedy(5, Duration.ofMinutes(1))
                .build();
        this.bucket = Bucket.builder().addLimit(limit).build();
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        String username = request.getUsername() != null ? request.getUsername().trim() : "";
        String name = request.getName() != null ? request.getName().trim() : "";
        String email = request.getEmail() != null ? request.getEmail().trim().toLowerCase() : "";

        if (!ValidationUtils.isValidUsername(username)) {
            return ResponseEntity.badRequest().body(
                    "Invalid username. Use 3–30 characters: letters, numbers, underscore only.");
        }
        if (!ValidationUtils.isValidName(name)) {
            return ResponseEntity.badRequest().body("Name must be between 2 and 100 characters.");
        }
        if (!ValidationUtils.isValidEmail(email)) {
            return ResponseEntity.badRequest().body("Invalid email address.");
        }
        if (!ValidationUtils.isValidPassword(request.getPassword())) {
            return ResponseEntity.badRequest().body("Password must be at least 6 characters.");
        }
        if (request.getRole() == null || request.getRole().trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Role is required");
        }

        Role role;
        try {
            role = Role.valueOf(request.getRole().trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Invalid role. Allowed: FARMER, VET, ADMIN");
        }

        if (role == Role.SYSTEM) {
            return ResponseEntity.badRequest().body("Cannot register as SYSTEM user");
        }

        if (userRepository.findByUsername(username).isPresent()) {
            return ResponseEntity.status(409).body("Username already exists");
        }
        if (userRepository.findByEmailIgnoreCase(email).isPresent()) {
            return ResponseEntity.status(409).body("Email already registered");
        }

        User user = new User();
        user.setUsername(username);
        user.setName(name);
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(role);
        try {
            userRepository.save(user);
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.status(409).body("Username or email already exists");
        }

        return ResponseEntity.status(201).body(new AuthResponse(null, "Registration successful"));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AuthRequest request) {
        if (!bucket.tryConsume(1)) {
            return ResponseEntity.status(429).body("Too many login attempts. Please try again later.");
        }

        String email = request.getEmail() != null ? request.getEmail().trim().toLowerCase() : "";
        if (!ValidationUtils.isValidEmail(email)) {
            return ResponseEntity.badRequest().body("Invalid email address.");
        }
        if (request.getPassword() == null || request.getPassword().isEmpty()) {
            return ResponseEntity.badRequest().body("Password is required.");
        }

        Optional<User> userOpt = userRepository.findByEmailIgnoreCase(email);

        if (userOpt.isPresent() && passwordEncoder.matches(request.getPassword(), userOpt.get().getPassword())) {
            User user = userOpt.get();

            if (request.getExpectedRole() != null && !request.getExpectedRole().isBlank()) {
                try {
                    Role expectedRole = Role.valueOf(request.getExpectedRole().trim().toUpperCase());
                    if (user.getRole() != expectedRole) {
                        return ResponseEntity.status(403).body("This account is not authorized for this portal");
                    }
                } catch (IllegalArgumentException e) {
                    return ResponseEntity.badRequest().body("Invalid expected role");
                }
            }

            String tempToken = jwtUtil.generate2FaToken(user.getUsername());
            String code = otpService.generateAndStore(user.getUsername());

            try {
                emailService.sendOtpEmail(user.getEmail(), user.getName(), code);
            } catch (MailException e) {
                otpService.invalidate(user.getUsername());
                return ResponseEntity.status(503).body(
                        "Could not send verification email. Open http://localhost:8025 (Mailpit) or check SMTP settings.");
            }

            return ResponseEntity.ok(new AuthResponse(tempToken, "2FA code sent to your email."));
        }
        return ResponseEntity.status(401).body("Invalid credentials");
    }

    @PostMapping("/verify-2fa")
    public ResponseEntity<?> verify2Fa(@RequestBody TwoFaRequest request) {
        String token = request.getTempToken();

        try {
            String username = jwtUtil.extractUsername(token);
            if (jwtUtil.validateToken(token, username) && jwtUtil.is2FaToken(token)) {
                if (otpService.verify(username, request.getCode())) {
                    User user = userRepository.findByUsername(username).orElseThrow();
                    String finalToken = jwtUtil.generateToken(user.getUsername(), user.getRole().name());
                    return ResponseEntity.ok(new AuthResponse(finalToken, "Login successful"));
                } else {
                    return ResponseEntity.status(401).body("Invalid or expired 2FA code");
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
    private String email;
    private String password;
    private String expectedRole;
}

@Data
class RegisterRequest {
    private String username;
    private String name;
    private String email;
    private String password;
    private String role;
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
