package com.digitalromania.farm.controllers;

import org.springframework.security.core.Authentication;
import com.digitalromania.farm.models.Animal;
import com.digitalromania.farm.models.GrantDossier;
import com.digitalromania.farm.models.GrantDossierStatus;
import com.digitalromania.farm.models.User;
import com.digitalromania.farm.repositories.AnimalRepository;
import com.digitalromania.farm.repositories.GrantDossierRepository;
import com.digitalromania.farm.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import com.digitalromania.farm.services.EmailService;
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
    public ResponseEntity<?> submitFarmerDossier(@RequestBody Map<String, Object> payload, Authentication auth) {
        try {
            User farmer = userRepository.findByUsername(auth.getName())
                .orElseThrow(() -> new RuntimeException("Farmer not found"));
            
            List<Animal> animals = animalRepository.findByOwnerId(farmer.getId());
            Animal animal;
            if (animals.isEmpty()) {
                animal = new Animal();
                animal.setTagNumber(payload.containsKey("animalTag") ? payload.get("animalTag").toString() : "RO000000");
                animal.setOwnerId(farmer.getId());
                animal.setSpecies("Bovine");
                animal.setHealthStatus("ALIVE");
                animal = animalRepository.save(animal);
            } else {
                animal = animals.get(0);
            }

            String iban = payload.getOrDefault("iban", "RO00XXXX0000").toString();

            GrantDossier dossier;
            boolean isDraft = payload.containsKey("isDraft") && (Boolean) payload.get("isDraft");

        if (payload.containsKey("dossierId") && payload.get("dossierId") != null) {
            Long existingId = Long.valueOf(payload.get("dossierId").toString());
            dossier = grantDossierRepository.findById(existingId).orElseThrow(() -> new RuntimeException("Dossier not found"));
        } else {
            dossier = new GrantDossier();
            dossier.setFarmer(farmer);
            dossier.setAnimal(animal);
            dossier.setCreatedAt(LocalDateTime.now());
        }

        // Extract from payload
        String farmName = payload.containsKey("farmName") ? payload.get("farmName").toString() : farmer.getUsername();
        String animalTag = payload.containsKey("animalTag") ? payload.get("animalTag").toString() : animal.getTagNumber();
        String signatureBase64 = payload.containsKey("signatureBase64") ? payload.get("signatureBase64").toString() : null;

        // Always regenerate PDF if it's a draft or if a document URL hasn't been set
        if (isDraft || dossier.getFarmerDocumentUrl() == null) {
            String farmerDocumentUrl = pdfGeneratorService.generateApiaGrantRequest(farmName, iban, animalTag, signatureBase64);
            dossier.setFarmerDocumentUrl(farmerDocumentUrl);
        }

        dossier.setUpdatedAt(LocalDateTime.now());
        
        if (isDraft) {
            dossier.setStatus(GrantDossierStatus.DRAFT_FERMIER);
        } else {
            dossier.setStatus(GrantDossierStatus.PENDING_VET);
            // Assign vet
            if (payload.containsKey("veterinarianId") && payload.get("veterinarianId") != null) {
                Long vetId = Long.valueOf(payload.get("veterinarianId").toString());
                User vet = userRepository.findById(vetId).orElseThrow(() -> new RuntimeException("Veterinarian not found"));
                dossier.setVeterinarian(vet);
            }
        }

        grantDossierRepository.save(dossier);

        return ResponseEntity.ok(Map.of("message", isDraft ? "Draft created" : "Dossier sent to Veterinarian", "dossierId", dossier.getId(), "documentUrl", dossier.getFarmerDocumentUrl()));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(e.getMessage());
        }
    }

    @Autowired
    private EmailService emailService;

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
            String signatureBase64 = payload.containsKey("signatureBase64") ? payload.get("signatureBase64").toString() : null;
            String vetDocumentUrl = pdfGeneratorService.generateF1Form(vet.getUsername(), dossier.getAnimal().getTagNumber(), signatureBase64);
            dossier.setVetDocumentUrl(vetDocumentUrl);
            dossier.setStatus(GrantDossierStatus.PENDING_APIA);
        }

        grantDossierRepository.save(dossier);

        // Send email notification to farmer
        User farmer = dossier.getFarmer();
        if (farmer != null && farmer.getEmail() != null) {
            String docUrl = dossier.getVetDocumentUrl();
            emailService.sendDossierStatusEmail(farmer.getEmail(), farmer.getName() != null ? farmer.getName() : farmer.getUsername(), dossier.getStatus().toString(), docUrl);
        }

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

        // Send email notification to farmer
        User farmer = dossier.getFarmer();
        if (farmer != null && farmer.getEmail() != null) {
            emailService.sendDossierStatusEmail(farmer.getEmail(), farmer.getName() != null ? farmer.getName() : farmer.getUsername(), dossier.getStatus().toString(), null);
        }

        return ResponseEntity.ok(Map.of("message", "APIA review completed", "status", dossier.getStatus()));
    }

    // 4. Download PDF document (farmer or vet)
    @GetMapping("/{dossierId}/download/{docType}")
    public ResponseEntity<Resource> downloadDocument(@PathVariable Long dossierId, @PathVariable String docType) {
        GrantDossier dossier = grantDossierRepository.findById(dossierId).orElseThrow();

        String filePath;
        if ("farmer".equalsIgnoreCase(docType)) {
            filePath = dossier.getFarmerDocumentUrl();
        } else if ("vet".equalsIgnoreCase(docType)) {
            filePath = dossier.getVetDocumentUrl();
        } else {
            return ResponseEntity.badRequest().build();
        }

        if (filePath == null || filePath.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        File file = new File(filePath);
        if (!file.exists()) {
            return ResponseEntity.notFound().build();
        }

        Resource resource = new FileSystemResource(file);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + file.getName() + "\"")
                .body(resource);
    }

    // 5. Upload signed PDF document (farmer or vet)
    @PostMapping("/{dossierId}/upload-signed")
    public ResponseEntity<?> uploadSignedDocument(
            @PathVariable Long dossierId,
            @RequestParam("file") MultipartFile file,
            @RequestParam("docType") String docType) throws IOException {

        GrantDossier dossier = grantDossierRepository.findById(dossierId).orElseThrow();

        if (!"farmer".equalsIgnoreCase(docType) && !"vet".equalsIgnoreCase(docType)) {
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid docType. Must be 'farmer' or 'vet'."));
        }

        // Ensure generated_docs directory exists
        Path outputDir = Paths.get("generated_docs");
        Files.createDirectories(outputDir);

        // Build filename: SIGNED_<docType>_<dossierId>_<timestamp>.pdf
        String timestamp = String.valueOf(System.currentTimeMillis());
        String fileName = "SIGNED_" + docType.toUpperCase() + "_" + dossierId + "_" + timestamp + ".pdf";
        Path targetPath = outputDir.resolve(fileName);

        // Save uploaded file
        Files.copy(file.getInputStream(), targetPath);

        // Update dossier with new signed document path
        if ("farmer".equalsIgnoreCase(docType)) {
            dossier.setFarmerDocumentUrl(targetPath.toString());
        } else {
            dossier.setVetDocumentUrl(targetPath.toString());
        }
        dossier.setUpdatedAt(LocalDateTime.now());
        grantDossierRepository.save(dossier);

        return ResponseEntity.ok(Map.of("message", "Signed document uploaded successfully", "filePath", targetPath.toString()));
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
