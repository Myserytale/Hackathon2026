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

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AuthRequest request) {
        Optional<User> userOpt = userRepository.findByUsername(request.getUsername());
        
        if (userOpt.isPresent() && passwordEncoder.matches(request.getPassword(), userOpt.get().getPassword())) {
            // ROeID Step 1: Return a temporary 2FA token
            String tempToken = jwtUtil.generate2FaToken(userOpt.get().getUsername());
            return ResponseEntity.ok(new AuthResponse(tempToken, "2FA required. Call /api/auth/verify-2fa"));
        }
        return ResponseEntity.status(401).body("Invalid credentials");
    }

    @PostMapping("/verify-2fa")
    public ResponseEntity<?> verify2Fa(@RequestBody TwoFaRequest request) {
        String token = request.getTempToken();
        
        try {
            String username = jwtUtil.extractUsername(token);
            if (jwtUtil.validateToken(token, username) && jwtUtil.is2FaToken(token)) {
                // Hackathon Mock: Accept '123456' as valid 2FA code
                if ("123456".equals(request.getCode())) {
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
