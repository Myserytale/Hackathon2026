package com.digitalromania.farm.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class VeterinaryConsultation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long animalId;

    @Column(nullable = false)
    private Long vetId;

    private String notes;
    private String diagnosis;
    private String prescription;
    
    @Column(nullable = false)
    private LocalDate consultationDate;
}
