package com.digitalromania.farm.config;

import com.digitalromania.farm.models.Role;
import com.digitalromania.farm.models.User;
import com.digitalromania.farm.repositories.UserRepository;
import com.digitalromania.farm.repositories.AnimalRepository;
import com.digitalromania.farm.repositories.FundingApplicationRepository;
import com.digitalromania.farm.models.Animal;
import com.digitalromania.farm.models.AnimalType;
import com.digitalromania.farm.models.FundingApplication;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;

@Component
@ConditionalOnProperty(name = "app.data-seeder.enabled", havingValue = "true", matchIfMissing = true)
public class DataSeeder implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AnimalRepository animalRepository;

    @Autowired
    private FundingApplicationRepository fundingRepository;

    @Override
    public void run(String... args) throws Exception {
        if (userRepository.count() == 0) {
            System.out.println("Seeding mock users for hackathon...");
            
            User farmer = new User();
            farmer.setUsername("test_farmer");
            farmer.setPassword(passwordEncoder.encode("password123"));
            farmer.setRole(Role.FARMER);
            userRepository.save(farmer);

            User vet = new User();
            vet.setUsername("vet_ana");
            vet.setPassword(passwordEncoder.encode("vet123"));
            vet.setRole(Role.VET);
            userRepository.save(vet);

            User admin = new User();
            admin.setUsername("admin_maria");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setRole(Role.ADMIN);
            userRepository.save(admin);
            
            System.out.println("Mock users seeded successfully!");
        }

        if (animalRepository.count() == 0) {
            System.out.println("Seeding mock animals and funding applications...");
            User farmer = userRepository.findByUsername("test_farmer").orElse(null);
            if (farmer != null) {
                Animal cow1 = new Animal(null, "RO123456789", "Cow", "Bessie", AnimalType.COW, "Holstein", java.time.LocalDate.now().minusYears(3), "Healthy", farmer.getId(), false);
                Animal cow2 = new Animal(null, "RO987654321", "Cow", "Milka", AnimalType.COW, "Angus", java.time.LocalDate.now().minusYears(2), "Healthy", farmer.getId(), false);
                Animal pig1 = new Animal(null, "RO555555555", "Pig", "Porky", AnimalType.PIG, "Mangalica", java.time.LocalDate.now().minusMonths(6), "Healthy", farmer.getId(), false);
                Animal sheep1 = new Animal(null, "RO111222333", "Sheep", "Fluffy", AnimalType.SHEEP, "Merinos", java.time.LocalDate.now().minusYears(1), "Healthy", farmer.getId(), false);
                Animal chicken1 = new Animal(null, "RO444555666", "Chicken", "Clucky", AnimalType.CHICKEN, "Rhode Island Red", java.time.LocalDate.now().minusMonths(4), "Healthy", farmer.getId(), false);
                Animal goat1 = new Animal(null, "RO777888999", "Goat", "Billy", AnimalType.GOAT, "Alpine", java.time.LocalDate.now().minusYears(1), "Sick", farmer.getId(), false);
                animalRepository.save(cow1);
                animalRepository.save(cow2);
                animalRepository.save(pig1);
                animalRepository.save(sheep1);
                animalRepository.save(chicken1);
                animalRepository.save(goat1);

                FundingApplication application = new FundingApplication(null, farmer.getId(), "PENDING", 15000.0, "Tractor purchase subsidy", java.time.LocalDate.now(), false);
                fundingRepository.save(application);
                System.out.println("Mock animals seeded successfully!");
            }
        }
    }
}
