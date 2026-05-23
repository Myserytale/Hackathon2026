package com.digitalromania.farm.controllers;

import com.digitalromania.farm.models.Document;
import com.digitalromania.farm.repositories.DocumentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.security.access.prepost.PreAuthorize;

import java.util.List;
import java.util.UUID;
import java.time.LocalDate;

@RestController
@RequestMapping("/api/documents")
public class DocumentController {

    @Autowired
    private DocumentRepository documentRepository;

    @GetMapping
    public List<Document> getAllDocuments() {
        return documentRepository.findAll();
    }

    @GetMapping("/animal/{animalId}")
    public List<Document> getDocumentsByAnimalId(@PathVariable Long animalId) {
        return documentRepository.findByAnimalId(animalId);
    }

    @PostMapping(consumes = {"multipart/form-data"})
    @PreAuthorize("hasAnyRole('FARMER', 'VET', 'CIVIL_SERVANT')")
    public ResponseEntity<Document> uploadDocument(
            @RequestParam("file") MultipartFile file,
            @RequestParam("animalId") Long animalId,
            @RequestParam("type") String type) {
        
        // Mocking an S3/Blob storage upload
        String mockUrl = "https://cdn.digitalromania.ro/docs/" + UUID.randomUUID() + "_" + file.getOriginalFilename();

        Document doc = new Document();
        doc.setAnimalId(animalId);
        doc.setType(type);
        doc.setDocumentUrl(mockUrl);
        doc.setUploadDate(LocalDate.now());
        
        return ResponseEntity.ok(documentRepository.save(doc));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Document> getDocumentById(@PathVariable Long id) {
        return documentRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteDocument(@PathVariable Long id) {
        return documentRepository.findById(id)
                .map(document -> {
                    documentRepository.delete(document);
                    return ResponseEntity.ok().build();
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
