package com.digitalromania.farm.controllers;

import com.digitalromania.farm.models.Animal;
import com.digitalromania.farm.models.GrantDossier;
import com.digitalromania.farm.models.GrantDossierStatus;
import com.digitalromania.farm.models.User;
import com.digitalromania.farm.repositories.AnimalRepository;
import com.digitalromania.farm.repositories.GrantDossierRepository;
import com.digitalromania.farm.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import com.digitalromania.farm.services.PdfGeneratorService;

@RestController
@RequestMapping("/api/grant-dossiers")
@CrossOrigin(origins = "*")
public class GrantDossierController {

    @Autowired
    private GrantDossierRepository grantDossierRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AnimalRepository animalRepository;
    
    @Autowired
    private PdfGeneratorService pdfGeneratorService;

    // 1. Fermier creates dossier (submits APIA form)
    @PostMapping("/submit-farmer")
    public ResponseEntity<?> submitFarmerDossier(@RequestBody Map<String, Object> payload) {
        Long farmerId = Long.valueOf(payload.get("farmerId").toString());
        Long animalId = Long.valueOf(payload.get("animalId").toString());
        String iban = payload.getOrDefault("iban", "RO00XXXX0000").toString();
        
        User farmer = userRepository.findById(farmerId).orElseThrow(() -> new RuntimeException("Farmer not found"));
        Animal animal = animalRepository.findById(animalId).orElseThrow(() -> new RuntimeException("Animal not found"));

        // Generate Real PDF
        String farmerDocumentUrl = pdfGeneratorService.generateApiaGrantRequest(farmer.getName(), iban, animal.getTagNumber());

        GrantDossier dossier = new GrantDossier();
        dossier.setFarmer(farmer);
        dossier.setAnimal(animal);
        dossier.setFarmerDocumentUrl(farmerDocumentUrl);
        dossier.setStatus(GrantDossierStatus.PENDING_VET);
        dossier.setCreatedAt(LocalDateTime.now());
        dossier.setUpdatedAt(LocalDateTime.now());

        grantDossierRepository.save(dossier);

        return ResponseEntity.ok(Map.of("message", "Dossier sent to Veterinarian", "dossierId", dossier.getId(), "documentUrl", farmerDocumentUrl));
    }

    // 2. Vet updates dossier (adds F1 form)
    @PostMapping("/{dossierId}/vet-review")
    public ResponseEntity<?> vetReview(@PathVariable Long dossierId, @RequestBody Map<String, Object> payload) {
        Long vetId = Long.valueOf(payload.get("veterinarianId").toString());
        String statusAction = payload.get("action").toString(); // "APPROVE" or "REJECT"
        
        GrantDossier dossier = grantDossierRepository.findById(dossierId).orElseThrow();
        User vet = userRepository.findById(vetId).orElseThrow();
        
        dossier.setVeterinarian(vet);
        dossier.setUpdatedAt(LocalDateTime.now());

        if ("REJECT".equalsIgnoreCase(statusAction)) {
            dossier.setStatus(GrantDossierStatus.RETURNED_TO_FARMER);
        } else {
            // Generate Real PDF F1
            String vetDocumentUrl = pdfGeneratorService.generateF1Form(vet.getName(), dossier.getAnimal().getTagNumber());
            dossier.setVetDocumentUrl(vetDocumentUrl);
            dossier.setStatus(GrantDossierStatus.PENDING_APIA);
        }

        grantDossierRepository.save(dossier);
        return ResponseEntity.ok(Map.of("message", "Vet review recorded", "status", dossier.getStatus()));
    }

    // 3. APIA Final Review
    @PostMapping("/{dossierId}/apia-review")
    public ResponseEntity<?> apiaReview(@PathVariable Long dossierId, @RequestBody Map<String, String> payload) {
        String action = payload.get("action"); // "APPROVE" or "REJECT"
        GrantDossier dossier = grantDossierRepository.findById(dossierId).orElseThrow();
        
        dossier.setUpdatedAt(LocalDateTime.now());
        if ("APPROVE".equalsIgnoreCase(action)) {
            dossier.setStatus(GrantDossierStatus.APPROVED);
        } else {
            dossier.setStatus(GrantDossierStatus.RETURNED_TO_VET); // Or Farmer
        }
        
        grantDossierRepository.save(dossier);
        return ResponseEntity.ok(Map.of("message", "APIA review completed", "status", dossier.getStatus()));
    }

    // List dossiers
    @GetMapping("/status/{status}")
    public ResponseEntity<List<GrantDossier>> getByStatus(@PathVariable GrantDossierStatus status) {
        return ResponseEntity.ok(grantDossierRepository.findByStatus(status));
    }
    
    @GetMapping("/farmer/{farmerId}")
    public ResponseEntity<List<GrantDossier>> getByFarmer(@PathVariable Long farmerId) {
        return ResponseEntity.ok(grantDossierRepository.findByFarmerId(farmerId));
    }
}
