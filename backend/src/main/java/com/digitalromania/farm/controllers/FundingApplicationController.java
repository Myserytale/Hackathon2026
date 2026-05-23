package com.digitalromania.farm.controllers;

import com.digitalromania.farm.models.FundingApplication;
import com.digitalromania.farm.repositories.FundingApplicationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.digitalromania.farm.models.Animal;
import com.digitalromania.farm.repositories.AnimalRepository;

import java.util.List;

@RestController
@RequestMapping("/api/funding")
public class FundingApplicationController {

    @Autowired
    private FundingApplicationRepository fundingRepository;

    @GetMapping
    public List<FundingApplication> getAllApplications() {
        return fundingRepository.findAll();
    }

    @GetMapping("/farmer/{farmerId}")
    public List<FundingApplication> getApplicationsByFarmerId(@PathVariable Long farmerId) {
        return fundingRepository.findByFarmerId(farmerId);
    }

    @Autowired
    private AnimalRepository animalRepository;

    @PostMapping
    public ResponseEntity<?> createApplication(@RequestBody FundingApplication application) {
        // Business Logic: Reject if any animal is SICK
        List<Animal> farmerAnimals = animalRepository.findByOwnerId(application.getFarmerId());
        boolean hasSickAnimals = farmerAnimals.stream()
                .anyMatch(a -> "SICK".equalsIgnoreCase(a.getHealthStatus()) || "TREATMENT_PENDING".equalsIgnoreCase(a.getHealthStatus()));
                
        if (hasSickAnimals) {
            application.setStatus("REJECTED_AUTOMATICALLY");
        } else {
            application.setStatus("PENDING");
        }
        
        return ResponseEntity.ok(fundingRepository.save(application));
    }

    @GetMapping("/{id}")
    public ResponseEntity<FundingApplication> getApplicationById(@PathVariable Long id) {
        return fundingRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<FundingApplication> updateStatus(@PathVariable Long id, @RequestBody String status) {
        return fundingRepository.findById(id)
                .map(application -> {
                    application.setStatus(status);
                    return ResponseEntity.ok(fundingRepository.save(application));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
