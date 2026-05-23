package com.digitalromania.farm.controllers;

import com.digitalromania.farm.models.Animal;
import com.digitalromania.farm.repositories.AnimalRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import com.digitalromania.farm.repositories.UserRepository;
import com.digitalromania.farm.models.User;
import com.digitalromania.farm.models.Role;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.CacheEvict;
import java.util.List;
import java.util.Map;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@Tag(name = "Animals", description = "Animal Management API")
@RequestMapping("/api/animals")
public class AnimalController {

    @Autowired
    private AnimalRepository animalRepository;

    @Autowired
    private UserRepository userRepository;

    @GetMapping
    @Operation(summary = "Get all animals", description = "Fetches all animals accessible to the current user (Farmers see their own, Admin/Vet see all).")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved list")
    @PreAuthorize("hasAnyRole('FARMER', 'VET', 'ADMIN', 'SYSTEM')")
    @Cacheable(value = "animals", key = "#authentication.name")
    public List<Animal> getAllAnimals(Authentication authentication) {
        String username = authentication.getName();
        User user = userRepository.findByUsername(username).orElseThrow();
        
        if (user.getRole() == Role.FARMER) {
            return animalRepository.findByOwnerId(user.getId());
        }
        return animalRepository.findAll();
    }

    @GetMapping("/registry/check/{tagNumber}")
    @Operation(summary = "Check TRACES EU Registry", description = "Queries the European Union TRACES system for validation.")
    @ApiResponse(responseCode = "200", description = "Validation result returned")
    @PreAuthorize("hasAnyRole('SYSTEM', 'ADMIN')")
    public ResponseEntity<?> checkEuropeanRegistry(@PathVariable String tagNumber) {
        // Mock external API call to European Union TRACES system
        boolean isRegisteredInEU = tagNumber.startsWith("RO") || tagNumber.startsWith("EU");
        
        return ResponseEntity.ok(Map.of(
            "tagNumber", tagNumber,
            "registeredInEU", isRegisteredInEU,
            "status", isRegisteredInEU ? "VERIFIED" : "UNREGISTERED",
            "lastChecked", java.time.LocalDateTime.now()
        ));
    }

    @PostMapping
    @Operation(summary = "Create an animal", description = "Registers a new animal in the system.")
    @ApiResponse(responseCode = "200", description = "Animal created")
    @PreAuthorize("hasAnyRole('ADMIN', 'FARMER')")
    @CacheEvict(value = "animals", allEntries = true)
    public Animal createAnimal(@RequestBody Animal animal, Authentication authentication) {
        String username = authentication.getName();
        User user = userRepository.findByUsername(username).orElseThrow();
        
        // Farmers can only create animals for themselves
        if (user.getRole() == Role.FARMER) {
            animal.setOwnerId(user.getId());
        }
        return animalRepository.save(animal);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Animal> getAnimalById(@PathVariable Long id) {
        return animalRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update animal details", description = "Updates attributes of an existing animal.")
    @PreAuthorize("hasAnyRole('FARMER', 'VET', 'ADMIN')")
    @CacheEvict(value = "animals", allEntries = true)
    public ResponseEntity<Animal> updateAnimal(@PathVariable Long id, @RequestBody Animal animalDetails, Authentication authentication) {
        String username = authentication.getName();
        User user = userRepository.findByUsername(username).orElseThrow();

        return animalRepository.findById(id)
                .map(animal -> {
                    if (user.getRole() == Role.FARMER && !animal.getOwnerId().equals(user.getId())) {
                        return ResponseEntity.status(403).<Animal>build();
                    }
                    animal.setTagNumber(animalDetails.getTagNumber());
                    animal.setSpecies(animalDetails.getSpecies());
                    animal.setBreed(animalDetails.getBreed());
                    animal.setBirthDate(animalDetails.getBirthDate());
                    animal.setHealthStatus(animalDetails.getHealthStatus());
                    if (user.getRole() != Role.FARMER) {
                        animal.setOwnerId(animalDetails.getOwnerId());
                    }
                    return ResponseEntity.ok(animalRepository.save(animal));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete an animal", description = "Removes an animal from the registry.")
    @CacheEvict(value = "animals", allEntries = true)
    public ResponseEntity<?> deleteAnimal(@PathVariable Long id) {
        return animalRepository.findById(id)
                .map(animal -> {
                    animalRepository.delete(animal);
                    return ResponseEntity.ok().build();
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
