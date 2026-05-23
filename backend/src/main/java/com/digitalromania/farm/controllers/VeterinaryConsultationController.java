package com.digitalromania.farm.controllers;

import com.digitalromania.farm.models.VeterinaryConsultation;
import com.digitalromania.farm.repositories.VeterinaryConsultationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/consultations")
public class VeterinaryConsultationController {

    @Autowired
    private VeterinaryConsultationRepository consultationRepository;

    @GetMapping
    public List<VeterinaryConsultation> getAllConsultations() {
        return consultationRepository.findAll();
    }

    @GetMapping("/animal/{animalId}")
    public List<VeterinaryConsultation> getConsultationsByAnimalId(@PathVariable Long animalId) {
        return consultationRepository.findByAnimalId(animalId);
    }

    @PostMapping
    public VeterinaryConsultation createConsultation(@RequestBody VeterinaryConsultation consultation) {
        return consultationRepository.save(consultation);
    }

    @GetMapping("/{id}")
    public ResponseEntity<VeterinaryConsultation> getConsultationById(@PathVariable Long id) {
        return consultationRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteConsultation(@PathVariable Long id) {
        return consultationRepository.findById(id)
                .map(consultation -> {
                    consultationRepository.delete(consultation);
                    return ResponseEntity.ok().build();
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
