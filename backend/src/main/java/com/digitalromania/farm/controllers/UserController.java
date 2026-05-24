package com.digitalromania.farm.controllers;

import com.digitalromania.farm.models.Role;
import com.digitalromania.farm.models.User;
import com.digitalromania.farm.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/vets")
    public ResponseEntity<List<Map<String, Object>>> getVeterinarians() {
        List<Map<String, Object>> vets = userRepository.findByRole(Role.VET)
                .stream()
                .map(vet -> Map.<String, Object>of(
                        "id", vet.getId(),
                        "username", vet.getUsername()
                ))
                .collect(Collectors.toList());
        return ResponseEntity.ok(vets);
    }
}
