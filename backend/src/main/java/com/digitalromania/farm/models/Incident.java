package com.digitalromania.farm.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Incident {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String type; // Disease, Missing Animal, Damage

    private String description;
    private String location;
    
    private Long animalId; // Optional, if the incident is tied to a specific animal

    private LocalDateTime reportedAt;
    
    @Column(nullable = false)
    private String status; // Open, Investigating, Resolved
}
