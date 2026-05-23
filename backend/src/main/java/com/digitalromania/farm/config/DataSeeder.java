package com.digitalromania.farm.config;

import com.digitalromania.farm.models.Role;
import com.digitalromania.farm.models.User;
import com.digitalromania.farm.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataSeeder implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        if (userRepository.count() == 0) {
            System.out.println("Seeding mock users for hackathon...");
            
            User citizen = new User();
            citizen.setUsername("fermier_ion");
            citizen.setPassword(passwordEncoder.encode("parola123"));
            citizen.setRole(Role.CITIZEN);
            userRepository.save(citizen);

            User admin = new User();
            admin.setUsername("admin_maria");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setRole(Role.CIVIL_SERVANT);
            userRepository.save(admin);
            
            System.out.println("Mock users seeded successfully!");
        }
    }
}
