package com.digitalromania.farm.controllers;

import com.digitalromania.farm.models.Animal;
import com.digitalromania.farm.repositories.AnimalRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;

import java.util.List;

@RestController
@RequestMapping("/api/animals")
public class AnimalController {

    @Autowired
    private AnimalRepository animalRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('FARMER', 'VET', 'CIVIL_SERVANT', 'SYSTEM')")
    public List<Animal> getAllAnimals() {
        return animalRepository.findAll();
    }

    @PostMapping
    @PreAuthorize("hasRole('CIVIL_SERVANT')")
    public Animal createAnimal(@RequestBody Animal animal) {
        return animalRepository.save(animal);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Animal> getAnimalById(@PathVariable Long id) {
        return animalRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Animal> updateAnimal(@PathVariable Long id, @RequestBody Animal animalDetails) {
        return animalRepository.findById(id)
                .map(animal -> {
                    animal.setTagNumber(animalDetails.getTagNumber());
                    animal.setSpecies(animalDetails.getSpecies());
                    animal.setBreed(animalDetails.getBreed());
                    animal.setBirthDate(animalDetails.getBirthDate());
                    animal.setHealthStatus(animalDetails.getHealthStatus());
                    animal.setOwnerId(animalDetails.getOwnerId());
                    return ResponseEntity.ok(animalRepository.save(animal));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteAnimal(@PathVariable Long id) {
        return animalRepository.findById(id)
                .map(animal -> {
                    animalRepository.delete(animal);
                    return ResponseEntity.ok().build();
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
